import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

/// Disk-backed map tile cache (raw image bytes), with size-based eviction.
///
/// Keeps the first map frame fast: tiles are served from disk on every launch
/// after the first download, instead of re-fetching them from the network.
class TileCacheService {
  TileCacheService._(this.directory);

  final Directory directory;

  static TileCacheService? _instance;
  static TileCacheService? get instance => _instance;

  static const int maxBytes = 250 * 1024 * 1024;

  static Future<void> initialise() async {
    try {
      final base = await getApplicationCacheDirectory();
      final dir = Directory('${base.path}${Platform.pathSeparator}map_tiles');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _instance = TileCacheService._(dir);
      unawaited(_instance!._trim(maxBytes));
    } catch (_) {
      // Caching disabled; the map still works over the network.
    }
  }

  File fileForUrl(String url) =>
      File('${directory.path}${Platform.pathSeparator}${_hash(url)}.tile');

  Future<void> _trim(int limit) async {
    try {
      final files = await directory
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();
      var total = 0;
      final stats = <({File file, int size, DateTime modified})>[];
      for (final file in files) {
        final stat = await file.stat();
        total += stat.size;
        stats.add((file: file, size: stat.size, modified: stat.modified));
      }
      if (total <= limit) return;
      stats.sort((a, b) => a.modified.compareTo(b.modified));
      for (final entry in stats) {
        if (total <= limit) break;
        try {
          await entry.file.delete();
          total -= entry.size;
        } catch (_) {}
      }
    } catch (_) {}
  }

  static String _hash(String value) {
    var hash = 0xcbf29ce484222325;
    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }
}

/// Tile provider that uses [TileCacheService] when available.
class CachedTileProvider extends TileProvider {
  CachedTileProvider({TileCacheService? cache})
      : _cache = cache ?? TileCacheService.instance;

  final TileCacheService? _cache;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    final cache = _cache;
    if (cache == null) return NetworkImage(url);
    return _DiskCachedImage(url, cache.fileForUrl(url));
  }
}

class _DiskCachedImage extends ImageProvider<_DiskCachedImage> {
  const _DiskCachedImage(this.url, this.file);

  final String url;
  final File file;

  @override
  Future<_DiskCachedImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_DiskCachedImage>(this);

  @override
  ImageStreamCompleter loadImage(
      _DiskCachedImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _load(
      _DiskCachedImage key, ImageDecoderCallback decode) async {
    Uint8List? bytes;
    try {
      if (await file.exists()) {
        bytes = await file.readAsBytes();
      }
    } catch (_) {
      bytes = null;
    }
    if (bytes == null || bytes.isEmpty) {
      bytes = await _download();
      if (bytes != null && bytes.isNotEmpty) {
        try {
          final tmp = File('${file.path}.tmp');
          await tmp.writeAsBytes(bytes, flush: true);
          await tmp.rename(file.path);
        } catch (_) {}
      }
    }
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Failed to load map tile');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  Future<Uint8List?> _download() async {
    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader,
          'WeFamily/1.0 (com.wefamily.wefamily)');
      final response = await request.close().timeout(
            const Duration(seconds: 20),
          );
      if (response.statusCode != 200) return null;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
      }
      return builder.takeBytes();
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _DiskCachedImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

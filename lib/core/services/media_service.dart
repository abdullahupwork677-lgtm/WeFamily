import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import '../constants/config.dart';

class MediaUploadException implements Exception {
  const MediaUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Uploads profile/chat media to Cloudinary with the unsigned preset.
class MediaService {
  const MediaService();

  Future<String> uploadProfilePhoto(
    File file, {
    ValueChanged<double>? onProgress,
  }) async {
    final compressed = await _compress(file);
    final bytes = await compressed.readAsBytes();
    return uploadBytes(
      endpoint: Uri.parse(AppConfig.cloudinaryImageUrl),
      bytes: bytes,
      filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      onProgress: onProgress,
    );
  }

  Future<String> uploadBytes({
    required Uri endpoint,
    required List<int> bytes,
    required String filename,
    ValueChanged<double>? onProgress,
  }) async {
    final request = _ProgressMultipartRequest(
      'POST',
      endpoint,
      onProgress: onProgress,
    );
    request.fields['upload_preset'] = AppConfig.cloudinaryPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MediaUploadException(_errorMessage(response));
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final url = decoded['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw const MediaUploadException('Upload failed');
    }
    return url;
  }

  Future<File> _compress(File source) async {
    final target =
        '${Directory.systemTemp.path}/wefamily_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        target,
        minWidth: 512,
        minHeight: 512,
        quality: 88,
        format: CompressFormat.jpeg,
      );
      if (result != null) return File(result.path);
    } catch (_) {
      // Fall back to the original file if compression is unavailable.
    }
    return source;
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic> && error['message'] is String) {
        return error['message'] as String;
      }
    } catch (_) {
      // Ignore malformed error bodies.
    }
    return 'Upload failed (${response.statusCode})';
  }
}

class _ProgressMultipartRequest extends http.MultipartRequest {
  _ProgressMultipartRequest(super.method, super.url, {this.onProgress});

  final ValueChanged<double>? onProgress;

  @override
  http.ByteStream finalize() {
    final total = contentLength;
    final stream = super.finalize();
    var sent = 0;
    return http.ByteStream(
      stream.transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (chunk, sink) {
            sent += chunk.length;
            if (total > 0) {
              onProgress?.call((sent / total).clamp(0.0, 1.0));
            }
            sink.add(chunk);
          },
        ),
      ),
    );
  }
}

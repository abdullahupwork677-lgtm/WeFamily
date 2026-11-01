import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/config.dart';
import '../models/models.dart';

class ChatRepository {
  ChatRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _messages(String circleId) =>
      _db.collection('circles').doc(circleId).collection('messages');

  Stream<List<ChatMessage>> watchMessages(String circleId, {int limit = 30}) {
    return _messages(circleId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  ChatMessage _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawTime = data['createdAt'];
    final createdAt = rawTime is Timestamp ? rawTime.toDate() : DateTime.now();
    final persisted = (data['status'] as String?) ?? 'sent';
    return ChatMessage(
      id: doc.id,
      senderUid: (data['senderUid'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? '',
      type: (data['type'] as String?) ?? 'text',
      text: data['text'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      thumbUrl: data['thumbUrl'] as String?,
      width: (data['width'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      durationMs: (data['durationMs'] as num?)?.toInt(),
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      createdAt: createdAt,
      status: doc.metadata.hasPendingWrites ? 'sending' : persisted,
    );
  }

  Future<void> sendText({
    required String circleId,
    required String uid,
    required String name,
    required String text,
  }) {
    return _messages(circleId).add({
      'senderUid': uid,
      'senderName': name,
      'type': 'text',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
  }

  Future<void> sendLocation({
    required String circleId,
    required String uid,
    required String name,
    required double lat,
    required double lng,
  }) {
    return _messages(circleId).add({
      'senderUid': uid,
      'senderName': name,
      'type': 'location',
      'lat': lat,
      'lng': lng,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
  }

  /// Compresses to max 1600 px / quality 80, uploads to Cloudinary and writes
  /// the message document. Returns the uploaded dimensions.
  Future<({double width, double height})> uploadAndSendImage({
    required String circleId,
    required String uid,
    required String name,
    required File file,
    ValueChanged<double>? onProgress,
  }) async {
    final compressed = await _compressImage(file);
    final bytes = await compressed.readAsBytes();
    if (bytes.length > 10 * 1024 * 1024) {
      throw StateError('image-too-large');
    }
    final size = await _imageSize(bytes);
    final url = await _upload(
      endpoint: Uri.parse(AppConfig.cloudinaryImageUrl),
      bytes: bytes,
      filename: 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg',
      onProgress: onProgress,
    );
    await _messages(circleId).add({
      'senderUid': uid,
      'senderName': name,
      'type': 'image',
      'mediaUrl': url,
      'thumbUrl': _thumbUrl(url),
      'width': size.$1,
      'height': size.$2,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
    return (width: size.$1, height: size.$2);
  }

  Future<void> uploadAndSendVoice({
    required String circleId,
    required String uid,
    required String name,
    required File file,
    required int durationMs,
    ValueChanged<double>? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      throw StateError('voice-too-large');
    }
    final url = await _upload(
      endpoint: Uri.parse(AppConfig.cloudinaryVideoUrl),
      bytes: bytes,
      filename: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      onProgress: onProgress,
    );
    await _messages(circleId).add({
      'senderUid': uid,
      'senderName': name,
      'type': 'voice',
      'mediaUrl': url,
      'durationMs': durationMs,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
  }

  Future<File> _compressImage(File source) async {
    final target =
        '${Directory.systemTemp.path}/wefamily_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        target,
        minWidth: 1600,
        minHeight: 1600,
        quality: 80,
        format: CompressFormat.jpeg,
      );
      if (result != null) return File(result.path);
    } catch (_) {
      // Fall back to the original file if compression is unavailable.
    }
    return source;
  }

  Future<(double, double)> _imageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width.toDouble();
      final height = frame.image.height.toDouble();
      frame.image.dispose();
      codec.dispose();
      return (width, height);
    } catch (_) {
      return (0.0, 0.0);
    }
  }

  String _thumbUrl(String url) =>
      url.replaceFirst('/upload/', '/upload/w_480,h_480,c_fill,q_auto/');

  Future<String> _upload({
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

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('upload-failed-${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final url = decoded['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw StateError('upload-failed');
    }
    return url;
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

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(FirebaseFirestore.instance),
);

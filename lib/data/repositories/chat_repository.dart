import 'dart:convert';

import 'package:dio/dio.dart';

import '../api/endpoints.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';

class ChatRepository {
  ChatRepository(this._dio);
  final Dio _dio;

  Future<List<ChatConversation>> listConversations({
    required String viewerId,
    String? viewerRole,
    String? viewerName,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.listConversations,
      queryParameters: {
        'viewerId': viewerId,
        if (viewerRole != null && viewerRole.isNotEmpty) 'viewerRole': viewerRole,
        if (viewerName != null && viewerName.isNotEmpty) 'viewerName': viewerName,
      },
    );
    final data = res.data;
    if (data is List) {
      return data.map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return const [];
  }

  
  Future<String> upsertConversation({
    required String requesterId,
    required String requesterName,
    String? requesterRole,
    String? recipientId,
    required String recipientName,
    String? recipientRole,
    String? subject,
    String? listingId,
    String? initialMessage,
    String conversationScope = 'listing',
    String? serviceCode,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.upsertConversation,
      data: {
        'requesterId': requesterId,
        'requesterName': requesterName,
        if (requesterRole != null && requesterRole.isNotEmpty) 'requesterRole': requesterRole,
        if (recipientId != null && recipientId.isNotEmpty) 'recipientId': recipientId,
        'recipientName': recipientName,
        if (recipientRole != null && recipientRole.isNotEmpty) 'recipientRole': recipientRole,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (listingId != null && listingId.isNotEmpty) 'listingId': listingId,
        if (initialMessage != null && initialMessage.isNotEmpty) 'initialMessage': initialMessage,
        'conversationScope': conversationScope,
        if (serviceCode != null && serviceCode.isNotEmpty) 'serviceCode': serviceCode,
      },
    );

    final data = res.data;
    if (data is Map) {
      final convo = data['conversation'];
      if (convo is Map && convo['id'] != null) return convo['id'].toString();
      if (data['id'] != null) return data['id'].toString();
    }
    throw Exception('Failed to upsert conversation');
  }

Future<List<ChatMessage>> getMessages({
    required String conversationId,
    required String viewerId,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.messages(conversationId),
      queryParameters: {'viewerId': viewerId},
    );
    final data = res.data;
    if (data is List) {
      return data.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return const [];
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderRole,
    required String content,
    List<Map<String, dynamic>>? attachments,
    Map<String, dynamic>? metadata,
    String messageType = 'text',
  }) async {
    final res = await _dio.post(
      ApiEndpoints.messages(conversationId),
      data: {
        'senderId': senderId,
        'senderName': senderName,
        if (senderRole != null && senderRole.isNotEmpty) 'senderRole': senderRole,
        'messageType': messageType,
        'content': content,
        if (metadata != null) 'metadata': metadata,
        if (attachments != null && attachments.isNotEmpty) 'attachments': attachments,
      },
    );
    return ChatMessage.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// Upload files (base64) to server which stores in Supabase Storage.
  /// Returns list of attachment descriptors {bucketId, storagePath, fileName, mimeType, fileSizeBytes}.
  Future<List<Map<String, dynamic>>> uploadAttachments({
    required String conversationId,
    required String senderId,
    required List<LocalFilePayload> files,
    String? scope, // 'service' or default
  }) async {
    final res = await _dio.post(
      ApiEndpoints.attachments(conversationId),
      data: {
        'senderId': senderId,
        if (scope != null && scope.isNotEmpty) 'scope': scope,
        'files': files.map((f) => f.toJson()).toList(),
      },
    );
    final data = res.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['uploaded'] is List) {
      return (data['uploaded'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }
}

class LocalFilePayload {
  LocalFilePayload({
    required this.fileName,
    required this.contentBase64,
    this.mimeType,
    this.fileSizeBytes,
  });

  final String fileName;
  final String contentBase64; // raw base64 or data url; server supports both
  final String? mimeType;
  final int? fileSizeBytes;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'contentBase64': contentBase64,
        if (mimeType != null) 'mimeType': mimeType,
        if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      };

  static LocalFilePayload fromBytes({
    required String fileName,
    required List<int> bytes,
    String? mimeType,
  }) {
    final b64 = base64Encode(bytes);
    return LocalFilePayload(
      fileName: fileName,
      contentBase64: b64,
      mimeType: mimeType,
      fileSizeBytes: bytes.length,
    );
  }
}

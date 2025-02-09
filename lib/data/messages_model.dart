import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  String recipientName;
  final String messageText;
  final DateTime dateTime;
  final String avatarUrl;
  final String recipientId;
  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.dateTime,
    required this.avatarUrl,
    required this.recipientId,
    required this.recipientName,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      messageText: map['messageText'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      dateTime: (map['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recipientId: map['recipientId'] ?? '',
      recipientName: map['recipientName'] ?? ' '
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'messageText': messageText,
      'avatarUrl': avatarUrl,
      'dateTime': dateTime,
      'recipientId': recipientId,
      'recipientName': recipientName,
    };
  }
}

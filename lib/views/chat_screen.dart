import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saglik_personel_sistemi/data/messages_model.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatarUrl;


  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatarUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _textController = TextEditingController();

  late String currentUserName;
  late String currentUserAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Mevcut kullanıcının bilgilerini Firestore'dan alıyoruz
    _fetchCurrentUserInfo();
  }

  /// Mevcut kullanıcının bilgilerini Firestore'dan alır
  Future<void> _fetchCurrentUserInfo() async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('personnel').doc(widget.currentUserId).get();
      if (userDoc.exists) {
        setState(() {
          currentUserName = userDoc['name'] ?? 'Siz';
          currentUserAvatarUrl = userDoc['avatarUrl'] ??
              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'; // Varsayılan avatar
        });
      } else {
        setState(() {
          currentUserName = 'Siz';
          currentUserAvatarUrl =
          'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';
        });
      }
    } catch (e) {
      // Hata durumunda varsayılan değerleri kullan
      setState(() {
        currentUserAvatarUrl =
        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'; // Varsayılan avatar
      });
      print('Kullanıcı bilgileri alınırken hata oluştu: $e');
    }
  }

  /// Firestore'dan iki kullanıcı arasındaki mesajları dinleyen bir Stream oluşturur
  Stream<List<MessageModel>> getChatStream() {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [widget.currentUserId, widget.otherUserId])
        .where('recipientId', whereIn: [widget.currentUserId, widget.otherUserId])
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  /// Mesaj gönderme fonksiyonu
  Future<void> _sendMessage() async {
    final messageText = _textController.text.trim();
    if (messageText.isEmpty) return;

    // Mesajı Firestore'a ekliyoruz
    final message = MessageModel(
      id: '', // Firestore doküman ID'si otomatik oluşturulacak
      senderId: widget.currentUserId,
      senderName: currentUserName,
      messageText: messageText,
      dateTime: DateTime.now(),
      avatarUrl: currentUserAvatarUrl,
      recipientId: widget.otherUserId,
      recipientName: widget.otherUserName,
    );

    try {
      await _firestore.collection('messages').add(message.toMap());
      _textController.clear();
    } catch (e) {
      print('Mesaj gönderilirken hata oluştu: $e');
      // Kullanıcıya hata mesajı göstermek için bir SnackBar ekleyebilirsiniz
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj gönderilemedi. Lütfen tekrar deneyin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst kısımdaki özel AppBar tasarımı
      appBar: AppBar(
        // Kullanıcı adı ve küçük avatar
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.otherUserAvatarUrl),
              radius: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.otherUserName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      // İki bölüm: Mesajlar listesi + Mesaj yazma alanı
      body: Column(
        children: [
          // 1) Mesajlar Listesi
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: getChatStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(child: Text('Henüz mesajınız yok.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  reverse: true, // En yeni mesaj en üstte görünür
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUserId;

                    return _buildChatBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          // 2) Mesaj Yazma Alanı
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Mesaj balonlarını tasarlayan widget
  Widget _buildChatBubble(MessageModel msg, bool isMe) {
    final bubbleAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isMe ? Colors.blue.shade400 : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final radius = isMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    return Column(
      crossAxisAlignment: bubbleAlignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                msg.messageText,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(msg.dateTime),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Ekranın altındaki mesaj yazma ve gönderme butonu
  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Metin girişi
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Gönder butonu
          InkWell(
            onTap: _sendMessage,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade600,
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Datetime’ı "HH:MM" formatına çevirir
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

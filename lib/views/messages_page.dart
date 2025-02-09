import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:saglik_personel_sistemi/data/messages_model.dart';
import 'package:saglik_personel_sistemi/data/personnel.dart';
import 'chat_screen.dart';

const String defaultAvatarUrl =
    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUserId;

  // Tüm mesajları (giden + gelen) tek bir akışta tutacağımız stream
  late final Stream<List<MessageModel>> _combinedMessagesStream;

  // İsimleri önbellekte tutmak için
  final Map<String, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? '';

    // 1) Kullanıcının aldığı mesajlar
    final receivedMessagesStream = _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: currentUserId)
        .orderBy('dateTime', descending: true)
        .snapshots();

    // 2) Kullanıcının gönderdiği mesajlar
    final sentMessagesStream = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('dateTime', descending: true)
        .snapshots();

    // RxDart ile iki stream'i birleştirip tek bir Stream<List<MessageModel>> yapıyoruz
    _combinedMessagesStream = Rx.combineLatest2<
        QuerySnapshot, QuerySnapshot, List<MessageModel>>(
      receivedMessagesStream,
      sentMessagesStream,
          (receivedSnapshot, sentSnapshot) {
        // Gelen dokümanlar
        final receivedDocs = receivedSnapshot.docs;
        final sentDocs = sentSnapshot.docs;

        // Her iki dokümanı tek listeye atıyoruz
        final allDocs = [...receivedDocs, ...sentDocs];

        // Dokümanları model'e dönüştür
        final allMessages = allDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return MessageModel.fromMap(data, doc.id);
        }).toList();

        // Tarihe göre sıralayalım (yeniden eskiye)
        allMessages.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        return allMessages;
      },
    );
  }

  /// Bütün mesajları aldıktan sonra, bunları "karşı tarafın userId"sine göre
  /// gruplarız. Böylece aynı kişiyle yapılan sohbeti tek bir satırda gösteririz.
  List<MessageModel> _groupMessagesByConversationPartner(
      List<MessageModel> allMessages) {
    final Map<String, MessageModel> lastMessageMap = {};

    for (var msg in allMessages) {
      // Karşı tarafın userId'sini buluyoruz:
      final otherUserId = (msg.senderId == currentUserId)
          ? msg.recipientId
          : msg.senderId;

      // Daha önce o userId için hiç mesaj yoksa veya bu msg daha güncelse, güncelle
      if (!lastMessageMap.containsKey(otherUserId)) {
        lastMessageMap[otherUserId] = msg;
      } else {
        final existingMsg = lastMessageMap[otherUserId]!;
        if (msg.dateTime.isAfter(existingMsg.dateTime)) {
          lastMessageMap[otherUserId] = msg;
        }
      }
    }

    // Map'teki "her userId'nin en son mesajı" nı bir listeye dönüştür
    final groupedList = lastMessageMap.values.toList();

    // Ekranda en güncel mesaja göre sıralayalım
    groupedList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return groupedList;
  }

  /// Firestore'dan kullanıcı adını çekmek
  Future<String> _fetchUserName(String userId) async {
    // Daha önce önbelleğe aldıysak, oradan döndür
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }

    try {
      final userDoc =
      await _firestore.collection('personnel').doc(userId).get();
      if (userDoc.exists) {
        final name = userDoc['name'] ?? 'Unknown';
        _userNamesCache[userId] = name;
        return name;
      }
    } catch (e) {
      debugPrint('Kullanıcı adı alınırken hata oluştu: $e');
    }
    return 'Unknown';
  }

  /// "Yeni Mesaj" butonuna basıldığında personel listesi açılır
  void _showPersonnelList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Yeni Mesaj Gönder',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: PersonnelList(
              currentUserId: currentUserId,
            ),
          ),
        );
      },
    );
  }

  /// Zaman formatı (HH:MM)
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Mesajlar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: _combinedMessagesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Bir hata oluştu: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allMessages = snapshot.data ?? [];
          if (allMessages.isEmpty) {
            return const Center(child: Text('Henüz mesajınız yok.'));
          }

          // Aynı kullanıcıya ait mesajları tek satırda göstermek için grupla
          final groupedMessages =
          _groupMessagesByConversationPartner(allMessages);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groupedMessages.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final msg = groupedMessages[index];
              final bool isMe = (msg.senderId == currentUserId);
              // Diğer kullanıcının id'si
              final String otherUserId =
              isMe ? msg.recipientId : msg.senderId;


              return FutureBuilder<String>(
                future: isMe
                    ? _fetchUserName(msg.recipientId) // ben gönderdim => alıcı adı
                    : _fetchUserName(msg.senderId),   // bana geldi => gönderici adı
                builder: (context, nameSnapshot) {
                  final displayName = nameSnapshot.data ?? '...';

                  return ListTile(
                    onTap: () {
                      // Sohbet ekranına git
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            currentUserId: currentUserId,
                            otherUserId: otherUserId,
                            otherUserName: displayName,
                            otherUserAvatarUrl: defaultAvatarUrl,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(defaultAvatarUrl),
                      radius: 24,
                    ),
                    title: Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      msg.messageText, // En son mesaj metnini göster
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTime(msg.dateTime),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPersonnelList,
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.message, color: Colors.white),
        tooltip: 'Yeni Mesaj Gönder',
      ),
    );
  }
}

/// Personel Listesini Gösteren Widget
class PersonnelList extends StatelessWidget {
  final String currentUserId;

  const PersonnelList({Key? key, required this.currentUserId})
      : super(key: key);

  /// Firestore'dan personel verilerini çeker
  Stream<List<Personnel>> getPersonnelStream() {
    return FirebaseFirestore.instance
        .collection('personnel')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Personnel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
      )
      // Kendimizi listede göstermemek için
          .where((person) => person.uid != currentUserId)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Personnel>>(
      stream: getPersonnelStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final personnel = snapshot.data ?? [];
        if (personnel.isEmpty) {
          return const Center(child: Text('Kayıtlı personel bulunmuyor.'));
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: personnel.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final person = personnel[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  // Personel seçildiğinde Chat ekranına yönlendir
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        currentUserId: currentUserId,
                        otherUserId: person.uid,
                        otherUserName: '${person.name} ${person.surname}',
                        otherUserAvatarUrl: defaultAvatarUrl,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(defaultAvatarUrl),
                  radius: 24,
                ),
                title: Text(
                  '${person.name} ${person.surname}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.apartment,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            person.branch,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            person.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                isThreeLine: true, // Alt başlık için üç satır kullanımını sağlar
              ),
            );
          },
        );
      },
    );
  }
}

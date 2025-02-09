// lib/data/personnel.dart

class Personnel {
  String uid; // Firebase Auth tarafından oluşturulan benzersiz kullanıcı ID'si
  String name;
  String surname;
  String mail;
  String branch;
  String title;
  String? avatarUrl="https://cdn-icons-png.flaticon.com/512/3135/3135715.png";


  Personnel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.mail,
    required this.branch,
    required this.title,
    this.avatarUrl

  });

  // Firestore'dan Personnel objesi oluşturmak için factory constructor
  factory Personnel.fromMap(Map<String, dynamic> data, String documentId) {
    return Personnel(
      uid: documentId,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      mail: data['mail'] ?? '',
      branch: data['branch'] ?? '',
      title: data['title'] ?? '',
    );
  }

  // Personnel objesini Firestore'a kaydetmek için Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'mail': mail,
      'branch': branch,
      'title': title,
      // Şifre burada saklanmamalıdır!
    };
  }
}

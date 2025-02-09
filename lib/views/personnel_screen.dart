// lib/views/personnel_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:saglik_personel_sistemi/data/personnel.dart';
import 'package:saglik_personel_sistemi/views/co_worker_screen.dart';
import 'package:saglik_personel_sistemi/views/messages_page.dart';
import 'package:saglik_personel_sistemi/views/tasks_page.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({Key? key}) : super(key: key);

  @override
  _PersonnelScreenState createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Personnel? _currentPersonnel;
  bool _isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadPersonnelData();
  }

  Future<void> _loadPersonnelData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
        await _firestore.collection('personnel').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _currentPersonnel =
                Personnel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            _isLoading = false;
          });
        } else {
          setState(() {
            error = 'Personel bilgileri bulunamadı.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Kullanıcı bulunamadı.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Veriler alınırken bir hata oluştu.';
        _isLoading = false;
      });
      print('Error fetching personnel data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: SpinKitCircle(color: Colors.blue.shade600))
          : error.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${_currentPersonnel?.name} ${_currentPersonnel?.surname}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade400
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 80.0,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    icon: Icons.email,
                    title: 'E-posta',
                    content: _currentPersonnel?.mail ?? 'N/A',
                  ),
                  _buildInfoCard(
                    icon: Icons.local_hospital,
                    title: 'Branş',
                    content: _currentPersonnel?.branch ?? 'N/A',
                  ),
                  _buildInfoCard(
                    icon: Icons.badge,
                    title: 'Ünvan',
                    content: _currentPersonnel?.title ?? 'N/A',
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Hızlı İşlemler',
                    style: GoogleFonts.poppins(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildQuickActionGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Footer
      bottomNavigationBar: !_isLoading && error.isEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '© 2023 Şehir Hastanesi. Tüm hakları saklıdır.',
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      )
          : null,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 28.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    final List<Map<String, dynamic>> actions = [
      {'icon': Icons.assignment, 'title': 'Görevler'},
      {'icon': Icons.co_present, 'title': 'Co-Worker'}, // "Hastalar" yerine "Co-Worker"
      {'icon': Icons.message, 'title': 'Mesajlar'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: InkWell(
            onTap: () {
              _handleQuickAction(actions[index]['title']);
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(actions[index]['icon'],
                    color: Colors.blue.shade600, size: 32.0),
                const SizedBox(height: 8.0),
                Text(
                  actions[index]['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleQuickAction(String title) {
    switch (title) {
      case 'Görevler':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskPage()), // Görevler sayfasını buraya ekleyin
        );
        break;
      case 'Co-Worker':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoWorkerScreen()),
        );
        break;
      case 'Mesajlar':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  MessagesPage()), // Mesajlar sayfasını buraya ekleyin
        );
        break;
      default:
        break;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saglik_personel_sistemi/data/personnel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CoWorkerScreen extends StatefulWidget {
  const CoWorkerScreen({Key? key}) : super(key: key);

  @override
  _CoWorkerScreenState createState() => _CoWorkerScreenState();
}

class _CoWorkerScreenState extends State<CoWorkerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentBranch;
  List<Personnel> _coWorkers = [];
  bool _isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchCoWorkers();
  }

  Future<void> _fetchCoWorkers() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('personnel').doc(user.uid).get();
        if (userDoc.exists) {
          Personnel currentPersonnel =
          Personnel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
          setState(() {
            _currentBranch = currentPersonnel.branch;
          });

          QuerySnapshot coWorkerSnapshot = await _firestore
              .collection('personnel')
              .where('branch', isEqualTo: _currentBranch)
              .where(FieldPath.documentId, isNotEqualTo: user.uid)
              .get();

          List<Personnel> coWorkers = coWorkerSnapshot.docs
              .map((doc) =>
              Personnel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          setState(() {
            _coWorkers = coWorkers;
            _isLoading = false;
          });
        } else {
          setState(() {
            error = 'Kendi personel bilgileriniz bulunamadı.';
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
        error = 'Co-Worker bilgileri alınırken bir hata oluştu.';
        _isLoading = false;
      });
      print('Error fetching co-workers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.white),
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Co-Workers',
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
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.people,
                    size: 80.0,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SpinKitCircle(color: Colors.blue.shade600),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                error,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  color: Colors.red.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_coWorkers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Aynı departmanda başka personel bulunmuyor.',
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                '$_currentBranch Departmanı',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _coWorkers.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildCoWorkerCard(_coWorkers[index]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoWorkerCard(Personnel coWorker) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  '${coWorker.name[0]}${coWorker.surname[0]}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coWorker.name} ${coWorker.surname}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coWorker.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
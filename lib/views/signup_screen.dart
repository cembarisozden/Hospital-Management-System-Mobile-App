// lib/views/signup_page.dart
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:saglik_personel_sistemi/data/personnel.dart';
import 'package:saglik_personel_sistemi/views/login_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form alanları için kontroller
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();

  String? _selectedBranch;
  String? _selectedTitle;

  // Branş ve Ünvan listeleri
  final List<String> branches = [
    "Dahiliye",
    "Cerrahi",
    "Pediatri",
    "Kardiyoloji",
    "Nöroloji",
    "Ortopedi",
    "Göz Hastalıkları",
    "Kulak Burun Boğaz",
    "Dermatoloji",
    "Psikiyatri"
  ];

  final List<String> titles = [
    "Uzman Doktor",
    "Asistan Doktor",
    "Hemşire",
    "Teknisyen",
    "İdari Personel"
  ];

  // Animasyon için controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animasyon controller'ı başlatma
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    // Kontrolleri temizleme
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  Future<void> _handleSubmit() async {
    // Form geçerliyse devam et
    if (_formKey.currentState!.validate()) {
      // Branş ve unvan seçili mi?
      if (_selectedBranch == null || _selectedTitle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
        );
        return;
      }

      // Şifreler eşleşiyor mu?
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifreler eşleşmiyor')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Kullanıcı oluşturma
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Mail doğrulama gönder
          await user.sendEmailVerification();

          // Personnel objesi
          Personnel newPersonnel = Personnel(
            uid: user.uid,
            name: _firstNameController.text.trim(),
            surname: _lastNameController.text.trim(),
            mail: _emailController.text.trim(),
            branch: _selectedBranch!,
            title: _selectedTitle!,
          );

          // Firestore'a kaydet
          await _firestore
              .collection('personnel')
              .doc(user.uid)
              .set(newPersonnel.toMap());

          // Kullanıcıya bilgi ver
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Kayıt başarılı! Lütfen email adresinize gönderilen doğrulama bağlantısını onaylayın.',
              ),
            ),
          );

          // Kullanıcı oturumunu kapat (doğrulama yapılana kadar giriş yapılmasın)
          await _auth.signOut();

          // Giriş sayfasına yönlendirme
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          // user null döndüyse hata
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı oluşturulurken bir hata oluştu.')),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Firebase Auth spesifik hatalar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Bir hata oluştu.')),
        );
      } catch (e) {
        // Diğer hatalar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt sırasında bir hata oluştu.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plan gradyanı
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20.0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo ve Başlık
                      Column(
                        children: [
                          // Logo ikonu
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 40.0,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Başlık animasyonu
                          AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                'Personel Kaydı',
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            ],
                            isRepeatingAnimation: false,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Hastane bilgi sistemine hoş geldiniz',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Ad
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                labelText: 'Ad',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen adınızı girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Soyad
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline),
                                labelText: 'Soyad',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen soyadınızı girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // E-posta
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                labelText: 'E-posta adresi',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen e-posta adresinizi girin';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Geçerli bir e-posta adresi girin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Şifre
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                labelText: 'Şifre',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen şifrenizi girin';
                                }
                                if (value.length < 6) {
                                  return 'Şifre en az 6 karakter olmalıdır';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Şifre Tekrarı
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                labelText: 'Şifre Tekrarı',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen şifrenizi tekrar girin';
                                }
                                if (value != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Branş Seçimi
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.local_hospital_outlined),
                                labelText: 'Branş Seçin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              value: _selectedBranch,
                              items: branches
                                  .map((branch) => DropdownMenuItem(
                                        value: branch,
                                        child: Text(branch),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBranch = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen bir branş seçin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Ünvan Seçimi
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.badge),
                                labelText: 'Unvan Seçin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              value: _selectedTitle,
                              items: titles
                                  .map((title) => DropdownMenuItem(
                                        value: title,
                                        child: Text(title),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTitle = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen bir ünvan seçin';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24.0),
                            // Kayıt Ol Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SpinKitCircle(
                                        color: Colors.white,
                                        size: 24.0,
                                      )
                                    : const Text(
                                        'Kayıt Ol',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Giriş Yap Linki
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Zaten hesabınız var mı? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: Text(
                              'Giriş yapın',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      // Alt Bilgi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Şehir Hastanesi Bilgi Sistemi',
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

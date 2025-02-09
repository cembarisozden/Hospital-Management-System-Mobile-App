import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:saglik_personel_sistemi/views/personnel_screen.dart';
import 'package:saglik_personel_sistemi/views/signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _rememberMe = false;

  final FirebaseFirestore_firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form alanları için kontroller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Form gönderim fonksiyonu
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase ile giriş yap
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Kullanıcının email doğrulaması yapılmış mı?
          if (user.emailVerified) {
            // Giriş başarılı
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Giriş Başarılı!')),
            );

            // Giriş sonrası yönlendirme
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PersonnelScreen()), // Ana sayfanıza yönlendirin
            );
          } else {
            // Email doğrulaması yapılmamış
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Lütfen email adresinizi doğrulayın. Mail kutunuzu kontrol edin.',
                ),
              ),
            );

            // Oturumu kapat (doğrulama yapılmadığı için girişe izin verme)
            await _auth.signOut();
          }
        }
      } on FirebaseAuthException catch (e) {
        // Firebase hatalarını yönet
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Böyle bir kullanıcı bulunamadı.';
            break;
          case 'wrong-password':
            errorMessage = 'Şifre yanlış. Lütfen tekrar deneyin.';
            break;
          case 'user-disabled':
            errorMessage = 'Bu kullanıcı hesabı devre dışı bırakılmış.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz bir email adresi girdiniz.';
            break;
          default:
            errorMessage = 'Giriş sırasında bir hata oluştu. Lütfen tekrar deneyin.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Diğer hatalar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir hata oluştu. Lütfen tekrar deneyin.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25.0,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Başlık Bölümü
                      Column(
                        children: [
                          // Arka plan görseli ve logo ikonu
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.purple.shade400
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              // Logo ikonu
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10.0,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  // Giriş ikonunu değiştirebilirsiniz
                                  color: Colors.blue,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          // Başlık animasyonu
                          AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                'Hastane Personel Girişi',
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 26.0,
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
                            'Güvenli bilgi sistemine hoş geldiniz',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: Colors.grey[700],
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
                            // E-posta
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                labelText: 'E-posta adresi',
                                hintText: 'E-posta adresinizi girin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
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
                                hintText: 'Şifrenizi girin',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              obscureText: true,
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
                            // Beni Hatırla ve Şifremi Unuttum
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue.shade600,
                                    ),
                                    const Text(
                                      'Beni hatırla',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Şifremi unuttum sayfasına yönlendirme
                                    // Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordPage()));
                                  },
                                  child: const Text(
                                    'Şifremi unuttum',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24.0),
                            // Giriş Yap Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 50.0,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SpinKitCircle(
                                        color: Colors.white,
                                        size: 24.0,
                                      )
                                    : const Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            // Kayıt Olma Bağlantısı
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Hesabınız yok mu? ',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                GestureDetector(
                                  onTap: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage()));
                                  },
                                  child: Text(
                                    'Kayıt Olun',
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:saglik_personel_sistemi/views/login_screen.dart';
import 'package:saglik_personel_sistemi/views/signup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isHoveredLogin = false;
  bool isHoveredSignup = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu al
    double screenWidth = MediaQuery.of(context).size.width;

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
                      // Logo ve Başlık Bölümü
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
                                'Hastane Personel Bilgi Sistemi',
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                                duration:
                                const Duration(milliseconds: 1500),
                              ),
                            ],
                            isRepeatingAnimation: false,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Güvenli ve Hızlı Erişim',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      // Giriş Yap ve Kayıt Ol Butonları
                      Column(
                        children: [
                          // Giriş Yap Butonu
                          GestureDetector(
                            onTap: () {
                              // Giriş yapma işlemi
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              );
                            },
                            child: MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  isHoveredLogin = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  isHoveredLogin = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..scale(isHoveredLogin ? 1.05 : 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    borderRadius:
                                    BorderRadius.circular(12.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isHoveredLogin
                                        ? 'Sisteme Giriş Yap →'
                                        : 'Giriş Yap',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Kayıt Ol Butonu
                          GestureDetector(
                            onTap: () {
                              // Kayıt olma işlemi
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpPage()),
                              );
                            },
                            child: MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  isHoveredSignup = true;
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  isHoveredSignup = false;
                                });
                              },
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..scale(
                                      isHoveredSignup ? 1.05 : 1.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Colors.blue.shade600,
                                      width: 2.0,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isHoveredSignup
                                        ? 'Yeni Hesap Oluştur →'
                                        : 'Kayıt Ol',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue.shade600,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      // Teknik Destek Metni
                      Text(
                        'Teknik destek için IT departmanı ile iletişime geçin',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // Footer
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            '© 2023 Şehir Hastanesi. Tüm hakları saklıdır.',
            style: GoogleFonts.poppins(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


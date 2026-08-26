import 'dart:async';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Inicializa la BD en segundo plano mientras se muestra el splash
    final startTime = DateTime.now();
    await DatabaseHelper.instance.database;
    final elapsed = DateTime.now().difference(startTime);

    // Mantiene el splash al menos 1 segundo para una transición suave
    final remaining = const Duration(milliseconds: 1200) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Diccionario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2C56),
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'de la lengua',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF1A2C56),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'española',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0A500),
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/views/screens/splash/splash_screen.dart

import 'package:atpl_flashing_app/logic/controller/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  final SplashController controller = Get.put(SplashController());

  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut)));
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _mainCtrl.forward();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060C1A),
      body: Stack(
        children: [

          // Grid
          CustomPaint(
            painter: _GridPainter(),
            child: const SizedBox.expand()),

          // Top accent
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFF97316),
                    Color(0xFFEA580C),
                    Colors.transparent,
                  ])))),

          // Bottom accent
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF3B82F6),
                    Color(0xFF06B6D4),
                    Colors.transparent,
                  ])))),

          // Main center
          Center(
            child: AnimatedBuilder(
              animation: _mainCtrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Logo
                  SizedBox(
                    width: 250,
                    height: 150,
                    child: Image.asset(
                      'assets/orange autopeepal logo.png',
                      fit: BoxFit.contain)),

                  const SizedBox(height: 10),

                  // App name
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'ATPL-PFS',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6))),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'ECU Flash Management System',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0x60FFFFFF),
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w400)),

                  const SizedBox(height: 12),

                  // Divider
                  Container(
                    width: 48,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
                      borderRadius: BorderRadius.circular(1))),

                  const SizedBox(height: 56),

                  // Progress
                  SizedBox(
                    width: 180,
                    child: Column(
                      children: [

                        // Track
                        Stack(
                          children: [
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2E45),
                                borderRadius: BorderRadius.circular(1))),
                            AnimatedBuilder(
                              animation: _progressAnim,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  widthFactor: _progressAnim.value,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF97316),
                                          Color(0xFFEA580C),
                                        ]),
                                      borderRadius: BorderRadius.circular(1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF97316)
                                              .withOpacity(0.5),
                                          blurRadius: 6)])));
                              }),
                          ]),

                        const SizedBox(height: 12),

                        // Status row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (context, child) {
                                return Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF97316)
                                        .withOpacity(_pulseAnim.value)));
                              }),
                            const SizedBox(width: 8),
                            const Text(
                              'Initializing...',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0x45FFFFFF),
                                letterSpacing: 1.5)),
                          ]),

                      ])),

                ]))),

          // Powered by
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (context, child) {
                return Opacity(opacity: _fadeAnim.value, child: child!);
              },
              child: const Text(
                'Powered by AutoPeepal Technologies',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0x30FFFFFF),
                  letterSpacing: 1.5)))),

        ]));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x06FFFFFF)
      ..strokeWidth = 0.5;
    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// lib/views/screens/splash/splash_screen.dart
// Premium Dark Splash — Deep Navy + Orange theme

import 'package:atpl_flashing_app/logic/controller/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  final SplashController controller = Get.put(SplashController());

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)));

    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [

          // ── Background radial glow ─────────────────────────
          Positioned(
            top: size.height * 0.2,
            left: size.width * 0.5 - 200,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF97316).withOpacity(0.12),
                    Colors.transparent,
                  ])))),

          // ── Top orange accent line ─────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9A3412),
                    Color(0xFFF97316),
                    Color(0xFFEA580C),
                    Color(0xFF9A3412),
                  ])))),

          // ── Bottom orange accent line ──────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9A3412),
                    Color(0xFFF97316),
                    Color(0xFFEA580C),
                    Color(0xFF9A3412),
                  ])))),

          // ── Corner decorative dots ─────────────────────────
          Positioned(top: 24, left: 24,
            child: _CornerDots()),
          Positioned(top: 24, right: 24,
            child: _CornerDots(flip: true)),

          // ── Main center content ────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _animCtrl,
              builder: (_, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Logo card ────────────────────────────────
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF243044)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFF2D3F55), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x60F97316),
                          blurRadius: 40, spreadRadius: 0,
                          offset: Offset(0, 8)),
                        BoxShadow(
                          color: Color(0x30000000),
                          blurRadius: 30, offset: Offset(0, 16)),
                      ]),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Image.asset(
                        'assets/new/autopeepal(1).png',
                        fit: BoxFit.contain))),

                  const SizedBox(height: 36),

                  // ── App name ──────────────────────────────────
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    ).createShader(bounds),
                    child: const Text('ATPL-PFS',
                      style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 4))),

                  const SizedBox(height: 8),

                  // ── Subtitle ──────────────────────────────────
                  const Text('ECU Flashing System',
                    style: TextStyle(
                      fontSize: 14, color: Color(0x80FFFFFF),
                      letterSpacing: 2, fontWeight: FontWeight.w400)),

                  const SizedBox(height: 6),

                  // ── Orange divider line ───────────────────────
                  Container(
                    width: 60, height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
                      borderRadius: BorderRadius.circular(2))),

                  const SizedBox(height: 48),

                  // ── Loading bar ───────────────────────────────
                  SizedBox(
                    width: 180,
                    child: Column(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          backgroundColor: Color(0xFF1E293B),
                          color: Color(0xFFF97316),
                          minHeight: 3)),
                      const SizedBox(height: 10),
                      const Text('Loading...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0x60FFFFFF),
                          letterSpacing: 1)),
                    ])),
                ],
              ),
            ),
          ),

          // ── Version tag bottom ─────────────────────────────
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, child) => Opacity(
                opacity: _fadeAnim.value, child: child),
              child: const Text('Powered by ATPL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11, color: Color(0x40FFFFFF),
                  letterSpacing: 1.5)))),
        ],
      ),
    );
  }
}

// ── Corner decorative dots ─────────────────────────────────
class _CornerDots extends StatelessWidget {
  final bool flip;
  const _CornerDots({this.flip = false});

  @override
  Widget build(BuildContext context) {
    final dots = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _dot(big: true), const SizedBox(width: 5), _dot(),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          _dot(), const SizedBox(width: 5), _dot(),
        ]),
      ]);

    return flip
        ? Transform.flip(flipX: true, child: dots)
        : dots;
  }

  Widget _dot({bool big = false}) => Container(
    width: big ? 8 : 5,
    height: big ? 8 : 5,
    decoration: BoxDecoration(
      color: big
          ? const Color(0xFFF97316)
          : const Color(0x40F97316),
      shape: BoxShape.circle));
}
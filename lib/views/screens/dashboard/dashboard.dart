// lib/views/screens/dashboard/dashboard_screen.dart
// Premium Dark UI — keeps MainLayout wrapper
// Deep Navy + Orange gradient inside content area

import 'dart:math' as math;
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';

// ── Color Palette ─────────────────────────────────────────────
const Color _cBg      = Color(0xFF0F172A);
const Color _cSurface = Color(0xFF1E293B);
const Color _cSurface2= Color(0xFF243044);
const Color _cBorder  = Color(0xFF2D3F55);
const Color _cOrange  = Color(0xFFF97316);
const Color _cOrangD  = Color(0xFFEA580C);
const Color _cOrangDD = Color(0xFF9A3412);
const Color _cWhite   = Color(0xFFFFFFFF);
const Color _cWhite70 = Color(0xB3FFFFFF);
const Color _cWhite15 = Color(0x26FFFFFF);
const Color _cWhite40 = Color(0x66FFFFFF);
const Color _cPass    = Color(0xFF22C55E);
const Color _cFail    = Color(0xFFEF4444);

const _gradientOrange = LinearGradient(
  colors: [_cOrange, _cOrangD, _cOrangDD],
  begin: Alignment.topLeft, end: Alignment.bottomRight,
);
const _gradientSurface = LinearGradient(
  colors: [_cSurface, _cSurface2],
  begin: Alignment.topLeft, end: Alignment.bottomRight,
);

// ════════════════════════════════════════════════════════════
//  DashboardScreen — uses MainLayout for drawer
// ════════════════════════════════════════════════════════════
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();

    return MainLayout(
      title: 'Dashboard',
      child: Container(
        color: _cBg,
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _cOrange),
            );
          }
          return RefreshIndicator(
            color: _cOrange,
            backgroundColor: _cSurface,
            onRefresh: c.refreshStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UserInfoCard(c: c),
                  const SizedBox(height: 20),
                  _sectionLabel('Production Stats'),
                  const SizedBox(height: 12),
                  _StatCardsRow(c: c),
                  const SizedBox(height: 20),
                  _sectionLabel('Analytics'),
                  const SizedBox(height: 12),
                  _ChartsRow(c: c),
                  const SizedBox(height: 20),
                  _sectionLabel('Quick Actions'),
                  const SizedBox(height: 12),
                  const _QuickActions(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────
Widget _sectionLabel(String text) => Row(
  children: [
    Container(
      width: 3, height: 16,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cOrange, _cOrangD],
          begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text, style: const TextStyle(
      color: _cWhite, fontSize: 14,
      fontWeight: FontWeight.w700, letterSpacing: 0.4)),
  ],
);

// ════════════════════════════════════════════════════════════
//  User Info Card
// ════════════════════════════════════════════════════════════
class _UserInfoCard extends StatelessWidget {
  final DashboardController c;
  const _UserInfoCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cSurface, _cSurface2],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cBorder),
        boxShadow: const [BoxShadow(
          color: Color(0x50000000), blurRadius: 16, offset: Offset(0, 4))]),
      child: Obx(() => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_cOrange, _cOrangD],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(
                  color: Color(0x60F97316),
                  blurRadius: 12, offset: Offset(0, 4))]),
              child: Center(
                child: Text(
                  '${c.firstName.value.isNotEmpty ? c.firstName.value[0] : ''}'
                  '${c.lastName.value.isNotEmpty ? c.lastName.value[0] : ''}'.toUpperCase(),
                  style: const TextStyle(
                    color: _cWhite, fontSize: 18, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + role
                  Row(children: [
                    Flexible(child: Text(
                      c.fullName.value.isNotEmpty ? c.fullName.value : 'User',
                      style: const TextStyle(
                        color: _cWhite, fontSize: 15, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_cOrange, _cOrangD]),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(c.role.value,
                        style: const TextStyle(
                          color: _cWhite, fontSize: 10, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 8),
                  // Orange divider
                  Container(height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_cOrange, Colors.transparent]))),
                  const SizedBox(height: 8),
                  if (c.stationName.value.isNotEmpty)
                    _InfoRow(Icons.location_on_outlined, 'Station',
                      '${c.stationName.value}  (${c.stationId.value})'),
                  if (c.oemName.value.isNotEmpty)
                    _InfoRow(Icons.business_outlined, 'OEM', c.oemName.value),
                  if (c.userEmail.value.isNotEmpty)
                    _InfoRow(Icons.email_outlined, 'Email', c.userEmail.value),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Icon(icon, size: 13, color: _cOrange),
      const SizedBox(width: 5),
      Text('$label : ', style: const TextStyle(
        color: _cWhite40, fontSize: 12, fontWeight: FontWeight.w500)),
      Expanded(child: Text(value,
        style: const TextStyle(color: _cWhite70, fontSize: 12),
        overflow: TextOverflow.ellipsis)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
//  Stat Cards — Total | Flashed | Failed
// ════════════════════════════════════════════════════════════
class _StatCardsRow extends StatelessWidget {
  final DashboardController c;
  const _StatCardsRow({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => Row(
    children: [
      Expanded(child: _StatCard(
        label: 'Total', value: '${c.totalCount}',
        icon: Icons.analytics_outlined,
        gradient: const LinearGradient(
          colors: [_cOrange, _cOrangD, _cOrangDD],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        glowColor: _cOrange)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        label: 'Flashed', value: '${c.totalPass.value}',
        icon: Icons.check_circle_outline_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF15803D), Color(0xFF14532D)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        glowColor: _cPass)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        label: 'Failed', value: '${c.totalFail.value}',
        icon: Icons.cancel_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFF7F1D1D)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        glowColor: _cFail)),
    ],
  ));
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  const _StatCard({required this.label, required this.value,
    required this.icon, required this.gradient, required this.glowColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(
        color: glowColor.withOpacity(0.3),
        blurRadius: 14, offset: const Offset(0, 5))]),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white12, shape: BoxShape.circle),
        child: Icon(icon, color: _cWhite, size: 22)),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(
        color: _cWhite, fontSize: 26,
        fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(
        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
//  Charts Row
// ════════════════════════════════════════════════════════════
class _ChartsRow extends StatelessWidget {
  final DashboardController c;
  const _ChartsRow({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: _ChartCard(
        title: 'Overall', subtitle: 'Pass vs Fail',
        child: SizedBox(height: 220, child: _DonutChart(
          pass: c.totalPass.value, fail: c.totalFail.value)))),
      const SizedBox(width: 14),
      Expanded(child: _ChartCard(
        title: 'Shift-wise', subtitle: 'Per shift breakdown',
        child: SizedBox(height: 220, child: _BarChart(
          s1p: c.shift1Pass.value, s1f: c.shift1Fail.value,
          s2p: c.shift2Pass.value, s2f: c.shift2Fail.value,
          s3p: c.shift3Pass.value, s3f: c.shift3Fail.value)))),
    ],
  ));
}

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_cSurface, _cSurface2],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _cBorder),
      boxShadow: const [BoxShadow(
        color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 4))]),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 3, height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_cOrange, _cOrangD],
                begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              color: _cWhite, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(
              color: _cWhite40, fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    ),
  );
}

// ── Donut Chart ───────────────────────────────────────────────
class _DonutChart extends StatelessWidget {
  final int pass, fail;
  const _DonutChart({required this.pass, required this.fail});

  @override
  Widget build(BuildContext context) {
    final total    = pass + fail;
    final passRate = total > 0
        ? (pass / total * 100).toStringAsFixed(1) : '0.0';
    return Column(children: [
      Expanded(child: CustomPaint(
        painter: _DonutPainter(pass: pass, fail: fail),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$total', style: const TextStyle(
            color: _cWhite, fontSize: 26,
            fontWeight: FontWeight.w900, letterSpacing: -1)),
          const Text('Total', style: TextStyle(color: _cWhite40, fontSize: 11)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _cPass.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20)),
            child: Text('$passRate% Pass',
              style: const TextStyle(
                color: _cPass, fontSize: 10, fontWeight: FontWeight.w700))),
        ])))),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Legend(color: _cPass, label: 'Pass', value: '$pass'),
        const SizedBox(width: 16),
        _Legend(color: _cFail, label: 'Fail', value: '$fail'),
      ]),
    ]);
  }
}

class _DonutPainter extends CustomPainter {
  final int pass, fail;
  _DonutPainter({required this.pass, required this.fail});

  @override
  void paint(Canvas canvas, Size size) {
    final total = (pass + fail).toDouble();
    if (total == 0) return;
    final c      = Offset(size.width / 2, size.height / 2);
    final r      = size.shortestSide / 2 - 12;
    const sw     = 22.0;
    const start  = -math.pi / 2;
    final pSweep = (pass / total) * 2 * math.pi;
    final fSweep = (fail / total) * 2 * math.pi;
    final rect   = Rect.fromCircle(center: c, radius: r);

    // Background ring
    canvas.drawArc(rect, 0, 2 * math.pi, false,
      Paint()..color = _cBorder
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw);

    // Pass arc
    canvas.drawArc(rect, start, pSweep, false,
      Paint()..color = _cPass
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);

    // Fail arc
    canvas.drawArc(rect, start + pSweep, fSweep, false,
      Paint()..color = _cFail
             ..style = PaintingStyle.stroke
             ..strokeWidth = sw
             ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.pass != pass || o.fail != fail;
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label, value;
  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)])),
    const SizedBox(width: 5),
    Text('$label: ', style: const TextStyle(color: _cWhite40, fontSize: 11)),
    Text(value, style: const TextStyle(
      color: _cWhite, fontSize: 11, fontWeight: FontWeight.bold)),
  ]);
}

// ── Bar Chart ─────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final int s1p, s1f, s2p, s2f, s3p, s3f;
  const _BarChart({required this.s1p, required this.s1f,
    required this.s2p, required this.s2f, required this.s3p, required this.s3f});

  @override
  Widget build(BuildContext context) {
    final max = [s1p, s1f, s2p, s2f, s3p, s3f]
        .fold<int>(1, (a, b) => a > b ? a : b);
    return Column(children: [
      Expanded(child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ShiftGroup(label: 'Shift 1', pass: s1p, fail: s1f, max: max),
          _ShiftGroup(label: 'Shift 2', pass: s2p, fail: s2f, max: max),
          _ShiftGroup(label: 'Shift 3', pass: s3p, fail: s3f, max: max),
        ],
      )),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Legend(color: _cPass, label: 'Pass', value: ''),
        const SizedBox(width: 16),
        _Legend(color: _cFail, label: 'Fail', value: ''),
      ]),
    ]);
  }
}

class _ShiftGroup extends StatelessWidget {
  final String label;
  final int pass, fail, max;
  const _ShiftGroup({required this.label, required this.pass,
    required this.fail, required this.max});

  @override
  Widget build(BuildContext context) {
    const maxH = 130.0;
    double ph  = max > 0 ? (pass / max) * maxH : 4;
    double fh  = max > 0 ? (fail / max) * maxH : 4;
    if (ph < 4) ph = 4; if (fh < 4) fh = 4;
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _GlowBar(h: ph, color: _cPass, value: pass),
        const SizedBox(width: 5),
        _GlowBar(h: fh, color: _cFail, value: fail),
      ]),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 10, color: _cWhite40)),
    ]);
  }
}

class _GlowBar extends StatelessWidget {
  final double h;
  final Color color;
  final int value;
  const _GlowBar({required this.h, required this.color, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text('$value', style: TextStyle(
        fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      const SizedBox(height: 3),
      Container(
        width: 22, height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.55)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8, offset: const Offset(0, 2))]),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  Quick Actions
// ════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _ActionCard(
      title: 'ECU Flashing',
      subtitle: 'Batch / Individual',
      icon: Icons.bolt_rounded,
      gradient: const LinearGradient(
        colors: [_cOrange, _cOrangD, _cOrangDD],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      onTap: () => Get.toNamed('/flashingScreen'))),
    const SizedBox(width: 12),
    Expanded(child: _ActionCard(
      title: 'Reprint',
      subtitle: 'Reprint sticker',
      icon: Icons.print_outlined,
      gradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF4C1D95)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      onTap: () => Get.toNamed('/reprint'))),
    const SizedBox(width: 12),
    Expanded(child: _ActionCard(
      title: 'Reports',
      subtitle: 'View all logs',
      icon: Icons.bar_chart_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7), Color(0xFF075985)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      onTap: () => Get.toNamed('/reports'))),
  ]);
}

class _ActionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _ActionCard({required this.title, required this.subtitle,
    required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cSurface, _cSurface2],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cBorder),
        boxShadow: const [BoxShadow(
          color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon box with gradient
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
              color: gradient.colors.first.withOpacity(0.35),
              blurRadius: 10, offset: const Offset(0, 4))]),
          child: Icon(icon, color: _cWhite, size: 22)),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(
          color: _cWhite, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(
          color: _cWhite40, fontSize: 11)),
        const SizedBox(height: 12),
        // Open arrow with gradient color
        ShaderMask(
          shaderCallback: (b) => gradient.createShader(b),
          child: const Row(children: [
            Text('Open', style: TextStyle(
              color: _cWhite, fontSize: 12, fontWeight: FontWeight.w700)),
            SizedBox(width: 3),
            Icon(Icons.arrow_forward_rounded, color: _cWhite, size: 13),
          ])),
      ]),
    ),
  );
}
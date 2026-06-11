// lib/views/screens/dashboard/dashboard_screen.dart
// Uses your existing MainLayout — drawer on left, content on right

import 'dart:math' as math;
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:atpl_flashing_app/common_widgets/main_layout.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/dasboardController.dart';

const Color _kOrange = Color(0xFFF9772C);
const Color _kBg     = Color(0xFFF5F6FA);
const Color _kCard   = Colors.white;
const Color _kText   = Color(0xFF1E2A3A);
const Color _kSub    = Color(0xFF6B7280);
const Color _kPass   = Color(0xFF22C55E);
const Color _kFail   = Color(0xFFEF4444);
const Color _kBorder = Color(0xFFE5E7EB);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();

    return MainLayout(
      title: 'Dashboard',
      child: Obx(() {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _kOrange),
          );
        }
        return RefreshIndicator(
          color: _kOrange,
          onRefresh: c.refreshStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserInfoCard(c: c),
                const SizedBox(height: 16),
                _StatCardsRow(c: c),
                const SizedBox(height: 16),
                _ChartsRow(c: c),
                const SizedBox(height: 16),
                _QuickActions(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  User Info Card
// ════════════════════════════════════════════════════════════
class _UserInfoCard extends StatelessWidget {
  final DashboardController c;
  const _UserInfoCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: _kOrange),
                  const SizedBox(width: 6),
                  Text(
                    c.fullName.value.isNotEmpty ? c.fullName.value : 'User',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: _kText),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c.role.value,
                        style: const TextStyle(
                            color: _kOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: _kBorder),
              const SizedBox(height: 8),
              if (c.stationName.value.isNotEmpty)
                _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Station',
                    value: '${c.stationName.value}  (${c.stationId.value})'),
              if (c.oemName.value.isNotEmpty)
                _InfoRow(icon: Icons.business_outlined, label: 'OEM', value: c.oemName.value),
              if (c.userEmail.value.isNotEmpty)
                _InfoRow(icon: Icons.email_outlined, label: 'Email', value: c.userEmail.value),
            ],
          )),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _kSub),
          const SizedBox(width: 6),
          Text('$label : ',
              style: const TextStyle(fontSize: 13, color: _kSub, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: _kText),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Stat Cards
// ════════════════════════════════════════════════════════════
class _StatCardsRow extends StatelessWidget {
  final DashboardController c;
  const _StatCardsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(child: _StatCard(label: 'Total', value: '${c.totalCount}', icon: Icons.bar_chart_rounded, color: _kOrange)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Flashed', value: '${c.totalPass.value}', icon: Icons.check_circle_outline, color: _kPass)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Failed', value: '${c.totalFail.value}', icon: Icons.cancel_outlined, color: _kFail)),
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: _kSub)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Charts Row
// ════════════════════════════════════════════════════════════
class _ChartsRow extends StatelessWidget {
  final DashboardController c;
  const _ChartsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ChartCard(title: 'Overall',
                child: SizedBox(height: 220, child: _DonutChart(pass: c.totalPass.value, fail: c.totalFail.value)))),
            const SizedBox(width: 16),
            Expanded(child: _ChartCard(title: 'Shift-wise',
                child: SizedBox(height: 220, child: _BarChart(
                    s1p: c.shift1Pass.value, s1f: c.shift1Fail.value,
                    s2p: c.shift2Pass.value, s2f: c.shift2Fail.value,
                    s3p: c.shift3Pass.value, s3f: c.shift3Fail.value)))),
          ],
        ));
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kText)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final int pass, fail;
  const _DonutChart({required this.pass, required this.fail});

  @override
  Widget build(BuildContext context) {
    final total = pass + fail;
    return Column(children: [
      Expanded(
        child: CustomPaint(
          painter: _DonutPainter(pass: pass, fail: fail),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$total', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _kText)),
            const Text('Total', style: TextStyle(fontSize: 12, color: _kSub)),
          ])),
        ),
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Dot(color: _kPass, label: 'Pass ($pass)'),
        const SizedBox(width: 16),
        _Dot(color: _kFail, label: 'Fail ($fail)'),
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
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 - 10;
    const sw = 32.0, start = -math.pi / 2;
    final pSweep = (pass / total) * 2 * math.pi;
    final fSweep = (fail / total) * 2 * math.pi;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(rect, start, pSweep, false,
        Paint()..color = _kPass ..style = PaintingStyle.stroke ..strokeWidth = sw ..strokeCap = StrokeCap.butt);
    canvas.drawArc(rect, start + pSweep, fSweep, false,
        Paint()..color = _kFail ..style = PaintingStyle.stroke ..strokeWidth = sw ..strokeCap = StrokeCap.butt);
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.pass != pass || o.fail != fail;
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 12, color: _kSub)),
  ]);
}

class _BarChart extends StatelessWidget {
  final int s1p, s1f, s2p, s2f, s3p, s3f;
  const _BarChart({required this.s1p, required this.s1f, required this.s2p,
      required this.s2f, required this.s3p, required this.s3f});

  @override
  Widget build(BuildContext context) {
    final max = [s1p, s1f, s2p, s2f, s3p, s3f].fold<int>(1, (a, b) => a > b ? a : b);
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
        _Dot(color: _kPass, label: 'Pass'),
        const SizedBox(width: 16),
        _Dot(color: _kFail, label: 'Fail'),
      ]),
    ]);
  }
}

class _ShiftGroup extends StatelessWidget {
  final String label;
  final int pass, fail, max;
  const _ShiftGroup({required this.label, required this.pass, required this.fail, required this.max});

  @override
  Widget build(BuildContext context) {
    const maxH = 130.0;
    double ph = max > 0 ? (pass / max) * maxH : 4;
    double fh = max > 0 ? (fail / max) * maxH : 4;
    if (ph < 4) ph = 4;
    if (fh < 4) fh = 4;
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _Bar(h: ph, color: _kPass, value: pass),
        const SizedBox(width: 4),
        _Bar(h: fh, color: _kFail, value: fail),
      ]),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: _kSub)),
    ]);
  }
}

class _Bar extends StatelessWidget {
  final double h;
  final Color color;
  final int value;
  const _Bar({required this.h, required this.color, required this.value});

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Text('$value', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Container(width: 20, height: h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
  ]);
}

// ════════════════════════════════════════════════════════════
//  Quick Actions
// ════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kText)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ActionCard(title: 'ECU Flashing', subtitle: 'Batch / Individual',
              icon: Icons.bolt_rounded, color: _kOrange, onTap: () => Get.toNamed('/flashingScreen'))),
          const SizedBox(width: 12),
          Expanded(child: _ActionCard(title: 'Reprint', subtitle: 'Reprint sticker',
              icon: Icons.print_outlined, color: const Color(0xFF8B5CF6), onTap: () => Get.toNamed('/reprint'))),
          const SizedBox(width: 12),
          Expanded(child: _ActionCard(title: 'Master Data', subtitle: 'Add / Edit',
              icon: Icons.edit_note_rounded, color: const Color(0xFF0EA5E9), onTap: () => Get.toNamed('/master-data'))),
        ]),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.title, required this.subtitle,
      required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kText)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: _kSub)),
          const SizedBox(height: 12),
          Row(children: [
            Text('Open', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(width: 3),
            Icon(Icons.arrow_forward_rounded, color: color, size: 13),
          ]),
        ]),
      ),
    );
  }
}
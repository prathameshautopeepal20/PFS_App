// lib/views/screens/dashboard/individual_flash_screen.dart
// Same world-class UI as home_page_screen.dart — batch design applied to individual flash

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/individual_flash_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';

// ── Palette (same as batch screen) ─────────────────────────
// Individual controller uses Colors.green/red/yellow (not custom consts)
const Color _icGreen  = Color(0xFF4CAF50); // Colors.green value
const Color _icRed    = Color(0xFFF44336); // Colors.red value
const Color _icYellow = Color(0xFFFFEB3B); // Colors.yellow value

const Color _bg        = Color(0xFF060C1A);
const Color _surface   = Color(0xFF0D1627);
const Color _card      = Color(0xFF0F1B2D);
const Color _border    = Color(0xFF1E2E45);
const Color _orange    = Color(0xFFF97316);
const Color _orangeD   = Color(0xFFEA580C);
const Color _orangeDD  = Color(0xFF9A3412);
const Color _orangeGlow= Color(0x40F97316);
const Color _pass      = Color(0xFF22C55E);
const Color _passGlow  = Color(0x3022C55E);
const Color _fail      = Color(0xFFEF4444);
const Color _failGlow  = Color(0x30EF4444);
const Color _yellow    = Color(0xFFF59E0B);
const Color _yellowGlow= Color(0x30F59E0B);
const Color _cyan      = Color(0xFF06B6D4);
const Color _blue      = Color(0xFF3B82F6);
const Color _w         = Color(0xFFFFFFFF);
const Color _w80       = Color(0xCCFFFFFF);
const Color _w60       = Color(0x99FFFFFF);
const Color _w40       = Color(0x66FFFFFF);
const Color _w20       = Color(0x33FFFFFF);
const Color _w10       = Color(0x1AFFFFFF);

const LinearGradient _gOrange = LinearGradient(
  colors: [_orange, _orangeD, _orangeDD],
  begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _gPass = LinearGradient(
  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _gBlue = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  begin: Alignment.topLeft, end: Alignment.bottomRight);
const LinearGradient _gProgress = LinearGradient(
  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  begin: Alignment.centerLeft, end: Alignment.centerRight);
const LinearGradient _gProgressDone = LinearGradient(
  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  begin: Alignment.centerLeft, end: Alignment.centerRight);

// ════════════════════════════════════════════════════════════
//  ENTRY POINT
// ════════════════════════════════════════════════════════════
class IndividualFlashScreen extends StatelessWidget {
  const IndividualFlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(IndividualFlashController(
      args: (Get.arguments as Map<String, dynamic>?) ?? {},
    ));
    return MainLayout(
      title: 'Individual ECU Flash',
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg, Color(0xFF080F1E)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Stack(children: [
          CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
          Column(children: [
            _ITopBar(controller: ctrl),
            const _ITableHeader(),
            Expanded(child: _ITableRows(controller: ctrl)),
            _IBottomBar(controller: ctrl),
          ]),
          Obx(() => ctrl.isLoading.value ? _ILoadingOverlay() : const SizedBox()),
          Obx(() => ctrl.showAlertPopup.value
              ? _IAlertPopup(controller: ctrl) : const SizedBox()),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TOP BAR
// ════════════════════════════════════════════════════════════
class _ITopBar extends StatelessWidget {
  final IndividualFlashController controller;
  const _ITopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final row   = controller.tableInfo.isNotEmpty ? controller.tableInfo.first : null;
    final sub   = row?.selectedSubModel;
    final model = row?.selectedModel;
    final ecuHw = (sub?.ecuSubmodel.isNotEmpty == true)
        ? (sub!.ecuSubmodel[0].ecu?.toString() ?? '—') : '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: _surface,
        border: const Border(bottom: BorderSide(color: _border)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [
        _IInfoCard(
          icon: Icons.directions_bike_rounded,
          label: 'MODEL',
          value: '${sub?.description ?? "—"}  /  ${model?.name ?? "—"}',
          accent: _orange),
        const SizedBox(width: 10),
        _IInfoCard(
          icon: Icons.memory_rounded,
          label: 'ECU HARDWARE',
          value: ecuHw,
          accent: _cyan),
      ]),
    );
  }

  IndividualFlashController get ctrl => controller;
}

class _IInfoCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color accent;
  const _IInfoCard({
    required this.icon, required this.label,
    required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: accent, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(
                fontSize: 9, color: accent,
                fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 2),
              Text(value,
                style: const TextStyle(
                  fontSize: 12, color: _w80, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            ])),
        ]),
      ),
    );
  }
}

class _ITableHeader extends StatelessWidget {
  const _ITableHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1525),
        border: Border(
          top:    BorderSide(color: _border),
          bottom: BorderSide(color: _orange, width: 1.5))),
      child: Row(children: [
        _ITH(w: 52,  label: '#'),            const _IDv(),
        _ITH(w: 58,  label: 'State'),        const _IDv(),
        Expanded(flex: 5, child: _ITH(label: 'Cal Id')),     const _IDv(),
        Expanded(flex: 4, child: _ITH(label: 'ECU Sr No.')), const _IDv(),
        Expanded(flex: 3, child: _ITH(label: 'SW Ver.')),    const _IDv(),
        Expanded(flex: 3, child: _ITH(label: 'CVN')),        const _IDv(),
        Expanded(flex: 3, child: _ITH(label: 'Part No.')),   const _IDv(),
        _ITH(w: 62,  label: 'Dongle'),       const _IDv(),
        _ITH(w: 58,  label: 'ECU'),          const _IDv(),
        Expanded(flex: 5, child: _ITH(label: 'Progress')),   const _IDv(),
        _ITH(w: 62,  label: 'Time'),         const _IDv(),
        _ITH(w: 88,  label: 'Status'),       const _IDv(),
        _ITH(w: 92,  label: 'Action'),
      ]),
    );
  }
}

class _ITH extends StatelessWidget {
  final String label;
  final double? w;
  const _ITH({required this.label, this.w});
  @override
  Widget build(BuildContext context) {
    final child = Center(child: Text(label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: _w60, fontWeight: FontWeight.w800,
        fontSize: 10, letterSpacing: 0.6)));
    return w != null ? SizedBox(width: w, child: child) : child;
  }
}

class _IDv extends StatelessWidget {
  const _IDv();
  @override
  Widget build(BuildContext context) => Container(width: 1, color: _border);
}

// ════════════════════════════════════════════════════════════
//  TABLE ROWS
// ════════════════════════════════════════════════════════════
class _ITableRows extends StatelessWidget {
  final IndividualFlashController controller;
  const _ITableRows({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Obx(() {
        if (controller.tableInfo.isEmpty) {
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: _orange.withOpacity(0.3), width: 2)),
                child: const Icon(Icons.radar_rounded, size: 40, color: _orange)),
              const SizedBox(height: 16),
              Obx(() => Text(
                controller.currStatus.value.isNotEmpty
                    ? controller.currStatus.value : 'No ECU registered',
                style: const TextStyle(fontSize: 15, color: _w60))),
              const SizedBox(height: 8),
              const Text('Connect dongle and press CHECK ECU STATUS',
                style: TextStyle(fontSize: 12, color: _w40)),
            ]));
        }
        return ListView.builder(
          itemCount: controller.tableInfo.length,
          itemBuilder: (_, i) => _IDataRow(
            device: controller.tableInfo[i],
            controller: controller,
            isEven: i % 2 == 0));
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  DATA ROW
// ════════════════════════════════════════════════════════════
class _IDataRow extends StatelessWidget {
  final IndividualRowModel device;
  final IndividualFlashController controller;
  final bool isEven;
  const _IDataRow({
    required this.device,
    required this.controller,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.tableInfo.indexWhere((x) => x.index == device.index);
      if (idx < 0) return const SizedBox.shrink();
      final d = controller.tableInfo[idx];

      final sc        = d.statusColor;
      final isPass    = sc == Colors.green  || sc == _icGreen;
      final isFail    = sc == Colors.red    || sc == _icRed;
      final isRunning = sc == Colors.yellow || sc == _icYellow;
      final rowAccent = isPass ? _pass : isFail ? _fail
          : isRunning ? _yellow : _border;
      final rowGlow   = isPass ? _passGlow : isFail ? _failGlow
          : isRunning ? _yellowGlow : Colors.transparent;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isEven ? _card : _surface,
          border: Border(
            bottom: BorderSide(color: _border, width: 0.8),
            left:   BorderSide(color: rowAccent, width: 2.5)),
          boxShadow: (isPass || isFail)
              ? [BoxShadow(color: rowGlow, blurRadius: 8)] : null),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // # badge
            SizedBox(width: 52, child: Center(child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: isPass ? _gPass
                    : isRunning
                        ? const LinearGradient(
                            colors: [_yellow, Color(0xFFD97706)])
                        : _gOrange,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: (isPass ? _pass : _orange).withOpacity(0.35),
                  blurRadius: 8)]),
              child: Center(child: Text('${d.srNo}',
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold,
                  color: _w)))))),
            const _IDv(),

            // Before / After
            SizedBox(width: 58, child: Column(children: [
              Expanded(child: Center(child: _IStatePill('Before', _w40, _w10))),
              Container(height: 0.8, color: _border),
              Expanded(child: Center(child: _IStatePill('After', _orange,
                _orangeGlow.withOpacity(0.15)))),
            ])),
            const _IDv(),

            // Cal Id
            Expanded(flex: 5, child: _IBACell(
              before: d.calIdBefore, after: d.printCalId,
              afterColor: isPass ? _pass : _orange)),
            const _IDv(),

            // ECU Sr No
            Expanded(flex: 4, child: _IBACell(
              before: d.ecuSrNo, after: d.ecuSrNoAfter,
              afterColor: isPass ? _pass : _orange)),
            const _IDv(),

            // SW Version
            Expanded(flex: 3, child: _IBACell(
              before: d.swVersionBefore, after: d.swVersionAfter,
              afterColor: isPass ? _pass : _orange)),
            const _IDv(),

            // CVN
            Expanded(flex: 3, child: _IBACell(
              before: d.cvnBefore, after: d.cvn,
              afterColor: isPass ? _pass : _orange)),
            const _IDv(),

            // Part No
            Expanded(flex: 3, child: Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                d.swPartNo.isNotEmpty ? d.swPartNo : '—',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: _w60),
                maxLines: 2, overflow: TextOverflow.ellipsis)))),
            const _IDv(),

            // Dongle indicator
            SizedBox(width: 62, child: Center(child: _IHwIndicator(
              on: d.dongleFlashingIndicator,
              icon: Icons.wifi_rounded, label: 'WiFi'))),
            const _IDv(),

            // ECU indicator
            SizedBox(width: 58, child: Center(child: _IHwIndicator(
              on: d.ecuFlashingIndicator,
              icon: Icons.memory_rounded, label: 'ECU'))),
            const _IDv(),

            // Progress
            Expanded(flex: 5, child: _IProgressCell(device: d)),
            const _IDv(),

            // Time
            SizedBox(width: 62, child: Center(
              child: _ITimeDisplay(time: d.flashTimer))),
            const _IDv(),

            // Status
            SizedBox(width: 88, child: Center(
              child: _IStatusBadge(color: d.statusColor))),
            const _IDv(),

            // Action
            SizedBox(width: 92, child: _IActionCell(
              device: d, controller: controller)),
          ]),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  PROGRESS BAR CELL
// ════════════════════════════════════════════════════════════
class _IProgressCell extends StatelessWidget {
  final IndividualRowModel device;
  const _IProgressCell({required this.device});

  @override
  Widget build(BuildContext context) {
    final pct    = device.progress.clamp(0.0, 1.0);
    final done   = pct >= 1.0;
    final active = device.isProgressVisible && pct > 0;
    final sc     = device.statusColor;
    final isPass = sc == Colors.green  || sc == _icGreen;
    final isFail = sc == Colors.red    || sc == _icRed;
    final showBar = device.isProgressVisible || done || isPass || isFail;

    final barGradient = (done && isPass)
        ? _gProgressDone
        : isFail
            ? const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
            : _gProgress;

    final glowColor = (done && isPass)
        ? _pass.withOpacity(0.4)
        : isFail
            ? _fail.withOpacity(0.35)
            : _cyan.withOpacity(0.35);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              showBar ? device.flashPercent : '—',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: done && isPass ? _pass
                    : isFail ? _fail
                    : active ? _cyan : _w40,
                letterSpacing: 0.5)),
            if (done && isPass)
              const Icon(Icons.check_circle_rounded, size: 12, color: _pass)
            else if (isFail)
              const Icon(Icons.cancel_rounded, size: 12, color: _fail),
          ]),
          const SizedBox(height: 4),

          Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1525),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _border, width: 0.8))),
            AnimatedFractionallySizedBox(
              widthFactor: pct,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: barGradient,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: active || done
                      ? [BoxShadow(color: glowColor, blurRadius: 6)] : null))),
            if (active && !done)
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor: pct,
                  alignment: Alignment.centerLeft,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 3, height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          blurRadius: 4)]))))),
          ]),
          const SizedBox(height: 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['0', '25%', '50%', '75%', '100%']
              .map((t) => Text(t, style: const TextStyle(
                  fontSize: 7, color: _w20)))
              .toList()),
        ],
      ),
    );
  }
}

// ── Small widgets ────────────────────────────────────────────
class _ITimeDisplay extends StatelessWidget {
  final String time;
  const _ITimeDisplay({required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1525),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border)),
      child: Text(time,
        style: const TextStyle(
          fontSize: 12, color: _w80,
          fontWeight: FontWeight.w700, letterSpacing: 1.0,
          fontFamily: 'monospace')));
  }
}

class _IActionCell extends StatelessWidget {
  final IndividualRowModel device;
  final IndividualFlashController controller;
  const _IActionCell({required this.device, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Center(
        child: _IMiniBtn(
          label: 'Flash',
          icon: Icons.bolt_rounded,
          enabled: !device.playButtonDisable,
          gradient: _gOrange,
          onTap: () => controller.startIndividualFlash(device)),
      ),
    );
  }
}

class _IMiniBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _IMiniBtn({required this.label, required this.icon,
    required this.enabled, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 26,
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          color: enabled ? null : _border,
          borderRadius: BorderRadius.circular(6),
          boxShadow: enabled ? [BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 6, offset: const Offset(0, 2))] : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _w, size: 12),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(
            fontSize: 10, color: _w, fontWeight: FontWeight.w800)),
        ])));
  }
}

class _IStatePill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _IStatePill(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: TextStyle(
        fontSize: 8.5, color: color,
        fontWeight: FontWeight.w800, letterSpacing: 0.4)));
  }
}

class _IBACell extends StatelessWidget {
  final String before, after;
  final Color afterColor;
  const _IBACell({required this.before, required this.after,
    this.afterColor = _orange});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(before.isNotEmpty ? before : '—',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9.5, color: _w60),
          maxLines: 1, overflow: TextOverflow.ellipsis)))),
      Container(height: 0.8, color: _border),
      Expanded(child: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(after.isNotEmpty ? after : '—',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9.5, color: afterColor,
            fontWeight: FontWeight.w700),
          maxLines: 1, overflow: TextOverflow.ellipsis)))),
    ]);
  }
}

class _IHwIndicator extends StatelessWidget {
  final bool on;
  final IconData icon;
  final String label;
  const _IHwIndicator({required this.on, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final c    = on ? _pass : const Color(0xFF374151);
    final glow = on ? _passGlow : Colors.transparent;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: on ? c : _border, width: 1.5),
            boxShadow: on ? [BoxShadow(color: glow, blurRadius: 8)] : null),
          child: Icon(icon, size: 15, color: on ? c : _w40)),
        const SizedBox(height: 2),
        Text(on ? 'ON' : 'OFF',
          style: TextStyle(
            fontSize: 7.5, color: on ? c : _w40,
            fontWeight: FontWeight.w900, letterSpacing: 0.6)),
      ]);
  }
}

class _IStatusBadge extends StatelessWidget {
  final Color color;
  const _IStatusBadge({required this.color});
  @override
  Widget build(BuildContext context) {
    final isPass    = color == Colors.green  || color == _icGreen;
    final isFail    = color == Colors.red    || color == _icRed;
    final isRunning = color == Colors.yellow || color == _icYellow;
    final Color bc;
    final IconData ico;
    final String lbl;
    final LinearGradient grad;
    if (isPass) {
      bc = _pass; ico = Icons.check_circle_rounded;
      lbl = 'PASS'; grad = _gPass;
    } else if (isFail) {
      bc = _fail; ico = Icons.cancel_rounded; lbl = 'FAIL';
      grad = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
    } else if (isRunning) {
      bc = _yellow; ico = Icons.sync_rounded; lbl = 'RUN';
      grad = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
    } else {
      bc = _w40; ico = Icons.remove_rounded; lbl = 'IDLE';
      grad = const LinearGradient(
        colors: [Color(0xFF1E2E45), Color(0xFF1E2E45)]);
    }
    final idle = !isPass && !isFail && !isRunning;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: idle ? null : grad,
        color: idle ? _w10 : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: idle ? _border : bc.withOpacity(0.4), width: 1),
        boxShadow: idle ? null
            : [BoxShadow(color: bc.withOpacity(0.3), blurRadius: 10)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ico, size: 10, color: _w),
        const SizedBox(width: 4),
        Text(lbl, style: const TextStyle(
          fontSize: 9, fontWeight: FontWeight.w900,
          color: _w, letterSpacing: 0.8)),
      ]));
  }
}

// ════════════════════════════════════════════════════════════
//  BOTTOM BAR
// ════════════════════════════════════════════════════════════
class _IBottomBar extends StatelessWidget {
  final IndividualFlashController controller;
  const _IBottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: const Border(top: BorderSide(color: _border)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 16, offset: const Offset(0, -4))]),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Obx(() => controller.currStatus.value.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _orange.withOpacity(0.12),
                    _orange.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _orange.withOpacity(0.3))),
                child: Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: _orange, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: _orange.withOpacity(0.5), blurRadius: 4)])),
                  const SizedBox(width: 8),
                  Expanded(child: Text(controller.currStatus.value,
                    style: const TextStyle(
                      color: _orange, fontSize: 12,
                      fontWeight: FontWeight.w500))),
                ]))
            : const SizedBox()),

        Row(children: [
          _IActionBtn(
            label: 'CHECK ECU STATUS',
            icon: Icons.radar_rounded,
            enabled: true,
            gradient: _gBlue,
            onTap: controller.checkEcuStatus),
          const Spacer(),
          _IActionBtn(
            label: 'FLASH ALL',
            icon: Icons.bolt_rounded,
            enabled: true,
            gradient: _gOrange,
            onTap: controller.startAllFlash),
        ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ACTION BUTTON
// ════════════════════════════════════════════════════════════
class _IActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _IActionBtn({required this.label, required this.icon,
    required this.enabled, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          color: enabled ? null : _border,
          borderRadius: BorderRadius.circular(9),
          boxShadow: enabled ? [BoxShadow(
            color: gradient.colors.first.withOpacity(0.35),
            blurRadius: 12, offset: const Offset(0, 3))] : null),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _w, size: 15),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w900,
            color: _w, letterSpacing: 0.5)),
        ])));
  }
}

// ════════════════════════════════════════════════════════════
//  LOADING OVERLAY
// ════════════════════════════════════════════════════════════
class _ILoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC060C1A),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: _surface,
            shape: BoxShape.circle,
            border: Border.all(color: _orange, width: 2),
            boxShadow: [BoxShadow(color: _orangeGlow, blurRadius: 20)]),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(color: _orange, strokeWidth: 3))),
        const SizedBox(height: 16),
        const Text('Loading...', style: TextStyle(
          color: _w60, fontSize: 14, fontWeight: FontWeight.w600)),
      ])));
  }
}

// ════════════════════════════════════════════════════════════
//  ALERT POPUP
// ════════════════════════════════════════════════════════════
class _IAlertPopup extends StatelessWidget {
  final IndividualFlashController controller;
  const _IAlertPopup({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC060C1A),
      child: Center(
        child: Container(
          width: 360,
          constraints: const BoxConstraints(maxHeight: 360),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 32)]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              decoration: const BoxDecoration(
                gradient: _gOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16))),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: _w, size: 20),
                SizedBox(width: 10),
                Text('Alert', style: TextStyle(
                  color: _w, fontSize: 15, fontWeight: FontWeight.bold)),
              ])),
            Flexible(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Expanded(child: Obx(() => SingleChildScrollView(
                  child: Text(controller.popupMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: _w60))))),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: controller.onOkPopup,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: _gOrange,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [BoxShadow(
                        color: _orangeGlow, blurRadius: 12,
                        offset: const Offset(0, 3))]),
                    child: const Center(child: Text('OK',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900,
                        color: _w, letterSpacing: 0.3))))),
              ]))),
          ]))));
  }
}

// ════════════════════════════════════════════════════════════
//  GRID PAINTER
// ════════════════════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08FFFFFF)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
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
// lib/views/screens/dashboard/home_page_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/home_page_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';

// Controller color constants — must match home_page_controller.dart exactly
const Color _cGreen = Color(0xFF4CAF50);
const Color _cRed = Color(0xFFF44336);
const Color _cYellow = Color(0xFFFFEB3B);
const Color _cWhite = Color(0xFFFFFFFF);
const Color _bg = Color(0xFF060C1A);
const Color _surface = Color(0xFF0D1627);
const Color _card = Color(0xFF0F1B2D);
const Color _border = Color(0xFF1E2E45);
const Color _orange = Color(0xFFF97316);
const Color _orangeD = Color(0xFFEA580C);
const Color _orangeDD = Color(0xFF9A3412);
const Color _orangeGlow = Color(0x40F97316);
const Color _pass = Color(0xFF22C55E);
const Color _passGlow = Color(0x3022C55E);
const Color _fail = Color(0xFFEF4444);
const Color _failGlow = Color(0x30EF4444);
const Color _yellow = Color(0xFFF59E0B);
const Color _yellowGlow = Color(0x30F59E0B);
const Color _cyan = Color(0xFF06B6D4);
const Color _w = Color(0xFFFFFFFF);
const Color _w80 = Color(0xCCFFFFFF);
const Color _w60 = Color(0x99FFFFFF);
const Color _w40 = Color(0x66FFFFFF);
const Color _w20 = Color(0x33FFFFFF);
const Color _w10 = Color(0x1AFFFFFF);

// ── Gradients ──────────────────────────────────────────────
const LinearGradient _gOrange = LinearGradient(
  colors: [_orange, _orangeD, _orangeDD],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient _gPass = LinearGradient(
  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient _gBlue = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const LinearGradient _gProgress = LinearGradient(
  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
const LinearGradient _gProgressDone = LinearGradient(
  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ════════════════════════════════════════════════════════════
//  ENTRY POINT
// ════════════════════════════════════════════════════════════
class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(
      HomePageController(args: (Get.arguments as Map<String, dynamic>?) ?? {}),
    );
    return MainLayout(
      title: 'ECU Flash System',
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg, Color(0xFF080F1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: _GridPainter(),
              child: const SizedBox.expand(),
            ),
            Column(
              children: [
                _TopBar(controller: ctrl),
                _AutoDetectRow(controller: ctrl),
                const _TableHeader(),
                Expanded(child: _TableRows(controller: ctrl)),
                _BottomBar(controller: ctrl),
              ],
            ),
            Obx(
              () => ctrl.isLoading.value ? _LoadingOverlay() : const SizedBox(),
            ),
            Obx(
              () => ctrl.showAlertPopup.value
                  ? _AlertPopup(controller: ctrl)
                  : const SizedBox(),
            ),
            Obx(
              () => ctrl.showChangePopup.value
                  ? _ChangePopup(controller: ctrl)
                  : const SizedBox(),
            ),
            Obx(
              () => ctrl.showPrintPopup.value
                  ? _InfoPopup(message: ctrl.popupMessage.value)
                  : const SizedBox(),
            ),
            Obx(
              () => ctrl.showWaitPopup.value
                  ? _WaitPopup(seconds: ctrl.afterFlashSeconds.value)
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  TOP BAR
// ════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final HomePageController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final sub = controller.selectedSubModel;
    final model = controller.selectedModel;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: _surface,
        border: const Border(bottom: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _TopInfoCard(
            icon: Icons.directions_bike_rounded,
            label: 'MODEL',
            value: '${sub?.description ?? "—"}  /  ${model?.name ?? "—"}',
            accent: _orange,
          ),
          const SizedBox(width: 10),

          _TopInfoCard(
            icon: Icons.memory_rounded,
            label: 'ECU HARDWARE',
            value: (sub?.ecuSubmodel.isNotEmpty == true)
                ? (sub!.ecuSubmodel[0].ecu?.toString() ?? '—')
                : '—',
            accent: _cyan,
          ),
          const SizedBox(width: 12),
          _FindDongleBtn(controller: controller),
          const SizedBox(width: 8),
          Obx(
            () => _ActionBtn(
              label: 'Reset Dongle',
              icon: Icons.refresh_rounded,
              enabled: controller.isResetDongleEnabled.value,
              gradient: _gBlue,
              onTap: controller.resetDongle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color accent;
  const _TopInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _w80,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auto-detect banner ──────────────────────────────────────
class _AutoDetectRow extends StatelessWidget {
  final HomePageController controller;
  const _AutoDetectRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final scanning = controller.isAutoScanning.value;
      final status = controller.autoScanStatus.value;
      if (!scanning && status.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          border: const Border(bottom: BorderSide(color: _border)),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated scan indicator
            if (scanning) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: _orange,
                  strokeWidth: 2.5,
                  backgroundColor: _orange.withOpacity(0.15),
                ),
              ),
            ] else ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _pass,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _passGlow, blurRadius: 6)],
                ),
              ),
            ],
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scanning ? 'AUTO SCANNING IN PROGRESS' : 'ECU DETECTED',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: scanning ? _orange : _pass,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _w60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scanning
                    ? _orange.withOpacity(0.12)
                    : _pass.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scanning
                      ? _orange.withOpacity(0.4)
                      : _pass.withOpacity(0.4),
                ),
              ),
              child: Text(
                scanning ? 'DO NOT PRESS BUTTONS' : 'AUTO CHECK RUNNING',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: scanning ? _orange : _pass,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  TABLE HEADER
// ════════════════════════════════════════════════════════════
class _TableHeader extends StatelessWidget {
  const _TableHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFF0A1525),
        border: Border(
          top: BorderSide(color: _border),
          bottom: BorderSide(color: _orange, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          _TH(w: 52, label: '#'),
          const _Dv(),
          _TH(w: 58, label: 'State'),
          const _Dv(),
          Expanded(flex: 5, child: _TH(label: 'Cal Id')),
          const _Dv(),
          Expanded(flex: 4, child: _TH(label: 'ECU Sr No.')),
          const _Dv(),
          Expanded(flex: 3, child: _TH(label: 'SW Ver.')),
          const _Dv(),
          Expanded(flex: 3, child: _TH(label: 'CVN')),
          const _Dv(),
          Expanded(flex: 3, child: _TH(label: 'Part No.')),
          const _Dv(),
          _TH(w: 62, label: 'Dongle'),
          const _Dv(),
          _TH(w: 58, label: 'ECU'),
          const _Dv(),
          Expanded(flex: 5, child: _TH(label: 'Progress')),
          const _Dv(),
          _TH(w: 62, label: 'Time'),
          const _Dv(),
          _TH(w: 88, label: 'Status'),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  final double? w;
  const _TH({required this.label, this.w});
  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _w60,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      ),
    );
    return w != null ? SizedBox(width: w, child: child) : child;
  }
}

class _Dv extends StatelessWidget {
  const _Dv();
  @override
  Widget build(BuildContext context) => Container(width: 1, color: _border);
}

// ════════════════════════════════════════════════════════════
//  TABLE ROWS
// ════════════════════════════════════════════════════════════
class _TableRows extends StatelessWidget {
  final HomePageController controller;
  const _TableRows({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: Obx(() {
        if (controller.tableInfo.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _orange.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    size: 40,
                    color: _orange,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Text(
                    controller.currStatus.value.isNotEmpty
                        ? controller.currStatus.value
                        : 'No ECU registered',
                    style: const TextStyle(fontSize: 15, color: _w60),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect dongle and press CHECK ECU STATUS',
                  style: TextStyle(fontSize: 12, color: _w40),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.tableInfo.length,
          itemBuilder: (_, i) => _DataRow(
            device: controller.tableInfo[i],
            controller: controller,
            isEven: i % 2 == 0,
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  DATA ROW
// ════════════════════════════════════════════════════════════
class _DataRow extends StatelessWidget {
  final TableInfoModel device;
  final HomePageController controller;
  final bool isEven;
  const _DataRow({
    required this.device,
    required this.controller,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access the item directly by index from the RxList — this ensures
      // the widget rebuilds whenever tableInfo.refresh() is called, which
      // the controller calls after every statusColor/progress/flashPercent
      // field update. tableInfo.toString() and tableInfo.length both fail
      // because TableInfoModel has no Rx fields and no custom toString().
      final idx = controller.tableInfo.indexWhere(
        (x) => x.index == device.index,
      );
      if (idx < 0) return const SizedBox.shrink();
      final d = controller.tableInfo[idx];

      final sc = d.statusColor;
      final isPass = sc == _cGreen;
      final isFail = sc == _cRed;
      final isRunning = sc == _cYellow;
      final rowAccent = isPass
          ? _pass
          : isFail
          ? _fail
          : isRunning
          ? _yellow
          : _border;
      final rowGlow = isPass
          ? _passGlow
          : isFail
          ? _failGlow
          : isRunning
          ? _yellowGlow
          : Colors.transparent;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isEven ? _card : _surface,
          border: Border(
            bottom: BorderSide(color: _border, width: 0.8),
            left: BorderSide(color: rowAccent, width: 2.5),
          ),
          boxShadow: (isPass || isFail)
              ? [BoxShadow(color: rowGlow, blurRadius: 8)]
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // # badge
              SizedBox(
                width: 52,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: isPass
                          ? _gPass
                          : isRunning
                          ? const LinearGradient(
                              colors: [_yellow, Color(0xFFD97706)],
                            )
                          : _gOrange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isPass ? _pass : _orange).withOpacity(0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${d.srNo}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const _Dv(),

              // Before / After
              SizedBox(
                width: 58,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(child: _StatePill('Before', _w40, _w10)),
                    ),
                    Container(height: 0.8, color: _border),
                    Expanded(
                      child: Center(
                        child: _StatePill(
                          'After',
                          _orange,
                          _orangeGlow.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _Dv(),

              Expanded(
                flex: 5,
                child: _BACell(
                  before: d.calIdBefore,
                  after: d.printCalId,
                  afterColor: isPass ? _pass : _orange,
                ),
              ),
              const _Dv(),

              Expanded(
                flex: 4,
                child: _BACell(
                  before: d.ecuSrNo,
                  after: d.ecuSrNoAfter,
                  afterColor: isPass ? _pass : _orange,
                ),
              ),
              const _Dv(),

              Expanded(
                flex: 3,
                child: _BACell(
                  before: d.swVersionBefore,
                  after: d.swVersionAfter,
                  afterColor: isPass ? _pass : _orange,
                ),
              ),
              const _Dv(),

              Expanded(
                flex: 3,
                child: _BACell(
                  before: d.cvnBefore,
                  after: d.cvn,
                  afterColor: isPass ? _pass : _orange,
                ),
              ),
              const _Dv(),

              Expanded(
                flex: 3,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      d.swPartNo.isNotEmpty ? d.swPartNo : '—',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, color: _w60),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const _Dv(),

              SizedBox(
                width: 62,
                child: Center(
                  child: _HwIndicator(
                    on: d.dongleFlashingIndicator,
                    icon: Icons.wifi_rounded,
                    label: 'WiFi',
                  ),
                ),
              ),
              const _Dv(),

              SizedBox(
                width: 58,
                child: Center(
                  child: _HwIndicator(
                    on: d.ecuFlashingIndicator,
                    icon: Icons.memory_rounded,
                    label: 'ECU',
                  ),
                ),
              ),
              const _Dv(),

              Expanded(
                flex: 5,
                child: _ProgressCell(device: d, controller: controller),
              ),
              const _Dv(),

              SizedBox(
                width: 62,
                child: Center(child: _TimeDisplay(time: d.flashTimer)),
              ),
              const _Dv(),

              SizedBox(
                width: 88,
                child: Center(child: _StatusBadge(color: d.statusColor)),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  PROGRESS BAR CELL
// ════════════════════════════════════════════════════════════
class _ProgressCell extends StatelessWidget {
  final TableInfoModel device;
  final HomePageController controller;
  const _ProgressCell({required this.device, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pct = device.progress.clamp(0.0, 1.0);
    final done = pct >= 1.0;
    final active = device.isProgressVisible && pct > 0;
    final sc = device.statusColor;
    final isPass = sc == _cGreen;
    final isFail = sc == _cRed;

    // Show bar if actively flashing OR if done (pass/fail) — never hide on completion
    final showBar = device.isProgressVisible || done || isPass || isFail;
    final barGradient = (done && isPass)
        ? _gProgressDone
        : isFail
        ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
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
          // Percentage + icon row — show when flashing or done
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showBar ? device.flashPercent : '—',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: done && isPass
                      ? _pass
                      : isFail
                      ? _fail
                      : active
                      ? _cyan
                      : _w40,
                  letterSpacing: 0.5,
                ),
              ),
              if (done && isPass)
                const Icon(Icons.check_circle_rounded, size: 12, color: _pass)
              else if (isFail)
                const Icon(Icons.cancel_rounded, size: 12, color: _fail),
            ],
          ),
          const SizedBox(height: 4),

          // Progress track — always visible
          Stack(
            children: [
              // Background track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1525),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _border, width: 0.8),
                ),
              ),

              // Fill
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
                        ? [BoxShadow(color: glowColor, blurRadius: 6)]
                        : null,
                  ),
                ),
              ),

              // White spark tip
              if (active && !done)
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: pct,
                    alignment: Alignment.centerLeft,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 3,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),

          // Tick marks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['0', '25%', '50%', '75%', '100%']
                .map(
                  (t) =>
                      Text(t, style: const TextStyle(fontSize: 7, color: _w20)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────
class _TimeDisplay extends StatelessWidget {
  final String time;
  const _TimeDisplay({required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1525),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _border),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          color: _w80,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  final TableInfoModel device;
  final HomePageController controller;
  const _ActionCell({required this.device, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (device.playButtonVisible) ...[
            _MiniBtn(
              label: 'Flash',
              icon: Icons.bolt_rounded,
              enabled: !device.playButtonDisable,
              gradient: _gOrange,
              onTap: () => controller.startIndividualFlash(device),
            ),
            const SizedBox(height: 4),
          ],
          _MiniBtn(
            label: 'Print',
            icon: Icons.print_rounded,
            enabled: !device.printButtonDisable,
            gradient: _gPass,
            onTap: () => controller.printSticker(device),
          ),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _MiniBtn({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.gradient,
    required this.onTap,
  });
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
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _w, size: 12),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _w,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _StatePill(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BACell extends StatelessWidget {
  final String before, after;
  final Color afterColor;
  const _BACell({
    required this.before,
    required this.after,
    this.afterColor = _orange,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                before.isNotEmpty ? before : '—',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9.5, color: _w60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        Container(height: 0.8, color: _border),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                after.isNotEmpty ? after : '—',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  color: afterColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HwIndicator extends StatelessWidget {
  final bool on;
  final IconData icon;
  final String label;
  const _HwIndicator({
    required this.on,
    required this.icon,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final c = on ? _pass : const Color(0xFF374151);
    final glow = on ? _passGlow : Colors.transparent;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: on ? c : _border, width: 1.5),
            boxShadow: on ? [BoxShadow(color: glow, blurRadius: 8)] : null,
          ),
          child: Icon(icon, size: 15, color: on ? c : _w40),
        ),
        const SizedBox(height: 2),
        Text(
          on ? 'ON' : 'OFF',
          style: TextStyle(
            fontSize: 7.5,
            color: on ? c : _w40,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  const _StatusBadge({required this.color});
  @override
  Widget build(BuildContext context) {
    // Controller sets: Colors.green=Pass, Colors.red=Fail,
    // Colors.yellow=Running, Colors.white=Idle
    final isPass = color == _cGreen;
    final isFail = color == _cRed;
    final isRunning = color == _cYellow;
    final Color bc;
    final IconData ico;
    final String lbl;
    final LinearGradient grad;
    if (isPass) {
      bc = _pass;
      ico = Icons.check_circle_rounded;
      lbl = 'PASS';
      grad = _gPass;
    } else if (isFail) {
      bc = _fail;
      ico = Icons.cancel_rounded;
      lbl = 'FAIL';
      grad = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      );
    } else if (isRunning) {
      bc = _yellow;
      ico = Icons.sync_rounded;
      lbl = 'RUN';
      grad = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      );
    } else {
      bc = _w40;
      ico = Icons.remove_rounded;
      lbl = 'IDLE';
      grad = const LinearGradient(
        colors: [Color(0xFF1E2E45), Color(0xFF1E2E45)],
      );
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
          color: idle ? _border : bc.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: idle
            ? null
            : [BoxShadow(color: bc.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ico, size: 10, color: _w),
          const SizedBox(width: 4),
          Text(
            lbl,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: _w,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  BOTTOM BAR
// ════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final HomePageController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: const Border(top: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => controller.currStatus.value.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _orange.withOpacity(0.12),
                          _orange.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _orange.withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.currStatus.value,
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),

          Row(
            children: [
              Obx(() {
                // Hide completely while auto scan is active — prevents interference
                if (controller.isAutoScanning.value)
                  return const SizedBox.shrink();
                return _ActionBtn(
                  label: 'CHECK ECU STATUS',
                  icon: Icons.radar_rounded,
                  enabled: controller.checkEcuStatusButton.value,
                  gradient: _gBlue,
                  onTap: controller.checkEcuStatus,
                );
              }),
              const Spacer(),
              Obx(
                () => controller.flashingButtonVisible.value
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _ActionBtn(
                          label: 'START FLASH ALL',
                          icon: Icons.bolt_rounded,
                          enabled: !controller.startFlashButtonDisable.value,
                          gradient: _gOrange,
                          onTap: controller.startFlash,
                        ),
                      )
                    : const SizedBox(),
              ),
              Obx(
                () => _ActionBtn(
                  label: 'RESET',
                  icon: Icons.refresh_rounded,
                  enabled: !controller.startResetButtonDisable.value,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
                  ),
                  onTap: controller.reset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  FIND DONGLE BUTTON
// ════════════════════════════════════════════════════════════
class _FindDongleBtn extends StatelessWidget {
  final HomePageController controller;
  const _FindDongleBtn({required this.controller});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DongleScanDialog(controller: controller),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: _orange, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: _orange.withOpacity(0.06),
          boxShadow: [BoxShadow(color: _orangeGlow, blurRadius: 8)],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_find_rounded, color: _orange, size: 15),
            SizedBox(width: 6),
            Text(
              'Find Dongle',
              style: TextStyle(
                color: _orange,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ACTION BUTTON
// ════════════════════════════════════════════════════════════
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.gradient,
    required this.onTap,
  });
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
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _w, size: 15),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: _w,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LOADING OVERLAY
// ════════════════════════════════════════════════════════════
class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC060C1A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _orange, width: 2),
                boxShadow: [BoxShadow(color: _orangeGlow, blurRadius: 20)],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: _orange,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(
                color: _w60,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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

// ════════════════════════════════════════════════════════════
//  DONGLE SCAN DIALOG
// ════════════════════════════════════════════════════════════
class _DongleScanDialog extends StatefulWidget {
  final HomePageController controller;
  const _DongleScanDialog({required this.controller});
  @override
  State<_DongleScanDialog> createState() => _DongleScanDialogState();
}

class _DongleScanDialogState extends State<_DongleScanDialog> {
  List<String> _foundIPs = [];
  bool _scanning = false;
  bool _done = false;
  double _progress = 0.0;
  String _status = 'Starting scan...';

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    if (!mounted) return;
    setState(() {
      _scanning = true;
      _done = false;
      _foundIPs = [];
      _progress = 0;
      _status = 'Getting WiFi info...';
    });
    try {
      final ifaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      String? subnet;
      for (final iface in ifaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('127.')) continue;
          final parts = ip.split('.');
          if (parts.length == 4) {
            subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
            break;
          }
        }
        if (subnet != null) break;
      }
      if (subnet == null) {
        if (!mounted) return;
        setState(() {
          _status = 'WiFi not detected. Check connection.';
          _scanning = false;
          _done = true;
        });
        return;
      }
      if (!mounted) return;
      setState(() => _status = 'Scanning $subnet.1–254 on port 6888...');
      final found = <String>[];
      final sub = subnet;
      for (int start = 1; start <= 254; start += 20) {
        if (!mounted) return;
        final end = (start + 19).clamp(1, 254);
        final futures = <Future<String?>>[];
        for (int i = start; i <= end; i++) {
          final ip = '$sub.$i';
          futures.add(() async {
            try {
              final s = await Socket.connect(
                ip,
                6888,
                timeout: const Duration(milliseconds: 400),
              );
              s.destroy();
              return ip;
            } catch (_) {
              return null;
            }
          }());
        }
        final results = await Future.wait(futures);
        for (final ip in results) {
          if (ip != null) {
            found.add(ip);
            if (mounted) setState(() => _foundIPs = List.from(found));
          }
        }
        if (mounted) {
          setState(() {
            _progress = end / 254;
            _status =
                'Scanning... ${(_progress * 100).toInt()}%'
                '  —  Found: ${found.length}';
          });
        }
      }
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _done = true;
        _foundIPs = found;
        _status = found.isEmpty
            ? 'No dongles found on port 6888'
            : '✅ Found ${found.length} dongle(s) on $sub.x';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _done = true;
        _status = 'Scan error: $e';
      });
    }
  }

  void _selectIP(String ip) {
    Navigator.of(context).pop();
    Get.snackbar(
      '✅ Dongle Found',
      'IP: $ip  ·  Port 6888',
      backgroundColor: _pass,
      colorText: _w,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 440,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: _gOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.wifi_find_rounded, color: _w, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Scanning for Dongles',
                      style: TextStyle(
                        color: _w,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!_scanning)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _w,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_scanning)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: _orange,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Icon(
                          _foundIPs.isEmpty
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_rounded,
                          color: _foundIPs.isEmpty ? _fail : _pass,
                          size: 14,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _status,
                          style: const TextStyle(color: _w60, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Progress bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1525),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _border, width: 0.8),
                        ),
                      ),
                      AnimatedFractionallySizedBox(
                        widthFactor: _scanning ? _progress : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _scanning ? _gProgress : _gProgressDone,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: _cyan.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(color: _w40, fontSize: 10),
                  ),
                  const SizedBox(height: 14),

                  if (_done) ...[
                    if (_foundIPs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _fail.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _fail.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No dongles found on port 6888.',
                              style: TextStyle(
                                color: _fail,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Dongle powered ON (LED blinking)',
                              style: TextStyle(color: _w40, fontSize: 11),
                            ),
                            Text(
                              '• Same WiFi network as laptop',
                              style: TextStyle(color: _w40, fontSize: 11),
                            ),
                            Text(
                              '• Port 6888 not blocked by firewall',
                              style: TextStyle(color: _w40, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Text(
                        '${_foundIPs.length} Dongle(s) — tap to copy:',
                        style: const TextStyle(
                          color: _pass,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._foundIPs.map(
                        (ip) => GestureDetector(
                          onTap: () => _selectIP(ip),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _orange),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _orange.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _orange,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.usb_rounded,
                                    color: _orange,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ip,
                                        style: const TextStyle(
                                          color: _w,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const Text(
                                        'Port 6888 · Responding ✅',
                                        style: TextStyle(
                                          color: _w40,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.copy_rounded,
                                  color: _orange,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],

                  Row(
                    children: [
                      if (_done) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: _startScan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(color: _orange, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: _orange,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Rescan',
                                    style: TextStyle(
                                      color: _orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _border,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: _w60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

// ════════════════════════════════════════════════════════════
//  POPUPS
// ════════════════════════════════════════════════════════════
class _AlertPopup extends StatelessWidget {
  final HomePageController controller;
  const _AlertPopup({required this.controller});
  @override
  Widget build(BuildContext context) {
    return _Shell(
      icon: Icons.warning_amber_rounded,
      title: 'Alert',
      child: Column(
        children: [
          Expanded(
            child: Obx(
              () => SingleChildScrollView(
                child: Text(
                  controller.popupMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _w60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Btn(label: 'OK', onTap: controller.onOkPopup),
        ],
      ),
    );
  }
}

class _ChangePopup extends StatelessWidget {
  final HomePageController controller;
  const _ChangePopup({required this.controller});
  @override
  Widget build(BuildContext context) {
    return _Shell(
      icon: Icons.swap_horiz_rounded,
      title: 'ECU Already Flashed',
      child: Column(
        children: [
          Expanded(
            child: Obx(
              () => SingleChildScrollView(
                child: Text(
                  controller.popupMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _w60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Btn(label: 'Reflash', onTap: controller.onReflash),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Btn(
                  label: 'Change ECU',
                  onTap: controller.onChangeECU,
                  outlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPopup extends StatelessWidget {
  final String message;
  const _InfoPopup({required this.message});
  @override
  Widget build(BuildContext context) {
    return _Shell(
      icon: Icons.print_rounded,
      title: 'Print Sticker',
      child: Expanded(
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _w60),
          ),
        ),
      ),
    );
  }
}

class _WaitPopup extends StatelessWidget {
  final int seconds;
  const _WaitPopup({required this.seconds});
  @override
  Widget build(BuildContext context) {
    return _Shell(
      icon: Icons.hourglass_top_rounded,
      title: 'Please Wait',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _gOrange,
              boxShadow: [BoxShadow(color: _orangeGlow, blurRadius: 16)],
            ),
            child: Center(
              child: Text(
                '$seconds',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _w,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'seconds remaining',
            style: TextStyle(fontSize: 13, color: _w60),
          ),
        ],
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Shell({required this.icon, required this.title, required this.child});
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
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 32)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: _gOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: _w, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: _w,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(padding: const EdgeInsets.all(20), child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  const _Btn({required this.label, required this.onTap, this.outlined = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: outlined ? null : _gOrange,
          border: outlined ? Border.all(color: _orange, width: 1.5) : null,
          borderRadius: BorderRadius.circular(9),
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: _orangeGlow,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: outlined ? _orange : _w,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

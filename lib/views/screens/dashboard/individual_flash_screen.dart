// lib/views/screens/dashboard/individual_flash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/individual_flash_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';

const Color _cBg      = Color(0xFF0F172A);
const Color _cSurface = Color(0xFF1E293B);
const Color _cSurface2= Color(0xFF243044);
const Color _cBorder  = Color(0xFF2D3F55);
const Color _cOrange  = Color(0xFFF97316);
const Color _cOrangD  = Color(0xFFEA580C);
const Color _cOrangDD = Color(0xFF9A3412);
const Color _cWhite   = Color(0xFFFFFFFF);
const Color _cWhite70 = Color(0xB3FFFFFF);
const Color _cWhite40 = Color(0x66FFFFFF);
const Color _cWhite15 = Color(0x26FFFFFF);
const Color _cPass    = Color(0xFF22C55E);
const Color _cFail    = Color(0xFFEF4444);
const Color _cYellow  = Color(0xFFF59E0B);

class IndividualFlashScreen extends StatelessWidget {
  const IndividualFlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      IndividualFlashController(
        args: (Get.arguments as Map<String, dynamic>?) ?? {},
      ),
    );
    return MainLayout(
      title: 'Individual ECU Flashing',
      child: Container(
        color: _cBg,
        child: Stack(children: [
          Column(children: [
            const _TableHeader(),
            Expanded(child: _TableRows(controller: controller)),
            _BottomBar(controller: controller),
          ]),
          // Loading overlay
          Obx(() => controller.isLoading.value
              ? Container(
                  color: const Color(0xB3000000),
                  child: Center(child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_cSurface, _cSurface2]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _cBorder)),
                    child: const CircularProgressIndicator(color: _cOrange))))
              : const SizedBox()),
          // Alert popup
          Obx(() => controller.showAlertPopup.value
              ? _AlertPopup(controller: controller)
              : const SizedBox()),
        ]),
      ),
    );
  }
}

// ── Table Header ──────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  const _TableHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2540), Color(0xFF1E2D4A)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter),
        border: Border(
          top: BorderSide(color: _cOrange, width: 2.5),
          bottom: BorderSide(color: _cBorder))),
      child: Row(children: [
        _TH(width: 46,  label: '#'),               _Dv(),
        _TH(width: 52,  label: 'State'),            _Dv(),
        Expanded(flex: 5, child: _TH(label: 'Cal Id')),       _Dv(),
        Expanded(flex: 4, child: _TH(label: 'ECU Sr No.')),   _Dv(),
        Expanded(flex: 3, child: _TH(label: 'SW Ver.')),      _Dv(),
        Expanded(flex: 3, child: _TH(label: 'CVN')),          _Dv(),
        Expanded(flex: 4, child: _TH(label: 'Part No.')),     _Dv(),
        _TH(width: 58,  label: 'Dongle'),          _Dv(),
        _TH(width: 54,  label: 'ECU'),             _Dv(),
        Expanded(flex: 4, child: _TH(label: 'Progress')),     _Dv(),
        _TH(width: 56,  label: 'Time'),            _Dv(),
        _TH(width: 76,  label: 'Status'),          _Dv(),
        _TH(width: 84,  label: 'Start / Print'),
      ]),
    );
  }
}

// ── Table Rows ────────────────────────────────────────────────
class _TableRows extends StatelessWidget {
  final IndividualFlashController controller;
  const _TableRows({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tableInfo.isEmpty) {
        return Center(child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar_rounded, size: 48, color: _cWhite40),
            const SizedBox(height: 12),
            Text(
              controller.currStatus.value.isNotEmpty
                  ? controller.currStatus.value
                  : 'No dongles assigned.',
              style: const TextStyle(fontSize: 14, color: _cWhite40)),
          ])));
      }
      return ListView.builder(
        itemCount: controller.tableInfo.length,
        itemBuilder: (_, i) => _DataRow(
          device: controller.tableInfo[i],
          controller: controller,
          isEven: i % 2 == 0));
    });
  }
}

// ── Data Row ──────────────────────────────────────────────────
class _DataRow extends StatelessWidget {
  final IndividualRowModel device;
  final IndividualFlashController controller;
  final bool isEven;
  const _DataRow({
    required this.device, required this.controller, required this.isEven});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.tableInfo.length; // trigger rebuild on list update

      final playEnabled = !device.playButtonDisable && !device.isflashing;

      return Container(
        decoration: BoxDecoration(
          color: isEven ? const Color(0xFF131E33) : const Color(0xFF0E1828),
          border: const Border(bottom: BorderSide(color: _cBorder, width: 0.6))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // # Sr No
              SizedBox(width: 46, child: Center(
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_cOrange, _cOrangD]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x40F97316), blurRadius: 5)]),
                  child: Center(child: Text('${device.srNo}',
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold, color: _cWhite)))))),
              _Dv(),

              // State Before/After
              SizedBox(width: 52, child: Column(children: [
                Expanded(child: Center(child: _Pill('Before', _cWhite40, _cWhite15))),
                Container(height: 0.6, color: _cBorder),
                Expanded(child: Center(child: _Pill('After', _cOrange, const Color(0x20F97316)))),
              ])),
              _Dv(),

              // Cal Id
              Expanded(flex: 5, child: _BACell(before: device.calIdBefore, after: device.printCalId)),
              _Dv(),

              // ECU Sr No
              Expanded(flex: 4, child: _BACell(before: device.ecuSrNo, after: device.ecuSrNoAfter)),
              _Dv(),

              // SW Version
              Expanded(flex: 3, child: _BACell(before: device.swVersionBefore, after: device.swVersionAfter)),
              _Dv(),

              // CVN
              Expanded(flex: 3, child: _BACell(before: device.cvnBefore, after: device.cvn)),
              _Dv(),

              // Part No
              Expanded(flex: 4, child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    device.swPartNo.isNotEmpty ? device.swPartNo : '—',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9, color: _cWhite70),
                    maxLines: 2, overflow: TextOverflow.ellipsis)))),
              _Dv(),

              // Dongle indicator
              SizedBox(width: 58, child: Center(
                child: _HwDot(on: device.dongleFlashingIndicator, icon: Icons.usb_rounded))),
              _Dv(),

              // ECU indicator
              SizedBox(width: 54, child: Center(
                child: _HwDot(on: device.ecuFlashingIndicator, icon: Icons.memory_rounded))),
              _Dv(),

              // Progress bar + %
              Expanded(flex: 4, child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (device.isProgressVisible) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: device.progress,    // real 0.0 → 1.0
                          minHeight: 7,
                          color: _cPass,
                          backgroundColor: _cBorder)),
                      const SizedBox(height: 2),
                    ],
                    Text(device.flashPercent,       // real "0.0%" → "100.0%"
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: _cWhite40)),
                  ]))),
              _Dv(),

              // Time — real stopwatch e.g. "01:30"
              SizedBox(width: 56, child: Center(
                child: Text(device.flashTimer,
                  style: const TextStyle(
                    fontSize: 11, color: _cWhite70,
                    fontFamily: 'monospace', fontWeight: FontWeight.w600)))),
              _Dv(),

              // Status badge
              SizedBox(width: 76, child: Center(
                child: _StatusBadge(color: device.statusColor))),
              _Dv(),

              // Start / Print button
              SizedBox(width: 84, child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                child: (device.flashingCompleted && device.flashingSuccess)
                    // Print button after successful flash
                    ? _ActionBtn(
                        label: 'Print',
                        icon: Icons.print_rounded,
                        enabled: !device.printButtonDisable,
                        color: _cOrange,
                        onTap: () => controller.printSticker(device))
                    // Start button — orange when enabled (matches .NET accent_color)
                    : _ActionBtn(
                        label: device.isflashing ? '...' : 'Start',
                        icon: device.isflashing
                            ? Icons.hourglass_top_rounded
                            : Icons.play_arrow_rounded,
                        enabled: playEnabled,
                        isLoading: device.isflashing,
                        color: _cOrange,
                        onTap: () => controller.startIndividualFlash(device)))),

            ],
          ),
        ),
      );
    });
  }
}

// ── Bottom Bar ────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final IndividualFlashController controller;
  const _BottomBar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_cSurface, _cSurface2]),
        border: Border(top: BorderSide(color: _cBorder))),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Status message during check/flash
        Obx(() => controller.currStatus.value.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x1AF97316),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _cOrangDD)),
                child: Row(children: [
                  const SizedBox(width: 12, height: 12,
                    child: CircularProgressIndicator(color: _cOrange, strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(controller.currStatus.value,
                    style: const TextStyle(color: _cOrange, fontSize: 12))),
                ]))
            : const SizedBox()),

        // ── Bottom buttons: CHECK ECU STATUS + ⚡ FLASH ALL ──
        Obx(() {
          final checkEnabled = controller.checkEcuStatusButton.value;
          final flashAllEnabled = controller.tableInfo.any((d) =>
              !d.playButtonDisable && !d.isflashing && d.flashingAvailabel);
          return Row(children: [
            // CHECK ECU STATUS
            Expanded(flex: 3, child: GestureDetector(
              onTap: checkEnabled ? () => controller.checkEcuStatus() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: checkEnabled
                      ? const LinearGradient(
                          colors: [_cOrange, _cOrangD, _cOrangDD],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      : null,
                  color: checkEnabled ? null : _cBorder,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: checkEnabled
                      ? const [BoxShadow(
                          color: Color(0x50F97316),
                          blurRadius: 14, offset: Offset(0, 4))]
                      : null),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radar_rounded,
                      color: checkEnabled ? _cWhite : _cWhite40, size: 17),
                    const SizedBox(width: 8),
                    Text('CHECK ECU STATUS',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold,
                        color: checkEnabled ? _cWhite : _cWhite40,
                        letterSpacing: 1.0)),
                  ])))),
            const SizedBox(width: 10),
            // ⚡ FLASH ALL — parallel flash all eligible ECUs simultaneously
            Expanded(flex: 2, child: GestureDetector(
              onTap: flashAllEnabled ? () => controller.startAllFlash() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: flashAllEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      : null,
                  color: flashAllEnabled ? null : _cBorder,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: flashAllEnabled
                      ? const [BoxShadow(
                          color: Color(0x5016A34A),
                          blurRadius: 14, offset: Offset(0, 4))]
                      : null),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on_rounded,
                      color: flashAllEnabled ? _cWhite : _cWhite40, size: 17),
                    const SizedBox(width: 8),
                    Text('FLASH ALL',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold,
                        color: flashAllEnabled ? _cWhite : _cWhite40,
                        letterSpacing: 1.0)),
                  ])))),
          ]);
        }),
      ]));
  }
}

// ── Alert Popup ───────────────────────────────────────────────
class _AlertPopup extends StatelessWidget {
  final IndividualFlashController controller;
  const _AlertPopup({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xB3000000),
      child: Center(child: Container(
        width: 360,
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_cSurface, _cSurface2]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cBorder),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_cOrange, _cOrangD, _cOrangDD]),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const Row(children: [
              Icon(Icons.warning_amber_rounded, color: _cWhite, size: 20),
              SizedBox(width: 12),
              Text('Alert', style: TextStyle(
                color: _cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
            ])),
          Flexible(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Flexible(child: Obx(() => SingleChildScrollView(
                child: Text(controller.popupMessage.value,
                  style: const TextStyle(fontSize: 13, color: _cWhite70, height: 1.6),
                  textAlign: TextAlign.center)))),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: controller.onOkPopup,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_cOrange, _cOrangD, _cOrangDD]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(
                      color: Color(0x50F97316),
                      blurRadius: 12, offset: Offset(0, 4))]),
                  child: const Center(child: Text('OK',
                    style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _cWhite, letterSpacing: 1))))),
            ]))),
        ]))));
  }
}

// ── Shared Widgets ────────────────────────────────────────────
class _TH extends StatelessWidget {
  final String label;
  final double? width;
  const _TH({required this.label, this.width});
  @override
  Widget build(BuildContext context) {
    final child = Center(child: Text(label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: _cWhite70, fontWeight: FontWeight.w700,
        fontSize: 10, letterSpacing: 0.2)));
    if (width != null) return SizedBox(width: width, child: child);
    return child;
  }
}

class _Dv extends StatelessWidget {
  const _Dv();
  @override
  Widget build(BuildContext context) => Container(width: 1, color: _cBorder);
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Pill(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(
      fontSize: 8.5, color: color, fontWeight: FontWeight.w700)));
}

class _BACell extends StatelessWidget {
  final String before, after;
  const _BACell({required this.before, required this.after});
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(before.isNotEmpty ? before : '—',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 9.5, color: _cWhite70),
        maxLines: 1, overflow: TextOverflow.ellipsis)))),
    Container(height: 0.6, color: _cBorder),
    Expanded(child: Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(after.isNotEmpty ? after : '—',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 9.5, color: _cOrange, fontWeight: FontWeight.w600),
        maxLines: 1, overflow: TextOverflow.ellipsis)))),
  ]);
}

class _HwDot extends StatelessWidget {
  final bool on;
  final IconData icon;
  const _HwDot({required this.on, required this.icon});
  @override
  Widget build(BuildContext context) {
    final c = on ? _cPass : _cFail;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: c, width: 1.5),
            boxShadow: on ? [BoxShadow(color: c.withOpacity(0.25), blurRadius: 5)] : null),
          child: Icon(icon, size: 14, color: c)),
        const SizedBox(height: 2),
        Text(on ? 'ON' : 'OFF',
          style: TextStyle(fontSize: 8, color: c, fontWeight: FontWeight.w800)),
      ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  const _StatusBadge({required this.color});
  @override
  Widget build(BuildContext context) {
    final isPass    = color == _cPass    || color == Colors.green;
    final isFail    = color == _cFail    || color == Colors.red;
    final isRunning = color == Colors.yellow || color == _cYellow;

    final Color bc;
    final IconData ico;
    final String lbl;
    if (isPass)         { bc = _cPass;    ico = Icons.check_circle_rounded; lbl = 'Pass'; }
    else if (isFail)    { bc = _cFail;    ico = Icons.cancel_rounded;       lbl = 'Fail'; }
    else if (isRunning) { bc = _cYellow;  ico = Icons.sync_rounded;         lbl = 'Running'; }
    else                { bc = _cWhite40; ico = Icons.remove_rounded;       lbl = 'Idle'; }

    final idle = !isPass && !isFail && !isRunning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: idle ? _cWhite15 : bc.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: idle ? _cBorder : bc, width: 1.2),
        boxShadow: idle ? null : [BoxShadow(color: bc.withOpacity(0.18), blurRadius: 5)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ico, size: 10, color: bc),
        const SizedBox(width: 3),
        Text(lbl, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: bc)),
      ]));
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool isLoading;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label, required this.icon,
    required this.enabled, this.isLoading = false,
    required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      height: 30,
      decoration: BoxDecoration(
        gradient: enabled
            ? LinearGradient(colors: [color, color.withOpacity(0.75)])
            : null,
        color: enabled ? null : _cBorder,
        borderRadius: BorderRadius.circular(7),
        boxShadow: enabled
            ? [BoxShadow(color: color.withOpacity(0.3),
                blurRadius: 6, offset: const Offset(0, 2))]
            : null),
      child: Center(child: isLoading
          ? const SizedBox(width: 12, height: 12,
              child: CircularProgressIndicator(color: _cWhite, strokeWidth: 2))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: _cWhite, size: 12),
              const SizedBox(width: 3),
              Text(label, style: const TextStyle(
                fontSize: 10, color: _cWhite, fontWeight: FontWeight.w700)),
            ]))));
}
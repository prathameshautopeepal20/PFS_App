// lib/views/screens/dashboard/home_page_screen.dart
// Fully responsive — Expanded flex, never overflows

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/home_page_controller.dart';
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

// ════════════════════════════════════════════════════════════
//  Entry point
// ════════════════════════════════════════════════════════════
class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      HomePageController(
        args: (Get.arguments as Map<String, dynamic>?) ?? {},
      ),
    );

    return MainLayout(
      title: 'ECU Flashing',
      child: Container(
        color: _cBg,
        child: Stack(
          children: [
            Column(
              children: [
                _InfoBar(controller: controller),
                _TableHeader(),
                Expanded(child: _TableRows(controller: controller)),
                _BottomBar(controller: controller),
              ],
            ),

            // Loading
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

            Obx(() => controller.showAlertPopup.value
                ? _AlertPopup(controller: controller)
                : const SizedBox()),
            Obx(() => controller.showChangePopup.value
                ? _ChangePopup(controller: controller)
                : const SizedBox()),
            Obx(() => controller.showPrintPopup.value
                ? _InfoPopup(message: controller.popupMessage.value)
                : const SizedBox()),
            Obx(() => controller.showWaitPopup.value
                ? _WaitPopup(seconds: controller.afterFlashSeconds.value)
                : const SizedBox()),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Info Bar
// ════════════════════════════════════════════════════════════
class _InfoBar extends StatelessWidget {
  final HomePageController controller;
  const _InfoBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final sub   = controller.selectedSubModel;
    final model = controller.selectedModel;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_cSurface, _cSurface2]),
        border: Border(bottom: BorderSide(color: _cBorder))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        Expanded(child: _InfoBox(
          label: 'MODEL DETAILS',
          value: '${sub?.description ?? ''}/${model?.name ?? ''}')),
        const SizedBox(width: 10),
        Expanded(child: _InfoBox(
          label: 'ECU HARDWARE',
          value: sub?.ecuSubmodel.isNotEmpty == true
              ? '${sub!.ecuSubmodel[0].ecu}' : '—')),
        const SizedBox(width: 10),
        // Find Dongle — scans WiFi network for dongle IP
        _FindDongleBtn(controller: controller),
        const SizedBox(width: 8),
        Obx(() => _OrangeBtn(
          label: 'Reset Dongle',
          enabled: controller.isResetDongleEnabled.value,
          icon: Icons.refresh_rounded,
          onTap: controller.resetDongle)),
      ]),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label, value;
  const _InfoBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(width: 3, height: 10,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cOrange, _cOrangD],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: _cWhite40, letterSpacing: 0.8)),
      ]),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x1AF97316),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _cBorder)),
        child: Text(value,
          style: const TextStyle(fontSize: 12, color: _cWhite70),
          overflow: TextOverflow.ellipsis)),
    ],
  );
}

// ════════════════════════════════════════════════════════════
//  Table Header — Expanded flex (never overflows)
// ════════════════════════════════════════════════════════════
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
          top:    BorderSide(color: _cBorder),
          bottom: BorderSide(color: _cOrangD, width: 1.5))),
      child: Row(children: [
        // Fixed width columns
        _TH(w: 46,  label: '#'),            _Dv(),
        _TH(w: 54,  label: 'State'),        _Dv(),
        // Flex columns — share remaining space
        Expanded(flex: 5, child: _TH(label: 'Cal Id')),      _Dv(),
        Expanded(flex: 4, child: _TH(label: 'ECU Sr No.')),  _Dv(),
        Expanded(flex: 3, child: _TH(label: 'SW Ver.')),     _Dv(),
        Expanded(flex: 3, child: _TH(label: 'CVN')),         _Dv(),
        Expanded(flex: 4, child: _TH(label: 'Part No.')),    _Dv(),
        // Fixed width columns
        _TH(w: 56,  label: 'Dongle'),       _Dv(),
        _TH(w: 52,  label: 'ECU'),          _Dv(),
        Expanded(flex: 4, child: _TH(label: 'Progress')),    _Dv(),
        _TH(w: 56,  label: 'Time'),         _Dv(),
        _TH(w: 78,  label: 'Status'),       _Dv(),
        _TH(w: 78,  label: 'Report'),       _Dv(),
        _TH(w: 86,  label: 'Print'),
      ]),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  final double? w;
  const _TH({required this.label, this.w});
  @override
  Widget build(BuildContext context) {
    final child = Center(child: Text(label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: _cWhite70, fontWeight: FontWeight.w700, fontSize: 10.5)));
    return w != null ? SizedBox(width: w, child: child) : child;
  }
}

class _Dv extends StatelessWidget {
  const _Dv();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: _cBorder);
}

// ════════════════════════════════════════════════════════════
//  Table Rows
// ════════════════════════════════════════════════════════════
class _TableRows extends StatelessWidget {
  final HomePageController controller;
  const _TableRows({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _cBg,
      child: Obx(() {
        if (controller.tableInfo.isEmpty) {
          return Center(child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radar_rounded, size: 48, color: _cWhite40),
              const SizedBox(height: 12),
              Text(
                controller.currStatus.value.isNotEmpty
                    ? controller.currStatus.value : 'Searching...',
                style: const TextStyle(fontSize: 15, color: _cWhite40)),
            ])));
        }
        return ListView.builder(
          itemCount: controller.tableInfo.length,
          itemBuilder: (_, i) => _DataRow(
            device: controller.tableInfo[i],
            controller: controller,
            isEven: i % 2 == 0));
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Data Row — EXACT same flex structure as header
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
      controller.tableInfo.length;
      return Container(
        decoration: BoxDecoration(
          color: isEven
              ? const Color(0xFF131E33)
              : const Color(0xFF0E1828),
          border: const Border(
            bottom: BorderSide(color: _cBorder, width: 0.6))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── # ─────────────────────────────────────────
              SizedBox(width: 46, child: Center(
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_cOrange, _cOrangD]),
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(
                      color: Color(0x40F97316), blurRadius: 5)]),
                  child: Center(child: Text('${device.srNo}',
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: _cWhite)))))),
              _Dv(),

              // ── Before/After ──────────────────────────────
              SizedBox(width: 54, child: Column(children: [
                Expanded(child: Center(child: _Pill('Before', _cWhite40, _cWhite15))),
                Container(height: 0.6, color: _cBorder),
                Expanded(child: Center(child: _Pill('After', _cOrange,
                  const Color(0x20F97316)))),
              ])),
              _Dv(),

              // ── Cal Id ────────────────────────────────────
              Expanded(flex: 5, child: _BACell(
                before: device.calIdBefore, after: device.printCalId)),
              _Dv(),

              // ── ECU Sr No ─────────────────────────────────
              Expanded(flex: 4, child: _BACell(
                before: device.ecuSrNo, after: device.ecuSrNoAfter)),
              _Dv(),

              // ── SW Version ────────────────────────────────
              Expanded(flex: 3, child: _BACell(
                before: device.swVersionBefore, after: device.swVersionAfter)),
              _Dv(),

              // ── CVN ───────────────────────────────────────
              Expanded(flex: 3, child: _BACell(
                before: device.cvnBefore, after: device.cvn)),
              _Dv(),

              // ── Part No ───────────────────────────────────
              Expanded(flex: 4, child: Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(device.swPartNo.isNotEmpty ? device.swPartNo : '—',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9.5, color: _cWhite70),
                  maxLines: 2, overflow: TextOverflow.ellipsis)))),
              _Dv(),

              // ── Dongle ────────────────────────────────────
              SizedBox(width: 56, child: Center(
                child: _HwDot(on: device.dongleFlashingIndicator,
                  icon: Icons.usb_rounded))),
              _Dv(),

              // ── ECU ───────────────────────────────────────
              SizedBox(width: 52, child: Center(
                child: _HwDot(on: device.ecuFlashingIndicator,
                  icon: Icons.memory_rounded))),
              _Dv(),

              // ── Progress + Flash btn ──────────────────────
              Expanded(flex: 4, child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (device.isProgressVisible) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: device.progress,
                          minHeight: 6,
                          color: _cPass,
                          backgroundColor: _cBorder)),
                      const SizedBox(height: 3),
                    ],
                    Text(device.flashPercent,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10, color: _cWhite40)),
                    if (device.playButtonVisible) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: device.playButtonDisable ? null
                            : () => controller.startIndividualFlash(device),
                        child: Container(
                          height: 26,
                          decoration: BoxDecoration(
                            gradient: device.playButtonDisable
                                ? null
                                : const LinearGradient(
                                    colors: [_cOrange, _cOrangD]),
                            color: device.playButtonDisable ? _cBorder : null,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: device.playButtonDisable ? null
                                : const [BoxShadow(
                                    color: Color(0x40F97316),
                                    blurRadius: 5)]),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                color: _cWhite, size: 13),
                              SizedBox(width: 3),
                              Text('Flash', style: TextStyle(
                                fontSize: 10, color: _cWhite,
                                fontWeight: FontWeight.w700)),
                            ]),
                        )),
                    ],
                  ]))),
              _Dv(),

              // ── Time ──────────────────────────────────────
              SizedBox(width: 56, child: Center(
                child: Text(device.flashTimer,
                  style: const TextStyle(
                    fontSize: 11, color: _cWhite70,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600)))),
              _Dv(),

              // ── Status badge ──────────────────────────────
              SizedBox(width: 78, child: Center(
                child: _StatusBadge(color: device.statusColor))),
              _Dv(),

              // ── Report badge ──────────────────────────────
              SizedBox(width: 78, child: Center(
                child: _StatusBadge(color: device.reportColor))),
              _Dv(),

              // ── Print button ──────────────────────────────
              SizedBox(width: 86, child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 7),
                child: GestureDetector(
                  onTap: device.printButtonDisable ? null
                      : () => controller.printSticker(device),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: device.printButtonDisable
                          ? null
                          : const LinearGradient(
                              colors: [_cOrange, _cOrangD]),
                      color: device.printButtonDisable ? _cBorder : null,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: device.printButtonDisable ? null
                          : const [BoxShadow(
                              color: Color(0x40F97316),
                              blurRadius: 6, offset: Offset(0, 2))]),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.print_rounded, color: _cWhite, size: 12),
                        SizedBox(width: 4),
                        Text('Print', style: TextStyle(
                          fontSize: 11, color: _cWhite,
                          fontWeight: FontWeight.w700)),
                      ]))))),
            ],
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════
//  Shared small widgets
// ════════════════════════════════════════════════════════════
class _Pill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _Pill(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(4)),
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
          fontSize: 9.5, color: _cOrange,
          fontWeight: FontWeight.w600),
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
            boxShadow: on ? [BoxShadow(
              color: c.withOpacity(0.25), blurRadius: 5)] : null),
          child: Icon(icon, size: 14, color: c)),
        const SizedBox(height: 2),
        Text(on ? 'ON' : 'OFF',
          style: TextStyle(
            fontSize: 8, color: c, fontWeight: FontWeight.w800)),
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
    else if (isRunning) { bc = _cYellow;  ico = Icons.sync_rounded;          lbl = 'Run'; }
    else                { bc = _cWhite40; ico = Icons.remove_rounded;        lbl = 'Idle'; }
    final idle = !isPass && !isFail && !isRunning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: idle ? _cWhite15 : bc.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: idle ? _cBorder : bc, width: 1.2),
        boxShadow: idle ? null : [BoxShadow(
          color: bc.withOpacity(0.18), blurRadius: 5)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ico, size: 10, color: bc),
        const SizedBox(width: 3),
        Text(lbl, style: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w700, color: bc)),
      ]));
  }
}

// ════════════════════════════════════════════════════════════
//  Bottom Bar
// ════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final HomePageController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_cSurface, _cSurface2]),
        border: const Border(top: BorderSide(color: _cBorder))),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Obx(() => controller.currStatus.value.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1AF97316),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _cOrangDD)),
                child: Row(children: [
                  const Icon(Icons.sync_rounded, color: _cOrange, size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text(controller.currStatus.value,
                    style: const TextStyle(color: _cOrange, fontSize: 12))),
                ]))
            : const SizedBox()),

        Row(children: [
          Obx(() => _OrangeBtn(
            label: 'CHECK ECU STATUS',
            enabled: controller.checkEcuStatusButton.value,
            icon: Icons.radar_rounded,
            onTap: controller.checkEcuStatus)),
          const Spacer(),
          Obx(() => controller.flashingButtonVisible.value
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _OrangeBtn(
                    label: 'START FLASH',
                    enabled: !controller.startFlashButtonDisable.value,
                    icon: Icons.bolt_rounded,
                    onTap: controller.startFlash))
              : const SizedBox()),
          Obx(() => _OrangeBtn(
            label: 'RESET',
            enabled: !controller.startResetButtonDisable.value,
            icon: Icons.refresh_rounded,
            onTap: controller.reset)),
        ]),
      ]));
  }
}

// ════════════════════════════════════════════════════════════
//  Find Dongle Button — scans WiFi and shows found IPs
// ════════════════════════════════════════════════════════════
class _FindDongleBtn extends StatelessWidget {
  final HomePageController controller;
  const _FindDongleBtn({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showScanSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: _cOrange, width: 1.5),
          borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_find_rounded, color: _cOrange, size: 15),
          SizedBox(width: 6),
          Text('Find Dongle',
            style: TextStyle(
              color: _cOrange, fontSize: 12,
              fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  void _showScanSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DongleScanDialog(controller: controller),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Dongle Scan Dialog
// ════════════════════════════════════════════════════════════
class _DongleScanDialog extends StatefulWidget {
  final HomePageController controller;
  const _DongleScanDialog({required this.controller});

  @override
  State<_DongleScanDialog> createState() => _DongleScanDialogState();
}

class _DongleScanDialogState extends State<_DongleScanDialog> {
  List<String> _foundIPs = [];
  bool   _scanning = false;
  bool   _done     = false;
  double _progress = 0.0;
  String _status   = 'Starting scan...';

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _done     = false;
      _foundIPs = [];
      _progress = 0.0;
      _status   = 'Getting WiFi info...';
    });

    try {
      // Get local IP to find subnet
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4);

      String? subnet;
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          // Skip loopback
          if (ip.startsWith('127.')) continue;
          // Take first LAN IP
          final parts = ip.split('.');
          if (parts.length == 4) {
            subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
            break;
          }
        }
        if (subnet != null) break;
      }

      if (subnet == null) {
        setState(() {
          _status   = 'Could not detect WiFi IP.\nMake sure WiFi is connected.';
          _scanning = false;
          _done     = true;
        });
        return;
      }

      setState(() => _status = 'Scanning $subnet.1–254 on port 6888...');

      final found  = <String>[];
      const total  = 254;
      const batch  = 20; // scan 20 IPs at a time

      for (int start = 1; start <= total; start += batch) {
        if (!mounted) return;

        final end     = (start + batch - 1).clamp(1, total);
        final futures = <Future<String?>>[];

        for (int i = start; i <= end; i++) {
          futures.add(_tryConnect('$subnet.$i'));
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
            _progress = end / total;
            _status   = 'Scanning... ${(end / total * 100).toInt()}%'
                '  —  Found: ${found.length}';
          });
        }
      }

      setState(() {
        _scanning = false;
        _done     = true;
        _foundIPs = found;
        _status   = found.isEmpty
            ? 'No dongles found on $subnet.x port 6888'
            : '✅ Found ${found.length} dongle(s)';
      });

    } catch (e) {
      setState(() {
        _scanning = false;
        _done     = true;
        _status   = 'Scan error: $e';
      });
    }
  }

  // Try TCP connect on port 6888 with 400ms timeout
  Future<String?> _tryConnect(String ip) async {
    try {
      final socket = await Socket.connect(ip, 6888,
        timeout: const Duration(milliseconds: 400));
      socket.destroy();
      return ip;
    } catch (_) {
      return null;
    }
  }

  // User selects an IP → update dongle row IP
  void _selectIP(String ip) {
    // Update all unconnected dongles with found IP
    // Or show which dongle to assign
    Navigator.of(context).pop();
    Get.snackbar(
      '✅ Dongle Found',
      'IP: $ip — Update this IP in server for dongle registration.',
      backgroundColor: _cPass,
      colorText: _cWhite,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );

    // Print to console for developer
    print('🔍 Dongle found at: $ip — Update dongle IP in server');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_cSurface, _cSurface2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cBorder),
          boxShadow: const [BoxShadow(
            color: Colors.black54, blurRadius: 24)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_cOrange, _cOrangD, _cOrangDD]),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16))),
              padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
              child: Row(children: [
                const Icon(Icons.wifi_find_rounded,
                  color: _cWhite, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text('Scanning for Dongles',
                  style: TextStyle(
                    color: _cWhite, fontSize: 15,
                    fontWeight: FontWeight.bold))),
                if (!_scanning)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded,
                      color: _cWhite, size: 20)),
              ])),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status text
                  Row(children: [
                    if (_scanning)
                      const SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                          color: _cOrange, strokeWidth: 2))
                    else
                      Icon(
                        _foundIPs.isEmpty ? Icons.error_outline_rounded
                            : Icons.check_circle_rounded,
                        color: _foundIPs.isEmpty ? _cFail : _cPass,
                        size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_status,
                      style: const TextStyle(
                        color: _cWhite70, fontSize: 11))),
                  ]),
                  const SizedBox(height: 10),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _scanning ? _progress : 1.0,
                      minHeight: 7,
                      color: _cOrange,
                      backgroundColor: _cBorder)),
                  const SizedBox(height: 4),
                  Text('${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: _cWhite40, fontSize: 10)),

                  const SizedBox(height: 14),

                  // Results
                  if (_done) ...[
                    if (_foundIPs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x15EF4444),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _cFail.withOpacity(0.3))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('No dongles found on port 6888.',
                              style: TextStyle(
                                color: _cFail, fontSize: 12,
                                fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Check:',
                              style: TextStyle(
                                color: _cWhite70, fontSize: 11,
                                fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('• Dongle is powered ON (LED blinking)',
                              style: TextStyle(color: _cWhite40, fontSize: 11)),
                            Text('• Dongle connected to same WiFi as laptop',
                              style: TextStyle(color: _cWhite40, fontSize: 11)),
                            Text('• Dongle port is 6888',
                              style: TextStyle(color: _cWhite40, fontSize: 11)),
                            Text('• Windows Firewall allows port 6888',
                              style: TextStyle(color: _cWhite40, fontSize: 11)),
                          ]))
                    else ...[
                      Text('${_foundIPs.length} Dongle(s) Found — Tap to copy IP:',
                        style: const TextStyle(
                          color: _cPass, fontSize: 12,
                          fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._foundIPs.map((ip) => GestureDetector(
                        onTap: () => _selectIP(ip),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0x15F97316),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _cOrange)),
                          child: Row(children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0x20F97316),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _cOrange, width: 1.5)),
                              child: const Icon(Icons.usb_rounded,
                                color: _cOrange, size: 16)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ip,
                                  style: const TextStyle(
                                    color: _cWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace')),
                                const Text('Port 6888 — Dongle responding ✅',
                                  style: TextStyle(
                                    color: _cWhite40, fontSize: 10)),
                              ])),
                            const Icon(Icons.copy_rounded,
                              color: _cOrange, size: 16),
                          ]),
                        ),
                      )).toList(),
                    ],
                    const SizedBox(height: 14),
                  ],

                  // Buttons
                  Row(children: [
                    if (_done) ...[
                      Expanded(child: GestureDetector(
                        onTap: _startScan,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            border: Border.all(color: _cOrange),
                            borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_rounded,
                                color: _cOrange, size: 15),
                              SizedBox(width: 6),
                              Text('Rescan',
                                style: TextStyle(
                                  color: _cOrange, fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                            ])),
                      )),
                      const SizedBox(width: 10),
                    ],
                    Expanded(child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: _cBorder,
                          borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('Close',
                          style: TextStyle(
                            color: _cWhite70, fontSize: 12,
                            fontWeight: FontWeight.w600)))),
                    )),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrangeBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final IconData icon;
  final VoidCallback onTap;
  const _OrangeBtn({required this.label, required this.enabled,
    required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: enabled ? const LinearGradient(
          colors: [_cOrange, _cOrangD, _cOrangDD],
          begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: enabled ? null : _cBorder,
        borderRadius: BorderRadius.circular(8),
        boxShadow: enabled ? const [BoxShadow(
          color: Color(0x50F97316),
          blurRadius: 10, offset: Offset(0, 3))] : null),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _cWhite, size: 14),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold,
          color: _cWhite, letterSpacing: 0.4)),
      ])));
}

// ════════════════════════════════════════════════════════════
//  Popups
// ════════════════════════════════════════════════════════════
class _AlertPopup extends StatelessWidget {
  final HomePageController controller;
  const _AlertPopup({required this.controller});
  @override
  Widget build(BuildContext context) => _Shell(
    icon: Icons.warning_amber_rounded, title: 'Alert',
    child: Column(children: [
      Expanded(child: Obx(() => SingleChildScrollView(
        child: Text(controller.popupMessage.value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _cWhite70))))),
      const SizedBox(height: 14),
      _Btn(label: 'OK', onTap: controller.onOkPopup),
    ]));
}

class _ChangePopup extends StatelessWidget {
  final HomePageController controller;
  const _ChangePopup({required this.controller});
  @override
  Widget build(BuildContext context) => _Shell(
    icon: Icons.swap_horiz_rounded, title: 'ECU Already Flashed',
    child: Column(children: [
      Expanded(child: Obx(() => SingleChildScrollView(
        child: Text(controller.popupMessage.value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: _cWhite70))))),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _Btn(label: 'Reflash', onTap: controller.onReflash)),
        const SizedBox(width: 10),
        Expanded(child: _Btn(
          label: 'Change ECU', onTap: controller.onChangeECU, outlined: true)),
      ]),
    ]));
}

class _InfoPopup extends StatelessWidget {
  final String message;
  const _InfoPopup({required this.message});
  @override
  Widget build(BuildContext context) => _Shell(
    icon: Icons.print_rounded, title: 'Print Sticker',
    child: Expanded(child: Center(child: Text(message,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: _cWhite70)))));
}

class _WaitPopup extends StatelessWidget {
  final int seconds;
  const _WaitPopup({required this.seconds});
  @override
  Widget build(BuildContext context) => _Shell(
    icon: Icons.hourglass_top_rounded, title: 'Please Wait',
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _cOrange, width: 3),
          color: const Color(0x1AF97316)),
        child: Center(child: Text('$seconds',
          style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: _cOrange)))),
      const SizedBox(height: 12),
      const Text('seconds remaining',
        style: TextStyle(fontSize: 13, color: _cWhite70)),
    ]));
}

class _Shell extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Shell({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xB3000000),
    child: Center(child: Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 340),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_cSurface, _cSurface2]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cBorder),
        boxShadow: const [BoxShadow(
          color: Colors.black54, blurRadius: 24, offset: Offset(0, 8))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_cOrange, _cOrangD, _cOrangDD]),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16))),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(icon, color: _cWhite, size: 20),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(
              color: _cWhite, fontSize: 15, fontWeight: FontWeight.bold)),
          ])),
        Flexible(child: Padding(
          padding: const EdgeInsets.all(20),
          child: child)),
      ]))));
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  const _Btn({required this.label, required this.onTap, this.outlined = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        gradient: outlined ? null : const LinearGradient(
          colors: [_cOrange, _cOrangD, _cOrangDD]),
        border: outlined ? Border.all(color: _cOrange, width: 1.5) : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: outlined ? null : const [BoxShadow(
          color: Color(0x50F97316), blurRadius: 10, offset: Offset(0, 3))]),
      child: Center(child: Text(label,
        style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold,
          color: outlined ? _cOrange : _cWhite)))));
}
// lib/views/screens/dashboard/individual_flash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/individual_flash_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';

const Color _kOrange = Color(0xFFF9772C);
const Color _kDark   = Color(0xFF1E2A3A);
const Color _kBg     = Color(0xFFF5F6FA);
const Color _kText   = Color(0xFF212121);

// ════════════════════════════════════════════════════════════
//  Screen
// ════════════════════════════════════════════════════════════
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
      child: Stack(
        children: [
          Column(
            children: [
              // ── Table header row ─────────────────────────────
              const _TableHeader(),

              // ── Table data rows ───────────────────────────────
              Expanded(child: _TableRows(controller: controller)),

              // ── Bottom: CHECK ECU STATUS ──────────────────────
              _BottomBar(controller: controller),
            ],
          ),

          // Loading overlay
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black38,
                  child: const Center(
                      child: CircularProgressIndicator(color: _kOrange)),
                )
              : const SizedBox()),

          // Alert popup
          Obx(() => controller.showAlertPopup.value
              ? _AlertPopup(controller: controller)
              : const SizedBox()),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Header
// ════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDark,
      child: Column(
        children: [
          Container(height: 4, color: _kOrange),
          Container(height: 2, color: _kOrange),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Text(
                    'Individual ECU Flashing',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  onPressed: () => Get.offAllNamed('/login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Table Header
//  Columns: # | Before/After | Cal Id | ECU Sr No | SW Version
//           | CVN | Final Part No | Dongle | ECU | Progress
//           | Time | Status | Report | Start | Print
// ════════════════════════════════════════════════════════════
class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDark,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _TH(w: 40,  text: '#'),
            _TVDiv(),
            _TH(w: 55,  text: ''),
            _TVDiv(),
            _TH(w: 130, text: 'Cal Id'),
            _TVDiv(),
            _TH(w: 110, text: 'ECU Sr No.'),
            _TVDiv(),
            _TH(w: 100, text: 'SW Version'),
            _TVDiv(),
            _TH(w: 100, text: 'CVN'),
            _TVDiv(),
            _TH(w: 110, text: 'Final Part No.'),
            _TVDiv(),
            _TH(w: 52,  text: 'Dongle'),
            _TVDiv(),
            _TH(w: 50,  text: 'ECU'),
            _TVDiv(),
            _TH(w: 150, text: 'Progress'),
            _TVDiv(),
            _TH(w: 60,  text: 'Time'),
            _TVDiv(),
            _TH(w: 50,  text: 'Status'),
            _TVDiv(),
            _TH(w: 50,  text: 'Report'),
            _TVDiv(),
            _TH(w: 70,  text: 'Start'),
            _TVDiv(),
            _TH(w: 70,  text: 'Print'),
          ],
        ),
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final double w;
  final String text;
  const _TH({required this.w, required this.text});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: w,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      );
}

class _TVDiv extends StatelessWidget {
  const _TVDiv();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: Colors.white24);
}

// ════════════════════════════════════════════════════════════
//  Table Rows
// ════════════════════════════════════════════════════════════
class _TableRows extends StatelessWidget {
  final IndividualFlashController controller;
  const _TableRows({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tableInfo.isEmpty) {
        return Center(
          child: Obx(() => Text(
                controller.currStatus.value.isNotEmpty
                    ? controller.currStatus.value
                    : 'No dongles assigned.',
                style: const TextStyle(fontSize: 18, color: _kText),
              )),
        );
      }
      return ListView.builder(
        itemCount: controller.tableInfo.length,
        itemBuilder: (_, i) => _DataRow(
          device: controller.tableInfo[i],
          controller: controller,
        ),
      );
    });
  }
}

class _DataRow extends StatelessWidget {
  final IndividualRowModel device;
  final IndividualFlashController controller;
  const _DataRow({required this.device, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.tableInfo.length; // rebuild trigger

      final bgColor = device.bgColor == '#eeeeee'
          ? const Color(0xFFEEEEEE)
          : const Color(0xFFCCCCCC);

      return Container(
        color: bgColor,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // # Sr No
                _DC(w: 40,
                    child: Text('${device.srNo}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12))),
                _DVDiv(),

                // Before/After label
                SizedBox(
                  width: 55,
                  child: Column(children: [
                    Expanded(child: Center(
                        child: Text('Before',
                            style: const TextStyle(fontSize: 11)))),
                    Container(height: 1, color: Colors.black26),
                    Expanded(child: Center(
                        child: Text('After',
                            style: const TextStyle(fontSize: 11)))),
                  ]),
                ),
                _DVDiv(),

                // Cal Id before/after
                _BACell(w: 130, before: device.calIdBefore, after: device.printCalId),
                _DVDiv(),

                // ECU Sr No before/after
                _BACell(w: 110, before: device.ecuSrNo, after: device.ecuSrNoAfter),
                _DVDiv(),

                // SW Version before/after
                _BACell(w: 100, before: device.swVersionBefore, after: device.swVersionAfter),
                _DVDiv(),

                // CVN before/after
                _BACell(w: 100, before: device.cvnBefore, after: device.cvn),
                _DVDiv(),

                // Final Part No
                _DC(w: 110,
                    child: Text(device.swPartNo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11))),
                _DVDiv(),

                // Dongle indicator
                _DC(w: 52,
                    child: Icon(Icons.usb,
                        size: 26,
                        color: device.dongleFlashingIndicator
                            ? Colors.green : Colors.red)),
                _DVDiv(),

                // ECU indicator
                _DC(w: 50,
                    child: Icon(Icons.memory,
                        size: 26,
                        color: device.ecuFlashingIndicator
                            ? Colors.green : Colors.red)),
                _DVDiv(),

                // Progress bar
                SizedBox(
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (device.isProgressVisible)
                          LinearProgressIndicator(
                            value: device.progress,
                            color: const Color(0xFF51FF0D),
                            backgroundColor: Colors.grey.shade300,
                          ),
                        Text(device.flashPercent,
                            style: const TextStyle(
                                fontSize: 10, color: _kText),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                _DVDiv(),

                // Timer
                _DC(w: 60,
                    child: Text(device.flashTimer,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12))),
                _DVDiv(),

                // Status color box
                _DC(w: 50,
                    child: Container(
                        width: 30, height: 30, color: device.statusColor)),
                _DVDiv(),

                // Report color box
                _DC(w: 50,
                    child: Container(
                        width: 30, height: 30, color: device.reportColor)),
                _DVDiv(),

                // START button (per row — individual flashing)
                SizedBox(
                  width: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: device.playButtonDisable
                            ? Colors.grey : _kOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: device.playButtonDisable || device.isflashing
                          ? null
                          : () => controller.startIndividualFlash(device),
                      child: Text(
                        device.isflashing ? '...' : 'Start',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                _DVDiv(),

                // PRINT button
                SizedBox(
                  width: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: device.printButtonDisable
                            ? Colors.grey : _kOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: device.printButtonDisable
                          ? null
                          : () => controller.printSticker(device),
                      child: const Text('Print',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _DC extends StatelessWidget {
  final double w;
  final Widget child;
  const _DC({required this.w, required this.child});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: w, child: Center(child: child));
}

class _DVDiv extends StatelessWidget {
  const _DVDiv();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: Colors.black);
}

class _BACell extends StatelessWidget {
  final double w;
  final String before;
  final String after;
  const _BACell({required this.w, required this.before, required this.after});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: w,
        child: Column(children: [
          Expanded(child: Center(
              child: Text(before,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center))),
          Container(height: 1, color: Colors.black26),
          Expanded(child: Center(
              child: Text(after,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center))),
        ]),
      );
}

// ════════════════════════════════════════════════════════════
//  Bottom bar — status + CHECK ECU STATUS button
// ════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final IndividualFlashController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Obx(() => Text(controller.currStatus.value,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.checkEcuStatusButton.value
                          ? _kOrange : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: controller.checkEcuStatusButton.value
                        ? controller.checkEcuStatus : null,
                    child: const Text('CHECK ECU STATUS',
                        style: TextStyle(fontSize: 14)),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Alert Popup
// ════════════════════════════════════════════════════════════
class _AlertPopup extends StatelessWidget {
  final IndividualFlashController controller;
  const _AlertPopup({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10)
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 50, color: _kOrange),
              const SizedBox(height: 8),
              const Text('Alert',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() => SingleChildScrollView(
                      child: Text(controller.popupMessage.value,
                          style: const TextStyle(
                              fontSize: 14, color: _kText),
                          textAlign: TextAlign.center),
                    )),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    foregroundColor: Colors.white),
                onPressed: controller.onOkPopup,
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
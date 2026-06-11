// lib/views/screens/dashboard/home_page_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/home_page_controller.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';


const Color _kOrange = Color(0xFFF9772C);
const Color _kDark   = Color(0xFF1E2A3A);
const Color _kBg     = Color(0xFFF5F6FA);
const Color _kText   = Color(0xFF212121);

// ════════════════════════════════════════════════════════════
//  Entry point — controller created INSIDE build so
//  Get.arguments is available
// ════════════════════════════════════════════════════════════
class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create controller here — Get.arguments is ready at this point
    final controller = Get.put(
      HomePageController(
        args: (Get.arguments as Map<String, dynamic>? ) ?? {},
      ),
    );

    return MainLayout(
      title: 'ECU Flashing',
      child: Stack(
        children: [
          Column(
            children: [
              _InfoBar(controller: controller),
              const _TableHeader(),
              Expanded(child: _TableRows(controller: controller)),
              _BottomBar(controller: controller),
            ],
          ),

          // Loading
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(color: _kOrange),
                  ),
                )
              : const SizedBox()),

          // Alert popup
          Obx(() => controller.showAlertPopup.value
              ? _AlertPopup(controller: controller)
              : const SizedBox()),

          // Change ECU popup
          Obx(() => controller.showChangePopup.value
              ? _ChangePopup(controller: controller)
              : const SizedBox()),

          // Print popup
          Obx(() => controller.showPrintPopup.value
              ? _InfoPopup(message: controller.popupMessage.value)
              : const SizedBox()),

          // Wait popup
          Obx(() => controller.showWaitPopup.value
              ? _WaitPopup(seconds: controller.afterFlashSeconds.value)
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
  final HomePageController controller;
  const _Header({required this.controller});

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
                Obx(() => Expanded(
                      child: Text(
                        controller.title.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
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
//  Info bar
// ════════════════════════════════════════════════════════════
class _InfoBar extends StatelessWidget {
  final HomePageController controller;
  const _InfoBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final subModel = controller.selectedSubModel;
    final model    = controller.selectedModel;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Model Details
          Expanded(
            child: Column(
              children: [
                const Text('MODEL DETAILS',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _kText)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text(
                    '${subModel?.description ?? ''}/${model?.name ?? ''}',
                    style: const TextStyle(fontSize: 13, color: _kText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ECU Hardware
          Expanded(
            child: Column(
              children: [
                const Text('ECU HARDWARE',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _kText)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text(
                    subModel?.ecuSubmodel.isNotEmpty == true
                        ? 'ECU ${subModel!.ecuSubmodel[0].ecu}'
                        : '-',
                    style: const TextStyle(fontSize: 13, color: _kText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Reset Dongle
          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isResetDongleEnabled.value
                      ? _kOrange
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: controller.isResetDongleEnabled.value
                    ? controller.resetDongle
                    : null,
                child: const Text('Reset Dongle',
                    style: TextStyle(fontSize: 13)),
              )),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Table header
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
            _TH(w: 90,  text: 'Print'),
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
//  Table rows
// ════════════════════════════════════════════════════════════
class _TableRows extends StatelessWidget {
  final HomePageController controller;
  const _TableRows({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tableInfo.isEmpty) {
        return Center(
          child: Obx(() => Text(
                controller.currStatus.value.isNotEmpty
                    ? controller.currStatus.value
                    : 'Searching...',
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
  final TableInfoModel device;
  final HomePageController controller;
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
                _DC(w: 40,
                    child: Text('${device.srNo}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12))),
                _DVDiv(),

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

                _BACell(w: 130, before: device.calIdBefore,   after: device.printCalId),
                _DVDiv(),
                _BACell(w: 110, before: device.ecuSrNo,       after: device.ecuSrNoAfter),
                _DVDiv(),
                _BACell(w: 100, before: device.swVersionBefore, after: device.swVersionAfter),
                _DVDiv(),
                _BACell(w: 100, before: device.cvnBefore,     after: device.cvn),
                _DVDiv(),

                _DC(w: 110,
                    child: Text(device.swPartNo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11))),
                _DVDiv(),

                _DC(w: 52,
                    child: Icon(Icons.usb,
                        size: 26,
                        color: device.dongleFlashingIndicator
                            ? Colors.green : Colors.red)),
                _DVDiv(),

                _DC(w: 50,
                    child: Icon(Icons.memory,
                        size: 26,
                        color: device.ecuFlashingIndicator
                            ? Colors.green : Colors.red)),
                _DVDiv(),

                // Progress + optional play button
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
                        if (device.playButtonVisible) ...[
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: device.playButtonDisable
                                    ? Colors.grey : _kOrange,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              onPressed: device.playButtonDisable
                                  ? null
                                  : () => controller.startIndividualFlash(device),
                              child: const Text('▶ Flash',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _DVDiv(),

                _DC(w: 60,
                    child: Text(device.flashTimer,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12))),
                _DVDiv(),

                _DC(w: 50,
                    child: Container(width: 30, height: 30, color: device.statusColor)),
                _DVDiv(),

                _DC(w: 50,
                    child: Container(width: 30, height: 30, color: device.reportColor)),
                _DVDiv(),

                SizedBox(
                  width: 90,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 8),
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
//  Bottom bar
// ════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final HomePageController controller;
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
            children: [
              // CHECK ECU STATUS
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
                        style: TextStyle(fontSize: 13)),
                  )),

              const Spacer(),

              // START FLASH (batch only)
              Obx(() => controller.flashingButtonVisible.value
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.startFlashButtonDisable.value
                                  ? Colors.grey : _kOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: controller.startFlashButtonDisable.value
                            ? null : controller.startFlash,
                        child: const Text('START FLASH',
                            style: TextStyle(fontSize: 13)),
                      ),
                    )
                  : const SizedBox()),

              // RESET
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.startResetButtonDisable.value
                              ? Colors.grey : _kOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: controller.startResetButtonDisable.value
                        ? null : controller.reset,
                    child: const Text('RESET',
                        style: TextStyle(fontSize: 13)),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Popups
// ════════════════════════════════════════════════════════════
class _AlertPopup extends StatelessWidget {
  final HomePageController controller;
  const _AlertPopup({required this.controller});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(children: [
        const Icon(Icons.info_outline, size: 55, color: _kOrange),
        const SizedBox(height: 10),
        const Text('Alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: Obx(() => Text(controller.popupMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _kText)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange, foregroundColor: Colors.white),
          onPressed: controller.onOkPopup,
          child: const Text('OK'),
        ),
      ]));
}

class _ChangePopup extends StatelessWidget {
  final HomePageController controller;
  const _ChangePopup({required this.controller});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(children: [
        const Icon(Icons.info_outline, size: 55, color: _kOrange),
        const SizedBox(height: 10),
        const Text('Alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: Obx(() => Text(controller.popupMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _kText)))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange, foregroundColor: Colors.white),
            onPressed: controller.onReflash,
            child: const Text('Reflash'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange, foregroundColor: Colors.white),
            onPressed: controller.onChangeECU,
            child: const Text('Change ECU'),
          ),
        ]),
      ]));
}

class _InfoPopup extends StatelessWidget {
  final String message;
  const _InfoPopup({required this.message});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(children: [
        const Icon(Icons.info_outline, size: 55, color: _kOrange),
        const SizedBox(height: 10),
        const Text('Alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(child: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _kText))),
      ]));
}

class _WaitPopup extends StatelessWidget {
  final int seconds;
  const _WaitPopup({required this.seconds});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_top, size: 55, color: _kOrange),
          const SizedBox(height: 16),
          const Text('Alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Please Wait for $seconds seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: _kText)),
        ],
      ));
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 320,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
}
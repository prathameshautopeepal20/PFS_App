// lib/views/widgets/auto_ecu_detection_banner.dart
// Simple, no animation — avoids SingleTickerProviderStateMixin
// which causes !_debugDuringDeviceUpdate crashes on Windows desktop

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/home_page_controller.dart';

class AutoEcuDetectionBanner extends StatelessWidget {
  const AutoEcuDetectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomePageController>();

    return Obx(() {
      final scanning = ctrl.isAutoScanning.value;
      final status   = ctrl.autoScanStatus.value;
      final enabled  = ctrl.autoDetectEnabled.value;
      final found    = ctrl.donglesFoundCount.value;
      final total    = ctrl.tableInfo.length;

      final bool allFound = enabled && found == total && total > 0;

      final Color bgColor    = allFound
          ? const Color(0xFF1B5E20)
          : enabled ? const Color(0xFF1E293B) : const Color(0xFF1a1a1a);
      final Color textColor  = allFound
          ? Colors.greenAccent
          : enabled ? Colors.white70 : Colors.grey;
      final Color borderColor = allFound
          ? Colors.greenAccent.withOpacity(0.5)
          : Colors.white12;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple dot — no animation, no ticker
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: allFound
                    ? Colors.greenAccent
                    : (enabled && scanning)
                        ? Colors.orangeAccent
                        : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),

            // Status text
            Text(
              enabled
                  ? (status.isNotEmpty ? status : 'Auto-scan active')
                  : 'Auto-detect OFF',
              style: TextStyle(
                color: textColor, fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Dongle count badge
            if (enabled && total > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: allFound
                      ? Colors.greenAccent.withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$found/$total',
                  style: TextStyle(
                    color: allFound ? Colors.greenAccent : Colors.white54,
                    fontSize: 10, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 8),

            // ON/OFF toggle
            GestureDetector(
              onTap: ctrl.toggleAutoDetect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: enabled
                        ? Colors.green.withOpacity(0.5)
                        : Colors.red.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  enabled ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: enabled ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 10, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
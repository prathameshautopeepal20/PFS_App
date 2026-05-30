import 'dart:async';
import 'dart:developer';

import 'package:atpl_flashing_app/utils/usb_web_stub.dart' as html;
class UsbDiscoveryServiceWeb {
  final StreamController<UsbDiscoveredDevice> _discoveredStreamController = StreamController.broadcast();
  Stream<UsbDiscoveredDevice> get discoveredDevices => _discoveredStreamController.stream;

  Future<UsbDiscoveredDevice?> requestWebDevice() async {
    try {
      final dynamic nav = html.window.navigator;
      if (nav.serial == null) throw Exception("Web Serial not supported");

      // 1. Browser popup (User Gesture required)
      final port = await nav.serial.requestPort();
      final info = await port.getInfo();

      // 2. Map to our unified model
      final device = UsbDiscoveredDevice(
        name: "VCI V3 Device",
        deviceId: "web_${info.usbVendorId}_${info.usbProductId}",
        vid: info.usbVendorId ?? 0,
        pid: info.usbProductId ?? 0,
        device: port,
      );
      
      _discoveredStreamController.add(device);
      return device;
    } catch (e) {
      log("User closed picker or error: $e");
      return null;
    }
  }

  void dispose() => _discoveredStreamController.close();
}
class UsbDiscoveredDevice {
  final String name;
  final String manufacturer;
  final String deviceId;
  final int vid;
  final int pid;
  final dynamic device; // On Web, this holds the SerialPort object
  DateTime lastSeen;

  UsbDiscoveredDevice({
    required this.name,
    this.manufacturer = "",
    required this.deviceId,
    required this.vid,
    required this.pid,
    this.device,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();
}
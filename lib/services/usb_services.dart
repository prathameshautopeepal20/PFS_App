import 'dart:async';
import 'dart:developer';

import 'package:usb_serial/usb_serial.dart';

class UsbDiscoveryService {
  final StreamController<UsbDiscoveredDevice> _discoveredStreamController =
      StreamController.broadcast();
  final StreamController<UsbDiscoveredDevice> _deviceOfflineStreamController =
      StreamController.broadcast();

  final Set<int> _discoveredDeviceIds = {}; // prevent duplicates using deviceId
  StreamSubscription? _usbEventSub;
  Timer? _pollingTimer;

  Stream<UsbDiscoveredDevice> get discoveredDevices =>
      _discoveredStreamController.stream;

  Stream<UsbDiscoveredDevice> get deviceOffline =>
      _deviceOfflineStreamController.stream;

  Future<void> startDiscovery() async {
    await stopDiscovery();

    // 1. Initial Scan
    await _scanDevices();

    // 2. Listen for hardware attach/detach events
    _usbEventSub = UsbSerial.usbEventStream?.listen((UsbEvent event) {
      log('[USB Event] ${event.event} : ${event.device}');
      _scanDevices(); 
    });

    // 3. Optional: Periodic polling (fallback for some Android versions)
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _scanDevices());
  }

  Future<void> _scanDevices() async {
    List<UsbDevice> currentDevices = await UsbSerial.listDevices();
    Set<int> currentIds = currentDevices.map((e) => e.deviceId!).toSet();

    // Check for new devices
    for (var device in currentDevices) {
      if (!_discoveredDeviceIds.contains(device.deviceId)) {
        _discoveredDeviceIds.add(device.deviceId!);
        
       final discovered = UsbDiscoveredDevice(
  name: device.productName ?? "Unknown VCI",
  manufacturer: device.manufacturerName ?? "atpl_flashing_app",
  deviceId: device.deviceId!, // Assuming deviceId is never null here
  vid: device.vid ?? 0,       // Fix: Provide default if null
  pid: device.pid ?? 0,       // Fix: Provide default if null
  device: device,
);

        _discoveredStreamController.add(discovered);
        log('[USB Discovery] Found: $discovered');
      }
    }

    // Check for lost devices
    List<int> lostIds = _discoveredDeviceIds.where((id) => !currentIds.contains(id)).toList();
    for (var id in lostIds) {
      _discoveredDeviceIds.remove(id);
      // Notify offline
      _deviceOfflineStreamController.add(UsbDiscoveredDevice(
        name: "Lost Device",
        deviceId: id,
        vid: 0,
        pid: 0,
      ));
      log('[USB Discovery] Device Lost: ID $id');
    }
  }

  Future<void> stopDiscovery() async {
    await _usbEventSub?.cancel();
    _pollingTimer?.cancel();
    _usbEventSub = null;
    _pollingTimer = null;
    _discoveredDeviceIds.clear();
  }

  Future<void> dispose() async {
    await stopDiscovery();
    await _discoveredStreamController.close();
    await _deviceOfflineStreamController.close();
  }
}

class UsbDiscoveredDevice {
  final String name;
  final String manufacturer;
  final int deviceId;
  final int vid;
  final int pid;
  final UsbDevice? device; // Reference to the actual UsbDevice object
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

  @override
  String toString() => 'UsbDevice{name: $name, VID: $vid, PID: $pid, ID: $deviceId}';
}
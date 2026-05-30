import 'dart:io';
import 'dart:async';
import 'package:atpl_flashing_app/common_widgets/popup.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/AddrecipeController.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/sensorAnalysisController.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/testingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PLCController extends GetxController {
  var isConnected = false.obs;
  var isConnecting = false.obs;
  var debugStatus = "Idle".obs;
  var plcDataValue = 0.obs;
  int? currentRegister;
  final ipController = TextEditingController();
  final portController = TextEditingController();
  Socket? socket;
  @override
  void onInit() {
    super.onInit();
    loadSettings(); // Load IP/Port automatically when screen opens
  }

  Future<void> saveSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('plc_ip', ipController.text);
      await prefs.setString('plc_port', portController.text);
      print("Settings Saved: ${ipController.text}:${portController.text}");
    } catch (e) {
      Get.dialog(
        CustomPopup(
          title: "Error saving settings:",
          message: "$e",
          isError: true, // This will make the button red and add an icon
        ),
      );
    }
  }

  // --- LOAD FROM SHARED PREFERENCES ---
  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    ipController.text = prefs.getString('plc_ip') ?? '';

    final dynamic storedPort = prefs.get('plc_port');

    int port;

    if (storedPort is int) {
      port = storedPort;
    } else if (storedPort is String) {
      port = int.tryParse(storedPort) ?? 502;
    } else {
      port = 502;
    }

    portController.text = port.toString();
  }

  // --- 2. CONNECTION LOGIC ---
  // Future<void> connectToPLC(String ip, String port) async {
  //   if (isConnecting.value) return;
  //   await _cleanupBeforeConnect();

  //   int? portNum = int.tryParse(port);
  //   if (portNum == null) return;

  //   try {
  //     isConnecting.value = true;
  //     debugStatus.value = "Connecting...";
  //     socket = await Socket.connect(ip, portNum,
  //         timeout: const Duration(seconds: 4));
  //     socket!.setOption(SocketOption.tcpNoDelay, true);

  //     isConnected.value = true;
  //     debugStatus.value = "Connected";

  //     socket!.listen(
  //       (data) => _handleResponse(data),
  //       onError: (err) => disconnect(),
  //       onDone: () => disconnect(),
  //       cancelOnError: true,
  //     );
  //   } catch (e) {
  //     debugStatus.value = "Connect Error";
  //     disconnect();
  //   } finally {
  //     isConnecting.value = false;
  //   }
  // }
  Future<void> connectToPLC(String ip) async {
    if (isConnecting.value) return;

    await _cleanupBeforeConnect();

    const int portNum = 502;

    try {
      isConnecting.value = true;
      debugStatus.value = "Connecting...";

      print("🔍 [PLC] Attempting to connect to $ip on port $portNum...");

      // Use InternetAddress.lookup or specify IPv4 to skip DNS delays
      socket = await Socket.connect(
        ip,
        portNum,
        timeout: const Duration(seconds: 4),
      );

      // Important for Modbus performance
      socket!.setOption(SocketOption.tcpNoDelay, true);

      isConnected.value = true;
      debugStatus.value = "Connected";

      socket!.listen(
        _handleResponse,
        onError: (err) {
          print("❌ [PLC] Socket Stream Error: $err");
          disconnect();
        },
        onDone: () {
          print("ℹ️ [PLC] Connection closed by server.");
          disconnect();
        },
        cancelOnError: true,
      );
    } on SocketException catch (e) {
      debugStatus.value = "Unreachable";
      print("❌ [PLC] Network unreachable or refused: ${e.message}");
      disconnect();
    } catch (e) {
      debugStatus.value = "Connect Error";
      print("❌ [PLC] General Exception: $e");
      disconnect();
    } finally {
      isConnecting.value = false;
    }
  }

  void sendGeneratorDataRequest() {
    if (socket == null || !isConnected.value) return;

    //MODBUS TCP PACKET STRUCTURE (No CRC!)
    List<int> packet = [
      0x00, 0x01, // Transaction ID (0001)
      0x00, 0x00, // Protocol ID (Always 0 for Modbus)
      0x00, 0x06, // Length (6 bytes follow: UnitID + Func + Addr + Count)
      0x01, // Unit ID (Slave ID)
      0x03, // Function Code (Read Holding Register)
      0x00, 0x01, // Starting Address (Register 1)
      0x00, 0x01 // Quantity (Read 1 register)
    ];

    socket!.add(packet);
    _printHex("SENT", packet);
  }

  // void _handleResponse(List<int> data) {
  //   _printHex("RESPONSE", data);

  //   if (data.length >= 11 && data[7] == 0x03) {
  //     int rawValue = (data[9] << 8) | data[10];
  //     print("Parsed VALUE: $rawValue");

  //     // ✅ ROUTE TO ESN CONTROLLER (MAIN FIX)
  //     if (Get.isRegistered<ESNController>() && currentRegister != null) {
  //       final esnCtrl = Get.find<ESNController>();
  //       esnCtrl.handlePlcData(currentRegister!, rawValue);
  //     }

  //     // OPTIONAL (keep your existing flows)
  //     if (Get.isRegistered<SensorAnalysisController>()) {
  //       Get.find<SensorAnalysisController>().addRealHardwarePoint(rawValue);
  //     }

  //     if (Get.isRegistered<AddRecipeController>()) {
  //       final recipeCtrl = Get.find<AddRecipeController>();

  //       double m = double.tryParse(recipeCtrl.multiplier.value.text) ?? 1.0;
  //       double c = double.tryParse(recipeCtrl.offset.value.text) ?? 0.0;

  //       double value = (rawValue * m) + c;

  //       recipeCtrl.testResult.value.text = value.toStringAsFixed(2);
  //     }
  //   }
  // }

  void _handleResponse(List<int> data) {
  _printHex("RESPONSE", data);

  if (data.length >= 11 && data[7] == 0x03) {
    int rawValue = (data[9] << 8) | data[10];
    print("Parsed VALUE: $rawValue");

    // ✅ ROUTE TO ANALYSIS FIRST (if analysis is active)
    if (Get.isRegistered<SensorAnalysisController>()) {
      final analysisCtrl = Get.find<SensorAnalysisController>();
      if (analysisCtrl.isAnalyzing.value && !analysisCtrl.isPaused.value) {
        print("📊 [ROUTE] → SensorAnalysisController");
        analysisCtrl.addRealHardwarePoint(rawValue);
        return; // ✅ Don't double-process
      }
    }

    // ✅ ROUTE TO TESTING SCREEN (if testing is active)
    if (Get.isRegistered<ESNController>() && currentRegister != null) {
      final esnCtrl = Get.find<ESNController>();
      if (esnCtrl.isTesting.value) {
        print("🔬 [ROUTE] → ESNController (Testing) | Reg: $currentRegister");
        esnCtrl.handlePlcData(currentRegister!, rawValue);
        return;
      }
    }

    // ✅ ROUTE TO RECIPE CONTROLLER (if adding recipe)
    if (Get.isRegistered<AddRecipeController>()) {
      final recipeCtrl = Get.find<AddRecipeController>();
      print("📋 [ROUTE] → AddRecipeController");

      double m = double.tryParse(recipeCtrl.multiplier.value.text) ?? 1.0;
      double c = double.tryParse(recipeCtrl.offset.value.text) ?? 0.0;
      double value = (rawValue * m) + c;

      recipeCtrl.testResult.value.text = value.toStringAsFixed(2);
      return;
    }

    // ✅ FALLBACK — route to ESN anyway (e.g. manual single read)
    if (Get.isRegistered<ESNController>() && currentRegister != null) {
      print("🔁 [ROUTE] → ESNController (Fallback)");
      Get.find<ESNController>().handlePlcData(currentRegister!, rawValue);
    }
  }
}

  void sendPacket(List<int> packet) {
    if (socket != null && isConnected.value) {
      socket!.add(packet);
      _printHex("SENT", packet);
    } else {
      print("Cannot send: Socket is null or disconnected");
    }
  }

  void _printHex(String label, List<int> data) {
    String hex = data
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
    print("$label: $hex");
  }

  void disconnect() {
    socket?.destroy();
    socket = null;
    isConnected.value = false;
    debugStatus.value = "Disconnected";
  }

  Future<void> _cleanupBeforeConnect() async {
    isConnected.value = false;
    if (socket != null) {
      socket!.destroy();
      socket = null;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

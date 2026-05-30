

import 'dart:async';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:atpl_flashing_app/services/mdns_command_helper.dart';

class UsbSerialService {
  final UsbDevice device;
  UsbPort? _port;
  bool isConnected = false;

  final StreamController<Uint8List> _responseStream = StreamController.broadcast();
  
  UsbSerialService({required this.device});

  Stream<Uint8List> get responses => _responseStream.stream;

  Future<void> connect({int baudRate = 115200}) async {
    try {
      _port = await device.create();
      bool openResult = await _port!.open();

      if (!openResult) {
        Fluttertoast.showToast(msg: "❌ Permission Denied");
        throw Exception("Could not open USB port.");
      }

      // Setting parameters based on .NET reference (8N1)
      await _port!.setPortParameters(
        baudRate, 
        UsbPort.DATABITS_8, 
        UsbPort.STOPBITS_1, 
        UsbPort.PARITY_NONE
      );

      // CRITICAL: .NET code often toggles DTR/RTS to reset/wake the VCI
      await _port!.setDTR(true);
      await _port!.setRTS(true);

      // Drain existing buffer noise
      StreamSubscription? drain = _port!.inputStream!.listen((data) {});
      await Future.delayed(const Duration(milliseconds: 200));
      await drain.cancel();

      isConnected = true;
      Fluttertoast.showToast(msg: "✅ Port Open ($baudRate Baud)");

      _port!.inputStream!.listen(
        _handleData,
        onError: (e) => Fluttertoast.showToast(msg: "⚠️ Stream Error: $e"),
        onDone: () => disconnect(),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Connect Error: $e");
      rethrow;
    }
  }

  // Defined disconnect method to fix your controller error
  Future<void> disconnect() async {
    try {
      isConnected = false;
      await _port?.close();
      _port = null;
      Fluttertoast.showToast(msg: "🔒 USB Disconnected");
    } catch (e) {
      print("Disconnect error: $e");
    }
  }

  Future<bool> sendSecurityKey(Uint8List keyBytes) async {
    if (_port == null || !isConnected) return false;

    try {
      // Clear accumulator
      final List<int> responseBuffer = [];
      final completer = Completer<bool>();

      var sub = _responseStream.stream.listen((data) {
        responseBuffer.addAll(data);
        if (responseBuffer.isNotEmpty && !completer.isCompleted) {
          completer.complete(true);
        }
      });

      await _port!.write(keyBytes);

      bool received = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );

      await sub.cancel();
      
      if (received) {
        String hex = MdnsCommandHelper.bytesToHex(Uint8List.fromList(responseBuffer));
        Fluttertoast.showToast(msg: "📥 RX: $hex");
      }
      return received;
    } catch (e) {
      return false;
    }
  }

  void _handleData(Uint8List data) {
    if (isConnected) _responseStream.add(data);
  }
}
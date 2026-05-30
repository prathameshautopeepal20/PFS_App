// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:async';
// import 'package:atpl_flashing_app/services/foreground_servie_helper.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// import 'mdns_command_helper.dart';

// class MdnsSocketService {
//   final String host;
//   final int port;
//   Socket? _socket;
//   dynamic handleData;
//   // New field
//   bool isConnected = false;

//   final StreamController<Uint8List> _responseStream =
//       StreamController.broadcast();
//   final StreamController<bool> _connectionStream = StreamController.broadcast();

//   MdnsSocketService({required this.host, required this.port});

//   Stream<Uint8List> get responses => _responseStream.stream;
//   Stream<bool> get connectionUpdates => _connectionStream.stream;

//   Future<void> connect() async {
//     try {
//       _socket = await Socket.connect(host, port, timeout: Duration(seconds: 3));
//       print("SOCKET CONNECTED");
//       startForegroundService();
//       isConnected = true;
//       _connectionStream.add(true);

//       _socket!.listen(
//         _handleData,
//         onError: (e) {
//           print("Socket error: $e");
//           isConnected = false;
//           _connectionStream.add(false);
//           FlutterForegroundTask.stopService();
//            _reconnect();
//         },
//         onDone: () {
//           print("onDone called and socket disconnected");
//           isConnected = false;
//           _connectionStream.add(false);
//           FlutterForegroundTask.stopService();
//         },
//         cancelOnError: true,
//       );
//     } on SocketException catch (e) {
//       isConnected = false;
//       _connectionStream.add(false);
//       print('SocketException during connect: $e');
//       rethrow;
//     } catch (e) {
//       isConnected = false;
//       _connectionStream.add(false);
//       rethrow;
//     }
//   }

//   Future<bool> tryConnection() async {
//     try {
//       _socket = await Socket.connect(host, port, timeout: Duration(seconds: 3));
//       return true;
//     // ignore: unused_catch_clause
//     } on SocketException catch (e) {
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }
// Future<bool> sendSecurityKey(Uint8List keyBytes) async {
//   try {
//     if (_socket == null || !isConnected) return false;

//     // Clear the stream buffer by waiting for a tiny bit
//     // then send the key
//     _socket!.add(keyBytes);
//     await _socket!.flush();

//     // The ESP32 usually responds with the same key or a success byte (0x06)
//     final response = await _responseStream.stream.first.timeout(
//       const Duration(seconds: 4),
//     );

//     print('Handshake Response: ${MdnsCommandHelper.bytesToHex(response)}');
//     return true; 
//   } on TimeoutException {
//     print("Handshake Timed Out - No response from ESP32");
//     return false;
//   } catch (e) {
//     print("Handshake Error: $e");
//     return false;
//   }
// }

//   Future<void> sendCommand(Uint8List command) async {
//     try {
//       if (_socket == null || !isConnected) {
//        // AppToast.error("Socket disconnected");
//       }

//       if (!isConnected) {
//         print('sendCommand failed: Socket not connected');
//         return;
//       }

//       print('Sending Command (HEX) >>> ${MdnsCommandHelper.bytesToHex(command)}');
//       _socket!.add(command);
//       await _socket!.flush();

//       try {
//         // ignore: unused_local_variable
//         final response = await _responseStream.stream.first.timeout(
//           Duration(seconds: 5),
//         );

//         print('Response received within 5 seconds');
//       } on TimeoutException {
//         print(
//           'No response received in 5 seconds. Assuming device is disconnected.',
//         );
//         await disconnect();
//       }
//     } catch (e) {
//       print('exception while sending command $e');
//       await disconnect();
//     }
//   }

//   void _handleData(Uint8List data) {
//     print('Response (HEX) >>> ${MdnsCommandHelper.bytesToHex(data)}');
//     print('Response (Raw) >>> $data');
//     if (isConnected == true) {
//       _responseStream.add(data);
//     }
//   }

//   Future<void> disconnect() async {
//     await _socket?.close();
//     //await _socket?.close();
//     _socket = null;
//     isConnected = false;
//     _connectionStream.add(false);
//   }

//   Future<void> _reconnect() async {
//     await disconnect();
//     await Future.delayed(Duration(seconds: 2));
//     await connect();
//   }

//   void dispose() {
//     _socket?.close();
//     _responseStream.close();
//     _connectionStream.close();
//     isConnected = false;
//   }
// }
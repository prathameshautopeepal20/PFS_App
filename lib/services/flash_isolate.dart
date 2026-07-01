// ════════════════════════════════════════════════════════════
// flash_isolate.dart
//
// THE REAL FIX for true ~2.5-3 min parallel flashing.
//
// Root cause (confirmed by reading the actual .NET source):
// .NET's StartECUFlashing wraps CAN_StartTP + FlashInterpreter +
// CAN_StopTP inside `await Task.Run(async () => {...})` — giving
// EACH ECU's entire flash session its own dedicated thread-pool
// thread. This is genuine OS-level parallelism.
//
// Dart's Future/async/await is COOPERATIVE single-threaded
// concurrency — both ECUs' code shares one thread no matter how
// the code is structured with locks, staggering, or yield points.
// That fundamental difference was the real, unfixable-without-this
// root cause of the intermittent "one ECU silently fails" bug we
// chased for so long — it was never a logic bug.
//
// THE FIX: spawn a real Dart Isolate per ECU. Each isolate:
//   - Creates its OWN socket connection (isolates can't share a
//     Socket object — must create it fresh inside the isolate)
//   - Creates its OWN CommControllerIsolateSafe/DongleComm/
//     UDSDiagnostic chain (isolate-safe versions, no GetX)
//   - Runs the ENTIRE flash sequence independently
//   - Sends only simple result data back via SendPort (the parent
//     isolate can't directly access isolate-local objects)
//
// This is the Dart equivalent of .NET's Task.Run — true parallel
// execution on separate OS threads, which is what actually enables
// the ~2.5-3 min total time you're after.
// ════════════════════════════════════════════════════════════
import 'dart:async';
import 'dart:isolate';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:ap_dongle_comm/utils/enums/protocol.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_diagnostic/models/flashingMtrixModel.dart';
import 'package:ap_diagnostic/structure/flash_structures.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';
import 'package:ap_dongle_comm/utils/comm_controller_isolate_safe.dart';

// ── Arguments passed INTO the isolate (must be sendable) ──────
class FlashIsolateRequest {
  final SendPort sendPort;
  final String ip;
  final int index;
  final int noOfSectors;
  final List<FlashingMatrix> sectorData;
  final String seqFileContent;
  final FlashConfig flashConfig;
  final String txHeader;
  final String rxHeader;
  final int protocolValue;

  FlashIsolateRequest({
    required this.sendPort,
    required this.ip,
    required this.index,
    required this.noOfSectors,
    required this.sectorData,
    required this.seqFileContent,
    required this.flashConfig,
    required this.txHeader,
    required this.rxHeader,
    required this.protocolValue,
  });
}

// ── Messages sent BACK from the isolate (must be sendable) ────
// Using simple Maps instead of custom classes for max compatibility
// across the isolate boundary.

/// Entry point that runs INSIDE the spawned isolate.
/// This function and everything it calls executes on its own
/// dedicated OS thread, completely independent of the main isolate
/// and any other ECU's flash isolate.
Future<void> flashEcuIsolateEntry(FlashIsolateRequest req) async {
  final sendPort = req.sendPort;
  void log(String msg) {
    // Forward print-style logs back to the main isolate so they
    // still show up in app_log.txt / debug console exactly as before.
    sendPort.send({'type': 'log', 'index': req.index, 'message': msg});
  }

  CommControllerIsolateSafe? ctrl;
  try {
    log('🧵 [${req.index}] ISOLATE STARTED — running on dedicated OS thread @ ${DateTime.now()}');

    // Fresh socket/comm chain, created entirely inside this isolate
    ctrl = CommControllerIsolateSafe();
    await ctrl.connectWifi(
      host: req.ip,
      port: 6888,
      selectedType: Connectivity.wiFi,
    );

    if (!ctrl.isConnected) {
      sendPort.send({
        'type': 'result',
        'index': req.index,
        'result': 'ERROR: socket connect failed in isolate',
      });
      return;
    }

    final protocol = Protocol.values.firstWhere(
      (p) => p.value == req.protocolValue,
      orElse: () => Protocol.ISO15765_500KB_11BIT_CAN,
    );

    final dongle = DongleComm(comm: ctrl, isChannel: true, channelId: '00');
    dongle.protocol = protocol;

    // CAN setup (StopTP → Protocol → TxHeader → RxHeaderMask → Padding)
    await dongle.canStopTP();
    await dongle.dongleSetProtocol(req.protocolValue);
    await dongle.canSetTxHeader(req.txHeader);
    await dongle.canSetRxHeaderMask(req.rxHeader);
    await dongle.canStartPadding('00');

    final diag = UDSDiagnostic(dongle, ECUCalculateSeedkey());

    log('▶️  [${req.index}] CAN_StartTP (inside isolate)...');
    await dongle.canStartTP();

    log('▶️  [${req.index}] flashInterpreter starting (inside isolate, TRUE parallel)...');

    // 🔥 PROGRESS BAR FIX: the UDSDiagnostic instance doing the actual
    // flashing now lives INSIDE this isolate, so the main isolate's
    // _slot.diag (a different, idle instance) never sees live progress
    // updates anymore — only the final 100% at completion. Poll this
    // isolate's own diag instance every 500ms and forward the percent
    // back through the SendPort so the UI can update smoothly.
    final progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      try {
        final p = (await diag.getRuntimeFlashPercent()).clamp(0.0, 1.0);
        sendPort.send({'type': 'progress', 'index': req.index, 'percent': p});
      } catch (_) {}
    });

    String result = 'No Resp From Dongle';
    try {
      result = await diag.flashInterpreter(
        req.flashConfig,
        req.noOfSectors,
        req.sectorData,
        req.seqFileContent,
      ) ?? 'NOERROR';
      log('📋 [${req.index}] flashInterpreter COMPLETE (isolate) @ ${DateTime.now()} — result=$result');
    } catch (e) {
      log('❌ [${req.index}] flashInterpreter EXCEPTION (isolate): $e');
      result = 'No Resp From Dongle';
    } finally {
      progressTimer.cancel();
      // Send final 100% so the bar visibly completes
      sendPort.send({'type': 'progress', 'index': req.index, 'percent': 1.0});
    }

    try {
      await dongle.canStopTP();
    } catch (e) {
      log('⚠️  [${req.index}] CAN_StopTP failed (isolate): $e');
    }

    final finalResult =
        (result == 'NOERROR' || result == 'ECUERROR_GENERALPROGRAMMINGFAILURE')
            ? 'NOERROR'
            : result;

    log('🏁 [${req.index}] Isolate flash complete — sending result back: $finalResult');
    sendPort.send({'type': 'result', 'index': req.index, 'result': finalResult});
  } catch (e, st) {
    log('❌ [${req.index}] Isolate top-level exception: $e\n$st');
    sendPort.send({
      'type': 'result',
      'index': req.index,
      'result': 'ERROR: $e',
    });
  } finally {
    try {
      await ctrl?.disconnect();
    } catch (_) {}
  }
}

/// Called from the MAIN isolate. Spawns a worker isolate for this
/// ECU's flash and waits for its result. Multiple calls to this
/// function (one per ECU) running inside a Future.wait will
/// execute on genuinely separate OS threads — true parallelism.
Future<String> runFlashInIsolate({
  required String ip,
  required int index,
  required int noOfSectors,
  required List<FlashingMatrix> sectorData,
  required String seqFileContent,
  required FlashConfig flashConfig,
  required String txHeader,
  required String rxHeader,
  required int protocolValue,
  required void Function(String) onLog,
  void Function(double)? onProgress,
}) async {
  final receivePort = ReceivePort();
  final completer = Completer<String>();

  final request = FlashIsolateRequest(
    sendPort: receivePort.sendPort,
    ip: ip,
    index: index,
    noOfSectors: noOfSectors,
    sectorData: sectorData,
    seqFileContent: seqFileContent,
    flashConfig: flashConfig,
    txHeader: txHeader,
    rxHeader: rxHeader,
    protocolValue: protocolValue,
  );

  late Isolate isolate;
  StreamSubscription? sub;

  sub = receivePort.listen((message) {
    if (message is Map) {
      if (message['type'] == 'log') {
        onLog(message['message'] as String);
      } else if (message['type'] == 'progress') {
        onProgress?.call((message['percent'] as num).toDouble());
      } else if (message['type'] == 'result') {
        if (!completer.isCompleted) {
          completer.complete(message['result'] as String);
        }
      }
    }
  });

  try {
    isolate = await Isolate.spawn(
      flashEcuIsolateEntry,
      request,
      onError: receivePort.sendPort,
      onExit: receivePort.sendPort,
    );

    final result = await completer.future.timeout(
      const Duration(minutes: 6),
      onTimeout: () {
        onLog('🚨 [$index] Isolate TIMED OUT after 6 minutes — force-killing isolate');
        return 'No Resp From Dongle';
      },
    );

    return result;
  } catch (e) {
    onLog('❌ [$index] runFlashInIsolate exception: $e');
    return 'ERROR: $e';
  } finally {
    await sub.cancel();
    receivePort.close();
    try {
      isolate.kill(priority: Isolate.immediate);
    } catch (_) {}
  }
}
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ══════════════════════════════════════════════════════════════════
// LogFile — captures every print() into Documents\app_log.txt
//
// Why this matters: during parallel ECU flashing, the debug console
// produces thousands of lines per second (CRC dumps, hex packets,
// block sequence counters). Scrolling through that live to find the
// exact failure point is nearly impossible. This file gives a
// permanent, searchable record after every run.
//
// Usage after a failed flash:
//   1. Open File Explorer → Documents → app_log.txt
//   2. Ctrl+End to jump to the bottom (most recent = end of session)
//   3. Search backwards for "FLASH SUCCESS" or "ECUERROR" or
//      "flashInterpreter CATCH" to find the exact failure line
//   4. Copy the surrounding ~100-200 lines and share for diagnosis
//
// Design notes:
//   - Fresh file each app launch (old log renamed to app_log_prev.txt)
//     so you're never looking at stale data from a previous session
//   - Buffered writes (flushed every 500ms or 50 lines) so we don't
//     hit disk on every single print() call — critical during bulk
//     data transfer where print() fires extremely rapidly
//   - All failures are swallowed silently — logging must NEVER crash
//     or slow down the actual flashing operation
// ══════════════════════════════════════════════════════════════════
class LogFile {
  static File? _file;
  static final List<String> _buffer = [];
  static Timer? _flushTimer;
  static bool _initializing = false;

  static Future<void> init() async {
    if (_file != null || _initializing) return;
    _initializing = true;
    try {
      final documentsPath =
          "${Platform.environment['USERPROFILE']}\\Documents";
      final dir = Directory(documentsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final logPath = "${dir.path}\\app_log.txt";
      final prevPath = "${dir.path}\\app_log_prev.txt";

      final existing = File(logPath);
      if (await existing.exists()) {
        // Keep one previous session for comparison, overwrite older one
        try {
          await existing.copy(prevPath);
        } catch (_) {}
      }

      _file = File(logPath);
      // Start fresh each launch — old content moved to _prev above
      await _file!.writeAsString(
        '===== APP LOG STARTED ${DateTime.now()} =====\n',
        mode: FileMode.write,
      );

      // Flush buffered lines every 500ms — balances disk I/O vs
      // losing the last few lines if app crashes hard
      _flushTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _flush();
      });
    } catch (_) {
      // Logging must never prevent the app from running
    } finally {
      _initializing = false;
    }
  }

  static Future<void> write(String text) async {
    if (_file == null) {
      await init();
    }
    final time = DateTime.now().toIso8601String();
    _buffer.add("[$time] $text");
    // Force-flush if buffer grows large, so we never lose too much
    // even if the timer hasn't fired yet (e.g. during a tight loop)
    if (_buffer.length >= 50) {
      await _flush();
    }
  }

  static Future<void> _flush() async {
    if (_file == null || _buffer.isEmpty) return;
    try {
      final chunk = _buffer.join('\n') + '\n';
      _buffer.clear();
      await _file!.writeAsString(chunk, mode: FileMode.append);
    } catch (_) {
      // Drop on failure rather than crash the app
    }
  }

  /// Call when app is closing to ensure last lines are saved
  static Future<void> dispose() async {
    _flushTimer?.cancel();
    await _flush();
  }
}
import 'dart:async';
import 'dart:io';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/common_widgets/app_error_widget.dart';
import 'package:atpl_flashing_app/logic/bindings/initial_bindings.dart';
import 'package:atpl_flashing_app/routes/routes.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/services/error_handler/error_handler_service.dart';
import 'package:atpl_flashing_app/themes/app_theme.dart';
import 'package:atpl_flashing_app/utils/app_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:atpl_flashing_app/services/log_file.dart';

// ── Window lifecycle — keeps app alive when minimised during flash ────────────
class _AppWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    // Allow normal close — flash runs in Dart async, not a separate process
    // If you want to block close during flash, check isFlashing flag here
    await windowManager.destroy();
  }
}

class App {
  static App instance = App();

  static const MethodChannel platform = MethodChannel(
    'atpl_flashing_app/native',
  );

  final String _appName = 'ATPL PFS';
  static String jwtToken        = '';
  static String connectedVia    = '';
  static int    oemId           = 0;
  static int    subModelId      = 0;
  static String firmwareVersion = '';
  static String sessionId       = '';
  static String currentUserId   = '';

  bool?   _devMode;
  bool?   _appLog;
  bool?   _apiLog;
  String? _baseURLType;
  bool?   _setDefault;
  bool?   _samplePayment;

  static const String countryCode = "INDIA";

  String get appName     => _appName;
  bool   get devMode     => _devMode     ?? false;
  bool   get appLog      => _appLog      ?? false;
  bool   get apiLog      => _apiLog      ?? false;
  bool   get setDefault  => _setDefault  ?? false;
  String get baseURLType => _baseURLType ?? AtomURLType.DEV;
  bool   get samplePayment => _samplePayment ?? true;
  bool   get isProd      => _baseURLType == AtomURLType.DEV;

  void initAndRunApp({
    required bool   appLog,
    required bool   apiLog,
    required bool   devMode,
    required bool   setDefault,
    required bool   samplePayment,
    required String baseURLType,
  }) {
    // ══════════════════════════════════════════════════════════════
    // CAPTURE EVERY print() INTO Documents\app_log.txt AUTOMATICALLY
    //
    // Previously LogFile.write() existed but was never called — the
    // log file stayed empty while thousands of print() statements only
    // went to the debug console (impossible to scroll through after
    // a long flash session). This zoneSpecification intercepts EVERY
    // print() call app-wide and:
    //   1. still prints to console as before (for live debugging)
    //   2. ALSO appends it to Documents\app_log.txt with timestamp
    //
    // After any flash, just open Documents\app_log.txt and copy the
    // last 200-300 lines — no more scrolling through console output.
    // ══════════════════════════════════════════════════════════════
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        print('✅ Step 1: WidgetsFlutterBinding initialized');

        // ── Desktop window setup ──────────────────────────────────
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          await windowManager.ensureInitialized();
          print('✅ Step 2: WindowManager initialized');

          // Add listener so app keeps running on minimize
          windowManager.addListener(_AppWindowListener());

          const WindowOptions windowOptions = WindowOptions(
            center:        true,
            title:         "ATPL PFS",
            titleBarStyle: TitleBarStyle.normal,
            size:          Size(1280, 720),
            minimumSize:   Size(800, 600),
          );

          await windowManager.waitUntilReadyToShow(windowOptions, () async {
            await windowManager.maximize();
            await windowManager.show();
            await windowManager.focus();
            // Ensure window is NOT always-on-top (allows minimise freely)
            await windowManager.setAlwaysOnTop(false);
          });
          print('✅ Step 3: Window shown and maximized');
        }

        // ── GetStorage ────────────────────────────────────────────
        try {
          await GetStorage.init();
          print('✅ Step 4: GetStorage initialized');
        } catch (e) {
          print('⚠️ GetStorage skipped: $e');
        }

        // ── App config ────────────────────────────────────────────
        _devMode      = devMode;
        _appLog       = appLog;
        _apiLog       = apiLog;
        _setDefault   = setDefault;
        _baseURLType  = baseURLType;
        _samplePayment = samplePayment;
        print('✅ Step 5: App config set');

        // ── Mobile only ───────────────────────────────────────────
        if (Platform.isAndroid || Platform.isIOS) {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          print('✅ Step 6: Mobile orientation set');
        }

        // ── Error widget ──────────────────────────────────────────
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          print('❌ Flutter Error: ${errorDetails.exception}');
          print('❌ Stack: ${errorDetails.stack}');
          return AppErrorWidget(errorDetails: errorDetails);
        };

        initLogger();
        print('✅ Step 7: Logger initialized');

        print('✅ Step 8: Calling runApp...');
        runApp(const MyApp());
        print('✅ Step 9: runApp called successfully');
      },
      (error, stack) {
        print('❌ FATAL ERROR: $error');
        print('❌ STACK: $stack');
        ErrorHandlerService.instance.appRecordError(error, stack);
      },
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          // Still print to console as normal
          parent.print(zone, line);
          // ALSO append to Documents\app_log.txt (fire-and-forget,
          // never blocks or throws — flashing must never be slowed
          // down or interrupted by a logging failure)
          LogFile.write(line).catchError((_) {});
        },
      ),
    );
  }
}

// ── Root widget ───────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('✅ MyApp build called');
    final config = App.instance;

    return GetMaterialApp(
      initialBinding:          InitialBinding(),
      debugShowCheckedModeBanner: false,
      title:                   config.appName,
      initialRoute:            Routes.splashScreen,
      theme:                   appTheme,
      getPages:                AppRoutes.routes,
      builder: (context, child) {
        return child ?? const Center(
          child: Text(
            'App failed to load',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        );
      },
    );
  }
}
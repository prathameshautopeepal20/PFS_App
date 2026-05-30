import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/app.dart';
import 'package:atpl_flashing_app/services/log_file.dart'; // ✅ FIXED PATH

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LogFile.init();

  App.instance.initAndRunApp(
    devMode: true,
    appLog: true,
    apiLog: false,
    setDefault: true,
    samplePayment: true,
    baseURLType: AtomURLType.PROD,
  );
}
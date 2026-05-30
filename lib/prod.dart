import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/app.dart';

void main() async {
  App.instance.initAndRunApp(
    devMode: false,
    appLog: false,
    apiLog: false,
    setDefault: true,
    samplePayment: true,
    baseURLType: AtomURLType.PROD,
  );
}

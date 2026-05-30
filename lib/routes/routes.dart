import 'package:atpl_flashing_app/dev/dev_screen.dart';
import 'package:atpl_flashing_app/logic/bindings/dashboard_bindings.dart';
import 'package:atpl_flashing_app/logic/bindings/login_bindings.dart';
import 'package:atpl_flashing_app/logic/bindings/testing_bindings.dart';
import 'package:atpl_flashing_app/views/screens/auth/login.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/dashboard.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/recipeAdditionScreen.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/recipeAdditionScreenReadOnly.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/sensorAnalysis.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/settings.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/testRecipeScreen.dart';
import 'package:atpl_flashing_app/views/screens/dashboard/testingScreen.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:atpl_flashing_app/views/screens/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: Routes.splashScreen, page: () => SplashScreen()),
    GetPage(name: Routes.devScreen, page: () => DevScreen()),
    GetPage(
      name: Routes.loginScreen,
      binding: LoginBindings(),
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.testingScreen,
      binding: TestingBinding(),
      page: () => TestingScreen(),
    ),
    GetPage(
      name: Routes.testRecipeScreen,
      //binding: LoginBindings(),
      page: () => TestRecipeScreen(),
    ),
    GetPage(
      name: Routes.recipeAdditionScreen,
      //binding: LoginBindings(),
      page: () => RecipeAdditionScreen(),
    ),
    GetPage(
      name: Routes.dashboardScreen,
      binding: DashboardBindings(),
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: Routes.loginScreen,
      binding: LoginBindings(),
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.settingsScreen,
      page: () => SettingsScreen(),
    ),
     GetPage(
      name: Routes.recipeAdditionReadOnlyScreen,
      page: () => RecipeAdditionReadOnly(),
    ),
     GetPage(
      name: Routes.sensorAnalysis,
      page: () => SensorAnalysisScreen(),
    ),
    // GetPage(
    //   name: Routes.registerScreen,
    //   binding: RegisterBindings(),
    //   page: () => RegisterScreen(),
    // ),
  ];
}

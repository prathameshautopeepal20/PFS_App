import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/api/app_urls.dart';
import 'package:atpl_flashing_app/api/dev/dev_service.dart';
import 'package:atpl_flashing_app/logic/controller/dashboard/testRecipeController.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/services/log_file.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  // 1. Controllers for TextFields
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final hidePassword = true.obs;
  final isLoading = false.obs;
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials(); // ✅ Load on init
  }

  Future<void> _loadSavedCredentials() async {
    final String? savedUser = await AppPreferences.getSavedUsername();
    final String? savedPass = await AppPreferences.getSavedPassword();

    if (savedUser != null && savedUser.isNotEmpty) {
      usernameController.text = savedUser;
    }
    if (savedPass != null && savedPass.isNotEmpty) {
      passwordController.text = savedPass;
    }
    print("📖 [LOGIN] Loaded saved credentials for: $savedUser");
    LogFile.write("📖 [LOGIN] Loaded saved credentials for: $savedUser");
  }

  void login() async {
    String user = usernameController.value.text;
    String pass = passwordController.value.text;

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter credentials",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      print("🚀 [LOGIN START] Authenticating: $user");
      LogFile.write("🚀 [LOGIN START] Authenticating: $user");

      print("password: $pass");
      LogFile.write("password: $pass");

      final String baseUrl = AppEnvironment.baseUrl;
      final String loginUrl = "$baseUrl${AppURLs.login}";
      print("🌐 [API] Hitting: $loginUrl");
      LogFile.write("🌐 [API] Hitting: $loginUrl");

      // ✅ Use form encoding — Django REST expects this by default
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
        body: {
          "username": user,
          "password": pass,
        },
      );

      print("📡 [RESPONSE] Status: ${response.statusCode}");
      print("📡 [RESPONSE] Body: ${response.body}");
      LogFile.write("📡 [RESPONSE] Status: ${response.statusCode}");
      LogFile.write("📡 [RESPONSE] Body: ${response.body}");

      Map<String, dynamic> parsedResponse = {};
      try {
        parsedResponse = jsonDecode(response.body);
      } catch (_) {
        parsedResponse = {"raw": response.body};
      }
      parsedResponse['statusCode'] = response.statusCode;

      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST ${response.statusCode}',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"}, // ✅ password masked
        response: parsedResponse,
      ));

      if (response.statusCode == 200) {
        await AppPreferences.saveUsername(user);
        await AppPreferences.savePassword(pass);
        print("💾 [LOGIN] Credentials saved for: $user");
        LogFile.write("💾 [LOGIN] Credentials saved for: $user");
        final Map<String, dynamic> data = jsonDecode(response.body);

        final String? token = data['data']['accessToken'];
        if (token != null) {
          await AppPreferences.setToken(token);
          print("🔑 [TOKEN] Saved: $token");
          LogFile.write("🔑 [TOKEN] Saved: $token");

        }

        await AppPreferences.setActiveUser(user);
        print("👤 [SESSION] Active User set: $user");
         LogFile.write("👤 [SESSION] Active User set: $user");

        if (Get.isRegistered<TestRecipeController>()) {
          final testController = Get.find<TestRecipeController>();
          await testController.loadStoredRecipes();
          print("🔄 [SYNC] Recipes: ${testController.recipeList.length}");
          LogFile.write("🔄 [SYNC] Recipes: ${testController.recipeList.length}");
        }

        isLoading.value = false;
        Get.offAllNamed(Routes.dashboardScreen);
      } else if (response.statusCode == 400) {
        isLoading.value = false;
        final Map<String, dynamic> errData = jsonDecode(response.body);
        final String errMsg =
            errData['error'] ?? errData['detail'] ?? "Invalid request";
        print("❌ [LOGIN 400] $errMsg");
        LogFile.write("❌ [LOGIN 400] $errMsg");
        Get.snackbar("Login Failed", errMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else if (response.statusCode == 401) {
        isLoading.value = false;
        Get.snackbar("Login Failed", "Invalid email or password",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        isLoading.value = false;
        Get.snackbar(
            "Server Error", "Something went wrong. (${response.statusCode})",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } on SocketException {
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST ERROR',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"},
        response: {
          "error": "SocketException",
          "message": "No internet connection"
        },
      ));
      isLoading.value = false;
      Get.snackbar("No Connection", "Check your internet and try again",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } on TimeoutException {
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST TIMEOUT',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"},
        response: {"error": "TimeoutException", "message": "Request timed out"},
      ));
      isLoading.value = false;
      Get.snackbar("Timeout", "Server took too long to respond",
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST TIMEOUT',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"},
        response: {"error": "TimeoutException", "message": "Request timed out"},
      ));
      isLoading.value = false;
      print("❌ [LOGIN ERROR] $e");
      LogFile.write("❌ [LOGIN ERROR] $e");
      Get.snackbar("Login Failed", "An error occurred during login");
    }
  }

  void login1() async {
    String user = usernameController.value.text;
    String pass = passwordController.value.text;

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter credentials",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      print("🚀 [LOGIN START] Authenticating: $user");
      LogFile.write("🚀 [LOGIN START] Authenticating: $user");

      final String loginUrl = "${AppEnvironment.baseUrl}${AppURLs.login}";
      print("🌐 [API] Hitting: $loginUrl");
      LogFile.write("🌐 [API] Hitting: $loginUrl");

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
        body: {
          "username": user,
          "password": pass,
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 [RESPONSE] Status: ${response.statusCode}");
      LogFile.write("📡 [RESPONSE] Status: ${response.statusCode}");
      print("📡 [RESPONSE] Body: ${response.body}");
      LogFile.write("📡 [RESPONSE] Body: ${response.body}");
      Map<String, dynamic> parsedResponse = {};
      try {
        parsedResponse = jsonDecode(response.body);
      } catch (_) {
        parsedResponse = {"raw": response.body};
      }
      parsedResponse['statusCode'] = response.statusCode;

      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST ${response.statusCode}',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"}, // ✅ password masked
        response: parsedResponse,
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // ✅ Check responseStatus from your API structure
        final String? responseStatus = body['responseStatus'];
        if (responseStatus != 'SUCCESS') {
          isLoading.value = false;
          final String errMsg =
              body['messages']?[0]?['message'] ?? "Login failed";
          print("❌ [LOGIN] responseStatus: $responseStatus | $errMsg");
          LogFile.write("❌ [LOGIN] responseStatus: $responseStatus | $errMsg");
          Get.snackbar("Login Failed", errMsg,
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }

        // ✅ Extract from data object
        final Map<String, dynamic> data = body['data'];

        final String? accessToken = data['accessToken'];
        final int? userId = data['userId'];
        final String? firstName = data['firstName'];
        final String? lastName = data['lastName'];
        final String? userName = data['userName'];

        print("🔑 [TOKEN] accessToken: $accessToken");
        LogFile.write("🔑 [TOKEN] accessToken: $accessToken");
        print("👤 [USER] userId: $userId | name: $firstName $lastName");
        LogFile.write("👤 [USER] userId: $userId | name: $firstName $lastName");

        // ✅ Save token
        if (accessToken != null) {
          await AppPreferences.setToken(accessToken);
          print("✅ [PREFS] Token saved");
        } else {
          isLoading.value = false;
          Get.snackbar("Login Failed", "Token not received",
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }

        // ✅ Save credentials & session
        await AppPreferences.saveUsername(user);
        await AppPreferences.savePassword(pass);
        await AppPreferences.setActiveUser(userName ?? user);

        print("💾 [PREFS] Credentials saved for: $user");
        LogFile.write("💾 [PREFS] Credentials saved for: $user");
        print("👤 [SESSION] Active User set: ${userName ?? user}");
        LogFile.write("👤 [SESSION] Active User set: ${userName ?? user}");
        // ✅ Sync recipes if controller exists
        if (Get.isRegistered<TestRecipeController>()) {
          final testController = Get.find<TestRecipeController>();
          await testController.loadStoredRecipes();
          print("🔄 [SYNC] Recipes: ${testController.recipeList.length}");
        }

        isLoading.value = false;
        Get.offAllNamed(Routes.dashboardScreen);
      } else if (response.statusCode == 400) {
        isLoading.value = false;
        final Map<String, dynamic> errData = jsonDecode(response.body);
        final String errMsg =
            errData['error'] ?? errData['detail'] ?? "Invalid request";
        print("❌ [LOGIN 400] $errMsg");
        Get.snackbar("Login Failed", errMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else if (response.statusCode == 401) {
        isLoading.value = false;
        Get.snackbar("Login Failed", "Invalid username or password",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        isLoading.value = false;
        Get.snackbar(
            "Server Error", "Something went wrong. (${response.statusCode})",
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } on SocketException {
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST TIMEOUT',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"},
        response: {"error": "TimeoutException", "message": "Request timed out"},
      ));
      isLoading.value = false;
      Get.snackbar("No Connection", "Check your internet and try again",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } on TimeoutException {
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST TIMEOUT',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"},
        response: {"error": "TimeoutException", "message": "Request timed out"},
      ));
      isLoading.value = false;
      Get.snackbar("Timeout", "Server took too long to respond",
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      DevService.instance.insertAPICall(AppAPIsCall(
        id: "${DateTime.now().millisecondsSinceEpoch} ${DateTime.now().toIso8601String()}",
        type: 'POST TIMEOUT',
        path: AppURLs.login,
        dateTime: DateTime.now(),
        data: {"username": user, "password": "***"},
        response: {"error": "TimeoutException", "message": "Request timed out"},
      ));
      isLoading.value = false;
      print("❌ [LOGIN ERROR] $e");
      LogFile.write("❌ [LOGIN ERROR] $e");
      Get.snackbar("Login Failed", "An error occurred during login",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // Create a reusable header helper
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await AppPreferences.getToken();
    return {
      'Authorization': 'Bearer $token', // ✅ Bearer not JWT
      'Content-Type': 'application/json',
    };
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:atpl_flashing_app/AppPreferences/app_areferences.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/api/app_urls.dart';
import 'package:atpl_flashing_app/routes/routes_string.dart';

class LoginController extends GetxController {
  // ================= UI =================
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final hidePassword = true.obs;

  final selectedRole = "Admin".obs;
  final roles = ["User", "Supervisor", "Admin"];

  // ================= SERVER STATUS =================
  final serverStatus = "Checking...".obs;
  final serverColor = Colors.grey.obs;

  bool isPageVisible = true;

  // ================= APP CONSTANTS (LIKE .NET) =================
  static const String deviceType = "windows";
  static const String macId = "29:14:65:11:63:70";

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    startServerCheck();
  }

  // ================= SERVER CHECK (LIKE .NET LOOP) =================
  Future<bool> checkServerStatus() async {
    try {
      final url = "${AppEnvironment.baseUrl}oem/oem/";

      print("\n🌐 [SERVER CHECK]");
      print("URL: $url");

      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 6));

      print("📡 STATUS: ${res.statusCode}");

      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      print("❌ SERVER ERROR: $e");
      return false;
    }
  }

  Future<void> startServerCheck() async {
    while (isPageVisible) {
      final ok = await checkServerStatus();

      if (ok) {
        serverStatus.value = "Server reachable";
        serverColor.value = Colors.green;
        print("🟢 SERVER OK");
      } else {
        serverStatus.value = "Server not reachable";
        serverColor.value = Colors.red;
        print("🔴 SERVER DOWN");
      }

      await Future.delayed(const Duration(seconds: 3));
    }
  }

  // ================= LOGIN =================
  Future<void> login() async {
    final user = usernameController.text.trim();
    final pass = passwordController.text.trim();
    final role = selectedRole.value;

    print("\n====================================");
    print("🚀 LOGIN CLICKED");
    print("👤 USER: $user");
    print("🔑 PASS: $pass");
    print("🎭 ROLE: $role");
    print("🖥 DEVICE: $deviceType");
    print("📱 MAC: $macId");
    print("====================================");

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar("Error", "Enter username & password");
      return;
    }

    try {
      isLoading.value = true;

      final url = "${AppEnvironment.baseUrl}${AppURLs.login}";

      final body = {
        "username": user,
        "password": pass,
        "role": role,
        "device_type": deviceType,
        "mac_id": macId,
      };

      print("🌐 API URL: $url");
      print("📦 REQUEST BODY:");
      print(jsonEncode(body));

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print("📡 RESPONSE STATUS: ${response.statusCode}");
      print("📡 RESPONSE BODY:");
      print(response.body);

      final res = jsonDecode(response.body.isEmpty ? "{}" : response.body);

      isLoading.value = false;

      // ================= SUCCESS =================
      if (response.statusCode == 200) {
        print("✅ LOGIN SUCCESS");

        final token = res["token"]?["access"];
        final refresh = res["token"]?["refresh"];

        print("🔑 TOKEN: $token");
        print("🔄 REFRESH: $refresh");

        await AppPreferences.setToken(token);
        await AppPreferences.setActiveUser(user);

        Get.offAllNamed(Routes.dashboardScreen);
        return;
      }

      // ================= ERROR =================
      final error = res["error"] ?? "Login failed";

      print("❌ LOGIN FAILED FROM SERVER");
      print("❌ ERROR: $error");

      Get.snackbar(
        "Login Failed",
        error.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on SocketException {
      isLoading.value = false;
      Get.snackbar("No Internet", "Check connection");
    } on TimeoutException {
      isLoading.value = false;
      Get.snackbar("Timeout", "Server not responding");
    } catch (e) {
      isLoading.value = false;
      print("❌ ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }

  @override
  void onClose() {
    isPageVisible = false;
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
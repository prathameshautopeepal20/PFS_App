import 'dart:convert';
import 'package:atpl_flashing_app/models/receipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  // 🔑 Keys
  static const String _currentUserIdKey = 'active_user_id';
  static const String _userRecipePrefix = 'recipes_for_user_'; // Unique prefix
  static const String _tokenKey = 'auth_token';

  // ================= SESSION MANAGEMENT =================

  /// Called during Login to identify who is using the app
  static Future<void> setActiveUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, userId);
  }

  /// Get current session ID
  static Future<String?> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserIdKey);
  }

  /// Logout: Simply removes the "Active User" pointer
  /// This leaves the actual recipe data on the device for next time
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
  }
 

  // ================= USER-SPECIFIC RECIPES =================

  /// Saves a recipe into a map unique to the logged-in User ID
  static Future<void> saveRecipeForCurrentUser(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(_currentUserIdKey);

    // DEBUG: Monitor the Save key
    print("💾 PREFS-SAVE: Active User is [$userId]");

    if (userId == null) {
      print("❌ PREFS-SAVE ERROR: No Active User! Data will be lost.");
      return;
    }
    if (recipe.model == null) return;

    String storageKey = "$_userRecipePrefix$userId";

    final String? rawData = prefs.getString(storageKey);
    Map<String, dynamic> recipeMap = rawData != null ? jsonDecode(rawData) : {};

    recipeMap[recipe.model!] = recipe.toJson();

    bool success = await prefs.setString(storageKey, jsonEncode(recipeMap));
    print(
        "✅ PREFS-SAVE: Model [${recipe.model}] saved to key [$storageKey]. Success: $success");
  }

  static Future<List<Recipe>> getRecipesForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Try to get the ID
    String? userId = prefs.getString(_currentUserIdKey);

    // 🚀 SAFETY FALLBACK: If userId is null, force the default developer ID
    // This prevents the "Successfully synced 0 recipes" error during testing.
    // if (userId == null || userId == "null") {
    //   print("🛠️ PREFS-READ: UserId was null, recovering session...");
    //   userId = "abc@autopeepal.com";
    //   await prefs.setString(_currentUserIdKey, userId);
    // }

    print("📖 PREFS-READ: Attempting to load for User [$userId]");

    String storageKey = "$_userRecipePrefix$userId";
    final String? rawData = prefs.getString(storageKey);

    if (rawData == null || rawData.isEmpty) {
      print("📂 PREFS-READ: Key [$storageKey] not found or empty.");
      return [];
    }

    try {
      Map<String, dynamic> map = jsonDecode(rawData);
      List<Recipe> recipes =
          map.values.map((json) => Recipe.fromJson(json)).toList();
      print("📦 PREFS-READ: Found ${recipes.length} recipes in [$storageKey]");
      return recipes;
    } catch (e) {
      print("❌ PREFS-READ: Parse Error (likely malformed JSON): $e");
      return [];
    }
  }

static Future<void> deleteRecipeForCurrentUser(
  String recipeModel,
) async {
  final prefs = await SharedPreferences.getInstance();

  final String? userId =
      prefs.getString(_currentUserIdKey);

  print("🗑️ PREFS-DELETE: Active User [$userId]");

  if (userId == null) {
    print("❌ PREFS-DELETE ERROR: No Active User");
    return;
  }

  String storageKey =
      "$_userRecipePrefix$userId";

  final String? rawData =
      prefs.getString(storageKey);

  if (rawData == null || rawData.isEmpty) {
    print("⚠️ No recipes found");
    return;
  }

  Map<String, dynamic> recipeMap =
      jsonDecode(rawData);

  // REMOVE RECIPE
  recipeMap.remove(recipeModel);

  // SAVE UPDATED MAP
  bool success = await prefs.setString(
    storageKey,
    jsonEncode(recipeMap),
  );

  print(
    "✅ Recipe Deleted [$recipeModel] Success: $success",
  );
}


// --- TOKEN MANAGEMENT ---
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print("🔑 [PREFS] Token saved for persistent login");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print("🗑️ [PREFS] Token cleared");
  }

  // ── USERNAME ──────────────────────────────────────
static Future<void> saveUsername(String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('saved_username', username);
}

static Future<String?> getSavedUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('saved_username');
}

static Future<void> saveStationId(String StationId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('stationId', StationId);
}

static Future<String?> getStationId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('stationId');
}

// ── PASSWORD ──────────────────────────────────────
static Future<void> savePassword(String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('saved_password', password);
}

static Future<String?> getSavedPassword() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('saved_password');
}

// ── CLEAR ON LOGOUT ───────────────────────────────
static Future<void> clearCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('saved_username');
  await prefs.remove('saved_password');
  print("🗑️ [PREFS] Credentials cleared");
}

  // ================= MODBUS CONNECTION =================

  static Future<void> setModbusSettings(String ip, int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plc_ip', ip.trim());
    await prefs.setInt('plc_port', port);
  }

  static Future<Map<String, String>> getModbusSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Get IP
    String ip = prefs.getString('plc_ip') ?? "192.168.1.1";

    // Get Port safely
    final Object? rawPort = prefs.get('plc_port');
    int portInt;

    if (rawPort is int) {
      portInt = rawPort;
    } else if (rawPort is String) {
      portInt = int.tryParse(rawPort) ?? 502;
    } else {
      portInt = 502;
    }

    return {
      "ip": ip,
      "port": portInt.toString(), // Returns string for your UI/Controllers
    };
  }

  static Future<void> setUserRole(String value) async {}
}

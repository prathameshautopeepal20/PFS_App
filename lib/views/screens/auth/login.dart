import 'package:atpl_flashing_app/logic/controller/auth/loginController.dart';
import 'package:atpl_flashing_app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LoginController());

    final Size screenSize = MediaQuery.of(context).size;
    final bool isDesktop = screenSize.width > 900;

    const Color primaryOrange = Color(0xFFF9772C);
    const Color textDark = Color(0xFF1E293B);
    const Color textLight = Color(0xFF64748B);
    const Color formBg = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ================= LEFT SIDE =================

          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF9772C),
                      Color(0xFFE56717),
                      Color(0xFFCC5A0F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -100,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -120,
                      right: -120,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/new/autopeepal.png',
                              height: 140,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(
                                Icons.settings_suggest,
                                size: 120,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "ATPL FLASHING",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              "Precision • Performance • Diagnostics",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 40),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flash_on_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Enterprise Vehicle Flashing Platform",
                                    style: TextStyle(
                                      color:
                                          Colors.white.withOpacity(0.95),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ================= RIGHT SIDE =================

          Expanded(
            flex: 5,
            child: Container(
              color: formBg,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 40,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MOBILE LOGO

                        if (!isDesktop) ...[
                          Center(
                            child: Image.asset(
                              'assets/new/autopeepal.png',
                              height: 80,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(
                                Icons.settings_suggest,
                                size: 60,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Login to continue accessing the flashing platform",
                          style: TextStyle(
                            color: textLight,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 45),

                        // ================= USERNAME =================

                        _buildLabel("USERNAME OR EMAIL"),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.usernameController,
                            cursorColor: primaryOrange,
                            style: const TextStyle(fontSize: 15),
                            decoration: _inputDecoration(
                              'name@company.com',
                              Icons.alternate_email_rounded,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ================= PASSWORD =================

                        _buildLabel("PASSWORD"),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Obx(
                            () => TextField(
                              controller:
                                  controller.passwordController,
                              obscureText:
                                  controller.hidePassword.value,
                              cursorColor: primaryOrange,
                              style:
                                  const TextStyle(fontSize: 15),
                              decoration: _inputDecoration(
                                '••••••••',
                                Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.hidePassword.value
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 20,
                                    color: textLight,
                                  ),
                                  onPressed: () => controller
                                      .hidePassword
                                      .toggle(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                color: primaryOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // ================= LOGIN BUTTON =================

                        Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              minimumSize:
                                  const Size(double.infinity, 58),
                              elevation: 8,
                              shadowColor:
                                  primaryOrange.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                controller.isLoading.value
                                    ? null
                                    : () => controller.login(),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ================= FOOTER =================

                        Center(
                          child: Column(
                            children: const [
                              Divider(),

                              SizedBox(height: 20),

                              Text(
                                "PFS",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: textDark,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "Powered By",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  letterSpacing: 1,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                "autopeepal",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          fontSize: 11,
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFCBD5E1),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryColor,
          width: 2,
        ),
      ),
    );
  }
}
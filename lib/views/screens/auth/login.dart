import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/logic/controller/auth/loginController.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: isDesktop ? 1000 : double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                )
              ],
            ),
            child: Row(
              children: [
                // ================= LEFT PANEL =================
                if (isDesktop)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF97316),
                            Color(0xFFEA580C),
                            Color(0xFF9A3412),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(),
                              child: Image.asset(
                                "assets/new/autopeepal.png",
                                height: 150,
                                width: 300,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.flash_on,
                                    size: 80,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "ATPL FLASHING",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Vehicle ECU Flashing System",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                "Secure • Fast • Reliable",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                // ================= RIGHT PANEL =================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Login to continue",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ================= SERVER STATUS =================
                          Obx(() => Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: controller.serverColor.value,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.circle,
                                        size: 12,
                                        color: controller.serverColor.value),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller.serverStatus.value,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              )),

                          const SizedBox(height: 25),

                          // ================= USERNAME =================
                          _buildInput(
                            controller.usernameController,
                            "Username",
                            Icons.person,
                          ),

                          const SizedBox(height: 15),

                          // ================= PASSWORD =================
                          Obx(
                            () => _buildInput(
                              controller.passwordController,
                              "Password",
                              Icons.lock,
                              obscure: controller.hidePassword.value,
                              suffix: IconButton(
                                icon: Icon(
                                  controller.hidePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: controller.hidePassword.toggle,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // ================= ROLE =================
                          Obx(
                            () => Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: _boxStyle(),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.selectedRole.value,
                                  dropdownColor: const Color(0xFF1E293B),
                                  iconEnabledColor: Colors.white,
                                  style: const TextStyle(color: Colors.white),
                                  items: controller.roles
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      controller.selectedRole.value = v!,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // ================= REMEMBER ME =================
                          Obx(() => GestureDetector(
                            onTap: () => controller.rememberMe.value =
                                !controller.rememberMe.value,
                            child: Row(children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: controller.rememberMe.value
                                      ? const Color(0xFFF97316)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: controller.rememberMe.value
                                        ? const Color(0xFFF97316)
                                        : Colors.white38,
                                    width: 1.5)),
                                child: controller.rememberMe.value
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 13)
                                    : null),
                              const SizedBox(width: 10),
                              const Text('Remember me',
                                style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                            ]),
                          )),

                          const SizedBox(height: 25),

                          // ================= LOGIN BUTTON =================
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.login,
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "⚠ Device must be approved by admin",
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT DESIGN =================
  Widget _buildInput(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: _boxStyle(),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ================= BOX STYLE =================
  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
    );
  }
}
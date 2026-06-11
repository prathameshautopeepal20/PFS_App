// import 'package:atpl_flashing_app/logic/controller/dashboard/settingsController.dart'; // Ensure PLCController is here
// import 'package:atpl_flashing_app/themes/app_textstyles.dart';
// import 'package:atpl_flashing_app/views/screens/dashboard/mainLayoutScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// class SettingsScreen extends StatelessWidget {
//   SettingsScreen({super.key});

//   // Inject/Find the Controller
//   final PLCController plcController = Get.put(PLCController(), permanent: true);

//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final bool isDesktop = MediaQuery.of(context).size.width > 800;

//     return SafeArea(
//       child: MainLayout(
//         title: "Plc Configuration",
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(isDesktop ? 80 : 20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Center(
//                 //   child: const Text(
//                 //     "PLC Connection Settings",
//                 //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,fontFamily: "Roboto-Regular"),
//                 //   ),
//                 // ),
//                 // const SizedBox(height: 25),

//                 // IP Address Field
//                 _buildLabel(" Enter PLC IP"),
//                 TextFormField(
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   controller: plcController.ipController,
//                   keyboardType: TextInputType.number,
//                   decoration: _inputDecoration(
//                     'Enter PLC Ip',
//                   ),
//                   validator: (v) =>
//                       (v == null || v.isEmpty) ? 'Required PLC Ip' : null,
//                 ),
//                 const SizedBox(height: 16),

//                 // Port Field
//                 _buildLabel("Enter PLC Port"),
//                 TextFormField(
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   controller: plcController.portController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   decoration: _inputDecoration(
//                     'Enter PLC Port',
//                   ),
//                   style: TextStyles.textfieldTextStyle,
//                   validator: (v) =>
//                       (v == null || v.isEmpty) ? 'Required PLC Port' : null,
//                 ),

//                 const SizedBox(height: 40),

//                 // Reactive Connection Button
//                 Obx(
//                   () => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 28),
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // ---------------- BUTTON ----------------
//                           // ElevatedButton(
//                           //   onPressed: plcController.isConnecting.value
//                           //       ? null
//                           //       : () async {
//                           //           if (_formKey.currentState!.validate()) {
//                           //             plcController.disconnect();

//                           //             await Future.delayed(
//                           //               const Duration(milliseconds: 500),
//                           //             );

//                           //             plcController.connectToPLC(
//                           //               plcController.ipController.text,
//                           //               plcController.portController.text,
//                           //             );
//                           //           }
//                           //         },
//                           //   style: ElevatedButton.styleFrom(
//                           //     backgroundColor: const Color(0xFF4A5A71),
//                           //     shape: RoundedRectangleBorder(
//                           //       borderRadius: BorderRadius.circular(6),
//                           //     ),
//                           //     padding: const EdgeInsets.symmetric(
//                           //       horizontal: 150,
//                           //       vertical: 20,
//                           //     ),
//                           //   ),
//                           //   child: plcController.isConnecting.value
//                           //       ? const SizedBox(
//                           //           height: 18,
//                           //           width: 18,
//                           //           child: CircularProgressIndicator(
//                           //             strokeWidth: 2,
//                           //             color: Colors.white,
//                           //           ),
//                           //         )
//                           //         :Text("okay")
//                           //       // : Text(
//                           //       //     plcController.isConnected.value
//                           //       //         ? 'RECONNECT DEVICE'
//                           //       //         : 'CONNECT TO PLC',
//                           //       //     style: const TextStyle(
//                           //       //       color: Colors.white,
//                           //       //       fontSize: 16,
//                           //       //     ),
//                           //       //   ),
//                           // ),
//                           // ---------------- BUTTON ----------------
//                           ElevatedButton(
//                             onPressed: plcController.isConnecting.value
//                                 ? null
//                                 : () async {
//                                     if (_formKey.currentState!.validate()) {
//                                       // 1. SAVE to Shared Preferences
//                                       await plcController.saveSettings();

//                                       // 2. Perform connection logic
//                                       plcController.disconnect();

//                                       await Future.delayed(
//                                         const Duration(milliseconds: 500),
//                                       );
//                                     }
//                                   },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF4A5A71),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 150,
//                                 vertical: 20,
//                               ),
//                             ),
//                             child: plcController.isConnecting.value
//                                 ? const SizedBox(
//                                     height: 18,
//                                     width: 18,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : const Text(
//                                     "okay", // Changed back to your requested text
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 16),
//                                   ),
//                           ),

//                           const SizedBox(
//                               height: 12), // 🔥 spacing between button & status

//                           // ---------------- STATUS ----------------
//                           // Row(
//                           //   mainAxisSize: MainAxisSize
//                           //       .min, // 🔥 IMPORTANT (centers row content)
//                           //   children: [
//                           //     Icon(
//                           //       plcController.isConnected.value
//                           //           ? Icons.check_circle
//                           //           : Icons.error_outline,
//                           //       color: plcController.isConnected.value
//                           //           ? Colors.green
//                           //           : Colors.red,
//                           //     ),
//                           //     const SizedBox(width: 8),
//                           //     Text(
//                           //       "Device Status: ${plcController.isConnected.value ? 'ONLINE' : 'OFFLINE'}",
//                           //       style: TextStyle(
//                           //         color: plcController.isConnected.value
//                           //             ? Colors.green
//                           //             : Colors.red,
//                           //         fontWeight: FontWeight.bold,
//                           //         fontSize: 14,
//                           //       ),
//                           //     ),
//                           //   ],
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 ElevatedButton(
//                   onPressed: plcController.isConnected.value
//                       ? () => plcController.sendGeneratorDataRequest()
//                       : null,
//                   child: Text(
//                     "Read D0 Register",
//                     style: TextStyles.textfieldTextStyle,
//                   ),
//                 ),

//                 Obx(() => Text(
//                       "PLC D0 Value: ${plcController.plcDataValue.value}",
//                       style: const TextStyle(
//                           fontSize: 24, fontWeight: FontWeight.bold),
//                     )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String label) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 4, bottom: 8),
//         child: Text(label,
//             style: const TextStyle(
//               fontFamily: "Roboto-Regular",
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             )),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,

//       // prefixIcon: Icon(icon, size: 20, color: Colors.blue.shade300),
//       filled: true,
//       fillColor: Colors.blueGrey.withOpacity(0.03),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
//       ),
//     );
//   }
// }

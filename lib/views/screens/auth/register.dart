// import 'package:atpl_flashing_app/common_widgets/customDropdown.dart';
// import 'package:atpl_flashing_app/common_widgets/popup.dart';
// import 'package:atpl_flashing_app/common_widgets/ui_helper_widgets.dart';
// import 'package:atpl_flashing_app/logic/controller/auth/registerController.dart';
// import 'package:atpl_flashing_app/routes/routes_string.dart';
// import 'package:atpl_flashing_app/themes/app_colors.dart';
// import 'package:atpl_flashing_app/themes/app_textstyles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class RegisterScreen extends StatelessWidget {
//   RegisterScreen({super.key});
//   final controller = Get.put(RegistrationController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryColor,
//         // Change this line in your AppBar:
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context);
//             } else {
//               // If there is no back stack, go to a specific route
//               Get.offAllNamed(Routes.loginScreen);
//             }
//           },
//         ),
//         title: Text('Register', style: TextStyles.appBarTitle),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFieldWithLabel(
//                       "Enter First Name",
//                       hint: "Enter first name",
//                       onChanged: (v) => controller.firstName.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Last Name",
//                       hint: "Enter last name",
//                       onChanged: (v) => controller.lastName.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Email ID",
//                       keyboardType: TextInputType.emailAddress,
//                       hint: "Enter email Id",
//                       onChanged: (v) => controller.email.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Mobile Number",
//                       keyboardType: TextInputType.phone,
//                       hint: "Enter mobile number",
//                       onChanged: (v) => controller.mobileNumber.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Password",
//                       obscureText: true,
//                       hint: "Enter password",
//                       onChanged: (v) => controller.password.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Confirm Password",
//                       obscureText: true,
//                       hint: "Confirm Password",
//                       onChanged: (v) => controller.confirmPassword.value = v,
//                     ),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedOem,
//                           items: controller.oemList
//                               .map((e) => e.name ?? "")
//                               .toList(),
//                           label: "Select OEM",
//                           dialogTitle: "Select OEM",
//                           hint: "Select OEM",
//                           onItemSelected: (name) {
//                             // Find the full object and trigger the command logic
//                             final selected = controller.oemList
//                                 .firstWhere((e) => e.name == name);
//                             controller.oemListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedWorkshopGroup,
//                           items: controller.workshopGroupList
//                               .map((e) => e.workshopsGroupName ?? "")
//                               .toList(), // <-- use workshopGroupList
//                           label: "Select Workshop Group",
//                           dialogTitle: "Select Workshop Group",
//                           hint: "Select Workshop Group",
//                           onItemSelected: (name) {
//                             final selected = controller.workshopGroupList
//                                 .firstWhere(
//                                     (e) => e.workshopsGroupName == name);
//                             controller.workShopGroupListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedCity,
//                           items: controller.cityList
//                               .map((e) => e.city ?? "")
//                               .toList(),
//                           label: "Select City",
//                           dialogTitle: "Select City",
//                           hint: "Select City",

//                           // 🔥 VALIDATION HERE
//                           onBeforeTap: () async {
//                             if (controller
//                                 .selectedWorkshopGroup.value.isEmpty) {
//                               Get.dialog(
//                                 CustomPopup(
//                                   title: "Alert",
//                                   message:
//                                       "Please select Workshop Group first.",
//                                   onButtonPressed: () => Get.back(),
//                                 ),
//                                 barrierDismissible: false,
//                               );
//                               return false;
//                             }

//                             if (controller.cityList.isEmpty) {
//                               Get.dialog(
//                                 CustomPopup(
//                                   title: "Alert",
//                                   message: "No cities available.",
//                                   onButtonPressed: () => Get.back(),
//                                 ),
//                                 barrierDismissible: false,
//                               );
//                               return false;
//                             }

//                             return true; // ✅ allow open
//                           },

//                           onItemSelected: (name) {
//                             final selected = controller.cityList
//                                 .firstWhere((e) => e.city == name);
//                             controller.cityModelListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedWorkshop,
//                           items: controller.workshopList
//                               .map((e) => e.name ?? "")
//                               .toList(),
//                           label: "Select Workshop",
//                           dialogTitle: "Select Workshop",
//                           hint: "Select Workshop",

//                           // 🔥 SAME VALIDATION LIKE CITY
//                           onBeforeTap: () async {
//                             if (controller
//                                 .selectedWorkshopGroup.value.isEmpty) {
//                               Get.dialog(
//                                 CustomPopup(
//                                   title: "Alert",
//                                   message:
//                                       "Please select Workshop Group first.",
//                                   onButtonPressed: () => Get.back(),
//                                 ),
//                                 barrierDismissible: false,
//                               );
//                               return false;
//                             }

//                             if (controller.selectedCity.value.isEmpty) {
//                               Get.dialog(
//                                 CustomPopup(
//                                   title: "Alert",
//                                   message: "Please select City first.",
//                                   onButtonPressed: () => Get.back(),
//                                 ),
//                                 barrierDismissible: false,
//                               );
//                               return false;
//                             }

//                             if (controller.workshopList.isEmpty) {
//                               Get.dialog(
//                                 CustomPopup(
//                                   title: "Alert",
//                                   message: "No workshops available.",
//                                   onButtonPressed: () => Get.back(),
//                                 ),
//                                 barrierDismissible: false,
//                               );
//                               return false;
//                             }

//                             return true; // ✅ allow open
//                           },

//                           onItemSelected: (name) {
//                             final selected = controller.workshopList
//                                 .firstWhere((e) => e.name == name);
//                             controller.workShopListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C25(),
//                   ],
//                 ),
//               ),
//             ),
//             Center(
//               child: Obx(() => ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFFF7A18),
//                       padding: const EdgeInsets.symmetric(horizontal: 60),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6)),
//                     ),
//                     onPressed:
//                         controller.isBusy.value ? null : controller.submit,
//                     child: controller.isBusy.value
//                         ? const CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2)
//                         : const Text(
//                             'Submit',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontFamily: "OpenSans-SemiBold",
//                               color: Colors.black,
//                             ),
//                           ),
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFieldWithLabel(
//     String label, {
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//     String hint = "",
//     required void Function(String) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 14,
//             color: Colors.black,
//             fontFamily: "OpenSans-Regular",
//           ),
//         ),
//         C2(),
//         TextField(
//           style: TextStyles.textfieldTextStyle2,
//           cursorColor: Colors.black,
//           keyboardType: keyboardType,
//           obscureText: obscureText,
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyles.hintStyle1,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(color: AppColors.primaryColor),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(color: AppColors.primaryColor),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(color: AppColors.primaryColor),
//             ),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//           ),
//         ),
//       ],
//     );
//   }
// }

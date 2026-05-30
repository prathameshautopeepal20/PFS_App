import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atpl_flashing_app/themes/app_colors.dart';

// class CustomSnackBar {
//   static final RxBool isSnackBarVisible = false.obs;
//   //static OverlayEntry? _overlayEntry;

//   static void show({
//     required String message,
//     required bool isIssue,
//     Color? color,
//   }) {
//     if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
//     isSnackBarVisible.value = true; 
//     //_showInteractionBlocker(); 
//     Get.snackbar(
//       "",
//       message,
//       maxWidth: MediaQuery.of(Get.context!).size.width / 1.1,
//       backgroundColor: color ?? (isIssue ? AppColors.error : AppColors.green),
//       colorText: Colors.white,
//       snackPosition: SnackPosition.TOP,
//       titleText: Text(
//         "",
//         style: TextStyle(fontSize: 2, fontFamily: "Inter-Bold", color: AppColors.white),
//       ),
//       messageText: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           isIssue
//               ? const Icon(
//                   Icons.info_outline,
//                   color: Colors.red,
//                 )
//               : const Icon(
//                   Icons.check_circle_outline,
//                   color: Colors.green,
//                 ),
//            C10(),
//           Expanded(
//             child: Text(
//               message,
//               style: TextStyle(
//                   fontSize: 12.sp,
//                   fontFamily: "Roboto-Bold",
//                   color: const Color(0xFF33475B)),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Get.closeCurrentSnackbar();
//               isSnackBarVisible.value = false; 
//               //_removeInteractionBlocker();
//             },
//             child: const Icon(Icons.close, color: Color(0xFF33475B)),
//           ),
//         ],
//       ),
//       borderRadius: 27.0,
//       margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 20),
//       duration: const Duration(seconds: 3),
//       snackStyle: SnackStyle.FLOATING,
//       isDismissible: true,
//       animationDuration: const Duration(milliseconds: 300),
//       onTap: (_) {
//         isSnackBarVisible.value = false; 
//         //_removeInteractionBlocker();
//       },
//     );

//     Future.delayed(const Duration(seconds: 3), () {
//       isSnackBarVisible.value = false;
//       //_removeInteractionBlocker();
//     });
//   }

//   // static void _showInteractionBlocker() {
//   //   final context = Get.overlayContext;
//   //   if (context != null && _overlayEntry == null) {
//   //     final overlay = Overlay.of(context);
//   //     _overlayEntry = OverlayEntry(
//   //       builder: (context) => Obx(() {
//   //         return isSnackBarVisible.value
//   //             ? const Positioned.fill(
//   //                 child: Stack(
//   //                   children: [
//   //                     ModalBarrier(
//   //                       dismissible: false,
//   //                       color: Colors.transparent,
//   //                     ),
//   //                   ],
//   //                 ),
//   //               )
//   //             : const SizedBox.shrink();
//   //       }),
//   //     );
//   //     overlay.insert(_overlayEntry!);
//   //   }
//   // }
//   // static void _removeInteractionBlocker() {
//   //   if (_overlayEntry != null) {
//   //     _overlayEntry!.remove();
//   //     _overlayEntry = null;
//   //   }
//   // }
// }




class CustomSnackBar {
  static final RxBool isSnackBarVisible = false.obs;

  /// Show the custom snackbar
  static void show({
    required String message,
    required bool isIssue,
    Color? color,
  }) {
    // Close previous snackbar if any
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    isSnackBarVisible.value = true;

    Get.snackbar(
      "",
      "",
      maxWidth: MediaQuery.of(Get.context!).size.width / 1.1,
      backgroundColor: color ?? (isIssue ? AppColors.error : AppColors.green),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 27.0,
      margin: const EdgeInsets.only(left: 8.0, right: 8.0),
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
      titleText: Text(
        message,
        style: TextStyle(fontSize: 14, fontFamily: "Inter-Bold", color: AppColors.white),
      ),
      messageText: SizedBox.shrink(),
      // messageText: Row(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     isIssue
      //         ? const Icon(Icons.info_outline, color: Colors.red)
      //         : const Icon(Icons.check_circle_outline, color: Colors.green),
      //     C10(),
      //     Expanded(
      //       child: Text(
      //         message,
      //         style: const TextStyle(
      //             fontSize: 12,
      //             fontFamily: "Roboto-Bold",
      //             color: Color(0xFF33475B)),
      //       ),
      //     ),
      //     GestureDetector(
      //       onTap: () {
      //         Get.closeCurrentSnackbar();
      //         isSnackBarVisible.value = false;
      //       },
      //       child: const Icon(Icons.close, color: Color(0xFF33475B)),
      //     ),
      //   ],
      // ),
      onTap: (_) {
        isSnackBarVisible.value = false;
      },
    );

    // Reset visibility after snackbar duration
    Future.delayed(const Duration(seconds: 3), () {
      isSnackBarVisible.value = false;
    });
  }
}
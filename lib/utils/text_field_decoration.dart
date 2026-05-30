// import 'package:atpl_flashing_app/themes/app_colors.dart';
// import 'package:atpl_flashing_app/utils/sizes.dart';
// import 'package:flutter/material.dart';

// class TextFieldDecoration {
//   static InputDecoration textfieldDecoration({required String hint}) =>
//       new InputDecoration(
//           contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: AppColors.primary, width: 1.0),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: AppColors.grey),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.red),
//           ),
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: AppColors.grey),
//           ),
//           hintText: hint,
//           hintStyle: TextStyle(
//               fontFamily: "Inter-Regular",
//               fontWeight: FontWeight.w400,
//               color: AppColors.subtitleColor,
//               fontSize: 14));

//   static InputDecoration textfieldDecorationForSaveCard({String? hintText}) =>
//       new InputDecoration(
//           filled: true,
//           fillColor: AppColors.white,
//           hintText: hintText,
//           hintStyle: TextStyle(
//               fontSize: FontSizes.s14,
//               color: AppColors.subtitleColor,
//               fontWeight: FontWeight.w400,
//               fontStyle: FontStyle.normal),
//           contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//             borderSide: BorderSide(color: AppColors.primary, width: 1.0),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//             borderSide: BorderSide(color: AppColors.textFieldBorderColor),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//             borderSide: BorderSide(color: Colors.red),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//             borderSide: BorderSide(color: AppColors.textFieldBorderColor),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//             borderSide: BorderSide(
//               color: AppColors.textFieldBorderColor,
//             ),
//           ));
// }
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:atpl_flashing_app/themes/app_colors.dart';
import 'package:atpl_flashing_app/utils/sizes.dart';

class TextFieldDecoration {
  static InputDecoration textfieldDecorationChangePassword(
          {required String hint,
          required Function() sufficIconOntap,
          required Widget sufficIcon}) =>
      InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          focusedBorder: const OutlineInputBorder(
            borderRadius:  BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.grey, width: 0.25),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.grey, width: 0.25),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.grey, width: 0.25),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.red),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.grey, width: 0.25),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: sufficIconOntap,
              child: sufficIcon,
            ),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: "Roboto-Regular",
              fontSize: 14,
              color: Color(0xFF616161)));

  static InputDecoration textfieldDecorationicon(
          {required String hint,
          Function()? sufficIconOntap,
          IconData? sufficIcon}) =>
      InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          suffixIcon: sufficIcon != null
              ? GestureDetector(
                  onTap: () => sufficIconOntap,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      "assets/new/calendericon.svg",
                      height: 24,
                      width: 24,
                    ),
                  ),
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xFF939393),
              fontFamily: "Roboto-Regular",
              fontSize: 12));

  static InputDecoration textfieldDecoration(
          {required String hint,
          Function()? sufficIconOntap,
          bool isReadOnly = false,
          IconData? sufficIcon}) =>
      InputDecoration(
          filled: true,
          fillColor: isReadOnly ? const Color(0xFFF5F5F5) : AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: AppColors.grey, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          suffixIcon: sufficIcon != null
              ? GestureDetector(
                  onTap: () => sufficIconOntap,
                  child: Icon(sufficIcon),
                )
              : null,
          hintText: hint,
          hintStyle:  TextStyle(
              color: Colors.grey.shade600,
              fontFamily: "Roboto-Regular",
              fontSize: 12));

  static InputDecoration textfieldDecorationForFilter(
          {required String hint,
          Function()? sufficIconOntap,
          IconData? sufficIcon}) =>
      InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.red),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFEAECF0)),
          ),
          prefixIcon: sufficIcon != null
              ? GestureDetector(
                  onTap: () => sufficIconOntap,
                  child: Icon(sufficIcon),
                )
              : null,
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.black,
              fontFamily: "Roboto-Regular",
              fontSize: 12));

  static InputDecoration textfieldDecorationForSaveCard({String? hintText}) =>
      InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: FontSizes.s14,
              color: AppColors.subtitleColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: AppColors.textFieldBorderColor),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.red),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: AppColors.textFieldBorderColor),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: AppColors.textFieldBorderColor,
            ),
          ));
}

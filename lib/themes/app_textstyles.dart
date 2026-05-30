import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/utils/sizes.dart';
import 'app_colors.dart';

class TextStyles {
  static const TextDecoration underline = TextDecoration.underline;
  static const TextDecoration lineThrough = TextDecoration.lineThrough;

  static TextStyle get defaultRegular => TextStyle(
      fontSize: FontSizes.s16,
      color: AppColors.black,
      inherit: true,
      fontWeight: FontWeight.normal);

  static TextStyle get textfieldTextStyle => TextStyle(
      color: Colors.black,
      fontFamily: "OpenSans-SemiBold",
      fontWeight: FontWeight.bold,
      fontSize: FontSizes.s14,
      );

  static TextStyle get textfieldTextStyle1 => TextStyle(
    
      color: Colors.black,
      fontFamily: "OpenSans-Regular",
     // fontWeight: FontWeight.w900,
      fontSize: FontSizes.s13);

  static TextStyle get textfieldTextStyle2 => TextStyle(
      color: Colors.black,
      fontFamily: "OpenSans-Regular",
      fontWeight: FontWeight.w500,
      fontSize: FontSizes.s13);

  static TextStyle get textfieldTextStyleBold => TextStyle(
      color: Color(0xFF1D2939),
      fontWeight: FontWeight.w500,
      fontSize: FontSizes.s20);

  static TextStyle get dialogTitle => TextStyle(
      color: Colors.black,
      fontSize: FontSizes.s20,
      fontWeight: FontWeight.bold);

  static TextStyle get bottomSheetsTitle => TextStyle(
      color: Colors.black,
      fontSize: FontSizes.s20,
      fontWeight: FontWeight.w300);

  static TextStyle get dialogSubTitle => TextStyle(
      color: Colors.grey, fontSize: FontSizes.s13, fontWeight: FontWeight.w300);

  static TextStyle get moneyFont => TextStyle(
        fontSize: FontSizes.s16,
        color: AppColors.black,
        inherit: false,
      );

  static TextStyle get appBarTitle => TextStyle(
        fontSize: FontSizes.s18,
        fontFamily: "Roboto-Regular",
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 0.0,
        inherit: false,
      );

  static TextStyle get defaultBold => TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: FontSizes.s16,
        color: AppColors.black,
        inherit: false,
      );

  static TextStyle get defaultMedium => TextStyle(
        fontSize: FontSizes.s16,
        color: const Color(0xFF155296),
        inherit: false,
      );

  static TextStyle get alertText => TextStyle(
        fontSize: FontSizes.s16,
        color: AppColors.black,
        inherit: false,
      );
  static TextStyle get splashScreenTitle => TextStyle(
        fontSize: FontSizes.s24,
        color: Colors.blue,
        inherit: false,
      );

  static TextStyle get dashBoardTitle => TextStyle(
        fontSize: FontSizes.s24,
        color: const Color(0xFF155296),
        inherit: false,
      );

  static TextStyle get alertTitle => TextStyle(
        fontSize: FontSizes.s22,
        color: AppColors.black,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.60,
        inherit: false,
      );

  static TextStyle get widgetListTitle => TextStyle(
        fontSize: FontSizes.s16,
        color: AppColors.black,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.60,
        inherit: false,
      );

  static TextStyle get alertTitle1 => TextStyle(
        fontSize: FontSizes.s30,
        color: AppColors.black,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.60,
        inherit: false,
      );

  static TextStyle get snackBarText => TextStyle(
        fontSize: FontSizes.s15,
        color: Colors.white,
        letterSpacing: 1.4,
        inherit: false,
      );

  static TextStyle get editText => TextStyle(
        fontSize: FontSizes.s20,
        color: AppColors.black,
        inherit: false,
        letterSpacing: 1.6,
        textBaseline: TextBaseline.alphabetic,
      );

  static TextStyle get valueStyle => TextStyle(
        fontSize: FontSizes.s16,
        color: AppColors.black,
        inherit: false,
        textBaseline: TextBaseline.alphabetic,
      );

  static TextStyle get labelStyle => TextStyle(
        fontSize: Sizes.s15,
        color: Colors.grey.shade700,
      );

  static TextStyle get smallLabel => TextStyle(
        fontSize: FontSizes.s12,
        color: Colors.grey.shade700,
        inherit: false,
      );

  static TextStyle get hintStyle => TextStyle(
        fontSize: FontSizes.s14,
        color: Colors.grey,
        inherit: false,
      );

  static TextStyle get hintStyle1 => TextStyle(
        fontSize: FontSizes.s14,
        color: AppColors.black,
        inherit: false,
      );

  static TextStyle get errorStyle => TextStyle(
        fontSize: FontSizes.s13,
        color: AppColors.error,
        inherit: false,
      );

  static TextStyle get buttonText => TextStyle(
        fontSize: FontSizes.s18,
        color: Colors.white,
        letterSpacing: 0.13,
        inherit: false,
      );

  static TextStyle get cardSubtitle => TextStyle(
        fontSize: FontSizes.s12,
        color: AppColors.subtitleColor,
        fontWeight: FontWeight.w400,
        inherit: false,
      );

  static TextStyle get cardtitle => TextStyle(
        fontSize: FontSizes.s14,
        color: AppColors.black,
        fontWeight: FontWeight.w500,
        inherit: false,
      );

  static TextStyle get chartLabel => TextStyle(
        fontSize: FontSizes.s10,
        color: AppColors.black,
        letterSpacing: 0.5,
        inherit: false,
      );

  static TextStyle get reportList => TextStyle(
      fontSize: FontSizes.s18, color: AppColors.black, inherit: false);

  static TextStyle get subTitle => TextStyle(
        fontSize: FontSizes.s14,
        color: Colors.grey.shade700,
        inherit: false,
      );
  static TextStyle get title => TextStyle(
        fontSize: FontSizes.s16,
        color: AppColors.black,
        inherit: false,
      );

  static TextStyle get textFieldLable => TextStyle(
      fontSize: FontSizes.s14,
      color: AppColors.textFieldLableColor,
      inherit: false,
      fontFamily: "Inter-Medium");

  static TextStyle get textFieldHintStyle => TextStyle(
      fontSize: FontSizes.s15,
      color: AppColors.textFieldLableColor,
      inherit: false,
      fontFamily: "Inter-Regular");

  static TextStyle get headline20 => TextStyle(
      fontSize: FontSizes.s20,
      color: AppColors.darkBlack,
      inherit: false,
      fontFamily: "Inter-Bold");

  static TextStyle get headline14 => TextStyle(
      fontSize: FontSizes.s14,
      color: AppColors.textFieldLableColor,
      inherit: false,
      fontFamily: "Inter-Regular");
  static TextStyle get unitTextStyle => TextStyle(
      fontSize: FontSizes.s12,
      fontFamily: "Inter-Regular",
      fontWeight: FontWeight.w400,
      color: AppColors.subtitleColor);
  static TextStyle get billcount => TextStyle(
      fontSize: FontSizes.s12,
      fontFamily: "Inter-Medium",
      fontWeight: FontWeight.w500,
      color: AppColors.subtitleColor);
  static TextStyle get productTitle => TextStyle(
      fontSize: FontSizes.s16,
      fontWeight: FontWeight.w600,
      fontFamily: "Inter-SemiBold",
      color: AppColors.gray800);
}

// ignore_for_file: unnecessary_const

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/api/app_envirments.dart';
import 'package:atpl_flashing_app/app.dart';
import 'package:atpl_flashing_app/utils/app_enums.dart';

class AppColors {
  static const Color subtitleColor = Color(0xFF667085);
  static const Color blueColor = Color(0xFF063970);
  static const Color primaryColor = Color(0xFFF6782C);
  static const Color pagebgColor = Color(0xFFf0f0f0);
  static const Color green = Color(0xFF618264);
  static const Color buttonColor = Color(0xFFFFF);
  static const Color grrenButtonn = Color(0xFf39A657);
  static const Color darkGrey = Color(0xFFE697D95);
  static const Color faintGrey = Color(0xFFF2F4F7);
  static const Color white = const Color(0xFFFFFFFF);
  static const Color pinkishGrey = const Color(0xff00E7DADA);
  static const Color error = Color(0xFFF04438);
  static const Color status = const Color(0xFFF79009);
  static const Color black = Color(0xFF27272B);
  static const Color blackFaint = Color(0xFF666666);
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color Warning = Colors.yellow;
  static const Color linearGradientPrimary = Color(0xFF66BB6A);
  static const Color linearGradientSecondary = Color(0xFF1B5F20);

  static const Color headerImageBackground = Color(0xFFE1F2CB);
  static const Color headertext = Color(0xFF3C4852);
  static const Color headersubText = Color(0xFF7A8B94);
  static const Color textFieldBorderColor = Color(0xFFD0D5DD);
  static const Color textFieldLableColor = Color(0xFF667085);

  static const Color darkBlack = Color(0xFF101828);

  static const Color textfieldLableColor = Color(0xFF667085);

// figma colors
  static const Color gray200 = Color(0xFFEAECF0);
  static const Color gray500 = Color(0xFFEAECF0);
  static const Color baseWhite = Color(0xFFFFFFFF);
  static const Color gray800 = Color(0xFF1D2939);
  static const Color dashbordItemType = Color(0xFF344054);
  static const Color dashbordItemPickTime = Color(0xFF1570EF);

  static Color get primary {
    switch (App.instance.baseURLType) {
      case AtomURLType.LOCAL:
        return Colors.grey;
      case AtomURLType.DEV:
        return Colors.grey;
      case AtomURLType.PROD:
        return Colors.grey;
    }
    return Colors.grey;
  }

  static Color get greetingColor {
    switch (App.instance.baseURLType) {
      case AtomURLType.LOCAL:
        return const Color(0xffA30024);
      case AtomURLType.DEV:
        return const Color(0xFF618264);
      case AtomURLType.PROD:
        return const Color(0xffA30024);
    }
    return const Color(0xffA30024);
  }

  static Color get primarySwatch {
    switch (App.instance.baseURLType) {
      case AtomURLType.LOCAL:
        return const MaterialColor(
          0xffA30024,
          <int, Color>{
            50: Color(0xffA30024),
            100: Color(0xffA30024),
            200: Color(0xffA30024),
            300: Color(0xffA30024),
            400: Color(0xffA30024),
            500: Color(0xffA30024),
            600: Color(0xffA30024),
            700: Color(0xffA30024),
            800: Color(0xffA30024),
            900: Color(0xffA30024),
          },
        );
      case AtomURLType.DEV:
        return const MaterialColor(
          0xffA30024,
          <int, Color>{
            50: Color(0xffA30024),
            100: Color(0xffA30024),
            200: Color(0xffA30024),
            300: Color(0xffA30024),
            400: Color(0xffA30024),
            500: Color(0xffA30024),
            600: Color(0xffA30024),
            700: Color(0xffA30024),
            800: Color(0xffA30024),
            900: Color(0xffA30024),
          },
        );
      case AtomURLType.PROD:
        return const MaterialColor(
          0xffA30024,
          <int, Color>{
            50: Color(0xffA30024),
            100: Color(0xffA30024),
            200: Color(0xffA30024),
            300: Color(0xffA30024),
            400: Color(0xffA30024),
            500: Color(0xffA30024),
            600: Color(0xffA30024),
            700: Color(0xffA30024),
            800: Color(0xffA30024),
            900: Color(0xffA30024),
          },
        );
    }
    return const MaterialColor(
      0xffA30024,
      <int, Color>{
        50: Color(0xffA30024),
        100: Color(0xffA30024),
        200: Color(0xffA30024),
        300: Color(0xffA30024),
        400: Color(0xffA30024),
        500: Color(0xffA30024),
        600: Color(0xffA30024),
        700: Color(0xffA30024),
        800: Color(0xffA30024),
        900: Color(0xffA30024),
      },
    );
  }

  static Color get secondary {
    switch (App.instance.baseURLType) {
      case AtomURLType.LOCAL:
        return const Color(0xFF33596E);
      case AtomURLType.DEV:
        return const Color(0xFF33596E);
      case AtomURLType.PROD:
        return const Color(0xFF33596E);
    }
    return const Color(0xFF33596E);
  }

  static Color get ternary {
    switch (App.instance.baseURLType) {
      case AtomURLType.LOCAL:
        return const Color(0xFF4E7D96);
      case AtomURLType.DEV:
        return const Color(0xFF4E7D96);
      case AtomURLType.PROD:
        return const Color(0xFF4E7D96);
    }
    return const Color(0xFF4E7D96);
  }

  static Color get random =>
      // ignore: deprecated_member_use
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  static Color getMasterUserColorByStatus(String status) {
    switch (status) {
      case UserStatus.ACTIVE:
        return Colors.green;
      case UserStatus.PENDINGAPPROVAL:
        return Colors.redAccent;
      case UserStatus.INPROCESS:
        return Colors.orange;
      case UserStatus.INACTIVE:
        return Colors.red;
    }
    return AppColors.primary;
  }

  static Color getColorByIndex(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.greenAccent;
      case 4:
        return Colors.green;
      case 5:
        return Colors.deepPurple;
      case 6:
        return Colors.indigo;
    }
    return AppColors.primary;
  }
}

class TextS {
  static const TextStyle smMedium = TextStyle(
    fontFamily: 'Roboto-Medium',
    fontSize: 14.0,
    color: AppColors.textfieldLableColor,
    fontWeight: FontWeight.w500, // Font weight 500 corresponds to Medium
    height: 1.43, // Line height of 20px / font size of 14px = 1.43
    textBaseline: TextBaseline.alphabetic,
  );
  static const TextStyle smNormal = TextStyle(
    fontFamily: 'Roboto-Regular',
    fontSize: 14.0,
    color: Color(0xFF939393),
    textBaseline: TextBaseline.alphabetic,
  );
  static const TextStyle smMediumRed = TextStyle(
    fontFamily: 'Roboto-Regular',
    fontSize: 14.0,
    color: AppColors.error,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle smSemibold = TextStyle(
    fontFamily: 'Inter-SemiBold',
    fontSize: 14.0,
    fontWeight: FontWeight.w600, // Font weight 600 corresponds to Semibold
    height: 1.43, // Line height of 20px / font size of 14px = 1.43
    textBaseline: TextBaseline.alphabetic, // Ensures proper line height
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Roboto-Medium',
    // fontSize: 16.0,
    color: Colors.white,
    textBaseline: TextBaseline.alphabetic, // Ensures proper line height
  );

  static const TextStyle xlBold = TextStyle(
    fontFamily: 'Inter-Bold',
    fontSize: 20.0,
    fontWeight: FontWeight.w700, // Font weight 700 corresponds to Bold
    height: 1.5, // Line height of 30px / font size of 20px = 1.5
    textBaseline: TextBaseline.alphabetic, // Ensures proper line height
  );
}

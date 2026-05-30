import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atpl_flashing_app/themes/app_colors.dart';
import 'package:atpl_flashing_app/utils/sizes.dart';

class AppTostMassage {
  static showTostMassage(
      {required String massage,
      ToastGravity? position,
      Color? backgroundColor,
      Color? textColor,
      double? fontSize}) {
    Fluttertoast.showToast(
        msg: massage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: position ?? ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primary,
        textColor:  AppColors.white,
        fontSize: fontSize ?? Sizes.s15);
  }

  static showTostErrorMassage(
      {required String massage,
      ToastGravity? position,
      Color? textColor,
      double? fontSize}) {
    Fluttertoast.showToast(
        msg: massage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: position ?? ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
        fontSize: fontSize ?? Sizes.s15);
  }

  static showTostWarningMassage(
      {required String massage,
      ToastGravity? position,
      Color? textColor,
      double? fontSize}) {
    Fluttertoast.showToast(
        msg: massage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: position ?? ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.Warning,
        textColor: textColor ?? AppColors.white,
        fontSize: fontSize ?? Sizes.s15);
  }
}

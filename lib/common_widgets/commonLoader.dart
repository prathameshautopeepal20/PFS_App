import 'package:atpl_flashing_app/common_widgets/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/themes/app_colors.dart';

class CommonLoader extends StatelessWidget {
  final String message; // 👈 dynamic text

  const CommonLoader({
    super.key,
    this.message = "Loading...", // 👈 default text
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              ),
              C15(),
              Text(
                message, // 👈 dynamic here
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "OpenSans-Regular",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
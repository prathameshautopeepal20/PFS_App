import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/common_widgets/ui_helper_widgets.dart';
import 'package:atpl_flashing_app/themes/app_colors.dart';

class LabelText extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Widget child;
  const LabelText(
      {Key? key,
      required this.label,
      this.isRequired = false,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                    fontFamily: "Roboto-Regular",
                    fontSize: 14,
                    color: Color(0xFF616161)),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextS.smMedium.copyWith(color: Colors.red),
                ),
            ],
          ),
        ),
        C5(),
        child
      ],
    );
  }
}

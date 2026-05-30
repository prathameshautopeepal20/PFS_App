import 'package:flutter/material.dart';
import 'package:atpl_flashing_app/themes/app_textstyles.dart';
import 'package:atpl_flashing_app/utils/sizes.dart';
import 'package:atpl_flashing_app/utils/ui_helper_widgets.dart';

class AppDropdownButtonField<T> extends StatelessWidget {
  final FormFieldSetter<T>? onSaved;
  final String label;
  final T? value;
  final bool isRequired;
  final List<T>? items;
  final ValueChanged<T> onChanged;
  final Function(T)? getLabel;
  final Function(T)? getSubLabel; // <-- new callback for subtext
  final bool? isExpanded;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final String prefix;
  final Widget? suffixIcon;
  final bool floatingLabel;
  final String hintText;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<T>? validator;
  final Color? dropdownIconColor;
  final bool enabled;

  const AppDropdownButtonField({
    Key? key,
    required this.onChanged,
    this.onSaved,
    this.label = "",
    this.hintText = "",
    this.validator,
    this.isRequired = true,
    this.isExpanded = true,
    this.enabled = true,
    this.prefixIcon,
    this.prefix = "",
    required this.items,
    required this.getLabel,
    this.getSubLabel, // <-- new param
    this.floatingLabel = false,
    this.value,
    this.focusNode,
    this.autovalidateMode,
    this.suffixIcon,
    this.dropdownIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (label.isNotEmpty)
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyles.labelStyle,
              children: [
                if (isRequired)
                  TextSpan(
                    text: " *",
                    style: TextStyles.labelStyle.copyWith(color: Colors.red),
                  )
              ],
            ),
          ),
        C5(),
        DropdownButtonFormField<T>(
          focusNode: focusNode,
          validator: validator,
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            enabled: enabled,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            hintText: hintText,
            labelText: floatingLabel ? '$label${isRequired ? ' *' : ''}' : null,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            prefix: Text(prefix,
                style: TextStyle(
                    fontSize: FontSizes.s14,
                    color: Color(0xFF616161),
                    fontFamily: "Roboto-regular")),
          ),
          isExpanded: isExpanded!,
          initialValue: value,
          items: items?.map<DropdownMenuItem<T>>((T data) {
            return DropdownMenuItem<T>(
              value: data,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${getLabel!(data)}', // main text
                    style: TextStyle(
                        fontSize: FontSizes.s14,
                        color: Color(0xFF616161),
                        fontFamily: "Roboto-Regular"),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (getSubLabel != null)
                    Text(
                      '${getSubLabel!(data)}', // subtext
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: "Roboto-Regular",
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? (T? value) => onChanged(value!) : null,
          iconEnabledColor: dropdownIconColor,
        ),
      ],
    );
  }
}

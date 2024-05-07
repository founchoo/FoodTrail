import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ThemedInputDecoration extends InputDecoration {
  ThemedInputDecoration({
    required String labelText,
    IconData? icon,
    Widget? suffixIcon,
  }) : super(
          labelText: labelText,
          hintText: 'input_msg'.tr(args: [labelText.toLowerCase()]),
          icon: icon != null ? Icon(icon) : null,
          suffixIcon: suffixIcon,
        );
}

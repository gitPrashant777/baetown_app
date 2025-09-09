import 'package:flutter/material.dart';

import '../constants.dart';

CheckboxThemeData checkboxThemeData = CheckboxThemeData(
  checkColor: MaterialStateProperty.all(Colors.white),
  fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return primaryColor; // Pink when checked
    }
    return Colors.transparent; // Transparent when unchecked
  }),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(defaultBorderRadious / 2),
    ),
  ),
  side: const BorderSide(color: whileColor40),
);

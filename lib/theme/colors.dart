//-------------------------- flutter_core ------------------------------
import 'package:flutter/material.dart';
//----------------------------------------------------------------------

//----------------------------- app_theme ------------------------------
class AppColors {
  // Brand
  static const Color primary = Color(0xff487852);
  static const Color primaryDark = Color(0xff144937);
  static const Color primaryLight = Color(0xff2f673b);

  // Backgrounds
  static const Color background = Color(0xffF5F9F6);
  static const Color surface = Colors.white;

  // Text
  static const Color textDark = Color(0xff0c3328);
  static const Color textMuted = Color(0xff86a38b);
  static const Color textLight = Colors.white;

  // Status (fixed colors)
  static const Color healthy = Color(0xff2f673b);
  static const Color danger = Color(0xff7a1d1d);

  // Shade-able palettes (so `.shade700`, `.shade800` work)
  static const MaterialColor warning =
      Colors.orange; // access .shade700/.shade800
  static const MaterialColor info = Colors.blue; // access .shade700
  static const MaterialColor success =
      Colors.green; // optional shades if needed
  static const MaterialColor errorSwatch = Colors.red;

  // Single-color variants
  static const Color error = Colors.redAccent;

  // Borders & Dividers
  static const Color border = Color(0xffE0E0E0);
  static const Color divider = Color(0xffBDBDBD);
}

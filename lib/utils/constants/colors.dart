import 'package:flutter/material.dart';

class APPColors {
  APPColors._();

  static const Color primary = Color.fromRGBO(5, 169, 231, 1);
  static const Color secondary = Color.fromRGBO(59, 62, 145, 1);
  static const Color accent = Color(0xFF79b4fb);

  // static const Color primary = Color.fromRGBO(16, 76, 113, 1);
  // static const Color secondary = Color.fromRGBO(236, 134, 4, 1);
  // static const Color accent = Colors.white;

  static const Gradient linerGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xFF9A9AEB), Color(0xFFBCBCF2), Color(0xFFDDDDF8)],
  );

  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  static const Color lightContainer = Color(0xFFF6F6F6);
  static const Color darkContainer = Color(0xFF2C2C2C);

  static const Color buttonPrimary = Color(0xFF31335e);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softgrey = Color(0xFFF4F4F4);
  static const Color lightgrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}

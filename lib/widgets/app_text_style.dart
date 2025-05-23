import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextStyle {
  // Font family names
  static const String dmSansFont = 'DMSans';
  static const String mochiyPopOneFont = 'MochiyPopOne';
  static const String poppinsFont = 'Poppins';

  // DMSans styles
  static TextStyle get dmSansRegular => const TextStyle(
        fontFamily: dmSansFont,
        fontWeight: AppFontWeight.regular,
      );

  static TextStyle get dmSansItalic => const TextStyle(
        fontFamily: dmSansFont,
        fontStyle: FontStyle.italic,
      );

  // MochiyPopOne styles
  static TextStyle get mochiyPopOneRegular => const TextStyle(
        fontFamily: mochiyPopOneFont,
        fontWeight: AppFontWeight.regular,
      );

  // Poppins styles
  static TextStyle get poppinsBlack => const TextStyle(
        fontFamily: poppinsFont,
        fontWeight: AppFontWeight.black,
      );

  static TextStyle get poppinsBold => const TextStyle(
        fontFamily: poppinsFont,
        fontWeight: AppFontWeight.bold,
      );

  static TextStyle get poppinsLight => const TextStyle(
        fontFamily: poppinsFont,
        fontWeight: AppFontWeight.light,
      );

  static TextStyle get poppinsMedium => const TextStyle(
        fontFamily: poppinsFont,
        fontWeight: AppFontWeight.medium,
      );

  static TextStyle get poppinsSemiBold => const TextStyle(
        fontFamily: poppinsFont,
        fontWeight: AppFontWeight.semiBold,
      );

  static TextStyle get poppinsRegular => const TextStyle(
        fontFamily: poppinsFont,
        fontWeight: AppFontWeight.regular,
      );

  // Helper methods for creating custom styles
  static TextStyle dmSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) =>
      TextStyle(
        fontFamily: dmSansFont,
        fontSize: fontSize?.sp,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle,
        decoration: TextDecoration.none,
      );

  static TextStyle mochiyPopOne({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: mochiyPopOneFont,
        fontSize: fontSize?.sp,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: poppinsFont,
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      decoration: TextDecoration.none,
    );
  }

  static TextStyle textWithStroke({
    required double fontSize,
    required Color textColor,
    required Color strokeColor,
    FontWeight fontWeight = FontWeight.bold,
    String fontFamily = mochiyPopOneFont,
    double strokeWidth = 8,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      fontFamily: fontFamily,
      shadows: [
        // Top
        Shadow(
          offset: Offset(0, -strokeWidth / 2),
          color: strokeColor,
          blurRadius: 0,
        ),
        // Bottom
        Shadow(
          offset: Offset(0, strokeWidth / 2),
          color: strokeColor,
          blurRadius: 0,
        ),
        // Left
        Shadow(
          offset: Offset(-strokeWidth / 2, 0),
          color: strokeColor,
          blurRadius: 0,
        ),
        // Right
        Shadow(
          offset: Offset(strokeWidth / 2, 0),
          color: strokeColor,
          blurRadius: 0,
        ),
        // Diagonals for smoother corners
        Shadow(
          offset: Offset(-strokeWidth / 2, -strokeWidth / 2),
          color: strokeColor,
          blurRadius: 0,
        ),
        Shadow(
          offset: Offset(-strokeWidth / 2, strokeWidth / 2),
          color: strokeColor,
          blurRadius: 0,
        ),
        Shadow(
          offset: Offset(strokeWidth / 2, -strokeWidth / 2),
          color: strokeColor,
          blurRadius: 0,
        ),
        Shadow(
          offset: Offset(strokeWidth / 2, strokeWidth / 2),
          color: strokeColor,
          blurRadius: 0,
        ),
      ],
      color: textColor,
    );
  }
}

abstract class AppFontWeight {
  /// FontWeight value of `w900`
  static const FontWeight black = FontWeight.w900;

  /// FontWeight value of `w800`
  static const FontWeight extraBold = FontWeight.w800;

  /// FontWeight value of `w700`
  static const FontWeight bold = FontWeight.w700;

  /// FontWeight value of `w600`
  static const FontWeight semiBold = FontWeight.w600;

  /// FontWeight value of `w500`
  static const FontWeight medium = FontWeight.w500;

  /// FontWeight value of `w400`
  static const FontWeight regular = FontWeight.w400;

  /// FontWeight value of `w300`
  static const FontWeight light = FontWeight.w300;

  /// FontWeight value of `w200`
  static const FontWeight extraLight = FontWeight.w200;

  /// FontWeight value of `w100`
  static const FontWeight thin = FontWeight.w100;
}

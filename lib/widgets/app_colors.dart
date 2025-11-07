import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6267E7);
  static const Color secondary = Color(0xFF8B60EF);
  static const Color accent = Color(0xFFE9515E);

  // Yellow shades
  static const Color yellowPrimary = Color(0xFFFFD217);
  static const Color yellowLight = Color(0xFFFFEE37);
  static const Color yellowLight2 = Color(0xFFFFFAEB);
  static const Color yellowDark = Color(0xFFFFAE02);
  static const Color yellowDark2 = Color(0xFFFFB213);
  static const Color yellowDark3 = Color(0xFFFF8413);
  static const Color yellowDark4 = Color(0xFFFFB828);
  static const Color deepYellow = Color(0xFFE9AD29);

  // Purple shades
  static const Color purplePrimary = Color(0xFFB26BFB);
  static const Color purpleLight = Color(0xFFB57BFE);
  static const Color purpleDark = Color(0xFF8B60EF);
  static const Color purpleDark2 = Color(0xFF9B3DD4);
  static const Color deepPurple = Color(0xFF5B15FF);
  static const Color purpleOverlay = Color(0xFFD3D8FF);
  static const Color purpleTransparent = Color(0x26D3D8FF);
  static const Color darkPurple = Color(0xFF7031FC);
  static const Color darkPurple1 = Color(0xFF8550F1);
  static const Color darkPurple2 = Color(0xFF9A4AFE);
  static const Color darkPurple3 = Color(0xFFA75CF4);
  static const Color darkPurple4 = Color(0xFF5B099B);

  // Gray shades
  static const Color grayLight = Color(0xFFF0F0F0);
  static const Color grayDark = Color(0xFFA5A5A5);
  static const Color grayTransparent = Color(0xFFD9D9D9);

  // Green shades
  static const Color greenBright = Color(0xFF67EB00);
  static const Color greenLight = Color(0xFFF4FFE4);
  static const Color greenDark = Color(0xFF4EC307);
  static const Color deepGreen = Color(0xFF52B342);
  static const Color green = Color(0xFF35CB83);
  static const Color teal = Color(0xFF3FD6B3);

  // Background colors
  static const Color backgroundDark = Color(0x66101010);
  static const Color backgroundLight = Color(0xFFF0F0F0);
  static const Color backgroundGrey = Color(0xFFD9D9D9);
  static const Color backgroundLight2 = Color(0xFFF3F2FF);

  // Pink/Red shades
  static const Color pinkPrimary = Color(0xFFFF4672);
  static const Color pinkDark = Color(0xFFE90038);
  static const Color pinkDark2 = Color(0xFFE530B6);
  static const Color pinkLight = Color(0xFFFF79EA);
  static const Color pinkBg = Color(0xFFFFF0F2);
  static const Color deepPink = Color(0xFFD53BFF);
  static const Color pinkLight2 = Color(0xFFF989FF);
  static const Color redLight = Color(0xFFF9F0F2);

  // Blue shades
  static const Color bluePrimary = Color(0xFF39C7FF);
  static const Color blueLight = Color(0xFF4CDAFE);
  static const Color blueLight2 = Color(0xFF53C1FF);
  static const Color blueLight3 = Color(0xFF67FCFF);
  static const Color blueLight4 = Color(0xFF95E9FF);
  static const Color blueDark = Color(0xFF08B9FF);
  static const Color blueDark2 = Color(0xFF05A4E8);
  static const Color deepBlue = Color(0xFF098AEE);
  static const Color deepBlue1 = Color(0xFF1E88E5);

  // Pink/Purple gradient colors
  static const Color gradientPink = Color(0xFFFDA5FF);
  static const Color gradientPinkDark = Color(0xFFFC8AFF);
  static const Color gradientPurple = Color(0xFFDA57F0);

  // Loading bar colors
  static const Color loadingBarStart = Color(0xFF8B60EF);
  static const Color loadingBarEnd = Color(0xFF2A0C32);

  static const LinearGradient loadingBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [loadingBarStart, loadingBarEnd],
  );
}

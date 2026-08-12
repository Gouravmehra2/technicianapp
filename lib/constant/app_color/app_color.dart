import 'package:flutter/material.dart';

class AppColor {
  // Black Shades
  static const Color blackShade1 = Color(0xFF1E1E1E);
  static const Color blackShade2 = Color(0xFF0A0A0A);
  static const Color blackShade3 = Color(0xFF1A1A1A);
  static const Color blackColor1 = Color(0xff000000);

  // Brown Accent
  static const Color brownAccentPrimary = Color(0xFFA5732F);
  static const Color brownAccentDark = Color(0xFF744300);

  // Neutral Colors
  static const Color neutral1 = Color(0xFFF2F2F2);
  static const Color neutral2 = Color(0xFFFAFAFA);

  // Gray Shades
  static const Color primaryGrey = Color(0xFF3C3C3C);
  static const Color darkGray = Color(0xFF555555);
  static const Color coolGrayText = Color(0xFF6B7280);
  static const Color grey1Color = Color(0xff4C4546);
  static const Color grey2Color = Color(0xff555555);
  static const Color grey3Color = Color(0xff444444);

  //light gray color
  static const Color lightGreyColor = Color(0xffEAEAEA);
  static const Color lightGrey2Color = Color(0xffF5F3F6);


  // Shadow
  static const Color shadowGrey = Color(0xFFEEEBEE);
  //soft - blue color
  static const Color blueColor = Color(0xFF2A8DA8);
  //soft - brown color
  static const Color brownColor = Color(0xff7F530F);
  //button color
  static const Color blackColor = Color(0xff111111);
  static const Color blackColor2 = Color(0xff1A1C1C);

  //background-gradient-color
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xffFBF9FC),
      Color(0xffFFE8C8),
      Color(0xffFFE8C8),
      Color(0xffFFE8C8),
      Color(0xffFBF9FC),
    ],
    stops: [
      0.0,
      0.4,
      0.6,
      0.8,
      1.0,
    ],
  );
  static const LinearGradient homeScreenBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xffFFBB5E),
      Color(0xffFFBB5E),
      Color(0xffFAFAFA),
      Color(0xffFAFAFA),
      Color(0xffFAFAFA),
    ],
    stops: [
     0.0,0.2,0.4,0.0,1.0
    ],

  );

  static const LinearGradient subscriptionCardGradient =LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffA5732F),
        Color(0xff936421),
        Color(0xff4E3616),
      ]);



  static const Color borderColor = Color(0xff777777);
  static const Color purpleColor = Color(0xff935DED);
  static const Color darkBrown = Color(0xff5A2600);
  static const Color greenColor = Color(0xff34C759);
  static const Color green2Color = Color(0xff229D4F);
  static const Color lightGreen1Color = Color(0xffDBF4E4);


}
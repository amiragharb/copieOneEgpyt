import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Color primaryColor = HexColor("#175998");
Color accentColor = HexColor("#f14e4e");
Color primaryDarkColor = HexColor("#124678");
Color greyColor = HexColor("#666666");
Color backgroundGreyColor = HexColor("#ece9e9");
Color grey200 = HexColor("#EEEEEE");
Color logoBlue = HexColor("#468dff");
Color red700 = HexColor("#D32F2F");
Color grey500 = HexColor("9E9E9E");
Color redDark = HexColor("#900c3e");
Color red400 = HexColor("#EF5350");

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
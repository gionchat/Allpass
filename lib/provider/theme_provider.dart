import 'package:flutter/material.dart';
import 'package:allpass/application.dart';
import 'package:allpass/params/config.dart';
import 'package:allpass/utils/allpass_ui.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData currTheme;

  init() {
    currTheme = getTheme(Config.theme);
  }

  void changeTheme(String themeName) {
    if (themeName == Config.theme) return;
    currTheme = getTheme(themeName);
    Config.theme = themeName;
    Application.sp.setString("theme", themeName);
    notifyListeners();
  }

  ThemeData getTheme(String themeName) {
    switch (themeName) {
      case "blue":
        return AllpassTheme.blueTheme();
      case "red":
        return AllpassTheme.redTheme();
      case "teal":
        return AllpassTheme.tealTheme();
      case "deepPurple":
        return AllpassTheme.deepPurpleTheme();
      case "orange":
        return AllpassTheme.orangeTheme();
      case "pink":
        return AllpassTheme.pinkTheme();
      case "blueGrey":
        return AllpassTheme.blueGreyTheme();
      case "dark":
        return AllpassTheme.darkTheme();
      default:
        return AllpassTheme.blueTheme();
    }
  }
}
import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    brightness: Brightness.light,
    textTheme: const TextTheme(
      titleLarge:
          TextStyle(color: Colors.black, fontSize: 40, fontFamily: 'OpenSans'),
      displayLarge: TextStyle(
          fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 3)),
      floatingLabelStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      labelStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      brightness: Brightness.dark,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            color: Colors.white, fontSize: 40, fontFamily: 'OpenSans'),
        displayLarge: TextStyle(
            fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
      cardTheme: CardTheme(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 3)),
        floatingLabelStyle:
            TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        labelStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
      ),
      textSelectionTheme:
          TextSelectionThemeData(cursorColor: Colors.blue, selectionColor: Colors.blue.withOpacity(0.2)));
}

import 'package:flutter/material.dart';

const kCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8)),
  boxShadow: [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 5,
      spreadRadius: 1,
      offset: Offset(1, 2),
    ),
  ],
);

ThemeData themeData = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F5F9),
    labelStyle: TextStyle(color: Colors.black54),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFD2D2D2),
        width: 1,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Color(0xFFD2D2D2),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFD2D2D2),
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
  ),
);

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

ThemeData mainThemeColor = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade50,
    primary: Color.fromARGB(255, 174, 208, 255),
    secondary: Color.fromARGB(255, 108, 173, 238),
    inversePrimary: Color.fromARGB(255, 99, 148, 221),
    error: Colors.red.shade200,
  ),
  textTheme: const TextTheme(
    //this Font we will use later 'H1'

    headline1: TextStyle(
      color: Colors.black,
      fontFamily: 'Inter',
      fontSize: 25,
      fontWeight: FontWeight.w700,
    ),

    //this font we will use later 'H2'

    headline2: TextStyle(
      color: Colors.black,
      fontFamily: 'Inter',
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    //this font we will use  later 'H3'

    headline3: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),

    //this font we will use later 'P1'

    bodyText1: TextStyle(
      //reminding card medicine name
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),

    //this font we will use later 'P2'

    bodyText2: TextStyle(
      //remindingCard dosage
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    //this font we will use later 'S'
    subtitle1: TextStyle(
      //register page
      fontFamily: 'Inter',
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    //thus we have added all the fonts used in the projct ..
  ),
);

TextTheme myCustomTextStyle = TextTheme(
  headlineMedium: TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  ),
  headlineLarge: TextStyle(
    fontSize: 28.sp,
    color: Colors.green.shade800,
    fontWeight: FontWeight.w500,
  ),
  headlineSmall: TextStyle(
    // Define your subtitle style here
    fontSize: 16.sp,
    color: Colors.grey[800],
    fontWeight: FontWeight.normal,
  ),
  labelMedium: TextStyle(),
  labelSmall: TextStyle(),
  titleLarge: TextStyle(),
  titleMedium: TextStyle(),
  bodySmall: TextStyle(
    fontSize: 9.sp,
    color: Colors.grey[800],
    fontWeight: FontWeight.w500,
  ),
);
// TextStyle myCustomTextStyle = const TextStyle(
//   fontSize: 18.0,
//   fontWeight: FontWeight.w500,
// );

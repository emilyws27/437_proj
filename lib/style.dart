import 'package:flutter/material.dart';

ThemeData appTheme(){
  return ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.deepOrange,
        secondary: Colors.indigo,
        background: Colors.amber,
        onError: Colors.deepOrangeAccent,)
  );

}
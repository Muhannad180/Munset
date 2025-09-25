import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:test1/main_navigation.dart';
import 'package:test1/welcome_page.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyAcPTCI5CX7ewXrCmyl35I-ptu4n6ixyjI');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body:MainNavigation()),
    ),
  );
}

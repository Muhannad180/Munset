import 'package:flutter/material.dart';
import 'package:test1/welcome_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: WelcomePage()),
    ),
  );
}

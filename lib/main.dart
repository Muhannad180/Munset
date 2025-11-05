import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/welcome_page.dart';

void main() async {
  await Supabase.initialize(
    url: "https://xzdmzyjoczcovczvzvac.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6ZG16eWpvY3pjb3ZjenZ6dmFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1ODEwMzMsImV4cCI6MjA3NTE1NzAzM30.rkdKcd-ijGxPlSdLtCCkW8V9N0hnSHZZ5AQpLnQrBgA",
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: WelcomePage()),
    ),
  );
}

final supabase = Supabase.instance.client;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/features/onboarding/presentation/screens/welcome_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://xzdmzyjoczcovczvzvac.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6ZG16eWpvY3pjb3ZjenZ6dmFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1ODEwMzMsImV4cCI6MjA3NTE1NzAzM30.rkdKcd-ijGxPlSdLtCCkW8V9N0hnSHZZ5AQpLnQrBgA",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(body: WelcomePage()),
        );
      },
    );
  }
}

final supabase = Supabase.instance.client;

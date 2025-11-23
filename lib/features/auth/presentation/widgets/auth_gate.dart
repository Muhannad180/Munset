// AUTH GATE This will continuously listen for auth state changes.

// unauthenticated -> Login Page
// authenticated -> Profile Page

import 'package:flutter/material.dart';
import 'package:test1/shared/navigation/main_navigation.dart';
import 'package:test1/features/auth/presentation/screens/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to auth state change
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, snapshot) {
        // loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return MainNavigation();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}

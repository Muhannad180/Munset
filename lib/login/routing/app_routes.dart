import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test1/nav_pages/home.dart';
import 'package:test1/login/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRoutes {
  // 🔹 هنا تقدر تضيف "notifier" لو تبغى التطبيق يتحدث لما تتغير حالة المستخدم
  static final router = GoRouter(
    initialLocation: '/',
    // refreshListenable: routingNotifier, // <-- لو عندك Notifier، خله هنا
    redirect: _redirect,
    routes: <RouteBase>[
      // 🔹 المسار الجذر يحوّل مباشرة للصفحة الرئيسية
      GoRoute(path: '/', redirect: (context, state) => '/home'),

      // 🔹 الصفحة الرئيسية
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),

      // 🔹 صفحة تسجيل الدخول
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const SignInScreen();
        },
      ),
    ],
  );

  // 🔐 التوجيه الذكي حسب حالة المستخدم
  static String? _redirect(BuildContext context, GoRouterState state) {
    // مثال مبدئي، لاحقًا نربطه مع Supabase Auth
    final bool loggedIn = false; // غيّرها لاحقًا حسب حالة المستخدم
    final bool loggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !loggingIn)
      return '/login'; // لو مو داخل يروح لتسجيل الدخول
    if (loggedIn && loggingIn) return '/home'; // لو داخل يروح للصفحة الرئيسية

    return null; // مافيه تحويل
  }
}

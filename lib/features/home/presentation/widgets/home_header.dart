import 'package:flutter/material.dart';
import 'package:test1/core/theme/app_style.dart';

class HomeHeader extends StatelessWidget {
  final String firstName;
  final VoidCallback onThemeToggle;

  const HomeHeader({
    super.key,
    required this.firstName,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dark Mode Toggle
          IconButton(
            icon: Icon(
              AppStyle.isDark(context) ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: AppStyle.textMain(context),
            ),
            onPressed: onThemeToggle,
          ),
          Icon(Icons.notifications_none_rounded, size: 28, color: AppStyle.textMain(context)),
          const Spacer(),
          Text('مساء الخير، $firstName', style: AppStyle.heading(context)),
        ],
      ),
    );
  }
}

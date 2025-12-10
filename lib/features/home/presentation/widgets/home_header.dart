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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // النص على أقصى اليمين
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  AppStyle.isDark(context)
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: AppStyle.textMain(context),
                ),
                onPressed: onThemeToggle,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: AppStyle.textMain(context),
              ),
            ],
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight, // يضمن النص على اليمين
            child: Text(
              'مساء الخير، $firstName',
              style: AppStyle.heading(context),
            ),
          ),
        ],
      ),
    );
  }
}

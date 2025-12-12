import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../features/home/presentation/screens/home.dart';
import '../../core/theme/app_style.dart';
import '../../features/chat/presentation/screens/sessions.dart';
import '../../features/journal/presentation/screens/journal.dart';
import '../../features/profile/presentation/screens/profile.dart';
import '../../features/tasks/presentation/screens/tasks.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.score});

  final int? score;

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  // Notifier to trigger Home refresh
  final ValueNotifier<bool> _refreshHome = ValueNotifier(false);
  // Notifier to trigger Tasks refresh
  final ValueNotifier<bool> _refreshTasks = ValueNotifier(false);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        refreshNotifier: _refreshHome,
        onNavigateTo: (index) => _navigateToPage(index),
        onHabitUpdated: () {
          // Trigger refresh in Tasks screen when habit is updated from home
          _refreshTasks.value = !_refreshTasks.value;
        },
      ),
      Journal(
        onJournalAdded: () {
          _refreshHome.value = !_refreshHome.value;
        },
      ),
      Sessions(),
      TasksScreen(
        onDataUpdated: () {
          // Trigger refresh in Home
          _refreshHome.value = !_refreshHome.value;
        },
      ),
      Profile(),
    ];
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows content to go behind the navbar
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNavBar() {
    bool isDark = AppStyle.isDark(context);

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 34),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E1E1E) : Colors.white).withOpacity(
          0.85,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home, Icons.home_outlined, 0, "Home"),
                _buildNavItem(
                  Icons.book,
                  Icons.bookmark_border_rounded,
                  1,
                  "Journal",
                ),
                _buildNavItem(
                  Icons.chat_bubble,
                  Icons.chat_bubble_outline_rounded,
                  2,
                  "Chat",
                ),
                _buildNavItem(Icons.check_circle, Icons.checklist, 3, "Tasks"),
                _buildNavItem(Icons.person, Icons.person_outline, 4, "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData filledIcon,
    IconData outlinedIcon,
    int index,
    String label,
  ) {
    bool isSelected = _currentIndex == index;
    bool isDark = AppStyle.isDark(context);
    final primaryColor = const Color(0xFF26A69A);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            _refreshHome.value = !_refreshHome.value;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 10 : 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.grey[400] : Colors.grey[500]),
                  size: 26,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 8,
                ), // Keeps height consistent to avoid jumping
              ],
            ],
          ),
        ),
      ),
    );
  }
}

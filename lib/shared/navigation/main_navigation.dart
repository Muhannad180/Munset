import 'package:flutter/material.dart';
import '../../features/home/presentation/screens/home.dart';
import '../../core/theme/app_style.dart';
import '../../features/chat/presentation/screens/sessions.dart';
import '../../features/journal/presentation/screens/journal.dart';
import '../../features/profile/presentation/screens/profile.dart';
import '../../features/tasks/presentation/screens/tasks.dart';

class MainNavigation extends StatefulWidget {
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
      Journal(onJournalAdded: () {
        _refreshHome.value = !_refreshHome.value;
      }),
      Sessions(),
      TasksScreen(
        refreshNotifier: _refreshTasks,
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 0),
          _buildNavItem(Icons.bookmark_add_outlined, 1),
          _buildNavItem(Icons.chat_bubble_outline_rounded, 2),
          _buildNavItem(Icons.checklist, 3),
          _buildNavItem(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    bool isDark = AppStyle.isDark(context);

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _refreshHome.value = !_refreshHome.value;
        }
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF4DB6AC).withOpacity(0.3) : const Color(0xFF8FD3C7).withOpacity(0.3))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected 
             ? (isDark ? const Color(0xFF80CBC4) : const Color(0xFF2C5F5A)) 
             : (isDark ? Colors.white54 : Colors.grey[600]),
          size: 28,
        ),
      ),
    );
  }
}

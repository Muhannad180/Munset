import 'package:flutter/material.dart';
import '../../features/home/presentation/screens/home.dart';
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(refreshNotifier: _refreshHome),
      Journal(onJournalAdded: () {
        _refreshHome.value = !_refreshHome.value;
      }),
      Sessions(),
      TasksScreen(onDataUpdated: () {
        // Trigger refresh in Home
        _refreshHome.value = !_refreshHome.value;
      }),
      Profile(),
    ];
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
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
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
              ? Color(0xFF8FD3C7).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isSelected ? Color(0xFF2C5F5A) : Colors.grey[600],
          size: 28,
        ),
      ),
    );
  }
}

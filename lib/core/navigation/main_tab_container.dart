// lib/core/navigation/main_tab_container.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../features/loadout/presentation/pages/loadout_page.dart';
import '../../features/training/presentation/pages/session-setup/session_setup_page.dart';


// Placeholder pages - replace with actual implementations
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppTheme.primary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64, color: AppTheme.primary),
            SizedBox(height: 16),
            Text(
              'Home Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            Text('Coming Soon!', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppTheme.primary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: AppTheme.primary),
            SizedBox(height: 16),
            Text(
              'History Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            Text('Coming Soon!', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: AppTheme.primary),
            SizedBox(height: 16),
            Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            Text('Coming Soon!', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class MainTabContainer extends StatefulWidget {
  final int initialIndex;

  const MainTabContainer({
    Key? key,
    this.initialIndex = 1, // Default to Loadout tab
  }) : super(key: key);

  @override
  State<MainTabContainer> createState() => _MainTabContainerState();
}

class _MainTabContainerState extends State<MainTabContainer> {
  late int _currentIndex;
  late PageController _pageController;

  // List of all tab pages
  final List<Widget> _pages = [
    const HomePage(),      // Index 0
    const LoadoutPage(),   // Index 1 - Remove the BottomNavigation from LoadoutPage
    const TrainingPage(),  // Index 2 - Remove the BottomNavigation from TrainingPage
    const HistoryPage(),   // Index 3
    const ProfilePage(),  // Index 4 - Remove the BottomNavigation from SettingsPage
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Text('🏠', style: TextStyle(fontSize: 20)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('assets/images/loadout_icon.png'),
                size: 24,
              ),
              label: 'Loadout',
            ),
            BottomNavigationBarItem(
              icon: Text('🎯', style: TextStyle(fontSize: 20)),
              label: 'Train',
            ),
            BottomNavigationBarItem(
              icon: Text('📊', style: TextStyle(fontSize: 20)),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Text('👤', style: TextStyle(fontSize: 20)),
              label: 'Profie',
            ),
          ],
        ),
      ),
    );
  }
}
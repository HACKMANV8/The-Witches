import 'package:flutter/material.dart';
import 'package:metropulse/pages/home/home_dashboard_page.dart';
import 'package:metropulse/pages/map_page.dart';
import 'package:metropulse/pages/planner_page.dart';
import 'package:metropulse/pages/alerts_page.dart';
import 'package:metropulse/pages/profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  // Allow descendants (like dashboard actions) to switch tabs programmatically
  static _HomeShellState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_HomeShellState>();

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HomeDashboardPage(),
    MapPage(),
    PlannerPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Public API for switching tabs
  void setTab(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _index = index);
  }
}

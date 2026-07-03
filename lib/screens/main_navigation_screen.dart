import 'package:flutter/material.dart';
import 'gym_timer_screen.dart';
import 'gym_calendar_screen.dart';
import 'gym_home_screen.dart';
import 'gym_notes_screen.dart';
import 'gym_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 2;

  // Lista ekrana više NIJE const jer profil prima promenljive podatke
  List<Widget> get _screens => [
        const GymTimerScreen(),
        const GymCalendarScreen(),
        const GymHomeScreen(), 
        const GymNotesScreen(),
        GymProfileScreen(
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // Ako je tamna tema stavlja tamnu pozadinu menija, inače svetlu
        backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
        selectedItemColor: const Color(0xFF2ECC71), 
        unselectedItemColor: Colors.grey.shade500, 
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Tajmer'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Kalendar'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Beleške'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
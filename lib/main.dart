import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const FitPlanetApp());
}

class FitPlanetApp extends StatefulWidget {
  const FitPlanetApp({super.key});

  @override
  State<FitPlanetApp> createState() => _FitPlanetAppAppState();
}

class _FitPlanetAppAppState extends State<FitPlanetApp> {
  bool _isDarkMode = false; // Početno stanje je svetla tema

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fit Planet',
      
      // 1. SVETLA TEMA
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F5F5), foregroundColor: Colors.black, elevation: 0),
        cardColor: const Color(0xFFF5F5F5), 
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2ECC71), 
          surface: Color(0xFFF5F5F5),
        ),
      ),

      // 2. TAMNA TEMA
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), 
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white, elevation: 0),
        cardColor: const Color(0xFF1E1E1E), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2ECC71), 
          surface: Color(0xFF1E1E1E),
        ),
      ),

      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, 
      
      // Prosleđujemo promenljive navigaciji
      home: MainNavigationScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (bool value) {
          setState(() {
            _isDarkMode = value;
          });
        },
      ),
    );
  }
}
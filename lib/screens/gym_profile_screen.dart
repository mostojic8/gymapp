import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const GymProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<GymProfileScreen> createState() => _GymProfileScreenState();
}

class _GymProfileScreenState extends State<GymProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  bool _timerNotifications = true;
  String _savedName = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Učitavanje podataka iz memorije telefona
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('user_name') ?? "";
      _nameController.text = _savedName;
      _timerNotifications = prefs.getBool('timer_notifications') ?? true;
    });
  }

  // Čuvanje podataka na klik dugmeta
  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setBool('timer_notifications', _timerNotifications);

    setState(() {
      _savedName = _nameController.text.trim();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Profil uspešno ažuriran!', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          backgroundColor: Theme.of(context).colorScheme.primary, // Prati tvoju zelenu boju
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarnaZelena = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Automatski bela ili crna pozadina
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              
              // GORNJI DEO: Avatar i Ime korisnika
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.cardColor, // Prilagođava se svetloj/tamnoj temi
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: _savedName.trim().isEmpty ? Colors.grey : primarnaZelena,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _savedName.trim().isEmpty ? "Gost Korisnik" : _savedName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                    ),
                    const Text("Član Fit Planet-a", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // KARTICA 1: Unos imena korisnika
              Text("LIČNI PODACI", style: TextStyle(color: primarnaZelena, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.badge, color: primarnaZelena),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                        decoration: const InputDecoration(
                          labelText: "Tvoje Ime",
                          labelStyle: TextStyle(color: Colors.grey),
                          hintText: "Unesi ime za Home ekran...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // KARTICA 2: Podešavanja aplikacije (Tema i Notifikacije)
              Text("PODEŠAVANJA APLIKACIJE", style: TextStyle(color: primarnaZelena, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text("Tamna Tema", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                      subtitle: const Text("Prebaci na svetli/tamni mod", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      secondary: Icon(Icons.dark_mode, color: primarnaZelena),
                      activeColor: primarnaZelena,
                      value: widget.isDarkMode,
                      onChanged: (bool value) {
                        widget.onThemeChanged(value); // Menja temu kroz main.dart u hodu
                      },
                    ),
                    Divider(color: theme.brightness == Brightness.light ? Colors.grey.shade300 : Colors.grey.shade800, height: 1),
                    SwitchListTile(
                      title: Text("Notifikacije Tajmera", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                      subtitle: const Text("Obavesti me kada tajmer istekne", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      secondary: Icon(Icons.notifications_active, color: primarnaZelena),
                      activeColor: primarnaZelena,
                      value: _timerNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _timerNotifications = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),
              
              // DUGME ZA ČUVANJE
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarnaZelena,
                  foregroundColor: theme.brightness == Brightness.light ? Colors.white : Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveProfileData,
                icon: const Icon(Icons.save, fontWeight: FontWeight.bold),
                label: const Text('Sačuvaj izmene', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
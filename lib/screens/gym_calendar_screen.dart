import 'package:flutter/material.dart';

class GymCalendarScreen extends StatefulWidget {
  const GymCalendarScreen({super.key});

  @override
  State<GymCalendarScreen> createState() => _GymCalendarScreenState();
}

class _GymCalendarScreenState extends State<GymCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<String>> _reminders = {};
  final TextEditingController _reminderController = TextEditingController();

  String _getDateKey(DateTime date) {
    return "${date.day}.${date.month}.${date.year}.";
  }

  void _addReminder() {
    if (_reminderController.text.trim().isEmpty) return;

    final String dateKey = _getDateKey(_selectedDate);
    setState(() {
      if (_reminders[dateKey] == null) {
        _reminders[dateKey] = [];
      }
      _reminders[dateKey]!.add(_reminderController.text.trim());
    });
    _reminderController.clear();
    Navigator.pop(context); 
  }

  void _showAddReminderDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor, // Prilagođava se svetloj/tamnoj temi
        title: Text(
          "Dodaj podsetnik za ${_getDateKey(_selectedDate)}",
          style: TextStyle(fontSize: 18, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _reminderController,
          autofocus: true,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: "Unesi tekst podsetnika...",
            hintStyle: const TextStyle(color: Colors.grey),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Otkaži", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
            onPressed: _addReminder,
            child: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarnaZelena = theme.colorScheme.primary;
    final String currentDateKey = _getDateKey(_selectedDate);
    final List<String> activeReminders = _reminders[currentDateKey] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Bela u svetloj / Crna u tamnoj
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor, // Svetlo siv / Tamno siv blok
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: theme.copyWith(
                    dividerColor: Colors.transparent,
                    colorScheme: theme.brightness == Brightness.light
                        ? const ColorScheme.light(
                            primary: Color(0xFF2ECC71),
                            onPrimary: Colors.white,
                            onSurface: Colors.black, // Crni brojevi u svetloj temi
                          )
                        : const ColorScheme.dark(
                            primary: Color(0xFF2ECC71),
                            onPrimary: Colors.black,
                            onSurface: Colors.white, // Beli brojevi u tamnoj temi
                          ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onDateChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primarnaZelena,
                foregroundColor: theme.brightness == Brightness.light ? Colors.white : Colors.black,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _showAddReminderDialog,
              icon: const Icon(Icons.add_comment),
              label: const Text('Dodaj podsetnik za ovaj dan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.cardColor, // Svetlo siv / Tamno siv blok za podsetnike
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Podsetnici za: $currentDateKey",
                      style: TextStyle(fontSize: 16, color: primarnaZelena, fontWeight: FontWeight.bold),
                    ),
                    Divider(color: theme.dividerColor, height: 20),
                    Expanded(
                      child: activeReminders.isEmpty
                          ? const Center(
                              child: Text(
                                "Nema zapisa za ovaj datum.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: activeReminders.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("• ", style: TextStyle(color: primarnaZelena, fontSize: 18, fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: Text(
                                          activeReminders[index],
                                          style: TextStyle(fontSize: 15, color: theme.textTheme.bodyMedium?.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
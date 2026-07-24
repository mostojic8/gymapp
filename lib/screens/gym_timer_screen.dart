import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GymTimerScreen extends StatefulWidget {
  const GymTimerScreen({super.key});

  @override
  State<GymTimerScreen> createState() => _GymTimerScreenState();
}

class _GymTimerScreenState extends State<GymTimerScreen> {
  Duration _duration = const Duration(minutes: 0);
  Timer? _countdownTimer;
  bool _isRunning = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _startTimer() {
    if (_isRunning || _duration.inSeconds == 0) return;
    setState(() {
      _isRunning = true;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final seconds = _duration.inSeconds - 1;
        if (seconds < 0) {
          _timerFinished();
        } else {
          _duration = Duration(seconds: seconds);
        }
      });
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  // REŠEN RESET: Vraća vreme tačno na 00:00
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _duration = Duration.zero;
    });
  }

  // Funkcija koja proverava podešavanja i pušta zvuk ako su notifikacije/zvuk uključeni
  Future<void> _pustiZvukAlarma() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isNotificationEnabled = prefs.getBool('timer_notifications') ?? true;

    if (isNotificationEnabled) {
      try {
        await _audioPlayer.play(AssetSource('audio/alarm_beep.mp3'));
      } catch (e) {
        debugPrint("Greška pri puštanju zvuka: $e");
      }
    }
  }

  void _timerFinished() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _duration = Duration.zero;
    });

    _pustiZvukAlarma();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            Icon(Icons.alarm_on, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              "Vreme je isteklo!", 
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        ),
        content: Text(
          "Vreme za pauzu ili vežbu je završeno. Spremi se za sledeću seriju!",
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer(); 
            },
            child: const Text(
              "U redu",
              style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarnaZelena = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Gym Timer", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              height: 220,
              child: _isRunning
                  ? Center(
                      child: Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 76,
                          fontWeight: FontWeight.bold,
                          color: primarnaZelena,
                          fontFamily: 'monospace', 
                        ),
                      ),
                    )
                  : Center(
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            pickerTextStyle: TextStyle(
                              color: primarnaZelena,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.ms,
                          initialTimerDuration: _duration,
                          onTimerDurationChanged: (newDuration) {
                            setState(() {
                              _duration = newDuration;
                            });
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _duration.inSeconds == 0 ? null : (_isRunning ? _stopTimer : _startTimer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.red : primarnaZelena,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isRunning ? "PAUZA" : "START",
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.brightness == Brightness.light ? Colors.grey.shade400 : Colors.grey.shade700),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "RESET",
                    style: TextStyle(
                      fontSize: 18, 
                      color: theme.brightness == Brightness.light ? Colors.grey.shade700 : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
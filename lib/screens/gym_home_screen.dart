import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

class GymHomeScreen extends StatefulWidget {
  const GymHomeScreen({super.key});

  @override
  State<GymHomeScreen> createState() => _GymHomeScreenState();
}

class _GymHomeScreenState extends State<GymHomeScreen> {
  String _timeString = "";
  String _dateString = "";
  late Timer _timer;
  
  // Lista koja cuva prave fajlove slika umesto obicnog teksta
  final List<File> _galleryImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now(), demandsTime: true);
    _dateString = _formatDateTime(DateTime.now(), demandsTime: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = _formatDateTime(now, demandsTime: true);
      _dateString = _formatDateTime(now, demandsTime: false);
    });
  }

  String _formatDateTime(DateTime dateTime, {required bool demandsTime}) {
    if (demandsTime) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}.${dateTime.month}.${dateTime.year}.";
    }
  }

  // PRAVA KAMERA I ČUVANJE U GALERIJU TELEFONA
  Future<void> _openCameraAndAddPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        // 1. Sacuvaj sliku u galeriju telefona (u album "Gymapp")
        await Gal.putImage(photo.path, album: 'Gymapp');

        // 2. Dodaj sliku u lokalnu listu za prikaz unutar aplikacije
        setState(() {
          _galleryImages.add(File(photo.path));
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Fotografija uspešno uslikana i sačuvana u galeriju telefona!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri slikanju: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Prikaz slike preko celog ekrana kada se klikne
  void _openFullImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarnaZelena = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40), 
            // BOKS SA SATOM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2,
                      color: primarnaZelena,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _dateString,
                    style: TextStyle(
                      fontSize: 16, 
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), 
            // DUGME ZA KAMERU
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primarnaZelena,
                foregroundColor: theme.brightness == Brightness.light ? Colors.white : Colors.black, 
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 1,
              ),
              onPressed: _openCameraAndAddPhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Pokreni Kameru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mini Galerija Forme:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _galleryImages.isEmpty
                  ? const Center(
                      child: Text(
                        'Nema napravljenih slika. Klikni na kameru iznad!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _galleryImages.length,
                      itemBuilder: (context, index) {
                        final imageFile = _galleryImages[index];
                        return GestureDetector(
                          onTap: () => _openFullImage(imageFile),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primarnaZelena.withOpacity(0.4)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
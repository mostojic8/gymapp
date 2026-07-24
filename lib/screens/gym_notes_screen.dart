import 'package:flutter/material.dart';
import '../models/gym_note.dart';
import 'note_edit_screen.dart';

class GymNotesScreen extends StatefulWidget {
  const GymNotesScreen({super.key});

  @override
  State<GymNotesScreen> createState() => _GymNotesScreenState();
}

class _GymNotesScreenState extends State<GymNotesScreen> {
  final List<GymNote> _notes = [];

  void _deleteNote(String id) async {
    final theme = Theme.of(context);
    final potvrdjeno = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Obriši belešku?', style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
        content: Text('Da li si siguran da želiš da obrišeš ovu belešku?', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Otkaži', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (potvrdjeno == true) {
      setState(() {
        _notes.removeWhere((note) => note.id == id);
      });
    }
  }

  void _openNoteEditor([GymNote? note]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(note: note),
      ),
    );

    if (result == 'delete' && note != null) {
      setState(() {
        _notes.removeWhere((element) => element.id == note.id);
      });
      return;
    }

    if (result != null && result is GymNote) {
      setState(() {
        if (note == null) {
          _notes.insert(0, result);
        } else {
          final index = _notes.indexWhere((element) => element.id == note.id);
          if (index != -1) {
            _notes[index] = result;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarnaZelena = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Moje Beleške', 
          style: TextStyle(color: primarnaZelena, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
                'Nema beležaka. Klikni + da dodaš.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final trenutnaNote = _notes[index];

                return Card(
                  color: theme.cardColor, // Svetlo siv boks u svetloj temi / Tamno siv u tamnoj temi
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      trenutnaNote.title.isEmpty ? 'Bez naslova' : trenutnaNote.title,
                      style: TextStyle(color: primarnaZelena, fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        trenutnaNote.content.isEmpty ? 'Nema dodatog teksta' : trenutnaNote.content,
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${trenutnaNote.dateTime.day}.${trenutnaNote.dateTime.month}.",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          onPressed: () => _deleteNote(trenutnaNote.id),
                        ),
                      ],
                    ),
                    onTap: () => _openNoteEditor(trenutnaNote),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.cardColor, // Sivi kružić prati boju blokova aplikacije
        elevation: 2,
        onPressed: () => _openNoteEditor(),
        child: Icon(Icons.add, color: primarnaZelena, size: 28), // Zeleni plus
      ),
    );
  }
}
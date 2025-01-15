import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../database_helper.dart';

class AddExhibitDialog extends StatefulWidget {
  final VoidCallback onSave; // Callback po zapisaniu wystawy
  final Map<String, dynamic>? initialData; // Opcjonalne dane do edycji

  const AddExhibitDialog({
    Key? key,
    required this.onSave,
    this.initialData,
  }) : super(key: key);

  @override
  AddExhibitDialogState createState() => AddExhibitDialogState();
}

class AddExhibitDialogState extends State<AddExhibitDialog> {
  late TextEditingController exhibitNameController;
  late TextEditingController exhibitLocationController;
  bool isExhibitNameEmpty = false;
  bool isExhibitLocationEmpty = false;

  @override
  void initState() {
    super.initState();
    exhibitNameController = TextEditingController(
      text: widget.initialData?['name'] ?? '', // Ustaw nazwę, jeśli istnieje
    );
    exhibitLocationController = TextEditingController(
      text: widget.initialData?['location'] ??
          '', // Ustaw lokalizację, jeśli istnieje
    );
  }

  @override
  void dispose() {
    exhibitNameController.dispose();
    exhibitLocationController.dispose();
    super.dispose();
  }

  Future<void> _saveExhibit() async {
    setState(() {
      isExhibitNameEmpty = exhibitNameController.text.trim().isEmpty;
      isExhibitLocationEmpty = exhibitLocationController.text.trim().isEmpty;
    });

    if (isExhibitNameEmpty || isExhibitLocationEmpty) {
      return;
    }

    final updatedExhibit = {
      'name': exhibitNameController.text.trim(),
      'location': exhibitLocationController.text.trim(),
    };

    if (widget.initialData == null) {
      // Tworzenie nowej wystawy
      final result = await DatabaseHelper().insertExhibit(updatedExhibit);

      if (result == -1) {
        // Sprawdź, czy widok jest zamontowany, zanim użyjesz context
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translate('duplicateExhibitError')),
            ),
          );
        }
        return;
      }

// Przy zamykaniu dialogu
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      // Aktualizacja istniejącej wystawy
      await DatabaseHelper()
          .updateExhibit(widget.initialData!['id'], updatedExhibit);
    }

    widget.onSave();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null
          ? translate('addExhibit') // Dodaj nową wystawę
          : translate('editExhibit')), // Edytuj istniejącą wystawę
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: exhibitNameController,
            decoration: InputDecoration(
              labelText: translate('exhibitName'),
              errorText: isExhibitNameEmpty ? translate('fieldRequired') : null,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: exhibitLocationController,
            decoration: InputDecoration(
              labelText: translate('exhibitLocation'),
              errorText:
                  isExhibitLocationEmpty ? translate('fieldRequired') : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(translate('cancel')),
        ),
        TextButton(
          onPressed: _saveExhibit,
          child: Text(translate('save')),
        ),
      ],
    );
  }
}

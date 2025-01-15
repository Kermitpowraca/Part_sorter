import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:part_sorter/views/add_edit/add_edit_box.dart';
import 'package:part_sorter/views/add_edit/add_exhibit_dialog.dart';
import '../database_helper.dart';
import '../views/add_edit/add_edit_cabinet_dialog.dart';
import 'package:logger/logger.dart';

class ContainerManagerView extends StatefulWidget {
  const ContainerManagerView({Key? key}) : super(key: key);

  @override
  ContainerManagerViewState createState() => ContainerManagerViewState();
}

class ContainerManagerViewState extends State<ContainerManagerView> {
  List<Map<String, dynamic>> exhibits = []; // Lista wystaw
  List<Map<String, dynamic>> boxes = []; // Lista pudełek
  List<Map<String, dynamic>> shelfUnits = []; // Lista regałów
  bool isLoading = true; // Flaga ładowania danych
  final Logger _logger = Logger(); // Dodano instancję loggera
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _logger.i('Ładowanie danych z bazy...');
      final fetchedBoxes = await DatabaseHelper().getBoxes();
      final fetchedExhibits = await DatabaseHelper().getExhibits();
      final fetchedShelfUnits = await DatabaseHelper().getShelfUnits();

      setState(() {
        boxes = fetchedBoxes;
        exhibits = fetchedExhibits;
        shelfUnits = fetchedShelfUnits;
        isLoading = false;
      });

      _logger.d(
          'Aktualizacja widoku: ${shelfUnits.length} regałów, ${boxes.length} pudełek, ${exhibits.length} wystaw.');
    } catch (e) {
      _logger.e('Błąd ładowania danych: $e');
      setState(() {
        boxes = [];
        exhibits = [];
        shelfUnits = [];
        isLoading = false;
      });
    }
  }

  Future<void> showAddEditBoxDialog(
    BuildContext context, {
    Map<String, dynamic>? boxData,
    required ValueChanged<Map<String, dynamic>> onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddEditBoxDialog(
        boxData: boxData,
        onSave: onSave,
      ),
    );
  }

  void _insertBox() async {
    await showAddEditBoxDialog(
      context,
      onSave: (data) async {
        await DatabaseHelper().insertBox(data); // Wywołujemy metodę insertBox
        _loadData(); // Funkcja odświeżenia danych (jeśli istnieje)
      },
    );
  }

  void _editBox(Map<String, dynamic> box) async {
    await showAddEditBoxDialog(context, boxData: box, onSave: (data) async {
      await _loadData(); // Odśwież listę po zapisaniu
    });
  }

  void _deleteBox(Map<String, dynamic> box) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('deleteConfirmationMessage')),
        content: Text(translate('confirmDelete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translate('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteBox(box['id']);
      _loadData();
    }
  }

  void _addContainer() async {
    final db = await DatabaseHelper().database;

    await showAddShelfDialog(
      context,
      db,
      onSave: () async {
        _loadData(); // Odśwież listę regałów po zapisaniu
      },
    );
  }

  void _deleteShelfUnit(Map<String, dynamic> shelfUnit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('deleteConfirmationMessage')),
        content: Text(translate('confirmDelete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translate('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper().database;

      // Usuń półki powiązane z regałem
      await DatabaseHelper().deleteShelvesByShelfUnitId(shelfUnit['id']);

      // Usuń sam regał
      await db.delete(
        'shelf_unit',
        where: 'id = ?',
        whereArgs: [shelfUnit['id']],
      );

      // Odśwież listę po usunięciu
      _loadData();
    }
  }

  void _editExhibit(Map<String, dynamic> exhibitData) async {
    await showDialog(
      context: context,
      builder: (context) => AddExhibitDialog(
        initialData: exhibitData, // Przekazujemy dane wystawy do edycji
        onSave: _loadData, // Odświeżanie danych po edycji
      ),
    );
  }

  void _showExhibitDetails(Map<String, dynamic> exhibit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${translate('exhibitDetails')} - ${exhibit['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${translate('name')}: ${exhibit['name']}'),
            const SizedBox(height: 8),
            Text('${translate('location')}: ${exhibit['location']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('close')),
          ),
        ],
      ),
    );
  }

  void _showBoxDetails(Map<String, dynamic> box) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${translate('boxDetails')} - ${box['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${translate('dimensions')}: ${box['width']} x ${box['height']} x ${box['depth']} cm'),
            if (box['hasCompartments'] == 1)
              Text('${translate('compartments')}: ${box['compartmentsCount']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('close')),
          ),
        ],
      ),
    );
  }

  void _deleteExhibit(Map<String, dynamic> exhibit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('deleteConfirmationMessage')),
        content: Text(translate('confirmDelete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(translate('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteExhibit(exhibit['id']);
      _loadData();
    }
  }

  void _editShelfUnit(Map<String, dynamic> shelfUnit) async {
    final db = await DatabaseHelper().database;

    // Pobierz półki powiązane z regałem
    final shelves =
        await DatabaseHelper().getShelvesByShelfUnitId(shelfUnit['id']);

    // Przekaż dane regału i półek do dialogu edycji
    await showAddShelfDialog(
      context,
      db,
      shelfData: {
        ...shelfUnit, // Dane regału
        'shelves': shelves, // Lista półek
      },
      onSave: _loadData, // Przekazanie callbacka odświeżającego listę regałów
    );

    // Po zakończeniu edycji również odśwież listę
    _loadData();
  }

  void _showShelfDetails(Map<String, dynamic> shelfUnit) async {
    final shelves =
        await DatabaseHelper().getShelvesByShelfUnitId(shelfUnit['id']);

    String formatDimension(double value) {
      return value % 1 == 0 ? '${value.toInt()}cm' : '${value}cm';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${translate('shelfDetails')} - ${shelfUnit['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${translate('shelfCount')}: ${shelfUnit['shelf_count']}\n'
                '${translate('isHorizontal')}: ${shelfUnit['is_horizontal'] == 1 ? translate('horizontal') : translate('vertical')}',
              ),
              const SizedBox(height: 16.0),
              ...shelves.map((shelf) => ListTile(
                    title:
                        Text('${translate('shelf')} ${shelf['shelf_number']}'),
                    subtitle: Text(
                      '${translate('dimensions')}: '
                      '${formatDimension(shelf['height'])} x '
                      '${formatDimension(shelf['width'])} x '
                      '${formatDimension(shelf['depth'])}',
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('close')),
          ),
        ],
      ),
    );
  }

  void _addExhibit() async {
    final TextEditingController exhibitNameController = TextEditingController();
    final TextEditingController exhibitLocationController =
        TextEditingController();
    bool isExhibitNameEmpty = false;
    bool isExhibitLocationEmpty = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(translate('addExhibit')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: exhibitNameController,
                    decoration: InputDecoration(
                      labelText: translate('exhibitName'),
                      errorText: isExhibitNameEmpty
                          ? translate('fieldRequired')
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: exhibitLocationController,
                    decoration: InputDecoration(
                      labelText: translate('exhibitLocation'),
                      errorText: isExhibitLocationEmpty
                          ? translate('fieldRequired')
                          : null,
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
                  onPressed: () async {
                    // Walidacja
                    setState(() {
                      isExhibitNameEmpty =
                          exhibitNameController.text.trim().isEmpty;
                      isExhibitLocationEmpty =
                          exhibitLocationController.text.trim().isEmpty;
                    });

                    if (isExhibitNameEmpty || isExhibitLocationEmpty) {
                      return;
                    }

                    // Próba dodania wystawy
                    final newExhibit = {
                      'name': exhibitNameController.text.trim(),
                      'location': exhibitLocationController.text.trim(),
                    };

                    final result =
                        await DatabaseHelper().insertExhibit(newExhibit);

                    if (result == -1) {
                      // Wyświetlenie komunikatu o duplikacie
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(translate('duplicateShelfError')),
                        ),
                      );
                    } else {
                      // Odśwież dane po dodaniu wystawy
                      Navigator.pop(context);
                      _loadData();
                    }
                  },
                  child: Text(translate('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('containerManager')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(translate('addBox')),
                  onPressed: _insertBox, // Funkcja dodawania pudełka
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(translate('addContainer')),
                  onPressed: _addContainer, // Przycisk dodawania regału
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(translate('addExhibit')),
                  onPressed: _addExhibit,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                if (shelfUnits.isNotEmpty)
                  _buildSection(
                    title: translate('shelfUnits'), // Tytuł sekcji regałów
                    items: shelfUnits,
                    itemBuilder: (shelfUnit) => ListTile(
                      title: Text(shelfUnit['name']), // Tylko nazwa regału
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info), // Ikona szczegółów
                            onPressed: () => _showShelfDetails(
                                shelfUnit), // Szczegóły regału
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _editShelfUnit(shelfUnit), // Edycja
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteShelfUnit(shelfUnit), // Usuwanie
                          ),
                        ],
                      ),
                    ),
                  ),
                if (boxes.isNotEmpty)
                  _buildSection(
                    title: translate('boxes'), // Tytuł sekcji pudełek
                    items: boxes,
                    itemBuilder: (box) => ListTile(
                      title: Text(box['name']), // Tylko nazwa pudełka
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info), // Ikona szczegółów
                            onPressed: () =>
                                _showBoxDetails(box), // Szczegóły pudełka
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editBox(box), // Edycja
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteBox(box), // Usuwanie
                          ),
                        ],
                      ),
                    ),
                  ),
                if (exhibits.isNotEmpty)
                  _buildSection(
                    title: translate('exhibits'), // Tytuł sekcji wystaw
                    items: exhibits,
                    itemBuilder: (exhibit) => ListTile(
                      title: Text(exhibit['name']), // Tylko nazwa wystawy
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info), // Ikona szczegółów
                            onPressed: () => _showExhibitDetails(
                                exhibit), // Szczegóły wystawy
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editExhibit(exhibit), // Edycja
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteExhibit(exhibit), // Usuwanie
                          ),
                        ],
                      ),
                    ),
                  ),
                if (shelfUnits.isEmpty && boxes.isEmpty && exhibits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        translate('noDataAvailable'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...items.map((item) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: itemBuilder(item),
          );
        }).toList(),
      ],
    );
  }
}

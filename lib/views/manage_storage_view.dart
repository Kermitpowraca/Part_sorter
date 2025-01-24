import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'container_manager_view.dart';
import '../database_helper.dart';
import 'package:logger/logger.dart';
import 'view_graphic.dart';
import 'view_text.dart';

class ManageStorageView extends StatefulWidget {
  const ManageStorageView({Key? key}) : super(key: key);

  @override
  ManageStorageViewState createState() => ManageStorageViewState();
}

class ManageStorageViewState extends State<ManageStorageView> {
  List<Map<String, dynamic>> shelfUnits = [];
  List<Map<String, dynamic>> boxes = [];
  List<Map<String, dynamic>> exhibits = [];
  List<Map<String, dynamic>> selectedBoxes = []; // Lista wybranych pudełek
  List<Map<String, dynamic>> selectedExhibits = [];
  final Logger _logger = Logger(); // Dodano instancję loggera
  double scaleFactor = 3; // Domyślna wartość skalowania
  static const double shelfSpacing =
      2.0; // Odstęp między półkami (w jednostkach przed skalowaniem)
  List<Map<String, dynamic>> selectedShelfUnits = [];
  String selectedView = 'graficzny'; // Domyślny widok

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedShelfUnits = await DatabaseHelper().getShelfUnits();
      final fetchedBoxes = await DatabaseHelper().getBoxes();
      final fetchedExhibits = await DatabaseHelper().getExhibits();

      setState(() {
        shelfUnits = fetchedShelfUnits;
        boxes = fetchedBoxes;
        exhibits = fetchedExhibits; // Pobieramy wystawy z bazy danych
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas ładowania danych: $e')),
      );
    }
  }

  void _selectAndAddExhibit(Map<String, dynamic> exhibit) {
    setState(() {
      selectedExhibits.add({
        'name': exhibit['name'],
        'width': 100,
        'depth': 50,
      });
    });

    // Logowanie dodanego elementu
    _logger.i('Added exhibit: ${exhibit['name']}');
  }

  void _showShelfUnitsDialog() async {
    await _loadData();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSelectionDialog(); // Powrót do okna "Select Option"
                },
              ),
              Text(translate('shelfUnits')),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: shelfUnits.length,
              itemBuilder: (context, index) {
                final shelfUnit = shelfUnits[index];
                return ListTile(
                  title: Text(shelfUnit['name']),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _addShelfUnit(shelfUnit); // Dodanie regału
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          translate(
                            'shelfSelected', // Klucz tłumaczenia
                            args: {
                              'name': shelfUnit['name']
                            }, // Dynamiczna wartość
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addShelfUnit(Map<String, dynamic> shelfUnit) async {
    try {
      // Pobierz dane półek związanych z danym regałem z bazy danych
      final shelves =
          await DatabaseHelper().getShelvesByShelfUnitId(shelfUnit['id']);
      final updatedShelfUnit = {
        ...shelfUnit,
        'shelves': shelves, // Dodajemy półki do regału
      };

      // Pokaż dodatkowe okno dialogowe z pytaniem o nazwę
      String? customName = await _askForShelfName(shelfUnit['name']);

      // Dodajemy regał do listy wybranych regałów
      setState(() {
        selectedShelfUnits.add({
          ...updatedShelfUnit,
          'customName':
              customName ?? shelfUnit['name'], // Ustawiamy nazwę tylko lokalnie
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate('shelfAdded',
                args: {'name': customName ?? shelfUnit['name']}),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${translate('addShelfError')} $e')),
      );
    }
  }

  Future<String?> _askForShelfName(String defaultName) async {
    final TextEditingController nameController =
        TextEditingController(text: defaultName);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('enterShelfName')),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: translate('shelfName'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null), // Anuluj
              child: Text(translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text); // Zwróć nazwę
              },
              child: Text(translate('save')),
            ),
          ],
        );
      },
    );
  }

  void _showBoxesDialog() async {
    await _loadData();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('boxes')),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: boxes.length,
              itemBuilder: (context, index) {
                final box = boxes[index];
                return ListTile(
                  title: Text(box['name']),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addBoxToLayout(box); // Dodajemy pudełko do układu
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('back')),
            ),
          ],
        );
      },
    );
  }

  void _addBoxToLayout(Map<String, dynamic> box) {
    _logger.i('Adding box: $box'); // Logowanie dodanego pudełka
    setState(() {
      selectedBoxes.add(box);
    });
  }

  void _showExhibitsDialog() async {
    await _loadData();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSelectionDialog(); // Powrót do okna "Select Option"
                },
              ),
              Text(translate('exhibits')),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exhibits.length,
              itemBuilder: (context, index) {
                final exhibit = exhibits[index];
                return ListTile(
                  title: Text(exhibit['name']),
                  onTap: () {
                    _logger.i('Selected exhibit: ${exhibit['name']}');
                    _selectAndAddExhibit(
                        exhibit); // Przekazanie tylko `exhibit`
                    Navigator.of(context).pop(); // Zamknięcie dialogu
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('selectOption')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.shelves),
                title: Text(translate('shelfDetails')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showShelfUnitsDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: Text(translate('boxDetails')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showBoxesDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.density_medium),
                title: Text(translate('exhibitDetails')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showExhibitsDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _navigateToContainerManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContainerManagerView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Rozszerz body pod AppBar
      extendBody: true, // Rozszerz body pod BottomAppBar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent, // lub inny kolor tła
        child: selectedView == 'graficzny'
            ? GraphicView(
                selectedShelfUnits: selectedShelfUnits,
                selectedBoxes: selectedBoxes,
                selectedExhibits: selectedExhibits,
                scaleFactor: scaleFactor, // Przekazanie skali
              )
            : const TextView(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(translate('view'),
                style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 8),
            SegmentedButton(
              segments: [
                ButtonSegment(
                  value: 'graficzny',
                  label: Text(translate('graphicView')), // Przetłumaczony tekst
                  icon: const Icon(Icons.grid_view),
                ),
                ButtonSegment(
                  value: 'tekstowy',
                  label: Text(translate('textView')), // Przetłumaczony tekst
                  icon: const Icon(Icons.text_fields),
                ),
              ],
              selected: {selectedView},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  selectedView = newSelection.first;
                  _logger.i('Wybrany widok: $selectedView');
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    scaleFactor += 1;
                  });
                },
                tooltip: translate('zoomIn'),
                child: const Icon(Icons.zoom_in),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    scaleFactor -= 1;
                  });
                },
                tooltip: translate('zoomOut'),
                child: const Icon(Icons.zoom_out),
              ),
              FloatingActionButton(
                onPressed: _showSelectionDialog,
                tooltip: translate('addFeature'),
                child: const Icon(Icons.add),
              ),
              FloatingActionButton(
                onPressed: _navigateToContainerManager,
                tooltip: translate('goToContainerManager'),
                child: const Icon(Icons.shelves),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

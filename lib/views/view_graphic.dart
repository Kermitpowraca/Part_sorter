import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../shelf_unit_renderer.dart';

class GraphicView extends StatefulWidget {
  final List<Map<String, dynamic>> selectedShelfUnits;
  final List<Map<String, dynamic>> selectedBoxes;
  final List<Map<String, dynamic>> selectedExhibits;

  final double scaleFactor;

  const GraphicView({
    Key? key,
    required this.selectedShelfUnits,
    required this.selectedBoxes,
    required this.selectedExhibits,
    required this.scaleFactor,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GraphicViewState createState() => _GraphicViewState();
}

class _GraphicViewState extends State<GraphicView> {
  final PageController _pageController = PageController();

  void _showExhibitOptionsDialog(int index, Map<String, dynamic> exhibit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${translate('exhibitOptions')} - ${exhibit['name']}'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: translate('editName'), // Tłumaczenie tooltipa
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  _showEditExhibitNameDialog(exhibit, index);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: translate('deleteExhibit'), // Tłumaczenie tooltipa
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  _confirmDeleteExhibit(exhibit, index);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text(translate('cancel')), // Przetłumaczony tekst przycisku
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteExhibit(Map<String, dynamic> exhibit, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('confirmation')), // Tłumaczenie tytułu
          content: Text(
            translate('confirmDeleteExhibit', args: {
              'name': exhibit['name'],
            }), // Tłumaczenie z dynamiczną nazwą wystawy
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('no')), // Tłumaczenie przycisku "Nie"
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.selectedExhibits.removeAt(index);
                });
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: Text(translate('yes')), // Tłumaczenie przycisku "Tak"
            ),
          ],
        );
      },
    );
  }

  void _showEditExhibitNameDialog(Map<String, dynamic> exhibit, int index) {
    final TextEditingController nameController =
        TextEditingController(text: exhibit['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('editName')), // Tłumaczenie tytułu
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
                labelText: translate('exhibitName')), // Tłumaczenie etykiety
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text(translate('cancel')), // Tłumaczenie przycisku "Anuluj"
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.selectedExhibits[index]['name'] = nameController.text;
                });
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: Text(translate('save')), // Tłumaczenie przycisku "Zapisz"
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteBox(Map<String, dynamic> box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('confirmDelete')),
          content: Text(
            '${translate('deleteBox')} "${box['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Anuluj
              child: Text(translate('no')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
                _deleteBox(box); // Usuń pudełko
              },
              child: Text(translate('yes')),
            ),
          ],
        );
      },
    );
  }

  void _deleteBox(Map<String, dynamic> box) {
    setState(() {
      widget.selectedBoxes.remove(box); // Używaj widget.selectedBoxes
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${translate('boxDeleted')} "${box['name']}"'),
      ),
    );
  }

  void _rotateBox(int index) {
    setState(() {
      // Pobierz kopię mapy, aby uniknąć modyfikacji oryginału
      final box = Map<String, dynamic>.from(
          widget.selectedBoxes[index]); // Dodano widget.

      // Zamiana szerokości i wysokości
      final temp = box['width'];
      box['width'] = box['depth'];
      box['depth'] = temp;

      // Nadpisz zmieniony box w liście
      widget.selectedBoxes[index] = box; // Dodano widget.
    });
  }

  void _showBoxOptionsDialog(int index, Map<String, dynamic> box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${translate('boxOptions')} - ${box['name']}'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.rotate_left),
                tooltip: translate('rotated'),
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  _rotateBox(index); // Wywołanie funkcji obracania
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Szczegóły',
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Szczegóły dla: ${box['name']}'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  _confirmDeleteBox(box);
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

  void _previousPage() {
    if (_pageController.page!.toInt() > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_pageController.page!.toInt() < widget.selectedShelfUnits.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  //funkcja obsługująca dialog z opcjami regału
  void _showShelfOptionsDialog(Map<String, dynamic> shelfUnit, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${translate('shelfOptionsFor')}: ${shelfUnit['name']}'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                tooltip: translate('editName'), // Przetłumaczony tooltip
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  _showEditShelfNameDialog(shelfUnit, index);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                tooltip: translate('deleteShelf'), // Przetłumaczony tooltip
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie dialogu
                  _confirmDeleteShelfUnit(shelfUnit, index);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text(translate('cancel')), // Przetłumaczony tekst przycisku
            ),
          ],
        );
      },
    );
  }

  // funkcję edycji nazwy regału
  void _showEditShelfNameDialog(Map<String, dynamic> shelfUnit, int index) {
    final TextEditingController nameController =
        TextEditingController(text: shelfUnit['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('editName')),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: translate('cabinetName')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.selectedShelfUnits[index]['name'] =
                      nameController.text;
                });
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: Text(translate('save')),
            ),
          ],
        );
      },
    );
  }

  // Funkcja usuwania regału z tłumaczeniami
  void _confirmDeleteShelfUnit(Map<String, dynamic> shelfUnit, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('confirmation')), // Tłumaczenie tytułu
          content: Text(
            translate('confirmDeleteContainer', args: {
              'name': shelfUnit['name']
            }), // Tłumaczenie treści z nazwą regału
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(translate('no')), // Tłumaczenie przycisku "Nie"
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.selectedShelfUnits.removeAt(index);
                });
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: Text(translate('yes')), // Tłumaczenie przycisku "Tak"
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tło całego widoku
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(255, 29, 124, 168), // Kolor tła
        ),
        // Główna zawartość podzielona na lewo i prawo
        Positioned.fill(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lewa strona - PageView dla regałów
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    // Tło lewej strony
                    Container(
                      color: const Color.fromARGB(255, 29, 76, 156),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 80), // Nad podłogą
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth;
                            final maxHeight = constraints.maxHeight;

                            return Stack(
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.selectedShelfUnits.length,
                                  itemBuilder: (context, index) {
                                    final shelfUnit =
                                        widget.selectedShelfUnits[index];
                                    final shelves = shelfUnit['shelves'] ?? [];

                                    // Obliczenie dynamicznego skalowania
                                    final shelfWidth =
                                        shelfUnit['width'] ?? 100.0;
                                    final shelfHeight =
                                        shelfUnit['height'] ?? 100.0;

                                    final widthScale =
                                        maxWidth * 1 / shelfWidth;
                                    final heightScale =
                                        maxHeight * 0.6 / shelfHeight;
                                    final dynamicScale =
                                        widthScale < heightScale
                                            ? widthScale
                                            : heightScale;

                                    final scale =
                                        dynamicScale < widget.scaleFactor
                                            ? dynamicScale
                                            : widget.scaleFactor;

                                    return GestureDetector(
                                      onTap: () {
                                        // Wyświetlamy przetłumaczoną wiadomość w SnackBarze
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(translate(
                                                'tapAndHoldToEditOrDelete')), // Przetłumaczony tekst
                                            duration: const Duration(
                                                seconds:
                                                    1), // Jak długo wiadomość jest widoczna
                                          ),
                                        );
                                      },
                                      onLongPress: () =>
                                          _showShelfOptionsDialog(
                                              shelfUnit, index),
                                      child: SizedBox(
                                        width: shelfUnit[
                                            'width'], // Ustaw szerokość regału
                                        height: shelfUnit[
                                            'height'], // Ustaw wysokość regału
                                        child: Align(
                                          alignment: Alignment
                                              .center, // Wyrównanie regału w centrum
                                          child: Transform.scale(
                                            scale: scale,
                                            alignment: Alignment.center,
                                            child: ShelfUnitRenderer
                                                .buildShelfUnit(
                                              shelfUnit,
                                              shelves,
                                              1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Przyciski nawigacyjne
                                Positioned(
                                  left: 10,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon:
                                        const Icon(Icons.arrow_back, size: 40),
                                    onPressed: _previousPage,
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_forward,
                                        size: 40),
                                    onPressed: _nextPage,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Prawa strona - wystawy i pudełka
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Górny kontener - wystawy
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.orangeAccent,
                          ),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    widget.selectedExhibits.map((exhibit) {
                                  final int index = widget.selectedExhibits
                                      .indexOf(
                                          exhibit); // Pobierz indeks wystawy
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Wyświetlenie komunikatu po kliknięciu
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              translate(
                                                  'tapAndHoldToEditOrDelete'),
                                            ), // Przetłumaczony tekst
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      onLongPress: () {
                                        // Wywołanie dialogu z opcjami dla wystawy
                                        _showExhibitOptionsDialog(
                                            index, exhibit);
                                      },
                                      child: Container(
                                        width: (exhibit['width'] ?? 100) *
                                            widget.scaleFactor,
                                        height: (exhibit['height'] ?? 50) *
                                            widget.scaleFactor,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 146, 61, 32),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.black, width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            exhibit['name'] ?? 'Wystawa',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dolny kontener - pudełka
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.greenAccent,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 80),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: widget.selectedBoxes.map((box) {
                                    final int index = widget.selectedBoxes
                                        .indexOf(box); // Pobierz indeks pudełka
                                    return Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () {
                                          // Wywołanie funkcji _showBoxOptionsDialog po kliknięciu na pudełko
                                          _showBoxOptionsDialog(index, box);
                                        },
                                        child: Container(
                                          width: (box['width'] ?? 100) *
                                              widget.scaleFactor,
                                          height: (box['height'] ?? 50) *
                                              widget.scaleFactor,
                                          decoration: BoxDecoration(
                                            color: box['color'] ??
                                                Colors.orangeAccent,
                                            border: Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              box['name'] ?? 'Pudełko',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

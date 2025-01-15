import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import dla FilteringTextInputFormatter
import 'package:flutter_translate/flutter_translate.dart';
import 'package:sqflite/sqflite.dart';
import '../../database_helper.dart';

Future<void> showAddShelfDialog(
  BuildContext context,
  Database db, {
  Map<String, dynamic>? shelfData,
  required VoidCallback onSave, // Dodaj funkcję odświeżania
}) async {
  final TextEditingController nameController = TextEditingController(
    text: shelfData?['name'] ?? '', // Wypełnij nazwę, jeśli edytujesz
  );

  final TextEditingController shelfCountController = TextEditingController(
    text: shelfData?['shelf_count']?.toString() ?? '1', // Domyślnie jedna półka
  );

  bool sameShelf =
      shelfData?['same_shelf'] == 1; // Czy półki mają te same wymiary
  bool horizontalShelf = shelfData?['is_horizontal'] == 1; // Domyślnie poziome
  bool isNameEmpty = false;
  bool isShelfCountEmpty = false;
  bool isHeightEmpty = false;
  bool isWidthEmpty = false;
  bool isDepthEmpty = false;
  bool isAnyDimensionEmpty = false;
  bool isDialogMounted = true; // Dodaj lokalną zmienną

  // Dynamiczna lista pól dla każdej półki
  List<Map<String, TextEditingController>> shelfDimensions = [];

  if (shelfData != null) {
    // Pobierz istniejące półki z bazy danych dla edytowanego regału
    final shelves =
        await DatabaseHelper().getShelvesByShelfUnitId(shelfData['id']);
    shelfDimensions = shelves.map((shelf) {
      return {
        'height':
            TextEditingController(text: shelf['height']?.toString() ?? ''),
        'width': TextEditingController(text: shelf['width']?.toString() ?? ''),
        'depth': TextEditingController(text: shelf['depth']?.toString() ?? ''),
      };
    }).toList();
  } else {
    // Domyślnie jedna półka, jeśli tworzymy nowy regał
    shelfDimensions = List.generate(
      int.tryParse(shelfCountController.text) ?? 1,
      (_) => {
        'height': TextEditingController(),
        'width': TextEditingController(),
        'depth': TextEditingController(),
      },
    );
  }

  final TextEditingController heightController = TextEditingController(
    text: (sameShelf &&
            shelfData != null &&
            shelfData['shelves'] != null &&
            shelfData['shelves'].isNotEmpty)
        ? shelfData['shelves'][0]['height']?.toString() ?? ''
        : '',
  );

  final TextEditingController widthController = TextEditingController(
    text: (sameShelf &&
            shelfData != null &&
            shelfData['shelves'] != null &&
            shelfData['shelves'].isNotEmpty)
        ? shelfData['shelves'][0]['width']?.toString() ?? ''
        : '',
  );

  final TextEditingController depthController = TextEditingController(
    text: (sameShelf &&
            shelfData != null &&
            shelfData['shelves'] != null &&
            shelfData['shelves'].isNotEmpty)
        ? shelfData['shelves'][0]['depth']?.toString() ?? ''
        : '',
  );

  final List<TextInputFormatter> numberInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
  ];

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(
              shelfData == null
                  ? translate('addCabinet') // Dodawanie nowego regału
                  : translate('editCabinet'), // Edycja regału
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Nazwa regału
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: translate('cabinetName'),
                      errorText:
                          isNameEmpty ? translate('fieldRequired') : null,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Liczba półek
                  TextField(
                    controller: shelfCountController,
                    decoration: InputDecoration(
                      labelText: translate('shelfCount'),
                      errorText: isShelfCountEmpty
                          ? translate('fieldRequired')
                          : (int.tryParse(shelfCountController.text) ?? 1) > 20
                              ? translate(
                                  'tooManyShelves') // Komunikat "Za dużo półek"
                              : null,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*')), // Tylko cyfry
                    ],
                    onChanged: (value) {
                      setState(() {
                        int count = int.tryParse(value) ?? 1;
                        if (count > 20) {
                          // Ustaw flagę błędu, jeśli liczba półek przekracza 20
                          isShelfCountEmpty = false;
                        } else {
                          isShelfCountEmpty =
                              true; // Reset błędu, jeśli liczba jest poprawna
                          shelfDimensions = List.generate(
                            count,
                            (_) => {
                              'height': TextEditingController(),
                              'width': TextEditingController(),
                              'depth': TextEditingController(),
                            },
                          );
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 16.0),

                  // Suwak: Czy półki mają te same wymiary?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translate('doTheyhaveTheSameDimensions'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Switch(
                        value: sameShelf,
                        onChanged: (bool value) {
                          setState(() {
                            sameShelf = value;
                          });
                        },
                      ),
                    ],
                  ),

                  // Orientacja półek
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate('shelfOrientation'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8.0),
                      SegmentedButton<String>(
                        segments: <ButtonSegment<String>>[
                          ButtonSegment(
                            value: 'horizontal',
                            label: Text(translate(
                                'horizontal')), // Tłumaczenie dla "Poziome"
                          ),
                          ButtonSegment(
                            value: 'vertical',
                            label: Text(translate(
                                'vertical')), // Tłumaczenie dla "Pionowe"
                          ),
                        ],
                        selected: <String>{
                          horizontalShelf ? 'horizontal' : 'vertical',
                        },
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            horizontalShelf =
                                newSelection.first == 'horizontal';
                          });
                        },
                      ),
                    ],
                  ),

                  // Pola wymiarów półek (jeśli mają te same wymiary)
                  if (sameShelf)
                    Column(
                      children: [
                        TextField(
                          controller: heightController,
                          decoration: InputDecoration(
                            labelText: translate('height'),
                            errorText: isHeightEmpty
                                ? translate('fieldRequired')
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: numberInputFormatter,
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: widthController,
                          decoration: InputDecoration(
                            labelText: translate('width'),
                            errorText: isWidthEmpty
                                ? translate('fieldRequired')
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: numberInputFormatter,
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: depthController,
                          decoration: InputDecoration(
                            labelText: translate('depth'),
                            errorText: isDepthEmpty
                                ? translate('fieldRequired')
                                : null,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: numberInputFormatter,
                        ),
                      ],
                    )
                  else
                    // Jeśli półki mają różne wymiary
                    Column(
                      children: shelfDimensions.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(translate('shelfDimensions',
                                args: {'index': '${index + 1}'})),
                            TextField(
                              controller: entry.value['height'],
                              decoration: InputDecoration(
                                labelText: translate('height'),
                                errorText: isAnyDimensionEmpty &&
                                        entry.value['height']!.text
                                            .trim()
                                            .isEmpty
                                    ? translate('fieldRequired')
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: numberInputFormatter,
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: entry.value['width'],
                              decoration: InputDecoration(
                                labelText: translate('width'),
                                errorText: isAnyDimensionEmpty &&
                                        entry.value['width']!.text
                                            .trim()
                                            .isEmpty
                                    ? translate('fieldRequired')
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: numberInputFormatter,
                            ),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: entry.value['depth'],
                              decoration: InputDecoration(
                                labelText: translate('depth'),
                                errorText: isAnyDimensionEmpty &&
                                        entry.value['depth']!.text
                                            .trim()
                                            .isEmpty
                                    ? translate('fieldRequired')
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: numberInputFormatter,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(translate('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    isNameEmpty = nameController.text.trim().isEmpty;
                    isShelfCountEmpty =
                        shelfCountController.text.trim().isEmpty;

                    if (sameShelf) {
                      isHeightEmpty = heightController.text.trim().isEmpty;
                      isWidthEmpty = widthController.text.trim().isEmpty;
                      isDepthEmpty = depthController.text.trim().isEmpty;
                    } else {
                      isAnyDimensionEmpty = shelfDimensions.any((shelf) =>
                          shelf['height']!.text.trim().isEmpty ||
                          shelf['width']!.text.trim().isEmpty ||
                          shelf['depth']!.text.trim().isEmpty);
                    }
                  });

                  // Jeśli są błędy, zatrzymaj zapis
                  if (isNameEmpty ||
                      isShelfCountEmpty ||
                      (sameShelf &&
                          (isHeightEmpty || isWidthEmpty || isDepthEmpty)) ||
                      (!sameShelf && isAnyDimensionEmpty)) {
                    return;
                  }

                  int shelfCount = int.tryParse(shelfCountController.text) ?? 1;

                  if (shelfData == null) {
                    // Dodawanie nowego regału
                    int shelfUnitId = await DatabaseHelper().insertShelfUnit(
                      db,
                      nameController.text.trim(),
                      shelfCount,
                      sameShelf ? 1 : 0,
                      horizontalShelf ? 1 : 0,
                    );

                    if (shelfUnitId == -1 && isDialogMounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            translate('duplicateShelfError'),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return; // Zatrzymanie zapisu w przypadku duplikatu
                    }

                    // Dodawanie półek (gdy nie ma duplikatu)
                    if (sameShelf) {
                      for (int i = 0; i < shelfCount; i++) {
                        await DatabaseHelper().insertShelf(
                          db,
                          shelfUnitId,
                          double.tryParse(heightController.text) ?? 0.0,
                          double.tryParse(widthController.text) ?? 0.0,
                          double.tryParse(depthController.text) ?? 0.0,
                          i + 1, // Numer półki
                        );
                      }
                    } else {
                      for (var shelf in shelfDimensions) {
                        await DatabaseHelper().insertShelf(
                          db,
                          shelfUnitId,
                          double.tryParse(shelf['height']!.text) ?? 0.0,
                          double.tryParse(shelf['width']!.text) ?? 0.0,
                          double.tryParse(shelf['depth']!.text) ?? 0.0,
                          shelfDimensions.indexOf(shelf) + 1, // Numer półki
                        );
                      }
                    }

                    if (isDialogMounted) {
                      onSave(); // Odświeżenie listy po dodaniu
                      Navigator.of(dialogContext)
                          .pop(); // Zamknięcie okna dialogowego
                    } // Zamknięcie okna dialogowego
                  } else {
                    // Edycja istniejącego regału
                    await DatabaseHelper().updateShelfUnit(
                      shelfData['id'],
                      nameController.text.trim(),
                      shelfCount,
                      sameShelf ? 1 : 0,
                      horizontalShelf ? 1 : 0,
                    );

                    await DatabaseHelper()
                        .deleteShelvesByShelfUnitId(shelfData['id']);

                    if (sameShelf) {
                      for (int i = 0; i < shelfCount; i++) {
                        await DatabaseHelper().insertShelf(
                          db,
                          shelfData['id'],
                          double.tryParse(heightController.text) ?? 0.0,
                          double.tryParse(widthController.text) ?? 0.0,
                          double.tryParse(depthController.text) ?? 0.0,
                          i + 1,
                        );
                      }
                    } else {
                      for (var shelf in shelfDimensions) {
                        await DatabaseHelper().insertShelf(
                          db,
                          shelfData['id'],
                          double.tryParse(shelf['height']!.text) ?? 0.0,
                          double.tryParse(shelf['width']!.text) ?? 0.0,
                          double.tryParse(shelf['depth']!.text) ?? 0.0,
                          shelfDimensions.indexOf(shelf) + 1,
                        );
                      }
                    }

                    if (isDialogMounted) {
                      onSave(); // Odśwież dane
                      Navigator.of(dialogContext).pop(); // Zamknij dialog;
                    }
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

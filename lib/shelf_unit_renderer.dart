import 'package:flutter/material.dart';
import 'dart:math';

class ShelfUnitRenderer {
  static const double shelfSpacingFactor = 2.0; // Przerwa między półkami

  static Widget buildShelfUnit(
    Map<String, dynamic> shelfUnit,
    List<Map<String, dynamic>> shelves,
    double scaleFactor, // Przyjmujemy scaleFactor jako parametr
  ) {
    final bool isHorizontal = shelfUnit['is_horizontal'] == 1;

    double shelfUnitWidth = 0.0;
    double shelfUnitHeight = 0.0;

    if (isHorizontal) {
      shelfUnitWidth = shelves.fold<double>(
        0.0,
        (maxWidth, shelf) => max(maxWidth, shelf['width'] ?? 0.0),
      );
      shelfUnitHeight = shelves.fold<double>(
        0.0,
        (sumHeight, shelf) => sumHeight + (shelf['height'] ?? 0.0),
      );
    } else {
      shelfUnitWidth = shelves.fold<double>(
        0.0,
        (sumWidth, shelf) => sumWidth + (shelf['width'] ?? 0.0),
      );
      shelfUnitHeight = shelves.fold<double>(
        0.0,
        (maxHeight, shelf) => max(maxHeight, shelf['height'] ?? 0.0),
      );
    }

    return SizedBox(
      width: shelfUnitWidth / scaleFactor,
      height: shelfUnitHeight / scaleFactor,
      child: Stack(
        children: shelves.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> shelf = entry.value;

          double shelfTop = 0.0;
          double shelfLeft = 0.0;

          if (isHorizontal) {
            shelfTop = shelves
                .sublist(0, index)
                .fold<double>(0.0, (sum, s) => sum + (s['height'] ?? 0.0));
            shelfLeft = (shelfUnitWidth - (shelf['width'] ?? 0.0)) / 2;
          } else {
            shelfTop = (shelfUnitHeight - (shelf['height'] ?? 0.0)) / 2;
            shelfLeft = shelves
                .sublist(0, index)
                .fold<double>(0.0, (sum, s) => sum + (s['width'] ?? 0.0));
          }

          // Obramowanie bez skalowania
          Border border;
          if (isHorizontal) {
            if (index == 0) {
              // Pierwsza półka pozioma
              border = const Border(
                top: BorderSide(color: Colors.black, width: 2),
                left: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 0.5),
              );
            } else if (index == shelves.length - 1) {
              // Ostatnia półka pozioma
              border = const Border(
                left: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
                top: BorderSide(color: Colors.black, width: 0.5),
              );
            } else {
              // Środkowe półki poziome
              border = const Border(
                left: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
                top: BorderSide(color: Colors.black, width: 0.5),
                bottom: BorderSide(color: Colors.black, width: 0.5),
              );
            }
          } else {
            if (index == 0) {
              // Pierwsza półka pionowa
              border = const Border(
                top: BorderSide(color: Colors.black, width: 2),
                left: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 0.5),
              );
            } else if (index == shelves.length - 1) {
              // Ostatnia półka pionowa
              border = const Border(
                top: BorderSide(color: Colors.black, width: 2),
                right: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
                left: BorderSide(color: Colors.black, width: 0.5),
              );
            } else {
              // Środkowe półki pionowe
              border = const Border(
                top: BorderSide(color: Colors.black, width: 2),
                bottom: BorderSide(color: Colors.black, width: 2),
                left: BorderSide(color: Colors.black, width: 0.5),
                right: BorderSide(color: Colors.black, width: 0.5),
              );
            }
          }

          return Positioned(
            top: shelfTop / scaleFactor,
            left: shelfLeft / scaleFactor,
            width: (shelf['width'] ?? 0.0) / scaleFactor,
            height: (shelf['height'] ?? 0.0) / scaleFactor,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 180, 153, 103),
                border: border,
              ),
              child: Center(
                child: Text(
                  'Półka ${shelf['shelf_number']}',
                  style: const TextStyle(
                    fontSize: 12, // Stały rozmiar tekstu
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

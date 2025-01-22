import 'package:flutter/material.dart';
import '../shelf_unit_renderer.dart';

class GraphicView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tło całego widoku
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(255, 29, 124, 168), // Kolor tła
        ),
        // Całość zawartości z możliwością przewijania
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80), // Nad podłogą
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Przewijanie w pionie
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Przewijanie w poziomie
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Regały na podłodze
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: selectedShelfUnits.map((shelfUnit) {
                          final shelves = shelfUnit['shelves']
                              as List<Map<String, dynamic>>;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: 30 *
                                  scaleFactor *
                                  scaleFactor, // Przerwa między regałami
                            ),
                            child: Transform.scale(
                              scale: scaleFactor, // Skalowanie regału
                              alignment: Alignment.bottomCenter,
                              child: ShelfUnitRenderer.buildShelfUnit(
                                shelfUnit,
                                shelves,
                                1.0, // Skala wewnętrzna
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Pudełka obok regałów
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Wystawy nad pudełkami
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: selectedExhibits.map((exhibit) {
                              final width = exhibit['width'] ?? 100;
                              final depth = exhibit['depth'] ?? 50;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: 10 *
                                      scaleFactor, // Przerwa między wystawami
                                ),
                                child: Container(
                                  width: width * scaleFactor,
                                  height: depth * scaleFactor,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 146, 61, 32),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(25),
                                        blurRadius: 5,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      exhibit['name'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                              height:
                                  10), // Odstęp między wystawami i pudełkami
                          // Pudełka poniżej wystaw
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: selectedBoxes.map((box) {
                              final width = (box['width'] ?? 100) * scaleFactor;
                              final height =
                                  (box['height'] ?? 50) * scaleFactor;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: 10 *
                                      scaleFactor, // Przerwa między pudełkami
                                ),
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  width: width,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: box['color'] ?? Colors.orangeAccent,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      box['name'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12, // Stały rozmiar tekstu
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Podłoga
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: 80, // Wysokość podłogi
            color: Colors.grey, // Kolor podłogi
          ),
        ),
      ],
    );
  }
}

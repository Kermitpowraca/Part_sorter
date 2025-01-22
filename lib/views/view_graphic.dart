import 'package:flutter/material.dart';
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
  _GraphicViewState createState() => _GraphicViewState();
}

class _GraphicViewState extends State<GraphicView> {
  final PageController _pageController = PageController();

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
                      color: Colors.blueAccent.withOpacity(0.2),
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

                                    final widthScale = maxWidth / shelfWidth;
                                    final heightScale = maxHeight / shelfHeight;
                                    final dynamicScale =
                                        widthScale < heightScale
                                            ? widthScale
                                            : heightScale;

                                    final scale =
                                        dynamicScale < widget.scaleFactor
                                            ? dynamicScale
                                            : widget.scaleFactor;

                                    return Center(
                                      child: Transform.scale(
                                        scale: scale,
                                        alignment: Alignment.center,
                                        child: ShelfUnitRenderer.buildShelfUnit(
                                          shelfUnit,
                                          shelves,
                                          1.0, // Brak wewnętrznego skalowania
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
                            color: Colors.orangeAccent.withOpacity(0.3),
                          ),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    widget.selectedExhibits.map((exhibit) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: (exhibit['width'] ?? 100) *
                                          widget.scaleFactor,
                                      height: (exhibit['height'] ?? 50) *
                                          widget.scaleFactor,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 146, 61, 32),
                                        borderRadius: BorderRadius.circular(10),
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
                            color: Colors.greenAccent.withOpacity(0.3),
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
                                    return Padding(
                                      padding: const EdgeInsets.all(10),
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

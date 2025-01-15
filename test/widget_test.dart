import 'package:flutter_test/flutter_test.dart';

import 'package:part_sorter/main.dart';

void main() {
  testWidgets('App has a title', (WidgetTester tester) async {
    await tester.pumpWidget(const PartSorterApp());

    // Sprawdzamy, czy aplikacja zawiera poprawny tytuł
    expect(find.text('Part Sorter'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class WarehouseView extends StatelessWidget {
  const WarehouseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: translate('searchPlaceholder'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              // Logika wyszukiwania (do zaimplementowania)
            },
          ),
        ),
        Expanded(
          child: Center(
            child: Text(translate('warehouseContent')),
          ),
        ),
      ],
    );
  }
}

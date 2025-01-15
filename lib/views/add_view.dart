import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class AddView extends StatelessWidget {
  const AddView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Logika dodawania klocków (do zaimplementowania)
            },
            icon: const Icon(Icons.add),
            label: Text(translate('addParts')),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Logika dodawania zestawów (do zaimplementowania)
            },
            icon: const Icon(Icons.add_box),
            label: Text(translate('addSets')),
          ),
        ],
      ),
    );
  }
}

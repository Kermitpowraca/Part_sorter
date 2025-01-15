import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  const TextView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Widok tekstowy',
        style: TextStyle(
            fontSize: 24, color: Theme.of(context).textTheme.bodyLarge!.color),
      ),
    );
  }
}

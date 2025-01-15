import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ShelfViewScreen extends StatefulWidget {
  final String shelfName;
  final List<Map<String, dynamic>> items;

  const ShelfViewScreen(
      {Key? key, required this.shelfName, required this.items})
      : super(key: key);

  @override
  ShelfViewScreenState createState() => ShelfViewScreenState();
}

class ShelfViewScreenState extends State<ShelfViewScreen> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
  }

  void _removeItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translate('deleteItem')),
          content: Text(translate('deleteItemConfirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(translate('itemDeleted'))),
                );
              },
              child: Text(translate('delete')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(translate('shelfContents', args: {'name': widget.shelfName})),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(translate('shelfEmpty')),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle:
                      Text(translate('type', args: {'type': item['type']})),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeItem(index),
                  ),
                );
              },
            ),
    );
  }
}

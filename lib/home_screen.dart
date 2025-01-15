import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'views/home_view.dart';
import 'views/warehouse_view.dart';
import 'views/add_view.dart';
import 'views/manage_storage_view.dart'; // Import nowego widoku

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final VoidCallback onLocaleChanged;

  const HomeScreen({
    Key? key,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _currentView = 'home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentView == 'home'
              ? translate('appTitle')
              : _currentView == 'warehouse'
                  ? translate('myWarehouse')
                  : _currentView == 'manageStorage'
                      ? translate('physicalWarehouse')
                      : translate('addToWarehouse'),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                translate('appTitle'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(translate('home')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentView = 'home';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: Text(translate('myWarehouse')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentView = 'warehouse';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: Text(translate('addToWarehouse')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentView = 'add';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: Text(translate('physicalWarehouse')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentView = 'manageStorage';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(translate('settingsTitle')),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: _currentView == 'home'
          ? HomeView(onLocaleChanged: widget.onLocaleChanged)
          : _currentView == 'warehouse'
              ? const WarehouseView()
              : _currentView == 'manageStorage'
                  ? const ManageStorageView()
                  : const AddView(),
    );
  }
}

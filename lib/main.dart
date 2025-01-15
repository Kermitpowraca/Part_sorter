import 'dart:io'; // Potrzebne do sprawdzania platformy
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import dla desktopu
import 'settings_screen.dart';
import 'home_screen.dart'; // Import klasy HomeScreen
import 'package:flutter/foundation.dart'; // Import dla kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja sqflite_common_ffi na desktopie
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicjalizacja tłumaczeń
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: ['en', 'pl'],
  );

  runApp(LocalizedApp(delegate, const PartSorterApp()));
}

class PartSorterApp extends StatefulWidget {
  const PartSorterApp({Key? key}) : super(key: key);

  @override
  State<PartSorterApp> createState() => _PartSorterAppState();
}

class _PartSorterAppState extends State<PartSorterApp> {
  ThemeMode _themeMode = ThemeMode.system; // Domyślny motyw: systemowy
  Key _appKey = UniqueKey(); // Dynamiczny klucz aplikacji

  void updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void refreshApp() {
    // Wymuszenie odświeżenia aplikacji
    setState(() {
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return MaterialApp(
      key: _appKey, // Klucz dynamiczny, który odświeża całą aplikację
      title: 'Part Sorter',
      localizationsDelegates: [
        localizationDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale, // Aktualny język
      theme: ThemeData.light(), // Motyw jasny
      darkTheme: ThemeData.dark(), // Motyw ciemny
      themeMode: _themeMode, // Responsywny tryb motywu
      home: HomeScreen(
        onThemeModeChanged: updateThemeMode,
        onLocaleChanged: refreshApp, // Funkcja do dynamicznej zmiany języka
      ), // Ekran główny
      routes: {
        '/settings': (context) =>
            SettingsScreen(onThemeModeChanged: updateThemeMode),
      },
    );
  }
}

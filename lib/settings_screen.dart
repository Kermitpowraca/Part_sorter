import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;

  const SettingsScreen({Key? key, required this.onThemeModeChanged})
      : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;
  late ThemeMode _selectedThemeMode;

  @override
  void initState() {
    super.initState();
    // Pobranie aktualnego języka aplikacji
    _selectedLanguage =
        LocalizedApp.of(context).delegate.currentLocale.languageCode;
    _selectedThemeMode = ThemeMode.system; // Domyślnie ustawiony na systemowy
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('settingsTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('languageSetting'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                      _changeLanguage(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(translate('systemLanguage')),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(translate('english')),
                    ),
                    DropdownMenuItem(
                      value: 'pl',
                      child: Text(translate('polish')),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate('themeSetting'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<ThemeMode>(
                  value: _selectedThemeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      setState(() {
                        _selectedThemeMode = newMode;
                      });
                      widget.onThemeModeChanged(newMode);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(translate('themeSystem')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(translate('themeLight')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(translate('themeDark')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(String languageCode) {
    if (languageCode == 'system') {
      var locale = View.of(context).platformDispatcher.locale;
      changeLocale(context, locale.languageCode);
    } else {
      changeLocale(context, languageCode);
    }
  }
}

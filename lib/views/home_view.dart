import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class HomeView extends StatelessWidget {
  final VoidCallback onLocaleChanged;

  const HomeView({Key? key, required this.onLocaleChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            translate('welcomeMessage'),
            style: const TextStyle(fontSize: 20),
          ),
          TextButton(
            onPressed: () {
              changeLocale(
                  context,
                  LocalizedApp.of(context)
                              .delegate
                              .currentLocale
                              .languageCode ==
                          'en'
                      ? 'pl'
                      : 'en');
              onLocaleChanged();
            },
            child: Text(translate('changeLanguage')),
          ),
        ],
      ),
    );
  }
}

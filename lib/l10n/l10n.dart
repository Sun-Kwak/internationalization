
import 'package:flutter/material.dart';
final systemLocale = WidgetsBinding.instance!.platformDispatcher.locale;

class L10n {
  static final all = <Locale>[
    const Locale('en', 'US'),
    const Locale('ko', 'KR'),
    const Locale('zh', 'CN'),
    const Locale('ja', 'JP'),
    const Locale('ru', 'RU'),
  ];

  static Locale findLocaleByLanguageCode(String languageCode) {
    for (var locale in all) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }
    return systemLocale;
  }

  static Locale findLocaleByCountryCode(String countryCode) {
    for (var locale in all) {
      if (locale.countryCode == countryCode) {
        return locale;
      }
    }
    return systemLocale;
  }
}
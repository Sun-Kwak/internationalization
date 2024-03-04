import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:internationalization/l10n/l10n.dart';

final appLocalizationsProvider =
StateNotifierProvider<AppLocalizationsNotifier, AppLocalizations>(
        (ref) {
          final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      return AppLocalizationsNotifier(lookupAppLocalizations(systemLocale));
    });

class AppLocalizationsNotifier extends StateNotifier<AppLocalizations> {
  AppLocalizationsNotifier(AppLocalizations state) : super(state);

  void updateLocale(String countryCode) {
    Locale foundLocale = L10n.findLocaleByCountryCode(countryCode);
    state = lookupAppLocalizations(foundLocale);
  }
}

final textProvider = StateProvider<String>((ref) => '');
final translatedTextProvider = StateProvider<String>((ref) => '');


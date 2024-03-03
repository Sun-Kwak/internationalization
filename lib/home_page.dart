import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internationalization/provider.dart';

import 'l10n/l10n.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late List<String> countryList;
  String currentCountry ='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countryList = convertLocaleToCountryList(L10n.all);
  }

  List<String> convertLocaleToCountryList(List<Locale> locales) {
    return locales.map((e) => e.countryCode).where((code) => code != null).cast<String>().toList();
  }
  @override
  Widget build(BuildContext context) {
    final localState = ref.watch(appLocalizationsProvider);
    Locale? foundLocale = L10n.findLocaleByLanguageCode(localState.localeName);
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internationalization'),
           ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CountryCodePicker(
              onChanged: (value) {
                ref.read(appLocalizationsProvider.notifier).updateLocale(value.code.toString());
              },
              initialSelection: foundLocale?.countryCode.toString(),
              showFlag: true,
              showCountryOnly: true,
              showOnlyCountryWhenClosed: true,
              countryFilter: countryList,
            )
,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appLocalizations.systemLanguage,
                ),
                const Text(
                 ":",
                ),
                Text(
                  appLocalizations.language,
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

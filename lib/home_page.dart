import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internationalization/provider.dart';
import 'l10n/l10n.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late List<String> countryList;

  @override
  void initState() {
    super.initState();
    countryList = convertLocaleToCountryList(L10n.all);
  }

  // 로케일 목록을 국가 코드 목록으로 변환하는 메서드
  List<String> convertLocaleToCountryList(List<Locale> locales) {
    return locales
        .map((e) => e.countryCode) // 국가 코드 추출
        .where((code) => code != null) // null 체크
        .cast<String>() // 타입 캐스팅
        .toList(); // 리스트로 변환
  }

  // 텍스트를 번역하는 비동기 메서드
  Future<void> translateText(String text, String targetLanguage) async {
    final translatedTextController = ref.read(translatedTextProvider.notifier);
    final String apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY']!;
    const String baseUrl =
        'https://translation.googleapis.com/language/translate/v2';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'q': text,
          'target': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        translatedTextController.state =
        data['data']['translations'][0]['translatedText'];
      } else {
        throw Exception('Failed to translate text: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error occurred during translation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final localState = ref.watch(appLocalizationsProvider);
    Locale? foundLocale = L10n.findLocaleByLanguageCode(localState.localeName);

    return Scaffold(
      appBar: _buildAppBar(appLocalizations, foundLocale),
      body: _buildBody(appLocalizations, foundLocale),
    );
  }

  // 앱 바 위젯 생성
  PreferredSizeWidget _buildAppBar(AppLocalizations appLocalizations, Locale? foundLocale) {
    return AppBar(
      title: const Text("Internalization"),
      actions: [
        CountryCodePicker(
          onChanged: (value) {
            ref
                .read(appLocalizationsProvider.notifier)
                .updateLocale(value.code.toString());
          },
          initialSelection: foundLocale!.countryCode.toString(),
          showFlag: true,
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          countryFilter: countryList,
        )
      ],
    );
  }

  // 바디 위젯 생성
  Widget _buildBody(AppLocalizations appLocalizations, Locale? foundLocale) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(appLocalizations),
          _buildInputField(appLocalizations),
          _buildTranslatedTextSection(appLocalizations, foundLocale),
        ],
      ),
    );
  }

  // 헤더 위젯 생성
  Widget _buildHeader(AppLocalizations appLocalizations) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(appLocalizations.systemLanguage),
          const Text(":"),
          Text(appLocalizations.language),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // 입력 필드 위젯 생성
  Widget _buildInputField(AppLocalizations appLocalizations) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: appLocalizations.memoHint,
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                ref.read(textProvider.notifier).state = text;
                ref.read(translatedTextProvider.notifier).state = text;
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(),
        )
      ],
    );
  }

  // 번역된 텍스트 섹션 위젯 생성
  Widget _buildTranslatedTextSection(AppLocalizations appLocalizations, Locale? foundLocale) {
    final translatedText = ref.watch(translatedTextProvider);
    final text = ref.watch(textProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(height: 50, child: Text(translatedText)),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              translateText(text, foundLocale!.languageCode);
            },
            child: Text(appLocalizations.translate),
          ),
        )
      ],
    );
  }
}

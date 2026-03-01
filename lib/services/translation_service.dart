import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate(String text) async {
    if (text.isEmpty) {
      return '';
    }
    try {
      var translation = await _translator.translate(text, from: 'ta', to: 'en');
      return translation.text;
    } catch (e) {
      // ignore: avoid_print
      print('Translation Error: $e');
      return text; // Return original text if translation fails
    }
  }
}

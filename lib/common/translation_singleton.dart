/* import 'package:miracle_manager/model/transalation_response_model.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();

  factory TranslationService() {
    return _instance;
  }

  TranslationService._internal();

  // Variable to store translation data
  TranslationModel? translationModel;

  // Method to update data
  void updateTranslation(TranslationModel model) {
    translationModel = model;
  }

  String? getTranslation(String key) {
  return translationModel?.data?[key] ?? key; // Fallback to key itself
}

}
 */

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();

  factory TranslationService() => _instance;

  TranslationService._internal();

  final Map<String, String> _translationsCache = {};

  // Load translations from persistent storage
  Future<void> loadTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTranslations = prefs.getString('translations');
    if (storedTranslations != null) {
      _translationsCache.addAll(Map<String, String>.from(
          jsonDecode(storedTranslations) as Map<String, dynamic>));
    }
  }

  // Update translations in memory and persistent storage
  Future<void> updateTranslations(Map<String, dynamic> newTranslations) async {
    final prefs = await SharedPreferences.getInstance();

    // Update in-memory cache
    newTranslations.forEach((key, value) {
      _translationsCache[key] = value.toString();
    });

    // Update persistent storage
    await prefs.setString('translations', jsonEncode(_translationsCache));
  }

  // Get a translation from the cache
  String getTranslation(String key) {
    return _translationsCache[key] ?? key; // Fallback to the key itself
  }
}

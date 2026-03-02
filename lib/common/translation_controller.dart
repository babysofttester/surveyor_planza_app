import 'package:get/get.dart';

class TranslationController extends GetxController {
  var translationData = <String, String>{}.obs;

  // Method to update translations by converting dynamic map to String map
  void updateTranslations(Map<String, dynamic> newTranslations) {
    // Convert the dynamic map to a Map<String, String>
    Map<String, String> updatedMap = {};

    newTranslations.forEach((key, value) {
      if (value != null) {
        updatedMap[key] = value.toString(); // Ensure the value is a String
      }
    });

    // Update the observable translation data
    translationData.value = updatedMap;
  }

  // Optional: You can create a getter to access translation
  String getTranslation(String key) {
    // ignore: invalid_use_of_protected_member
    return translationData.value[key] ?? key; // Fallback to key if not found
  }
}

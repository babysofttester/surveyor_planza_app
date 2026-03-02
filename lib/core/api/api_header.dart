
import '../storage/token_services.dart';

class ApiHeaders {
  static Future<Map<String, String>> authHeaders() async {
    final token = await TokenService.getToken();
    return {
      "Accept": "application/json",
      if (token != null) "authtoken": token, // ✅ YOUR REQUIREMENT
    };
  }
}



import 'package:http/http.dart' as http;

class ApiService {
  static Future<http.MultipartRequest> multipartPost(
      String url) async {
    return http.MultipartRequest('POST', Uri.parse(url));
  }
}

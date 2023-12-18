import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = 'http://192.168.4.1';

  static Future<bool> fetchLedState() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ledState'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body.toLowerCase() == 'true';
      } else {
        print('Failed to fetch LED state - Response: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error fetching LED state: $error');
      return false;
    }
  }

  static Future<void> setColor(String red, String green, String blue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/setColor'),
      body: {'red': red, 'green': green, 'blue': blue},
    );

    if (response.statusCode != 200) {
      print('Failed to set color');
    }
  }

  static Future<void> toggleLed(bool isLedOn) async {
    final response = await http.post(
      Uri.parse('$baseUrl/toggleLed'),
      body: {'isLedOn': isLedOn.toString()},
    );

    if (response.statusCode != 200) {
      print('Failed to toggle LED state');
    }
  }
}

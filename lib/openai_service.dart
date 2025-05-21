import 'package:http/http.dart' as http;
import 'dart:convert';

const String togetherAPIKey =
    'e576f1c97eed10e64366bc36712378fdcefb57587a70ed5dd622fdfa5e53ef9f';

class OpenAIService {
  final Uri url = Uri.parse('https://api.together.xyz/v1/chat/completions');

  Future<String> isArtPromptAPI(String prompt) async {
    final String question =
        "Does this message want to generate an AI picture, image, art, or anything similar? \"$prompt\". Simply answer with yes or no.";

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $togetherAPIKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "Qwen/Qwen2.5-72B-Instruct-Turbo",
          "messages": [
            {"role": "user", "content": question}
          ],
          "context_length_exceeded_behavior": "error",
        }),
      );

      print('Raw response: ${response.body}'); // 🔍 Debug print

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final message = jsonResponse['choices'][0]['message']['content'];
        return message.trim();
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}

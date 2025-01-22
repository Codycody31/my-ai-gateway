import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:my_ai_gateway/models/message.dart';
import "package:my_ai_gateway/models/model.dart";
import 'package:my_ai_gateway/models/chat_completion.dart';

class ApiService {
  final String apiUrl;
  final String? authToken;

  ApiService({required this.apiUrl, this.authToken});

  // Fetch models and parse into a list of Model objects
  Future<List<Model>> fetchModels() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/v1/models'), headers: {
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = data['data'] as List<dynamic>;
        return models.map((modelJson) => Model.fromJson(modelJson)).toList();
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching models: $e');
    }
  }

  // Fetch completions and parse into a ChatCompletion object
  Future<ChatCompletion> fetchCompletions(
      String model, List<Message> messages) async {
    try {
      final response = await http.post(Uri.parse('$apiUrl/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages
                .map((message) => message.standardMessageFormat())
                .toList(),
            'temperature': 0.7,
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ChatCompletion.fromJson(data);
      } else {
        throw Exception('Failed to fetch completions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Stream<String> fetchStreamedTokens(String model, List<Message> messages) async* {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$apiUrl/v1/chat/completions'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      });
      request.body = jsonEncode({
        'model': model,
        'messages': messages
            .map((message) => message.standardMessageFormat())
            .toList(),
        'temperature': 0.7,
        'stream': true, // Enable streaming
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        // Process the stream
        await for (var chunk in response.stream.transform(utf8.decoder)) {
          final lines = chunk.split('\n');
          for (var line in lines) {
            if (line.trim().isEmpty || !line.startsWith('data:')) {
              continue; // Skip empty lines or lines without the "data:" prefix
            }

            final jsonString = line.substring(5).trim(); // Remove the "data:" prefix
            if (jsonString == '[DONE]') {
              return; // End of the stream
            }

            try {
              final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
              if (jsonData.containsKey('choices') &&
                  jsonData['choices'] is List) {
                final content = jsonData['choices'][0]['delta']['content'];
                if (content != null) {
                  yield content;
                }
              }
            } catch (e) {
              debugPrint('Error parsing streamed data: $e');
            }
          }
        }
      } else {
        throw Exception(
            'Failed to fetch streamed tokens: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching streamed tokens: $e');
    }
  }

}

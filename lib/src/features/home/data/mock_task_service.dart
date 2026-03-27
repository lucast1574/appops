import 'dart:convert';
import 'package:flutter/services.dart';

class MockTaskService {
  static Future<List<Map<String, String>>> loadTasks() async {
    try {
      final String response = await rootBundle.loadString('assets/task_data.json');
      final List<dynamic> data = json.decode(response);
      return data.map((task) => Map<String, String>.from(task)).toList();
    } catch (e) {
      // Return empty list or log error if needed
      return [];
    }
  }
}

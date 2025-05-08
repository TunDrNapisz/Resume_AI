import 'package:http/http.dart' as http;
import 'dart:convert';

class SendMessageToAPI {
  static const String _apiUrl = "http://127.0.0.1:5005/api/chat";

  static Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "messages": [
            {"role": "user", "content": message}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('error')) {
          return {"error": data['error']};
        }

        List<dynamic> jobs = data["jobs"] ?? [];
        List<Map<String, String>> jobsWithStatus = [];

        for (var job in jobs) {
          String status = job["status"] == "active" ? "Active" : "Inactive";
          jobsWithStatus.add({
            "job_name": job["job_name"] ?? "Unknown Job",
            "status": status,
          });
        }

        return {
          "message": data["message"] ?? "No response message.",
          "intent": data["intent"] ?? "unknown",
          "jobs": jobsWithStatus,
        };
      } else {
        return {"error": "API Error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Connection failed: $e"};
    }
  }

  static addJob() {}

  static updateJob() {}

  static deleteJob() {}
}

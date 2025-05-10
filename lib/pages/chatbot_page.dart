import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sendMessageToAPI.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": message});
      _isLoading = true;
    });
    _controller.clear();

    var response = await SendMessageToAPI.sendMessage(message);

    setState(() {
      _isLoading = false;
    });

    if (response.containsKey('error')) {
      setState(() {
        _messages.add({"role": "bot", "content": "Error: ${response['error']}"}); 
      });
      return;
    }

    String intent = response["intent"] ?? "";
    Map<String, dynamic> jobData = response["job_data"] ?? {};
    String jobId = response["job_id"] ?? "";

    setState(() {
      _messages.add({"role": "bot", "content": response["message"] ?? ""});
    });

    switch (intent) {
      case "add_job":
        await _createJob(jobData);
        break;
      case "update":
        if (jobId.isEmpty) {
          Fluttertoast.showToast(msg: "Missing job ID to update.");
          break;
        }
        await updateJob(jobId, jobData);
        Fluttertoast.showToast(msg: "✅ Job updated.");
        break;
      case "view":
        if (jobId.isEmpty) {
          Fluttertoast.showToast(msg: "Missing job ID to view.");
          break;
        }
        await viewJob(jobId);
        break;
      case "delete":
        if (jobId.isEmpty) {
          Fluttertoast.showToast(msg: "Missing job ID to delete.");
          break;
        }
        await deleteJob(jobId);
        Fluttertoast.showToast(msg: "🗑️ Job deleted.");
        break;
      default:
        Fluttertoast.showToast(msg: "Unrecognized intent: $intent");
    }
  }

  Future<void> _createJob(Map<String, dynamic> jobData) async {
    try {
      if (jobData['job_title'] == null || jobData['location'] == null || jobData['job_type'] == null) {
        Fluttertoast.showToast(msg: "Missing required job fields.");
        return;
      }

      String jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> mappedData = {
        "job_id": jobId,
        "job_name": jobData['job_title'] ?? 'No Title',
        "job_title": jobData['job_title'] ?? 'No Title',
        "location": jobData['location'] ?? 'Unknown',
        "job_type": jobData['job_type'] ?? 'N/A',
        "majorRequirement": jobData['majorRequirement'] ?? 'N/A',
        "languages": jobData['languagesPreference'] ?? [],
        "skills_used": jobData['skillsPreference'] ?? [],
        "job_description": jobData['job_description'] ?? 'No Description',
        "Description": jobData['Description'] ?? '-',
        "isActive": jobData['active'] != null
            ? (jobData['active'].toString().toLowerCase() == "active" ||
                jobData['active'].toString().toLowerCase() == "open" ||
                jobData['active'].toString().toLowerCase() == "ongoing")
            : true,
        "created_at": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('Job').doc(jobId).set(mappedData);

      Fluttertoast.showToast(msg: "Job created & stored successfully.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to create job: $e");
      print("Failed to create job: $e");
    }
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> jobData) async {
    try {
      await FirebaseFirestore.instance.collection('Job').doc(jobId).update(jobData);
      setState(() {
        _messages.add({"role": "bot", "content": "✏️ Job $jobId updated."});
      });
    } catch (e) {
      print("Failed to update job: $e");
    }
  }

  Future<void> viewJob(String jobId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('Job').doc(jobId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String result = """
👀 Job ID: $jobId
🧑‍💻 Title: ${data['job_title']}
📍 Location: ${data['location']}
🛠️ Skills: ${(data['skills_used'] as List).join(', ')}
📅 Created: ${data['created_at'].toDate()}
✅ Status: ${data['isActive'] ? "Active" : "Inactive"}
""";
        setState(() {
          _messages.add({"role": "bot", "content": result});
        });
      } else {
        setState(() {
          _messages.add({"role": "bot", "content": "Job not found."});
        });
      }
    } catch (e) {
      print("Failed to view job: $e");
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await FirebaseFirestore.instance.collection('Job').doc(jobId).delete();
      setState(() {
        _messages.add({"role": "bot", "content": "🗑️ Job $jobId deleted successfully."});
      });
    } catch (e) {
      print("Failed to delete job: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildChatBubble(Map<String, String> message) {
    final isUser = message["role"] == "user";
    final icon = isUser ? LucideIcons.user : LucideIcons.bot;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: isUser ? Colors.white : Colors.teal),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message["content"] ?? '',
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    return _buildChatBubble(message);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask Anything',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.teal),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'sendMessageToAPI.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Import Lucide Icons

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Function to send user message to the API
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
      _messages.add({
        "role": "bot",
        "content": response['message'] ?? 'No response from bot.',
      });

      // Display job status if available
      if (response.containsKey('jobStatus')) {
        _messages.add({
          "role": "bot",
          "content": "Job Status: ${response['jobStatus'] == true ? 'Active' : 'Inactive'}",
        });
      }

      _isLoading = false;
    });
  }

  // Function to add a new job
  void _addJob() async {
    setState(() => _isLoading = true);
    var response = await SendMessageToAPI.addJob();
    setState(() {
      _messages.add({
        "role": "bot",
        "content": response['message'] ?? 'Failed to add job',
      });
      _isLoading = false;
    });
  }

  // Function to update an existing job
  void _updateJob() async {
    setState(() => _isLoading = true);
    var response = await SendMessageToAPI.updateJob();
    setState(() {
      _messages.add({
        "role": "bot",
        "content": response['message'] ?? 'Failed to update job',
      });
      _isLoading = false;
    });
  }

  // Function to delete a job
  void _deleteJob() async {
    setState(() => _isLoading = true);
    var response = await SendMessageToAPI.deleteJob();
    setState(() {
      _messages.add({
        "role": "bot",
        "content": response['message'] ?? 'Failed to delete job',
      });
      _isLoading = false;
    });
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    final Uri url = Uri.parse(link.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch ${link.url}");
    }
  }

  // Function to display the message bubble with icons
  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message["role"] == "user";
    IconData icon;
    Color iconColor;

    if (message["role"] == "user") {
      icon = LucideIcons.user; // User icon
      iconColor = Colors.blue;
    } else {
      icon = LucideIcons.briefcase; // Bot icon (Example)
      iconColor = Colors.teal;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 8),
            Expanded(
              child: isUser
                  ? Text(
                      message["content"] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : Linkify(
                      onOpen: _onOpenLink,
                      text: message["content"] ?? '',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                      linkStyle: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      options: LinkifyOptions(looseUrl: true),
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
        title: Text('AI Chatbot'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addJob,
                      icon: Icon(Icons.add),
                      label: Text('Add Job'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: _updateJob,
                      icon: Icon(Icons.edit),
                      label: Text('Update Job'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                    ElevatedButton.icon(
                      onPressed: _deleteJob,
                      icon: Icon(Icons.delete),
                      label: Text('Delete Job'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
 
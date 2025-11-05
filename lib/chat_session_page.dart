import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatSessionPage extends StatefulWidget {
  final String sessionTitle;
  final String sessionId;

  const ChatSessionPage({
    Key? key,
    required this.sessionTitle,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends State<ChatSessionPage> {
  // Use a base URL for your API, set via --dart-define
  static const String _baseUrl = String.fromEnvironment(
    'API_URL_BASE',
    defaultValue:
        'http://10.0.2.2:8000', // 10.0.2.2 is Android emulator's localhost
  );
  static const String _chatUrl = '$_baseUrl/chat';

  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser aiUser = ChatUser(id: '1', firstName: 'AI');

  // --- (NEW) Trigger summary when the user leaves the page ---
  @override
  void dispose() {
    // This function will run in the background
    _summarizeAndEndSession();
    super.dispose();
  }

  /// (NEW) Calls the backend to generate and save the AI summary
  /// This is "fire-and-forget" - we don't wait for the response.
  Future<void> _summarizeAndEndSession() async {
    print("Triggering session summary for ${widget.sessionId}...");

    // Build the correct URL for the summarize endpoint
    final summarizeUrl = Uri.parse(
      '$_baseUrl/api/sessions/${widget.sessionId}/summarize',
    );

    try {
      // We don't 'await' the response, as we don't want to block
      // the user from leaving the page.
      http
          .post(summarizeUrl, headers: {'Content-Type': 'application/json'})
          .then((resp) {
            if (resp.statusCode == 200) {
              print("Session summarized successfully.");
            } else {
              print(
                "Failed to summarize session. Status: ${resp.statusCode}, Body: ${resp.body}",
              );
            }
          })
          .catchError((e) {
            print("Error triggering summary: $e");
          });
    } catch (e) {
      print("Error in _summarizeAndEndSession: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- (NEW) Added AppBar ---
      appBar: AppBar(
        title: Text(widget.sessionTitle),
        // This makes the back button call dispose() automatically
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) async {
    // Add the user message to UI
    setState(() {
      messages = [chatMessage, ...messages];
    });

    // Add a temporary "Thinking..." message
    final loadingMsg = ChatMessage(
      user: aiUser,
      createdAt: DateTime.now(),
      text: "Thinking...",
    );
    setState(() {
      messages = [loadingMsg, ...messages];
    });

    try {
      // Use the updated _chatUrl variable
      final uri = Uri.parse(_chatUrl);
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': chatMessage.text,
          'session_id': widget.sessionId, // Pass the session ID
        }),
      );

      // Remove the "Thinking..." message
      messages.removeWhere((m) => m == loadingMsg);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final reply = data['reply'] ?? "No response from server.";

        final aiMessage = ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text: reply,
        );
        setState(() {
          messages = [aiMessage, ...messages];
        });
      } else {
        // Replace with an error message
        final errMsg = ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text: "Error: server returned ${resp.statusCode}",
        );
        setState(() {
          messages = [errMsg, ...messages];
        });
        print("Server error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      // Remove loading message on network error
      messages.removeWhere((m) => m == loadingMsg);
      final errMsg = ChatMessage(
        user: aiUser,
        createdAt: DateTime.now(),
        text: "Network error: $e",
      );
      setState(() {
        messages = [errMsg, ...messages];
      });
      print("Network error when calling backend: $e");
    }
  }
}

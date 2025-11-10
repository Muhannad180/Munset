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
  // Reads API URL from compile-time environment or falls back to local addresses.
  // Use --dart-define=API_URL="https://prod.example.com/chat" in production.
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://munset-backend.onrender.com/chat',
  );

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser aiUser = ChatUser(id: '1', firstName: 'AI');

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI());
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
      final uri = Uri.parse(_apiUrl);
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': chatMessage.text,
          'session_id': widget.sessionId,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final reply = data['reply'] ?? "No response from server.";

        // Replace the "Thinking..." message with the final reply
        setState(() {
          // Remove first occurrence of loadingMsg if present
          messages.removeWhere((m) => m == loadingMsg);
          final aiMessage = ChatMessage(
            user: aiUser,
            createdAt: DateTime.now(),
            text: reply,
          );
          messages = [aiMessage, ...messages];
        });
      } else {
        // Replace loading with error message
        setState(() {
          messages.removeWhere((m) => m == loadingMsg);
          final errMsg = ChatMessage(
            user: aiUser,
            createdAt: DateTime.now(),
            text: "Error: server returned ${resp.statusCode}",
          );
          messages = [errMsg, ...messages];
        });
        print("Server error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      setState(() {
        messages.removeWhere((m) => m == loadingMsg);
        final errMsg = ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text: "Network error: $e",
        );
        messages = [errMsg, ...messages];
      });
      print("Network error when calling backend: $e");
    }
  }
}

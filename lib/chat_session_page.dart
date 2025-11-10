import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // Reads API URL from compile-time environment if provided via --dart-define.
  // If not provided, pick a sensible default per platform:
  // - Web: use http://localhost:8000/chat (browser can reach local host)
  // - Mobile emulator: use 10.0.2.2 (Android emulator loopback)
  // - Desktop: use localhost
  // You can still override at build/run time with --dart-define=API_URL=<url>
  String? _apiUrl;

  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser aiUser = ChatUser(id: '1', firstName: 'AI');

  @override
  Widget build(BuildContext context) {
    // Ensure API URL is initialized once (uses compile-time dart-define if present)
    if (_apiUrl == null) {
      final env = const String.fromEnvironment('API_URL');
      if (env.isNotEmpty) {
        _apiUrl = env;
      } else {
        // Choose default based on platform
        if (kIsWeb) {
          _apiUrl = 'http://localhost:8000/chat';
        } else {
          // For desktop use localhost, for mobile emulator use Android loopback
          // We assume common developer setup: Android emulator uses 10.0.2.2
          _apiUrl = 'http://10.0.2.2:8000/chat';
        }
      }
    }
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

  Future<void> _sendMessage(ChatMessage chatMessage) async {
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
  final uri = Uri.parse(_apiUrl!);
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': chatMessage.text, 'session_id': widget.sessionId}),
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

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';


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
  int? _sessionId; // <-- store active session ID

  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://munset-backend.onrender.com/chat',
  );
  
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

  // Add temporary AI "Thinking..." message
  final loadingMsg = ChatMessage(
    user: aiUser,
    createdAt: DateTime.now(),
    text: "Thinking...",
  );
  setState(() {
    messages = [loadingMsg, ...messages];
  });

  // Get Supabase user ID (or fallback)
  String userId = "2f54534a-4fb0-493e-a514-c1ac08071f4d"; // fallback UUID TODO: delete and try to fetch from database
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      userId = user.id;
    }
  } catch (e) {
    debugPrint("Supabase auth fetch failed: $e");
  }

  try {
    final uri = Uri.parse(_apiUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        // send stored session id if available, else widget.sessionId, else null
        'session_id': _sessionId?.toString() ??
            (widget.sessionId.isEmpty ? null : int.tryParse(widget.sessionId)),
        'message': chatMessage.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['reply'] ?? "No response from server.";

      // 🔥 If this is the first message, capture the session ID from backend
      if (_sessionId == null && data['session_id'] != null) {
        final sid = data['session_id'];
        _sessionId = sid is int ? sid : int.tryParse(sid.toString());
        debugPrint("🔹 Assigned new session ID: $_sessionId");
      }

      setState(() {
        // Remove "Thinking..." and add real reply
        messages.removeWhere((m) => m == loadingMsg);
        final aiMessage = ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text: reply,
        );
        messages = [aiMessage, ...messages];
      });
    } else {
      setState(() {
        messages.removeWhere((m) => m == loadingMsg);
        final errMsg = ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text:
              "Error: server returned ${response.statusCode}\n${response.body}",
        );
        messages = [errMsg, ...messages];
      });
      debugPrint("Server error: ${response.statusCode} - ${response.body}");
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
    debugPrint("Network error when calling backend: $e");
  }
}

}
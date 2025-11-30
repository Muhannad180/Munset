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
  // store active session ID
  int? _sessionId;

  // Reads API URL from compile-time environment or falls back to Render backend.
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://munset-backend.onrender.com/chat',
  );

  static const String _defaultGreeting =
      "Hi — I'm here to help. How are you feeling today?";
  static const String _thinkingText = "Thinking...";

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser aiUser = ChatUser(id: '1', firstName: 'AI');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  /// Helper to get Supabase user ID or fallback.
  String _getUserId() {
    String userId =
        "2f54534a-4fb0-493e-a514-c1ac08071f4d"; // fallback UUID TODO: delete and try to fetch from database
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        userId = user.id;
      }
    } catch (e) {
      debugPrint("Supabase auth fetch failed: $e");
    }
    return userId;
  }

  /// Helper to create a "Thinking..." message from the AI.
  ChatMessage _buildThinkingMessage() {
    return ChatMessage(
      user: aiUser,
      createdAt: DateTime.now(),
      text: _thinkingText,
    );
  }

  /// Helper to remove a specific loading message and prepend an AI reply.
  void _replaceThinkingWithAi(ChatMessage loadingMsg, String text) {
    setState(() {
      messages.remove(loadingMsg);
      messages = [
        ChatMessage(
          user: aiUser,
          createdAt: DateTime.now(),
          text: text,
        ),
        ...messages,
      ];
    });
  }

  Future<void> _initSession() async {
    // Show a temporary AI "Thinking..." message while we initialize.
    final loadingMsg = _buildThinkingMessage();
    setState(() {
      messages = [loadingMsg, ...messages];
    });

    final userId = _getUserId();

    try {
      final startUri =
          Uri.parse(_apiUrl.replaceFirst('/chat', '/start-session'));
      final resp = await http
          .post(
            startUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final opening = data['opening_message'] ??
            data['openingMessage'] ??
            '';
        final sid = data['session_id'] ?? data['sessionId'];
        if (_sessionId == null && sid != null) {
          _sessionId = sid is int ? sid : int.tryParse(sid.toString());
          debugPrint("🔹 Assigned new session ID: $_sessionId");
        }

        final text = opening.isNotEmpty ? opening : _defaultGreeting;
        _replaceThinkingWithAi(loadingMsg, text);
      } else {
        _replaceThinkingWithAi(loadingMsg, _defaultGreeting);
        debugPrint('Start-session error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      _replaceThinkingWithAi(loadingMsg, _defaultGreeting);
      debugPrint('Network/start-session error: $e');
    }
  }

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

    // Add temporary AI "Thinking..." message
    final loadingMsg = _buildThinkingMessage();
    setState(() {
      messages = [loadingMsg, ...messages];
    });

    final userId = _getUserId();

    try {
      final uri = Uri.parse(_apiUrl);

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              // send stored session id if available, else widget.sessionId, else null
              'session_id': _sessionId?.toString() ??
                  (widget.sessionId.isEmpty
                      ? null
                      : int.tryParse(widget.sessionId)),
              'message': chatMessage.text,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? "No response from server.";

        // If this is the first message, capture the session ID from backend
        if (_sessionId == null && data['session_id'] != null) {
          final sid = data['session_id'];
          _sessionId = sid is int ? sid : int.tryParse(sid.toString());
          debugPrint("🔹 Assigned new session ID: $_sessionId");
        }

        _replaceThinkingWithAi(loadingMsg, reply);
      } else {
        final errorText =
            "Error: server returned ${response.statusCode}\n${response.body}";
        _replaceThinkingWithAi(loadingMsg, errorText);
        debugPrint("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      final errorText = "Network error: $e";
      _replaceThinkingWithAi(loadingMsg, errorText);
      debugPrint("Network error when calling backend: $e");
    }
  }
}

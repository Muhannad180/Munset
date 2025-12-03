import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatSessionPage extends StatefulWidget {
  final String sessionTitle;
  final String sessionId;
  final int sessionNumber;

  const ChatSessionPage({
    Key? key,
    required this.sessionTitle,
    required this.sessionId,
    required this.sessionNumber,
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
      "أهلاً! كيف يمكنني مساعدتك اليوم؟";
  static const String _thinkingText = "يكتب";

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser aiUser = ChatUser(id: '1', firstName: 'AI');

  // For "Thinking..." animation and disabling input
  bool _isAwaitingResponse = false;
  Timer? _thinkingTimer;
  ChatMessage? _thinkingMessage;
  int _thinkingDotCount = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    super.dispose();
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

  /// Start the animated "Thinking..." message and disable input.
  void _startThinking() {
    // Only one thinking message at a time
    _thinkingTimer?.cancel();
    _thinkingMessage = null;
    _thinkingDotCount = 1;
    _isAwaitingResponse = true;

    final msg = ChatMessage(
      user: aiUser,
      createdAt: DateTime.now(),
      text: '$_thinkingText.',
    );
    _thinkingMessage = msg;

    setState(() {
      messages = [msg, ...messages];
    });

    _thinkingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || _thinkingMessage == null) return;

      setState(() {
        _thinkingDotCount = (_thinkingDotCount % 3) + 1; // 1 → 2 → 3 → 1
        final index = messages.indexOf(_thinkingMessage!);
        if (index == -1) return;

        final updated = ChatMessage(
          user: aiUser,
          createdAt: _thinkingMessage!.createdAt,
          text: '${'.' * _thinkingDotCount}$_thinkingText',
        );
        messages[index] = updated;
        _thinkingMessage = updated;
      });
    });
  }

  /// Stop the animation, show AI reply, and re-enable input.
  void _stopThinkingAndShowAi(String text) {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
    _isAwaitingResponse = false;

    setState(() {
      if (_thinkingMessage != null) {
        messages.remove(_thinkingMessage);
      }
      final aiMessage = ChatMessage(
        user: aiUser,
        createdAt: DateTime.now(),
        text: text,
      );
      messages = [aiMessage, ...messages];
      _thinkingMessage = null;
    });
  }

  Future<void> _initSession() async {
    // Show animated "Thinking..." while session initializes.
    _startThinking();

    final userId = _getUserId();

    try {
      final startUri =
          Uri.parse(_apiUrl.replaceFirst('/chat', '/start-session'));
      final resp = await http
          .post(
            startUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'user_id': userId, 'session_number': widget.sessionNumber}),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final opening =
            data['opening_message'] ?? data['openingMessage'] ?? '';
        final sid = data['session_id'] ?? data['sessionId'];
        if (_sessionId == null && sid != null) {
          _sessionId = sid is int ? sid : int.tryParse(sid.toString());
          debugPrint("🔹 Assigned new session ID: $_sessionId");
        }

        final text = opening.isNotEmpty ? opening : _defaultGreeting;
        _stopThinkingAndShowAi(text);
      } else {
        _stopThinkingAndShowAi(_defaultGreeting);
        debugPrint('Start-session error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      _stopThinkingAndShowAi(_defaultGreeting);
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
      inputOptions: InputOptions(
        inputDisabled: _isAwaitingResponse,
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) async {
    // Add the user message to UI
    setState(() {
      messages = [chatMessage, ...messages];
    });

    // Start "Thinking..." animation and disable input
    _startThinking();

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

        _stopThinkingAndShowAi(reply);
      } else {
        final errorText =
            "Error: server returned ${response.statusCode}\n${response.body}";
        _stopThinkingAndShowAi(errorText);
        debugPrint("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      final errorText = "Network error: $e";
      _stopThinkingAndShowAi(errorText);
      debugPrint("Network error when calling backend: $e");
    }
  }
}

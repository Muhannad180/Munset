import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/core/theme/app_style.dart';

class ChatSessionPage extends StatefulWidget {
  final String sessionTitle;
  final String sessionId;
  // أزلنا sessionNumber إذا لم يكن مستخدماً في الباك إند حالياً أو جعله اختيارياً
  final int? sessionNumber;
  final bool isCompleted;

  const ChatSessionPage({
    Key? key,
    required this.sessionTitle,
    required this.sessionId,
    this.sessionNumber,
    this.isCompleted = false,
  }) : super(key: key);

  @override
  State<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends State<ChatSessionPage> {
  dynamic _sessionId;

  // ألوان الثيم
  final Color primaryColor = const Color(0xFF5E9E92);
  final Color bgColor = const Color(0xFFF8F9FA);

  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://munset-backend.onrender.com/chat', // Render
    // defaultValue: 'http://127.0.0.1:10000/chat', // Localhost
  );

  static const String _thinkingText = "يكتب";

  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: '0', firstName: 'أنا');
  ChatUser aiUser = ChatUser(
    id: '1',
    firstName: 'منصت',
    profileImage: "assets/images/ai_avatar.png",
  ); // يمكنك وضع صورة للأفاتار هنا

  bool _isAwaitingResponse = false;
  bool _isSessionEnded = false;
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

  String _getUserId() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) return user.id.trim();
    } catch (e) {
      debugPrint("Supabase auth fetch failed: $e");
    }
    // If no user is logged in, return empty or handle explicitly.
    // Returning a hardcoded ID causes DB crashes if that ID doesn't exist in Auth.
    return "";
  }

  void _startThinking() {
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
        _thinkingDotCount = (_thinkingDotCount % 3) + 1;
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

  void _stopThinkingAndShowAi(String text) {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
    _isAwaitingResponse = false;
    setState(() {
      if (_thinkingMessage != null) messages.remove(_thinkingMessage);
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
    _startThinking();
    final userId = _getUserId();
    if (userId.isEmpty) {
      _stopThinkingAndShowAi("يرجى تسجيل الدخول أولاً للبدء في المحادثة.");
      return;
    }

    try {
      final startUri = Uri.parse(
        _apiUrl.replaceFirst('/chat', '/start-session'),
      );
      final sNum = widget.sessionNumber ?? 1;

      final body = {'user_id': userId, 'session_number': sNum};

      final resp = await http
          .post(
            startUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final opening = data['opening_message'] ?? data['openingMessage'] ?? '';
        final sid = data['session_id'] ?? data['sessionId'];

        if (sid != null) {
          _sessionId = sid.toString();
        }

        // Fetch History
        await _loadHistory(_sessionId.toString());

        // If no messages loaded (new session), show opening
        if (messages.isEmpty && opening.isNotEmpty) {
          _stopThinkingAndShowAi(opening);
        } else {
          // If messages loaded, just stop thinking indicator
          _thinkingTimer?.cancel();
          _thinkingTimer = null;
          _isAwaitingResponse = false;
          if (mounted)
            setState(() {
              _thinkingMessage = null;
            });
        }
      } else {
        _stopThinkingAndShowAi("Error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      _stopThinkingAndShowAi("Connection error: $e");
    }
  }

  Future<void> _loadHistory(String sessionId) async {
    try {
      // If session is NOT completed (Active), filter by last 24 hours
      // If session IS completed, fetch all history
      String url = _apiUrl.replaceFirst(
        '/chat',
        '/session-history?session_id=$sessionId',
      );
      if (!widget.isCompleted) {
        url += '&hours=24';
      }

      final historyUri = Uri.parse(url);
      final resp = await http.get(historyUri);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final history = data['history'] as List<dynamic>;

        final List<ChatMessage> loaded = [];

        for (var item in history) {
          final content = item['message'] != null
              ? item['message']['content']
              : '';
          if (content == null || content.isEmpty) continue;

          final sender = item['sender'];
          final isUser = sender == 'user';

          loaded.add(
            ChatMessage(
              user: isUser ? currentUser : aiUser,
              text: content,
              createdAt: DateTime.parse(
                item['created_at'] ?? DateTime.now().toIso8601String(),
              ),
            ),
          );
        }

        if (mounted) {
          setState(() {
            messages = loaded.reversed.toList();
          });
        }
      }
    } catch (e) {
      debugPrint("History load error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = AppStyle.isDark(context);
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        appBar: AppBar(
          backgroundColor: AppStyle.bgTop(context),
          title: Text(
            widget.sessionTitle,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppStyle.textMain(context),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppStyle.textMain(context)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppStyle.mainGradient(context)),
          child: Column(
            children: [
              if (widget.isCompleted)
                Container(
                  width: double.infinity,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "هذه الجلسة منتهية (للقراءة فقط)",
                    style: GoogleFonts.cairo(
                      color: AppStyle.textSmall(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: DashChat(
                  currentUser: currentUser,
                  onSend: _sendMessage,
                  messages: messages,
                  readOnly: widget.isCompleted,
                  inputOptions: InputOptions(
                    inputDisabled:
                        _isAwaitingResponse ||
                        widget.isCompleted ||
                        _isSessionEnded,
                    inputTextStyle: GoogleFonts.cairo(
                      color: AppStyle.textMain(context),
                    ),
                    inputDecoration: InputDecoration(
                      hintText: widget.isCompleted
                          ? "الجلسة مغلقة"
                          : "اكتب رسالتك هنا...",
                      hintStyle: GoogleFonts.cairo(
                        color: AppStyle.textSmall(context),
                      ),
                      filled: true,
                      fillColor: AppStyle.cardBg(context),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    sendButtonBuilder: (onSend) {
                      if (widget.isCompleted) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppStyle.primary,
                          size: 30,
                        ),
                        onPressed: onSend,
                      );
                    },
                  ),
                  messageOptions: MessageOptions(
                    showOtherUsersAvatar: true,
                    showCurrentUserAvatar: false,
                    avatarBuilder: (user, onPress, onLongPress) {
                      if (user.id == aiUser.id) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppStyle.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    currentUserContainerColor: AppStyle.primary,
                    currentUserTextColor: Colors.white,
                    containerColor: AppStyle.cardBg(context),
                    textColor: AppStyle.textMain(context),
                    messageTextBuilder:
                        (message, previousMessage, nextMessage) {
                          return Text(
                            message.text,
                            style: GoogleFonts.cairo(
                              color: message.user.id == currentUser.id
                                  ? Colors.white
                                  : AppStyle.textMain(context),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          );
                        },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    _startThinking();
    final userId = _getUserId();
    if (userId.isEmpty) {
      _stopThinkingAndShowAi("يرجى تسجيل الدخول للمتابعة.");
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'session_id':
                  _sessionId ??
                  (widget.sessionId.isEmpty ? null : widget.sessionId),
              'message': chatMessage.text,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? "لا يوجد رد.";
        final nextPhase = data['next_phase'];
        if (nextPhase == 'END') {
          setState(() {
            _isSessionEnded = true;
          });
        }

        if (_sessionId == null && data['session_id'] != null) {
          _sessionId = data['session_id'];
        }
        _stopThinkingAndShowAi(reply);
      } else {
        _stopThinkingAndShowAi("خطأ في الخادم: ${response.statusCode}");
      }
    } catch (e) {
      _stopThinkingAndShowAi("خطأ في الاتصال.");
    }
  }
}

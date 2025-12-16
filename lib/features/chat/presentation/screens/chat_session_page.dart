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
    // defaultValue: 'https://munset-backend.onrender.com/chat', // Render
    defaultValue: 'https://munset-backend.onrender.com/chat',
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
        if (messages.isEmpty) {
          if (sNum == 1) {
             // Hardcoded welcome for Session 1
             _stopThinkingAndShowAi(
               "مرحباً بك في رحلتك نحو صحة نفسية أفضل! 🌟\n\n"
               "أنا معالجك الافتراضي، وسأكون معك في كل خطوة من هذه الرحلة العلاجية.\n\n"
               "في هذه الجلسة الأولى، سنتعرف على بعضنا البعض وأفهم ما تمر به حالياً. لا تقلق، أنا هنا لمساعدتك.\n\n"
               "هل يمكنك أن تخبرني قليلاً عن نفسك وما الذي جعلك تبحث عن الدعم النفسي؟"
             );
          } else if (opening.isNotEmpty) {
             _stopThinkingAndShowAi(opening);
          } else {
             _thinkingTimer?.cancel();
             _thinkingTimer = null;
             _isAwaitingResponse = false;
             if (mounted) setState(() { _thinkingMessage = null; });
          }
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

          // Parse created_at or use a default
          DateTime createdAt;
          try {
            createdAt = DateTime.parse(
              item['created_at'] ?? DateTime.now().toIso8601String(),
            );
          } catch (_) {
            createdAt = DateTime.now();
          }

          loaded.add(
            ChatMessage(
              user: isUser ? currentUser : aiUser,
              text: content,
              createdAt: createdAt,
            ),
          );
        }

        // Sort by createdAt descending (newest first) for DashChat
        loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // FORCE FIX: If Session 1, replace the *oldest* message (last in list) 
        // if it is from AI, to ensure the correct welcome message is shown.
        if ((widget.sessionNumber ?? 1) == 1 && loaded.isNotEmpty) {
           final lastMsg = loaded.last;
           if (lastMsg.user.id == aiUser.id) {
             loaded.last = ChatMessage(
               user: aiUser,
               createdAt: lastMsg.createdAt,
               text: "مرحباً بك في رحلتك نحو صحة نفسية أفضل! 🌟\n\n"
                     "أنا معالجك الافتراضي، وسأكون معك في كل خطوة من هذه الرحلة العلاجية.\n\n"
                     "في هذه الجلسة الأولى، سنتعرف على بعضنا البعض وأفهم ما تمر به حالياً. لا تقلق، أنا هنا لمساعدتك.\n\n"
                     "هل يمكنك أن تخبرني قليلاً عن نفسك وما الذي جعلك تبحث عن الدعم النفسي؟",
             );
           }
        }

        if (mounted) {
          setState(() {
            // Remove thinking message if it exists
            if (_thinkingMessage != null) {
              messages.remove(_thinkingMessage);
              _thinkingMessage = null;
            }
            messages = loaded;
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

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppStyle.primary.withOpacity(0.95),
                  const Color(0xFF4A8A7E),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppStyle.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  "🎉 أحسنت!",
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  "لقد أكملت هذه الجلسة بنجاح!\nنحن فخورون بتقدمك في رحلة التعافي.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tasks reminder box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "لديك مهام جديدة! توجه إلى صفحة المهام لإكمالها.",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(true); // Go back to sessions list with result
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppStyle.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "العودة للجلسات",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          // Show session complete popup after showing the final AI message
          Future.delayed(const Duration(milliseconds: 500), () {
            _showSessionCompleteDialog();
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

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart'; // تأكد من وجود المكتبة

class ChatSessionPage extends StatefulWidget {
  final String sessionTitle;
  final String sessionId;
  // أزلنا sessionNumber إذا لم يكن مستخدماً في الباك إند حالياً أو جعله اختيارياً
  final int? sessionNumber; 

  const ChatSessionPage({
    Key? key,
    required this.sessionTitle,
    required this.sessionId,
    this.sessionNumber,
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
    defaultValue: 'https://munset-backend.onrender.com/chat',
  );

  static const String _defaultGreeting = "أهلاً! كيف يمكنني مساعدتك اليوم؟";
  static const String _thinkingText = "يكتب";

  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: '0', firstName: 'أنا');
  ChatUser aiUser = ChatUser(id: '1', firstName: 'منصت', profileImage: "assets/images/ai_avatar.png"); // يمكنك وضع صورة للأفاتار هنا

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

  String _getUserId() {
    String userId = "2f54534a-4fb0-493e-a514-c1ac08071f4d"; 
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) userId = user.id;
    } catch (e) {
      debugPrint("Supabase auth fetch failed: $e");
    }
    return userId;
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
    
    // If we already have a numeric ID (passed from previous screen), use it without starting a new session on backend unless necessary
    // But backend /start-session is designed to resume or start based on number.
    
    try {
      final startUri = Uri.parse(_apiUrl.replaceFirst('/chat', '/start-session'));
      
      // Force integers for session_number
      final sNum = widget.sessionNumber ?? 1;
      
      final body = {
        'user_id': userId,
        'session_number': sNum, 
      };

      final resp = await http.post(
        startUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final opening = data['opening_message'] ?? data['openingMessage'] ?? '';
        final sid = data['session_id'] ?? data['sessionId'];
        
        // Parse session ID correctly
        if (sid != null) {
            // It might come as a String UUID or an int, depending on backend changes.
            // The clone backend uses UUIDs (strings) for session_id in the DB schema mostly, but let's check.
            // Actually, the new backend code uses UUIDs (String) for session_id.
            // But _sessionId variable is defined as int? in this file (line 28).
            // We need to change _sessionId to String? or dynamic?
            // For now, let's cast to String then try parse, or just store as is if we change type.
            // Wait, let's fix the type of _sessionId in the State class first.
             _sessionId = sid; 
        }
        
        _stopThinkingAndShowAi(opening.isNotEmpty ? opening : _defaultGreeting);
      } else {
        _stopThinkingAndShowAi("Error: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      _stopThinkingAndShowAi("Connection error: $e");
    }
  }

  // 🚪 دالة الخروج (إنهاء الجلسة)
  void _confirmExitSession() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: Text("إنهاء الجلسة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text("هل تريد حقاً إنهاء هذه الجلسة والخروج؟", style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // هنا يمكن إضافة كود لحفظ التلخيص إذا وجد
                Navigator.pop(ctx); // إغلاق الـ Dialog
                Navigator.pop(context); // الخروج من الصفحة
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("خروج", style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        // 1. إضافة AppBar
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            widget.sessionTitle,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // زر الخروج
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              tooltip: "إنهاء الجلسة",
              onPressed: _confirmExitSession,
            ),
          ],
        ),
        body: DashChat(
          currentUser: currentUser,
          onSend: _sendMessage,
          messages: messages,
          inputOptions: InputOptions(
            inputDisabled: _isAwaitingResponse,
            inputDecoration: InputDecoration(
              hintText: "اكتب رسالتك هنا...",
              hintStyle: GoogleFonts.cairo(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
            sendButtonBuilder: (onSend) {
              return IconButton(
                icon: Icon(Icons.send_rounded, color: primaryColor, size: 30),
                onPressed: onSend,
              );
            },
          ),
          messageOptions: MessageOptions(
            showOtherUsersAvatar: false,
            showCurrentUserAvatar: false,
            // تنسيق رسائل المستخدم (أخضر تركواز)
            currentUserContainerColor: primaryColor,
            currentUserTextColor: Colors.white,
            // تنسيق رسائل الـ AI (أبيض/رمادي)
            containerColor: Colors.white,
            textColor: Colors.black87,
            messageTextBuilder: (message, previousMessage, nextMessage) {
              return Text(
                message.text,
                style: GoogleFonts.cairo(
                  color: message.user.id == currentUser.id ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              );
            },
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

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'session_id': _sessionId ?? (widget.sessionId.isEmpty ? null : widget.sessionId),
          'message': chatMessage.text,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? "لا يوجد رد.";
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
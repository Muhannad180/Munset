import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/features/auth/presentation/screens/signin_screen.dart';
import 'dart:ui' as ui;
import 'package:test1/features/home/presentation/screens/home.dart';
import 'package:test1/core/theme/app_style.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  
  late AnimationController _btnController;
  String currentGender = 'ذكر';
  bool notificationEnabled = true;
  bool isLoading = true;
  String userId = '';
  final Color primaryColor = const Color(0xFF5E9E92);

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) { if(mounted) setState(() => isLoading = false); return; }
    userId = user.id;
    try {
      final response = await supabase.from('users').select().eq('id', user.id).maybeSingle();
      if (mounted && response != null) {
        firstNameController.text = response['first_name'] ?? '';
        lastNameController.text = response['last_name'] ?? '';
        usernameController.text = response['username'] ?? '';
        ageController.text = response['age']?.toString() ?? '';
        emailController.text = user.email ?? '';
        setState(() { currentGender = response['gender'] ?? 'ذكر'; notificationEnabled = response['notifications_enabled'] ?? true; });
      }
    } catch (e) { debugPrint("$e"); } finally { if (mounted) setState(() => isLoading = false); }
  }

  Future<void> _saveProfile() async {
    if (userId.isEmpty) return;
    try {
      setState(() => isLoading = true);
      await supabase.from('users').upsert({
        'id': userId, 'first_name': firstNameController.text.trim(), 'last_name': lastNameController.text.trim(), 'username': usernameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()), 'gender': currentGender, 'notifications_enabled': notificationEnabled,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ'), backgroundColor: Colors.green));
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل الحفظ'), backgroundColor: Colors.red));
    } finally { _loadUserData(); }
  }

  Widget _AnimatedButton({required Widget child, required VoidCallback onPressed}) {
    return GestureDetector(
      onTapDown: (_) => _btnController.forward(),
      onTapUp: (_) { _btnController.reverse(); onPressed(); },
      onTapCancel: () => _btnController.reverse(),
      child: ScaleTransition(scale: Tween<double>(begin: 1.0, end: 0.95).animate(_btnController), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        appBar: AppBar(title: const Text('ملفك الشخصي', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, elevation: 0, centerTitle: true),
        body: isLoading ? Center(child: CircularProgressIndicator(color: primaryColor)) : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
          child: Column(children: [
            CircleAvatar(radius: 50, backgroundColor: primaryColor, child: const Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 30),
            _field(firstNameController, 'الاسم الأول'),
            _field(lastNameController, 'اسم العائلة'),
            _field(usernameController, 'اسم المستخدم'),
            _field(ageController, 'العمر', isNum: true),
            _dropdownGender(),
            _field(emailController, 'البريد الإلكتروني', readOnly: true),
            const SizedBox(height: 30),
            _AnimatedButton(onPressed: _saveProfile, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('حفظ التغييرات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))))),
            const SizedBox(height: 15),
            _AnimatedButton(onPressed: () async { await supabase.auth.signOut(); if(mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false); }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]))),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool isNum = false, bool readOnly = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: TextField(controller: c, style: TextStyle(color: AppStyle.textMain(context)), readOnly: readOnly, keyboardType: isNum ? TextInputType.number : TextInputType.text, textAlign: TextAlign.right, decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: AppStyle.textSmall(context)), filled: true, fillColor: AppStyle.isDark(context) ? Colors.grey[800] : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))));
  }

  Widget _dropdownGender() {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppStyle.isDark(context) ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(dropdownColor: AppStyle.cardBg(context), style: TextStyle(color: AppStyle.textMain(context)), isExpanded: true, value: currentGender, items: ['ذكر', 'أنثى'].map((v) => DropdownMenuItem(value: v, child: Text(v, textAlign: TextAlign.right))).toList(), onChanged: (v) => setState(() => currentGender = v!)))));
  }
}
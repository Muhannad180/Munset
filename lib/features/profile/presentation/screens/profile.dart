import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/features/auth/presentation/screens/signin_screen.dart';
import 'dart:ui' as ui;
import 'package:test1/core/theme/app_style.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final supabase = Supabase.instance.client;
  
  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  
  // State
  String currentGender = 'ذكر';
  bool notificationEnabled = true;
  bool isLoading = true;
  String userId = '';
  
  // Theme Colors (Shortcuts)
  Color get primaryColor => AppStyle.primary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) { 
      if(mounted) setState(() => isLoading = false); 
      return; 
    }
    userId = user.id;
    try {
      final response = await supabase.from('users').select().eq('id', user.id).maybeSingle();
      if (mounted && response != null) {
        firstNameController.text = response['first_name'] ?? '';
        lastNameController.text = response['last_name'] ?? '';
        usernameController.text = response['username'] ?? '';
        ageController.text = response['age']?.toString() ?? '';
        emailController.text = user.email ?? '';
        setState(() { 
          currentGender = response['gender'] ?? 'ذكر'; 
          notificationEnabled = response['notifications_enabled'] ?? true; 
        });
      }
    } catch (e) { 
      debugPrint("Error loading profile: $e"); 
    } finally { 
      if (mounted) setState(() => isLoading = false); 
    }
  }

  Future<void> _saveProfile() async {
    if (userId.isEmpty) return;
    try {
      setState(() => isLoading = true);
      await supabase.from('users').upsert({
        'id': userId, 
        'first_name': firstNameController.text.trim(), 
        'last_name': lastNameController.text.trim(), 
        'username': usernameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()), 
        'gender': currentGender, 
        'notifications_enabled': notificationEnabled,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ التغييرات بنجاح', style: GoogleFonts.cairo()), backgroundColor: Colors.green)
      );
    } catch (e) { 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ', style: GoogleFonts.cairo()), backgroundColor: Colors.red)
      );
    } finally { 
      _loadUserData(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = AppStyle.isDark(context);
    
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        body: isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryColor)) 
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                         _buildSectionTitle("معلوماتي الشخصية"),
                         const SizedBox(height: 10),
                         _buildInfoCard([
                            _buildTextField(firstNameController, "الاسم الأول", Icons.person_outline),
                            _buildDivider(),
                            _buildTextField(lastNameController, "اسم العائلة", Icons.person_outline),
                            _buildDivider(),
                            _buildTextField(ageController, "العمر", Icons.calendar_today, isNum: true),
                            _buildDivider(),
                            _buildGenderDropdown(),
                         ]),
                         
                         const SizedBox(height: 25),
                         _buildSectionTitle("إعدادات الحساب"),
                         const SizedBox(height: 10),
                         _buildInfoCard([
                            _buildTextField(usernameController, "اسم المستخدم", Icons.alternate_email),
                            _buildDivider(),
                            _buildTextField(emailController, "البريد الإلكتروني", Icons.email_outlined, readOnly: true),
                         ]),

                         const SizedBox(height: 40),
                         ScaleButton(
                           onPressed: _saveProfile, 
                           child: Container(
                             padding: const EdgeInsets.symmetric(vertical: 16),
                             decoration: BoxDecoration(
                               gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                               borderRadius: BorderRadius.circular(16),
                               boxShadow: [
                                 BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,5))
                               ]
                             ),
                             child: Center(
                               child: Text('حفظ التغييرات', style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                             ),
                           )
                         ),
                         const SizedBox(height: 16),
                         _buildLogoutButton(),
                         
                         const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
     return Stack(
       clipBehavior: Clip.none,
       alignment: Alignment.center,
       children: [
         Container(
           height: 220,
           decoration: BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
               colors: isDark 
                 ? [const Color(0xFF1F2E2C), AppStyle.bgTop(context)] 
                 : [primaryColor, primaryColor.withOpacity(0.6)],
             ),
             borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
           ),
         ),
         Positioned(
           top: 60,
           child: Text(
             "ملفي الشخصي",
             style: GoogleFonts.cairo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
           ),
         ),
         Positioned(
           bottom: -50,
           child: Stack(
             alignment: Alignment.bottomRight,
             children: [
               Container(
                 padding: const EdgeInsets.all(4),
                 decoration: BoxDecoration(
                   color: AppStyle.bgTop(context), // Match bg to hide circular edge
                   shape: BoxShape.circle,
                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                 ),
                 child: CircleAvatar(
                   radius: 60,
                   backgroundColor: isDark ? const Color(0xFF333333) : Colors.grey[200],
                   child: Icon(Icons.person, size: 70, color: isDark ? Colors.white54 : Colors.grey),
                 ),
               ),
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: primaryColor,
                   shape: BoxShape.circle,
                   border: Border.all(color: AppStyle.bgTop(context), width: 3),
                 ),
                 child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
               ),
             ],
           ),
         ),
       ],
     );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        color: AppStyle.textMain(context).withOpacity(0.8),
        fontSize: 16, 
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    bool isDark = AppStyle.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(children: children),
    );
  }
  
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNum = false, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppStyle.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppStyle.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(label, style: GoogleFonts.cairo(color: AppStyle.textMain(context).withOpacity(0.6), fontSize: 12)),
                 TextField(
                   controller: controller,
                   readOnly: readOnly,
                   keyboardType: isNum ? TextInputType.number : TextInputType.text,
                   style: GoogleFonts.cairo(color: AppStyle.textMain(context), fontWeight: FontWeight.bold),
                   decoration: const InputDecoration(
                     border: InputBorder.none,
                     isDense: true,
                     contentPadding: EdgeInsets.zero,
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppStyle.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wc, color: Color(0xFF5E9E92), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text("الجنس", style: GoogleFonts.cairo(color: AppStyle.textMain(context).withOpacity(0.6), fontSize: 12)),
                 DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                     value: currentGender,
                     isExpanded: true,
                     dropdownColor: AppStyle.cardBg(context),
                     style: GoogleFonts.cairo(color: AppStyle.textMain(context), fontWeight: FontWeight.bold),
                     items: ['ذكر', 'أنثى'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                     onChanged: (v) => setState(() => currentGender = v!),
                     icon: Icon(Icons.keyboard_arrow_down, color: AppStyle.textMain(context)),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60, endIndent: 20);
  }

  Widget _buildLogoutButton() {
     return ScaleButton(
       onPressed: () async { 
         bool confirm = await showDialog(
           context: context, 
           builder: (ctx) => Directionality(
             textDirection: ui.TextDirection.rtl, 
             child: AlertDialog(
               backgroundColor: AppStyle.cardBg(context),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
               title: Text("تسجيل الخروج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppStyle.textMain(context))),
               content: Text("هل أنت متأكد أنك تريد تسجيل الخروج؟", style: GoogleFonts.cairo(color: AppStyle.textMain(context))),
               actions: [
                 TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("إلغاء", style: GoogleFonts.cairo())),
                 TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("خروج", style: GoogleFonts.cairo(color: Colors.red))),
               ]
             )
           )
         ) ?? false;

         if(confirm) {
           await supabase.auth.signOut(); 
           if(mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false); 
         }
       }, 
       child: Container(
         width: double.infinity, 
         padding: const EdgeInsets.symmetric(vertical: 16), 
         decoration: BoxDecoration(
           color: Colors.red.withOpacity(0.05), 
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: Colors.red.withOpacity(0.2))
         ), 
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center, 
           children: [
             Icon(Icons.logout, color: Colors.red.withOpacity(0.8)), 
             const SizedBox(width: 8), 
             Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.red.withOpacity(0.8), fontWeight: FontWeight.bold))
           ]
         )
       )
     );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  
  const ScaleButton({super.key, required this.child, required this.onPressed});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTap: () { 
        _controller.reverse(); 
        widget.onPressed(); 
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: Tween<double>(begin: 1.0, end: 0.95).animate(_controller), child: widget.child),
    );
  }
}
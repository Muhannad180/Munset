import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/login/signin_screen.dart';
import 'dart:ui' as ui;

class Profile extends StatelessWidget {
  final String? userEmail;
  const Profile({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) => ProfileScreen(userEmail: userEmail);
}

class ProfileScreen extends StatefulWidget {
  final String? userEmail;
  const ProfileScreen({super.key, this.userEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  // 🔹 Text Controllers for Editing
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController =
      TextEditingController(); // Read-only but required for display

  String currentGender = 'ذكر';
  bool notificationEnabled = true;
  // profilePictureUrl removed

  bool isLoading = true;
  String userId = '';

  // 🔹 Team Data (for Support Modal)
  final List<Map<String, String>> teamMembers = const [
    {'name': 'Turki Yousef Aloufi', 'id': '2240184'},
    {'name': 'Saeed Zaher Alshehri', 'id': '2240023'},
    {'name': 'Abdulrahman Haitham Salamah', 'id': '2240211'},
    {'name': 'Aamer Hamdan Aljagthami', 'id': '2340810'},
    {'name': 'Muhannad Almahdi Albaqami', 'id': '2240071'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    ageController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // 🔹 Load User Data and Populate Controllers
  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    userId = user.id;

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (response != null) {
        // Populate Controllers with data from Supabase
        firstNameController.text = response['first_name'] ?? '';
        lastNameController.text = response['last_name'] ?? '';
        usernameController.text = response['username'] ?? '';
        ageController.text = response['age']?.toString() ?? '';

        setState(() {
          currentGender = response['gender'] ?? 'ذكر';
          notificationEnabled = response['notifications_enabled'] ?? true;
          // profile_picture_url loading removed
        });
      }

      emailController.text = user.email ?? '';
    } catch (e) {
      print('❌ Error loading profile data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🔹 Save Changes to Supabase
  Future<void> _saveProfile() async {
    if (userId.isEmpty) return;

    // Basic form validation
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty) {
      _showSnackbar('الرجاء إدخال الاسم واسم المستخدم.', Colors.orange);
      return;
    }
    if (int.tryParse(ageController.text.trim()) == null ||
        int.parse(ageController.text.trim()) < 12) {
      _showSnackbar('الرجاء إدخال عمر صحيح (12 فما فوق).', Colors.orange);
      return;
    }

    try {
      setState(() => isLoading = true);

      final data = {
        'id': userId,
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'username': usernameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()),
        'gender': currentGender,
        'notifications_enabled': notificationEnabled,
        // profile_picture_url saving removed
      };

      // Use upsert to insert/update the user record
      await supabase.from('users').upsert(data);

      _showSnackbar('تم حفظ ملفك الشخصي بنجاح!', Colors.green);
    } catch (e) {
      _showSnackbar(
        'فشل الحفظ: تأكد من إضافة عمودي "username" و "notifications_enabled" في قاعدة البيانات.',
        Colors.red,
      );
      debugPrint('Save Error: $e');
    } finally {
      await _loadUserData();
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🔹 Utility for messages
  void _showSnackbar(String message, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // 🔹 Support Modal (Second Requirement)
  void _showSupportModal() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title: const Text('المساعدة والدعم'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'فريق عمل المشروع (Project Team)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                // Displaying team members
                ...teamMembers
                    .map(
                      (member) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${member['name']!} (ID: ${member['id']!})',
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    )
                    .toList(),
                const Divider(height: 20),
                const Text(
                  'جامعة جدة - قسم هندسة البرمجيات',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: Color(0xFF26A69A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Logout
  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double topGradientHeight = 200;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // 🟢 Top Section (Header and Waves)
                    SizedBox(
                      height: topGradientHeight,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: const Size(
                              double.infinity,
                              topGradientHeight,
                            ),
                            painter: _TopGradientPainter(),
                          ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Text(
                                'مُنصت',
                                style: TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🟢 Main Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'ملفك الشخصي',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 📸 STATIC Profile Picture
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFF26A69A), // Theme color
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // 🟡 Editable User Info Fields
                          _buildEditableField(
                            firstNameController,
                            'الاسم الأول',
                            editable: true,
                          ),
                          _buildEditableField(
                            lastNameController,
                            'اسم العائلة',
                            editable: true,
                          ),
                          _buildEditableField(
                            usernameController,
                            'اسم المستخدم',
                            editable: true,
                          ),
                          _buildEditableField(
                            ageController,
                            'العمر',
                            keyboardType: TextInputType.number,
                            editable: true,
                          ),

                          _buildGenderDropdown(),

                          // Email (Read-only)
                          _buildEditableField(
                            emailController,
                            'البريد الإلكتروني',
                            editable: false,
                          ),

                          const SizedBox(height: 20),

                          // Notifications Toggle
                          _buildToggleItem('الإشعارات', notificationEnabled, (
                            bool newValue,
                          ) {
                            setState(() {
                              notificationEnabled = newValue;
                            });
                          }),

                          const SizedBox(height: 10),

                          // Help and Support Button
                          _buildTappableItem(
                            'المساعدة والدعم',
                            Icons.help_outline,
                            _showSupportModal,
                          ),

                          const SizedBox(height: 30),

                          // Save Button
                          ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26A69A),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Logout Button (Re-using original design)
                          ElevatedButton.icon(
                            onPressed: _logout, // CORRECTED: calls _logout
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                237,
                                41,
                                41,
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 🔹 Helper Widget for Editable TextFields
  Widget _buildEditableField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool editable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.right,
            readOnly:
                !editable, // Use readOnly instead of enabled for better styling control
            style: TextStyle(color: editable ? Colors.black : Colors.grey[600]),
            decoration: InputDecoration(
              suffixIcon: editable
                  ? const Icon(Icons.edit, size: 20, color: Color(0xFF26A69A))
                  : null,
              fillColor: editable ? Colors.white : Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper Widget for Gender Dropdown
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الجنس',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: currentGender,
                items: ['ذكر', 'أنثى'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, textAlign: TextAlign.right),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      currentGender = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper Widget for Toggle Items
  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF26A69A),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper Widget for Tappable Action Items
  Widget _buildTappableItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Icon(icon, color: const Color(0xFF26A69A)),
          ],
        ),
      ),
    );
  }
}

// Custom Painters (Used for the background waves)
class _TopGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;

    const Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF9EEBE4), Color(0xFF5DD5CA), Color(0xFF26A69A)],
      stops: [0.0, 0.5, 1.0],
    );

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - 40)
      ..quadraticBezierTo(w * 0.5, h + 50, 0, h - 40)
      ..close();

    canvas.drawPath(
      path,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint paint1 = Paint()..color = const Color(0xFFE9E9E9);
    final Paint paint2 = Paint()..color = const Color(0xFFF5F5F5);

    final Path p1 = Path()
      ..moveTo(0, h * 0.6)
      ..quadraticBezierTo(w * 0.25, h * 0.45, w * 0.5, h * 0.6)
      ..quadraticBezierTo(w * 0.75, h * 0.75, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final Path p2 = Path()
      ..moveTo(0, h * 0.75)
      ..quadraticBezierTo(w * 0.28, h * 0.6, w * 0.5, h * 0.75)
      ..quadraticBezierTo(w * 0.72, h * 0.9, w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(p1, paint1);
    canvas.drawPath(p2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

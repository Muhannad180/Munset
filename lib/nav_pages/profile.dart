import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/login/signin_screen.dart';

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

  String firstName = '';
  String lastName = '';
  int age = 0;
  String gender = '';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        _showError('لم يتم العثور على المستخدم الحالي');
        setState(() => isLoading = false);
        return;
      }

      // 🔹 جلب بيانات المستخدم من جدول users حسب الـ email أو id
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        firstName = response['first_name'] ?? '';
        lastName = response['last_name'] ?? '';
        age = (response['age'] ?? 0) as int;
        gender = response['gender'] ?? '';
        email = response['email'] ?? '';
      });
    } catch (e) {
      debugPrint('❌ خطأ أثناء جلب البيانات: $e');
      _showError('حدث خطأ أثناء تحميل بيانات المستخدم');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

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
    const double wavesHeight = 160;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF26A69A)),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // 🟢 رأس الصفحة
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

                    // 🟢 محتوى الصفحة
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -wavesHeight + 20,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: wavesHeight,
                            child: CustomPaint(
                              size: const Size(double.infinity, wavesHeight),
                              painter: _WavesPainter(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20.0,
                          ),
                          child: Column(
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

                              // 🟣 صورة الملف الشخصي
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  const CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      'https://www.pngall.com/wp-content/uploads/12/Avatar-Profile-PNG-Clipart.png',
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),

                              // 🟡 معلومات المستخدم
                              _buildInfoField(
                                label: 'الاسم الأول',
                                value: firstName,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoField(
                                label: 'اسم العائلة',
                                value: lastName,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoField(
                                label: 'العمر',
                                value: age > 0 ? age.toString() : 'غير متوفر',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoField(label: 'الجنس', value: gender),
                              const SizedBox(height: 16),
                              _buildInfoField(
                                label: 'البريد الإلكتروني',
                                value: email,
                              ),

                              const SizedBox(height: 25),

                              // 🟠 خيارات إضافية
                              _buildActionCard(
                                icon: Icons.notifications_none,
                                text: 'الإشعارات',
                                trailingWidget: Switch(
                                  value: true,
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildActionCard(
                                icon: Icons.help_outline,
                                text: 'المساعدة والدعم',
                              ),

                              const SizedBox(height: 25),

                              // 🔴 زر تسجيل الخروج
                              ElevatedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 🔹 مكونات صغيرة
  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            value.isNotEmpty ? value : 'غير متوفر',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String text,
    Widget? trailingWidget,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 15),
            Text(text, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
}

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

import 'package:flutter/material.dart';
import 'package:test1/login/auth_service.dart';
import 'package:test1/login/signin_screen.dart';

class Profile extends StatelessWidget {
  final String? userEmail;

  const Profile({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(userEmail: userEmail);
  }
}

class ProfileScreen extends StatefulWidget {
  final String? userEmail;

  const ProfileScreen({super.key, this.userEmail});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final authService = AuthService();
      final userId = authService.getCurrentUserId();

      if (userId != null) {
        final userData = await authService.getUserDataById(userId);

        if (userData != null && mounted) {
          setState(() {
            firstName = userData['first_name'] ?? '';
            lastName = userData['last_name'] ?? '';
            age = userData['age'] ?? 0;
            gender = userData['gender'] ?? '';
            email = userData['email'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('خطأ في جلب البيانات: $e');
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تحميل البيانات'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    // Header Gradient
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
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: const Text(
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
                    // Main Content with Waves
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
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
                                const SizedBox(height: 10),
                                const Text(
                                  'ملفك الشخصي',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Profile Picture
                                Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                        'https://www.pngall.com/wp-content/uploads/12/Avatar-Profile-PNG-Clipart.png',
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // User Info Fields
                                _buildInfoField(
                                  label: 'الاسم الأول',
                                  value: firstName.isNotEmpty
                                      ? firstName
                                      : 'غير متوفر',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoField(
                                  label: 'اسم العائلة',
                                  value: lastName.isNotEmpty
                                      ? lastName
                                      : 'غير متوفر',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoField(
                                  label: 'العمر',
                                  value: age > 0 ? age.toString() : 'غير متوفر',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoField(
                                  label: 'الجنس',
                                  value: gender.isNotEmpty
                                      ? gender
                                      : 'غير متوفر',
                                ),
                                const SizedBox(height: 16),
                                _buildInfoField(
                                  label: 'البريد الإلكتروني',
                                  value: email.isNotEmpty ? email : 'غير متوفر',
                                ),
                                const SizedBox(height: 20),
                                // Action Cards
                                _buildActionCard(
                                  icon: Icons.notifications_none,
                                  text: 'الاشعارات',
                                  trailingWidget: Switch(
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildActionCard(
                                  icon: Icons.help_outline,
                                  text: 'المساعدة و الدعم',
                                ),
                                const SizedBox(height: 20),
                                // زر تسجيل الخروج
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final authService = AuthService();
                                    await authService.signOut();

                                    if (context.mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SignInScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },
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
                                    backgroundColor: Colors.redAccent,
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
                    ),
                  ],
                ),
              ),
      ),
    );
  }

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
            value,
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
    const Color lightColor = Color(0xFF9EEBE4);
    const Color secondaryColor = Color(0xFF5DD5CA);
    const Color primaryColor = Color(0xFF26A69A);

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h - 40);
    path.quadraticBezierTo(w * 0.5, h + 50, 0, h - 40);
    path.close();

    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [lightColor, secondaryColor, primaryColor],
      stops: const [0.0, 0.5, 1.0],
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    const Color waveColor1 = Color(0xFFE9E9E9);
    const Color waveColor2 = Color(0xFFF5F5F5);

    Paint paint1 = Paint()..color = waveColor1;
    Path p1 = Path();
    p1.moveTo(0, h * 0.6);
    p1.quadraticBezierTo(w * 0.25, h * 0.45, w * 0.5, h * 0.6);
    p1.quadraticBezierTo(w * 0.75, h * 0.75, w, h * 0.6);
    p1.lineTo(w, h);
    p1.lineTo(0, h);
    p1.close();
    canvas.drawPath(p1, paint1);

    Paint paint2 = Paint()..color = waveColor2;
    Path p2 = Path();
    p2.moveTo(0, h * 0.75);
    p2.quadraticBezierTo(w * 0.28, h * 0.6, w * 0.5, h * 0.75);
    p2.quadraticBezierTo(w * 0.72, h * 0.9, w, h * 0.75);
    p2.lineTo(w, h);
    p2.lineTo(0, h);
    p2.close();
    canvas.drawPath(p2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

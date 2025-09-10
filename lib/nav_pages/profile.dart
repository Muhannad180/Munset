import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
      theme: ThemeData(fontFamily: 'Inter'),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    const Color topBgColor = Color.fromRGBO(200, 230, 225, 1.0);
    const Color mainBgColor = Color.fromRGBO(236, 246, 243, 1.0);
    const Color cardBgColor = Colors.white;
    const Color badgeColor = Color.fromRGBO(173, 216, 230, 1.0);

    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: AppBar(
        backgroundColor: topBgColor,
        elevation: 0,
        title: const Text("Log in", style: TextStyle(color: Colors.black)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // User Profile Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                decoration: const BoxDecoration(
                  color: topBgColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
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
                          top: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.verified_user,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: topBgColor, width: 2),
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
                    const SizedBox(height: 10),
                    const Text(
                      'اسم المستخدم',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // First Card Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  color: cardBgColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.person_outline,
                          text: 'تعديل بيانات المستخدم',
                        ),
                        _buildListTile(
                          icon: Icons.notifications_none,
                          text: 'الاشعارات',
                          trailingWidget: Switch(
                            value: true,
                            onChanged: (value) {},
                          ),
                        ),
                        _buildListTile(
                          icon: Icons.language,
                          text: 'اللغة',
                          trailingWidget: const Text(
                            'العربية',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Second Card Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  color: cardBgColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.security,
                          text: 'الأمان',
                          trailingWidget: const Icon(Icons.arrow_forward_ios),
                        ),
                        _buildListTile(
                          icon: Icons.palette,
                          text: 'الهيئة',
                          trailingWidget: const Text(
                            'فاتح',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Third Card Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  color: cardBgColor,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.help_outline,
                          text: 'المساعدة و الدعم',
                        ),
                        _buildListTile(
                          icon: Icons.chat_bubble_outline,
                          text: 'تواصل معنا',
                        ),
                        _buildListTile(
                          icon: Icons.lock_outline,
                          text: 'الخصوصية',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String text,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }
}

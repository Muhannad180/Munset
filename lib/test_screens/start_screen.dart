import 'package:flutter/material.dart';
import 'package:test1/test_screens/test_screen.dart';
import 'package:test1/login/signin_screen.dart';
import '/style.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppStyle.gradientBackground(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 180),

              Container(
                width: 360,
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 40),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 138, 217, 190),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'في البداية اريد منك الإجابة على 9 اسئلة, اختبر بها حالتك النفسية رجاءً خذ وقتك ولا تتعجل في الإجابة...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),

              SizedBox(height: 30),

              Container(
                width: 360,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Color.fromARGB(255, 162, 1, 1),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'تنبيه: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 162, 1, 1),
                                fontSize: 18,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  'هذا الاختبار (PHQ-9) يعطي نبذة عن حالتك الصحية ولا يعد وسيلة تشخيص دقيقة فلابد من الرجوع للطبيب النفسي لتشخيصك !!',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 162, 1, 1),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 100),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TestScreen()),
                  );
                },
                icon: Icon(Icons.arrow_back_ios_new),
                label: const Text('الموافقة والبدأ'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              ),

              SizedBox(height: 100),

              Container(
                padding: EdgeInsets.only(left: 200),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LogInScreen()),
                      );
                    },
                    label: const Text('تخطي'),
                    icon: const Icon(Icons.arrow_circle_right_sharp),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

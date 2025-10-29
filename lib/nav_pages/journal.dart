import 'package:flutter/material.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  // 0..4 (سيء جداً ← ممتاز). لاحظ أننا نعكس الترتيب وقت العرض.
  int selectedMood = 4;

  final titleCtrl = TextEditingController();
  final detailsCtrl = TextEditingController();

  // من الغاضب إلى السعيد (سنقلبها في الواجهة)
  final List<String> moods = ['😠', '😞', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFB7D9CF),

        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'بماذا تشعر الان ؟',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // صف الوجوه: عكس الترتيب + بهتان غير المختار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(moods.length, (i) {
                        final index = moods.length - 1 - i; // نعكس الترتيب
                        final isSel = selectedMood == index;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: InkWell(
                            onTap: () => setState(() => selectedMood = index),
                            borderRadius: BorderRadius.circular(28),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSel ? Colors.white : Colors.grey[300],
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                              // ↓↓↓ نجعل الإيموجي نفسه باهت لغير المختار + تكبير للمختار
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: isSel
                                    ? 1.0
                                    : 0.38, // بهتان غير المختار
                                child: Transform.scale(
                                  scale: isSel
                                      ? 1.1
                                      : 1.0, // تكبير بسيط للمختار
                                  child: Text(
                                    moods[index],
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // الحقول
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: "اكتب بماذا تشعر هنا",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: detailsCtrl,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "اكتب تفاصيل اكثر..",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // زر المدونات السابقة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E9E92),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          // TODO: افتح صفحة المدونات السابقة
                        },
                        child: const Text(
                          "المدونات السابقة",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E9E92),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          // TODO: implement save functionality
                        },
                        child: const Text(
                          "حفظ",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

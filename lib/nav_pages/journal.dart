import 'package:flutter/material.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  final List<Map<String, dynamic>> journals = [];

  final List<String> moods = ['😠', '😞', '😐', '🙂', '😄'];

  // 🟢 الألوان حسب المزاج
  final Map<String, Color> moodColors = {
    '😠': Colors.redAccent.shade100,
    '😞': Colors.orangeAccent.shade100,
    '😐': Colors.grey.shade300,
    '🙂': Colors.lightBlueAccent.shade100,
    '😄': Colors.lightGreenAccent.shade100,
  };

  void _openAddJournalModal() {
    int selectedMood = 4;
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            right: 20,
            left: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "أضف شعورك اليوم 📝",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("كيف كان شعورك اليوم؟"),
                    const SizedBox(height: 10),

                    // صف الإيموجيات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(moods.length, (i) {
                        final index = moods.length - 1 - i;
                        final isSel = selectedMood == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: InkWell(
                            onTap: () =>
                                setModalState(() => selectedMood = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.grey[200]
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                                boxShadow: isSel
                                    ? [
                                        const BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: isSel ? 1.0 : 0.4,
                                child: Text(
                                  moods[index],
                                  style: TextStyle(fontSize: isSel ? 30 : 26),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: titleCtrl,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "اكتب عنوان شعورك",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: detailsCtrl,
                      maxLines: 4,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "اكتب تفاصيل أكثر..",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

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
                          if (titleCtrl.text.isEmpty &&
                              detailsCtrl.text.isEmpty)
                            return;

                          setState(() {
                            journals.insert(0, {
                              'mood': moods[selectedMood],
                              'title': titleCtrl.text,
                              'details': detailsCtrl.text,
                              'date': DateTime.now(),
                            });
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "حفظ",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("يومياتي 💭"),
          backgroundColor: const Color(0xFF5E9E92),
          centerTitle: true,
        ),

        body: journals.isEmpty
            ? const Center(
                child: Text(
                  "لا توجد يوميات بعد ✨",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journals.length,
                itemBuilder: (context, index) {
                  final j = journals[index];
                  final bgColor = moodColors[j['mood']] ?? Colors.grey.shade200;

                  return Card(
                    color: bgColor, // 🎨 لون الكرت حسب المزاج
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                j['mood'],
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  j['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            j['details'],
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${j['date'].hour}:${j['date'].minute.toString().padLeft(2, '0')} - ${j['date'].year}/${j['date'].month}/${j['date'].day}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 60, right: 16),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF5E9E92),
            onPressed: _openAddJournalModal,
            child: const Icon(Icons.add, size: 40, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.startFloat, // يثبتها يمين الشاشة
      ),
    );
  }
}

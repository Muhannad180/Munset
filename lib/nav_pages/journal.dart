import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/login/auth_service.dart';
import 'dart:ui' as ui;

// 💡 Define a callback function to notify other screens (like HomePage) to reload
class Journal extends StatefulWidget {
  final VoidCallback? onJournalSaved;
  const Journal({super.key, this.onJournalSaved});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  final supabase = Supabase.instance.client;
  final authService = AuthService();

  List<Map<String, dynamic>> journals = [];
  int currentIndex = 0;
  bool isLoading = true;

  // 💡 Moods with Arabic names for display
  final List<Map<String, String>> moods = [
    {'emoji': '😭', 'name': 'حزين جداً'},
    {'emoji': '😢', 'name': 'حزين'},
    {'emoji': '😔', 'name': 'مكتئب'},
    {'emoji': '😞', 'name': 'خيبة أمل'},
    {'emoji': '😐', 'name': 'محايد'},
    {'emoji': '🙂', 'name': 'هادئ'},
    {'emoji': '😄', 'name': 'سعيد'},
    {'emoji': '😍', 'name': 'محبوب'},
    {'emoji': '🤩', 'name': 'متحمس'},
    {'emoji': '😎', 'name': 'واثق'},
    {'emoji': '😇', 'name': 'مسترخٍ'},
    {'emoji': '😤', 'name': 'غاضب'},
    {'emoji': '🥳', 'name': 'محتفل'},
    {'emoji': '😴', 'name': 'متعب'},
  ];

  // FIX: Ensured all shade values are standard (e.g., shade100, not shade110)
  late final Map<String, Color> moodColors = {
    '😭': Colors.red.shade100,
    '😢': Colors.orange.shade100,
    '😔': Colors.orangeAccent.shade100,
    '😞': Colors.deepOrangeAccent.shade100,
    '😐': Colors.grey.shade300,
    '🙂': Colors.lightBlueAccent.shade100,
    '😄': Colors.greenAccent.shade100,
    '😍': Colors.pinkAccent.shade100,
    '🤩': Colors.amberAccent.shade100,
    '😎': Colors.blueAccent.shade100,
    '😇': Colors.tealAccent.shade100,
    '😤': Colors.redAccent.shade100,
    '🥳': Colors.purpleAccent.shade100,
    '😴': Colors.indigo.shade100,
  };

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  // 🔹 جلب اليوميات من Supabase
  Future<void> _loadJournals() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    try {
      final response = await supabase
          .from('journals')
          .select()
          .eq('id', userId)
          .order('journal_id', ascending: false); // ترتيب حسب اليومية

      setState(() {
        journals = response;
        isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل اليوميات');
      setState(() => isLoading = false);
    }
  }

  // 🔹 حفظ اليومية في Supabase
  Future<void> _saveJournal(
    String mood,
    String moodName,
    String description,
  ) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;

    int lastJournal = 0;
    if (journals.isNotEmpty) {
      lastJournal = journals[0]['journal_id'] ?? 0;
    }

    int journalId = lastJournal + 1;

    try {
      await supabase.from('journals').insert({
        'id': userId,
        'journal_id': journalId,
        'mode': mood,
        'mode_name': moodName,
        'mode_description': description,
        'mode_date': DateTime.now().toIso8601String(),
      });

      setState(() {
        journals.insert(0, {
          'journal_id': journalId,
          'mode': mood,
          'mode_name': moodName,
          'mode_description': description,
          'mode_date': DateTime.now().toIso8601String(),
        });
        currentIndex = 0;
      });
    } catch (e) {
      print('❌ خطأ أثناء الحفظ: $e');
    }
  }

  // 🔹 Open Add Journal Modal
  void _openAddJournalModal() {
    int selectedMoodIndex = 4; // Default to 'محايد'
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "أضف شعورك اليوم 📝",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Emojis Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(moods.length, (index) {
                          final isSel = selectedMoodIndex == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: InkWell(
                              onTap: () => setModalState(
                                () => selectedMoodIndex = index,
                              ),
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
                                    moods[index]['emoji']!,
                                    style: TextStyle(fontSize: isSel ? 32 : 26),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display current mood name in Arabic
                    Text(
                      'المزاج الحالي: ${moods[selectedMoodIndex]['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: detailsCtrl,
                      maxLines: 4,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "اكتب تفاصيل أكثر عن يومك..",
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
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E9E92),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          if (detailsCtrl.text.isEmpty) return;
                          await _saveJournal(
                            moods[selectedMoodIndex]['emoji']!,
                            moods[selectedMoodIndex]['name']!,
                            detailsCtrl.text.trim(),
                          );
                          if (context.mounted) Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "حفظ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
    final hasData = journals.isNotEmpty;
    final j = hasData ? journals[currentIndex] : null;
    final bgColor = hasData
        ? (moodColors[j!['mode']] ?? Colors.grey.shade200)
        : null;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "💭 يومياتي",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF5E9E92),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasData
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey(currentIndex),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bgColor ?? Colors.teal.shade100,
                        Colors.white.withOpacity(0.85),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 35,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(j!['mode'], style: const TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      // Display mood name in Arabic
                      Text(
                        j['mode_name'] ?? 'غير معرف',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        j['mode_description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        DateFormat(
                          'yyyy/MM/dd - HH:mm',
                        ).format(DateTime.parse(j['mode_date'])),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "يومية ${currentIndex + 1} من ${journals.length}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(
                child: Text(
                  "لا توجد يوميات بعد ✨",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: hasData && currentIndex > 0 ? 1.0 : 0.3,
                child: FloatingActionButton.small(
                  heroTag: "next",
                  backgroundColor: Colors.grey[400],
                  onPressed: hasData && currentIndex > 0
                      ? () => setState(() => currentIndex--)
                      : null,
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              FloatingActionButton(
                heroTag: "add",
                backgroundColor: const Color(0xFF5E9E92),
                onPressed: _openAddJournalModal,
                child: const Icon(Icons.add, size: 35, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Opacity(
                opacity: hasData && currentIndex < journals.length - 1
                    ? 1.0
                    : 0.3,
                child: FloatingActionButton.small(
                  heroTag: "prev",
                  backgroundColor: Colors.grey[400],
                  onPressed: hasData && currentIndex < journals.length - 1
                      ? () => setState(() => currentIndex++)
                      : null,
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
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

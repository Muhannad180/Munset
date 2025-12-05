import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;

class Journal extends StatefulWidget {
  const Journal({super.key});
  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  List<Map<String, dynamic>> journals = [];
  bool isLoading = true;
  final Color primaryColor = const Color(0xFF5E9E92);
  late AnimationController _btnController;

  final List<Map<String, String>> moods = [
    {'emoji': '😭', 'name': 'حزين'}, {'emoji': '😐', 'name': 'محايد'}, {'emoji': '🙂', 'name': 'هادئ'}, {'emoji': '😄', 'name': 'سعيد'},
  ];

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    try {
      final response = await supabase.from('journals').select().eq('id', userId).order('journal_id', ascending: false);
      if(mounted) setState(() { journals = response; isLoading = false; });
    } catch (e) { if(mounted) setState(() => isLoading = false); }
  }

  Future<void> _saveJournal(String mood, String moodName, String desc) async {
    final userId = authService.getCurrentUserId();
    if (userId == null) return;
    int journalId = (journals.isNotEmpty ? (journals[0]['journal_id'] ?? 0) : 0) + 1;
    try {
      await supabase.from('journals').insert({
        'id': userId, 'journal_id': journalId, 'mode': mood, 'mode_name': moodName, 'mode_description': desc, 'mode_date': DateTime.now().toIso8601String(),
      });
      _loadJournals();
    } catch (e) { debugPrint("$e"); }
  }

  void _openAdd() {
    int selIndex = 2;
    final txtCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      child: StatefulBuilder(builder: (c, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("كيف تشعر اليوم؟", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(moods.length, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: InkWell(onTap: () => setSt(() => selIndex = i), child: CircleAvatar(radius: 25, backgroundColor: selIndex == i ? primaryColor : Colors.grey[200], child: Text(moods[i]['emoji']!, style: const TextStyle(fontSize: 24))))))),
        const SizedBox(height: 20),
        TextField(controller: txtCtrl, textAlign: TextAlign.right, decoration: InputDecoration(hintText: "اكتب ما بخاطرك...", filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () { _saveJournal(moods[selIndex]['emoji']!, moods[selIndex]['name']!, txtCtrl.text); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)), child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('يومياتي', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: primaryColor, centerTitle: true, elevation: 0),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0, left: 10),
          child: GestureDetector(
            onTapDown: (_) => _btnController.forward(),
            onTapUp: (_) { _btnController.reverse(); _openAdd(); },
            onTapCancel: () => _btnController.reverse(),
            child: ScaleTransition(scale: Tween<double>(begin: 1.0, end: 0.9).animate(_btnController), child: Container(width: 56, height: 56, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]), child: const Icon(Icons.add, color: Colors.white))),
          ),
        ),
        body: isLoading ? Center(child: CircularProgressIndicator(color: primaryColor)) : journals.isEmpty 
          ? const Center(child: Text("لا توجد يوميات بعد", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: journals.length,
              itemBuilder: (ctx, i) {
                final j = journals[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                  child: ListTile(
                    leading: Text(j['mode'], style: const TextStyle(fontSize: 30)),
                    title: Text(j['mode_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if(j['mode_description'] != null) Text(j['mode_description'], style: const TextStyle(color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text(DateFormat('yyyy/MM/dd').format(DateTime.parse(j['mode_date'])), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ),
                );
              },
            ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;

class Journal extends StatefulWidget {
  final VoidCallback? onJournalAdded;
  const Journal({super.key, this.onJournalAdded});
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
    {'emoji': '😭', 'name': 'حزين جداً'}, {'emoji': '😢', 'name': 'حزين'}, {'emoji': '😔', 'name': 'مكتئب'},
    {'emoji': '😞', 'name': 'خيبة أمل'}, {'emoji': '😐', 'name': 'محايد'}, {'emoji': '🙂', 'name': 'هادئ'},
    {'emoji': '😄', 'name': 'سعيد'}, {'emoji': '😍', 'name': 'محبوب'}, {'emoji': '🤩', 'name': 'متحمس'},
    {'emoji': '😎', 'name': 'واثق'}, {'emoji': '😇', 'name': 'مسترخٍ'}, {'emoji': '😤', 'name': 'غاضب'},
    {'emoji': '🥳', 'name': 'محتفل'}, {'emoji': '😴', 'name': 'متعب'},
    {'emoji': '🤔', 'name': 'أخرى'},
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
    try {
       // Fetch last journal_id to increment safely. 
       // Note: In home.dart logical was simpler, here we rely on list. Ideally use DB count or max.
       // Let's stick to current logic but optimize if possible.
       final maxIdResp = await supabase.from('journals').select('journal_id').eq('id', userId).order('journal_id', ascending: false).limit(1).maybeSingle();
       int journalId = (maxIdResp != null) ? (maxIdResp['journal_id'] + 1) : 1;

      await supabase.from('journals').insert({
        'id': userId, 'journal_id': journalId, 'mode': mood, 'mode_name': moodName, 'mode_description': desc, 'mode_date': DateTime.now().toIso8601String(),
      });
      _loadJournals();
      widget.onJournalAdded?.call();
    } catch (e) { debugPrint("$e"); }
  }

  void _openAdd() {
    int selIndex = 4; // Default to Neutral (index 4 in new list)
    final txtCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), 
      builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 25, left: 20, right: 20),
      child: StatefulBuilder(builder: (c, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("كيف تشعر اليوم؟", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 25),
        
        // Mood Selector
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              ui.PointerDeviceKind.touch,
              ui.PointerDeviceKind.mouse,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(moods.length, (i) {
              bool isSelected = selIndex == i;
              return GestureDetector(
                onTap: () => setSt(() => selIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected ? Border.all(color: primaryColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                        ),
                        child: Text(moods[i]['emoji']!, style: TextStyle(fontSize: isSelected ? 36 : 28)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        moods[i]['name']!, 
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryColor : Colors.grey[600]
                        )
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Container(width: 5, height: 5, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle))
                      ]
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
        
        const SizedBox(height: 30),
        
        // Display selected mood name prominently
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Text(moods[selIndex]['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        
        const SizedBox(height: 20),
        
        TextField(
          controller: txtCtrl, 
          textAlign: TextAlign.right, 
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "اكتب ما بخاطرك...", 
            filled: true, 
            fillColor: Colors.grey[50], 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(15),
          )
        ),
        const SizedBox(height: 25),
        
        ElevatedButton(
          onPressed: () { 
            _saveJournal(moods[selIndex]['emoji']!, moods[selIndex]['name']!, txtCtrl.text); 
            Navigator.pop(ctx); 
          }, 
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, 
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
          ), 
          child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
        )
      ])),
    ));
  }
  Future<void> _deleteJournal(Map<String, dynamic> journal) async {
    bool confirm = await showDialog(context: context, builder: (ctx) => Directionality(textDirection: ui.TextDirection.rtl, child: AlertDialog(title: const Text("حذف"), content: const Text("تأكيد الحذف؟"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("حذف", style: TextStyle(color: Colors.red)))]))) ?? false;
    if (!confirm) return;
    try {
      await supabase.from('journals').delete().eq('id', supabase.auth.currentUser!.id).eq('journal_id', journal['journal_id']);
      _loadJournals();
      widget.onJournalAdded?.call(); // Refresh home
    } catch (e) { debugPrint("Del Err: $e"); }
  }

  void _editJournal(Map<String, dynamic> journal) {
    int selIndex = moods.indexWhere((m) => m['name'] == journal['mode_name']);
    if (selIndex == -1) selIndex = 4;
    final txtCtrl = TextEditingController(text: journal['mode_description']);
    
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), 
      builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 25, left: 20, right: 20),
      child: StatefulBuilder(builder: (c, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("تعديل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 25),
        
        // Mood Selector
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {ui.PointerDeviceKind.touch, ui.PointerDeviceKind.mouse}),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(moods.length, (i) {
                bool isSelected = selIndex == i;
                return GestureDetector(
                  onTap: () => setSt(() => selIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: isSelected ? Border.all(color: primaryColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                          ),
                          child: Text(moods[i]['emoji']!, style: TextStyle(fontSize: isSelected ? 36 : 28)),
                        ),
                        const SizedBox(height: 8),
                        Text(moods[i]['name']!, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? primaryColor : Colors.grey[600])),
                        if (isSelected) ...[const SizedBox(height: 4), Container(width: 5, height: 5, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle))]
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(moods[selIndex]['name']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        
        const SizedBox(height: 20),
        
        TextField(controller: txtCtrl, textAlign: TextAlign.right, maxLines: 4, decoration: InputDecoration(hintText: "اكتب ما بخاطرك...", filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(15))),
        const SizedBox(height: 25),
        
        ElevatedButton(
          onPressed: () async { 
             await supabase.from('journals').update({
               'mode': moods[selIndex]['emoji'], 
               'mode_name': moods[selIndex]['name'], 
               'mode_description': txtCtrl.text
             }).eq('id', supabase.auth.currentUser!.id).eq('journal_id', journal['journal_id']);
             Navigator.pop(ctx); 
             _loadJournals();
             widget.onJournalAdded?.call();
          }, 
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2), 
          child: const Text("تحديث", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
        )
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
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Text(j['mode'], style: const TextStyle(fontSize: 28))),
                    title: Text(j['mode_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 6),
                      if(j['mode_description'] != null) Text(j['mode_description'], style: const TextStyle(color: Colors.black87, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(DateTime.parse(j['mode_date'])), style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ]),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') _editJournal(j);
                        if (val == 'delete') _deleteJournal(j);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue, size: 20), SizedBox(width: 8), Text('تعديل')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('حذف', style: TextStyle(color: Colors.red))])),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
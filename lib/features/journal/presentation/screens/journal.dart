import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test1/data/services/auth_service.dart';
import 'dart:ui' as ui;
import 'package:test1/core/theme/app_style.dart';

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
  Color get primaryColor => AppStyle.primary;
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
    int selIndex = 4; // Default to Neutral
    final txtCtrl = TextEditingController();
    _showJournalSheet(selIndex: selIndex, controller: txtCtrl, isEdit: false);
  }
  
  void _editJournal(Map<String, dynamic> journal) {
    int selIndex = moods.indexWhere((m) => m['name'] == journal['mode_name']);
    if (selIndex == -1) selIndex = 4;
    final txtCtrl = TextEditingController(text: journal['mode_description']);
    _showJournalSheet(selIndex: selIndex, controller: txtCtrl, isEdit: true, journal: journal);
  }

  void _showJournalSheet({int selIndex = 4, required TextEditingController controller, required bool isEdit, Map<String, dynamic>? journal}) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: AppStyle.cardBg(context), 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))), 
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 25, left: 20, right: 20),
        child: StatefulBuilder(builder: (c, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
          Text(isEdit ? "تعديل اليومية" : "كيف تشعر اليوم؟", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20, color: AppStyle.textMain(context))),
          const SizedBox(height: 25),
          
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {ui.PointerDeviceKind.touch, ui.PointerDeviceKind.mouse}),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(moods.length, (i) {
                bool isSelected = selIndex == i;
                Color mColor = _getMoodColor(moods[i]['emoji']);
                return GestureDetector(
                  onTap: () => setSt(() => selIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? mColor.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? Border.all(color: mColor, width: 2) : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(moods[i]['emoji']!, style: TextStyle(fontSize: isSelected ? 32 : 26)),
                        const SizedBox(height: 6),
                        Text(moods[i]['name']!, style: GoogleFonts.cairo(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? mColor : AppStyle.textMain(context).withOpacity(0.6))),
                      ],
                    ),
                  ),
                );
              })),
            ),
          ),
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _getMoodColor(moods[selIndex]['emoji']).withOpacity(0.1), 
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(moods[selIndex]['name']!, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: _getMoodColor(moods[selIndex]['emoji']))),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: controller, 
            textAlign: TextAlign.right, 
            maxLines: 4,
            style: GoogleFonts.cairo(color: AppStyle.textMain(context)),
            decoration: InputDecoration(
              hintText: "أكتب تفاصيل يومك...", 
              hintStyle: GoogleFonts.cairo(color: Colors.grey),
              filled: true, 
              fillColor: AppStyle.isDark(context) ? Colors.white.withOpacity(0.05) : Colors.grey[50], 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(15),
            )
          ),
          const SizedBox(height: 25),
          
          ElevatedButton(
            onPressed: () async { 
              if (isEdit && journal != null) {
                 await supabase.from('journals').update({
                   'mode': moods[selIndex]['emoji'], 
                   'mode_name': moods[selIndex]['name'], 
                   'mode_description': controller.text
                 }).eq('id', supabase.auth.currentUser!.id).eq('journal_id', journal['journal_id']);
              } else {
                 await _saveJournal(moods[selIndex]['emoji']!, moods[selIndex]['name']!, controller.text); 
              }
              Navigator.pop(ctx); 
              _loadJournals();
              if (isEdit) widget.onJournalAdded?.call();
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: _getMoodColor(moods[selIndex]['emoji']),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
            ), 
            child: Text("حفظ", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
          )
        ])),
      )
    );
  }

  Future<void> _deleteJournal(Map<String, dynamic> journal) async {
    bool confirm = await showDialog(context: context, builder: (ctx) => Directionality(textDirection: ui.TextDirection.rtl, child: AlertDialog(
      backgroundColor: AppStyle.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("حذف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppStyle.textMain(context))), 
      content: Text("هل أنت متأكد من حذف هذه اليومية؟", style: GoogleFonts.cairo(color: AppStyle.textMain(context))), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("إلغاء", style: GoogleFonts.cairo(color: AppStyle.textMain(context)))), 
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("حذف", style: GoogleFonts.cairo(color: Colors.red)))
      ]))) ?? false;
    if (!confirm) return;
    try {
      await supabase.from('journals').delete().eq('id', supabase.auth.currentUser!.id).eq('journal_id', journal['journal_id']);
      _loadJournals();
      widget.onJournalAdded?.call();
    } catch (e) { debugPrint("Del Err: $e"); }
  }

  Color _getMoodColor(String? emoji) {
    if (emoji == null) return primaryColor;
    if (['😄', '😍', '🤩', '😎', '🥳'].contains(emoji)) return const Color(0xFFFFA726); 
    if (['😭', '😢', '😔', '😞'].contains(emoji)) return const Color(0xFF42A5F5); 
    if (['😤'].contains(emoji)) return const Color(0xFFEF5350); 
    if (['😴'].contains(emoji)) return const Color(0xFFAB47BC); 
    return primaryColor; 
  }

  LinearGradient _getMoodGradient(String? emoji) {
    final color = _getMoodColor(emoji);
    return LinearGradient(
      begin: Alignment.topCenter, 
      end: Alignment.bottomCenter,
      colors: [color, color.withOpacity(0.5)],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = AppStyle.isDark(context);
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        body: isLoading 
         ? Center(child: CircularProgressIndicator(color: primaryColor)) 
         : Column(
           children: [
             // Header
             SizedBox(
               height: 150,
               child: Stack(
                 alignment: Alignment.topCenter,
                 children: [
                   Container(
                     height: 120,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter, end: Alignment.bottomCenter,
                         colors: isDark 
                           ? [const Color(0xFF1F2E2C), AppStyle.bgTop(context)] 
                           : [primaryColor, primaryColor.withOpacity(0.6)],
                       ),
                       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                     ),
                   ),
                   Positioned(
                     top: 40,
                     child: Column(
                       children: [
                         Text("يومياتي", style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                         Text("وثّق لحظاتك ومشاعرك", style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
                       ],
                     ),
                   ),
                   // New Add Button in Header (Correctly positioned inside bounds)
                   Positioned(
                     bottom: 0,
                     child: GestureDetector(
                       onTap: _openAdd,
                       onTapDown: (_) => _btnController.forward(),
                       onTapUp: (_) => _btnController.reverse(),
                       onTapCancel: () => _btnController.reverse(),
                       child: ScaleTransition(
                         scale: Tween<double>(begin: 1.0, end: 0.9).animate(_btnController), 
                         child: Container(
                           width: 56, height: 56, 
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               begin: Alignment.topLeft, end: Alignment.bottomRight,
                               colors: [const Color(0xFF00897B), primaryColor]
                             ),
                             shape: BoxShape.circle, 
                             boxShadow: [
                               BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                             ]
                           ), 
                           child: const Icon(Icons.add, color: Colors.white, size: 30)
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),

             // List
             Expanded(
               child: journals.isEmpty 
               ? Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.menu_book_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                       const SizedBox(height: 15),
                       Text("ابدأ بتدوين مذكراتك!", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
                     ],
                   )
                 )
               : ListView.builder(
                   physics: const BouncingScrollPhysics(),
                   padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                   itemCount: journals.length,
                   itemBuilder: (ctx, i) => _buildJournalCard(journals[i]),
                 ),
             ),
           ],
         ),
         // Removed FAB
      ),
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> journal) {
    Color moodColor = _getMoodColor(journal['mode']);
    LinearGradient moodGradient = _getMoodGradient(journal['mode']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(AppStyle.isDark(context) ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 8,
                decoration: BoxDecoration(
                   gradient: moodGradient,
                   borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: moodColor.withOpacity(0.1),
                                shape: BoxShape.circle
                            ),
                            child: Text(journal['mode'], style: const TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(journal['mode_name'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: AppStyle.textMain(context))),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 12, color: AppStyle.textSmall(context)),
                                    const SizedBox(width: 5),
                                    Text(
                                      DateFormat('yyyy/MM/dd  •  hh:mm a', 'ar').format(DateTime.parse(journal['mode_date'])), 
                                      style: GoogleFonts.cairo(fontSize: 12, color: AppStyle.textSmall(context))
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'edit') _editJournal(journal);
                              if (val == 'delete') _deleteJournal(journal);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, color: Colors.blue, size: 20), const SizedBox(width: 8), Text('تعديل', style: GoogleFonts.cairo())])),
                              PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red, size: 20), const SizedBox(width: 8), Text('حذف', style: GoogleFonts.cairo(color: Colors.red))])),
                            ],
                            icon: Icon(Icons.more_vert, color: AppStyle.textSmall(context)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: AppStyle.cardBg(context),
                          ),
                        ],
                      ),
                      if (journal['mode_description'] != null && journal['mode_description'].isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppStyle.bgTop(context).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            journal['mode_description'],
                            style: GoogleFonts.cairo(color: AppStyle.textMain(context).withOpacity(0.8), height: 1.5, fontSize: 14),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
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
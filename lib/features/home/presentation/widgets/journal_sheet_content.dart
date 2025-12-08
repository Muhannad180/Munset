import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:test1/core/theme/app_style.dart';

class JournalSheetContent extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? existingJournal;
  final List<Map<String, String>> moods;
  final Function(String mood, String moodName, String desc, String adviceFeeling) onSave;
  final Function(String mood, String moodName, String desc) onUpdate;

  const JournalSheetContent({
    super.key,
    required this.isEdit,
    this.existingJournal,
    required this.moods,
    required this.onSave,
    required this.onUpdate,
  });

  @override
  State<JournalSheetContent> createState() => _JournalSheetContentState();
}

class _JournalSheetContentState extends State<JournalSheetContent> {
  late int selIndex;
  late TextEditingController detCtrl;
  late TextEditingController advCtrl;

  @override
  void initState() {
    super.initState();
    selIndex = 4;
    detCtrl = TextEditingController();
    advCtrl = TextEditingController();

    if (widget.isEdit && widget.existingJournal != null) {
      selIndex = widget.moods.indexWhere((m) => m['name'] == widget.existingJournal!['mode_name']);
      if (selIndex == -1) selIndex = 4;
      detCtrl.text = widget.existingJournal!['mode_description'] ?? '';
    }
  }

  @override
  void dispose() {
    detCtrl.dispose();
    advCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.isEdit ? "تعديل اليومية" : "كيف تشعر اليوم؟", style: AppStyle.heading(context).copyWith(fontSize: 22, color: AppStyle.primary), textAlign: TextAlign.center),
          const SizedBox(height: 25),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {ui.PointerDeviceKind.touch, ui.PointerDeviceKind.mouse}),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.moods.length, (i) {
                  bool isSelected = selIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => selIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppStyle.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? Border.all(color: AppStyle.primary, width: 2) : Border.all(color: Colors.transparent, width: 2),
                      ),
                      child: Column(children: [
                        Text(widget.moods[i]['emoji']!, style: TextStyle(fontSize: isSelected ? 38 : 30)),
                        const SizedBox(height: 8),
                        Text(widget.moods[i]['name']!, style: AppStyle.bodySmall(context).copyWith(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppStyle.primary : AppStyle.textSmall(context))),
                      ]),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: detCtrl, textAlign: TextAlign.right, maxLines: 3, 
            style: TextStyle(color: AppStyle.textMain(context)),
            decoration: InputDecoration(
              hintText: "ملاحظات...", 
              hintStyle: TextStyle(color: AppStyle.textSmall(context)),
              filled: true, 
              fillColor: AppStyle.isDark(context) ? Colors.grey[800] : Colors.grey[50], 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
            )
          ),
          if (!widget.isEdit) ...[
            const SizedBox(height: 15),
            TextField(
              controller: advCtrl, textAlign: TextAlign.right, maxLines: 2, 
              style: TextStyle(color: AppStyle.textMain(context)),
              decoration: InputDecoration(
                hintText: "صف شعورك للنصيحة...", 
                hintStyle: TextStyle(color: AppStyle.textSmall(context)),
                filled: true, 
                fillColor: AppStyle.isDark(context) ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50], 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
              )
            ),
          ],
          const SizedBox(height: 25),
          Container(
            decoration: BoxDecoration(gradient: AppStyle.buttonGradient, borderRadius: BorderRadius.circular(30)),
            child: ElevatedButton(
              onPressed: () {
                if (widget.isEdit) {
                  widget.onUpdate(widget.moods[selIndex]['emoji']!, widget.moods[selIndex]['name']!, detCtrl.text);
                } else {
                  widget.onSave(widget.moods[selIndex]['emoji']!, widget.moods[selIndex]['name']!, detCtrl.text, advCtrl.text);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: Text(widget.isEdit ? "تحديث" : "حفظ", style: AppStyle.buttonText),
            ),
          )
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/core/theme/app_style.dart';
import 'dart:ui' as ui;

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String selectedFrequency = "يومي";
  IconData selectedIcon = Icons.star;
  String? selectedCommonHabit;

  final List<String> commonHabits = [
    "شرب ماء", "رياضة", "قراءة", "تأمل", "نوم مبكر", "تعلم مهارة", 
    "مشي يومي", "أكل صحي", "كتابة مذكرات", "الأذكار"
  ];

  final Map<String, String> habitDescriptions = {
    "شرب ماء": "اشرب 6-8 أكواب ماء يوميًا لتحسين صحتك.",
    "رياضة": "مارس الرياضة 20-30 دقيقة يوميًا.",
    "قراءة": "اقرأ 10 صفحات يوميًا.",
    "تأمل": "5 دقائق لتصفية ذهنك.",
    "نوم مبكر": "نم قبل 12 لراحة أفضل.",
    "تعلم مهارة": "تعلم 15 دقيقة من مهارة جديدة.",
    "مشي يومي": "امشِ 3000–8000 خطوة.",
    "أكل صحي": "تناول وجبات متوازنة.",
    "كتابة مذكرات": "اكتب ما حدث اليوم.",
    "الأذكار": "اذكر الله صباحًا ومساءً.",
  };

  final List<IconData> iconsList = [
    Icons.water_drop, Icons.local_drink, Icons.sports_gymnastics, Icons.fitness_center,
    Icons.directions_run, Icons.self_improvement, Icons.book, Icons.menu_book,
    Icons.computer, Icons.code, Icons.school, Icons.edit, Icons.cleaning_services,
    Icons.bedtime, Icons.wb_sunny, Icons.nightlight_round, Icons.family_restroom,
    Icons.favorite, Icons.star, Icons.check_circle, Icons.task_alt, Icons.timelapse,
    Icons.alarm, Icons.health_and_safety, Icons.spa, Icons.face, Icons.person,
    Icons.air, Icons.handshake, Icons.volunteer_activism, Icons.mosque, Icons.run_circle,
    Icons.directions_walk, Icons.fastfood, Icons.local_cafe, Icons.energy_savings_leaf,
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        appBar: AppBar(
          title: Text(
            "إضافة عادة جديدة",
            style: GoogleFonts.cairo(
              color: AppStyle.textMain(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppStyle.textMain(context)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              "اقتراحات سريعة",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppStyle.textMain(context),
              ),
            ),
            const SizedBox(height: 12),
            buildHabitChips(),

            const SizedBox(height: 25),
            _buildSectionLabel("تفاصيل العادة"),
            const SizedBox(height: 10),
            buildTitleField(),
            const SizedBox(height: 12),
            buildDescriptionField(),

            const SizedBox(height: 25),
            _buildSectionLabel("التكرار"),
            const SizedBox(height: 10),
            buildFrequencyRow(),

            const SizedBox(height: 25),
            _buildSectionLabel("أيقونة"),
            const SizedBox(height: 10),
            buildIconsGrid(),

            const SizedBox(height: 40),
            buildSaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppStyle.textMain(context),
      ),
    );
  }

  Widget buildHabitChips() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: commonHabits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final habit = commonHabits[index];
          bool isSelected = selectedCommonHabit == habit;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCommonHabit = habit;
                _titleController.text = habit;
                _descController.text = habitDescriptions[habit] ?? "";
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppStyle.primary : AppStyle.cardBg(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected 
                  ? [BoxShadow(color: AppStyle.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] 
                  : [],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Text(
                  habit,
                  style: GoogleFonts.cairo(
                    color: isSelected ? Colors.white : AppStyle.textMain(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _titleController,
        style: GoogleFonts.cairo(color: AppStyle.textMain(context)),
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: "اسم العادة (مثلاً: قراءة)",
          hintStyle: GoogleFonts.cairo(color: AppStyle.textSmall(context)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _descController,
        style: GoogleFonts.cairo(color: AppStyle.textMain(context)),
        textAlign: TextAlign.right,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "وصف بسيط...",
          hintStyle: GoogleFonts.cairo(color: AppStyle.textSmall(context)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget buildFrequencyRow() {
    const options = ["يومي", "أسبوعي", "شهري"];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: options.map((opt) {
          bool isSelected = selectedFrequency == opt;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedFrequency = opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppStyle.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: GoogleFonts.cairo(
                    color: isSelected ? Colors.white : AppStyle.textMain(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildIconsGrid() {
    return Container(
      height: 200, // Fixed height for grid
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: iconsList.length,
        itemBuilder: (context, index) {
          final icon = iconsList[index];
          bool isSelected = selectedIcon == icon;
          return GestureDetector(
            onTap: () => setState(() => selectedIcon = icon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? AppStyle.primary.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppStyle.primary : Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppStyle.primary : AppStyle.textMain(context),
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyle.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: AppStyle.primary.withOpacity(0.4),
        ),
        child: Text(
          "حفظ العادة",
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء كتابة اسم العادة")),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يوجد مستخدم مسجل")),
      );
      return;
    }

    try {
      final response = await supabase.from('habits').insert({
        "user_id": user.id,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "icon_name": selectedIcon.codePoint.toString(),
        "completion_count": 0,
        "created_at": DateTime.now().toIso8601String(),
      }).select();

      if (!mounted) return;
      Navigator.pop(context, response.first);
    } catch (e) {
      debugPrint("Error saving habit: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }
}


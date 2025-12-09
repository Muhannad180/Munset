import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test1/core/theme/app_style.dart';
import 'dart:ui' as ui;

class AddHabitPage extends StatefulWidget {
  final Map<String, dynamic>? habit;
  const AddHabitPage({super.key, this.habit});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _weeklyTargetController = TextEditingController();

  String selectedPriority = "متوسط"; // low, medium, high
  String selectedFrequency = "يومي"; // daily, weekly, monthly
  int goalTarget = 7; 
  String goalUnit = "week";
  int selectedColor = 0xFF4DB6AC; 
  IconData selectedIcon = Icons.star;
  String? selectedCommonHabit;

  final List<String> commonHabits = [
    "قراءة", "رياضة", "شرب الماء", "تأمل", "نوم مبكر", "فطور صحي",
  ];

  final Map<String, String> habitDescriptions = {
    "قراءة": "قراءة 10 صفحات يومياً",
    "رياضة": "ممارسة تمارين لمدة 30 دقيقة",
    "شرب الماء": "شرب 8 أكواب ماء",
    "تأمل": "جلسة تأمل لمدة 10 دقائق",
    "نوم مبكر": "النوم قبل الساعة 11 مساءً",
    "فطور صحي": "تناول وجبة إفطار متكاملة",
  };

  final List<IconData> iconsList = [
    Icons.book, Icons.fitness_center, Icons.local_drink, Icons.self_improvement,
    Icons.bed, Icons.restaurant, Icons.work, Icons.school, Icons.code,
    Icons.brush, Icons.music_note, Icons.camera_alt, Icons.directions_bike,
    Icons.directions_run, Icons.pool, Icons.spa, Icons.wb_sunny,
    Icons.nightlight_round, Icons.star, Icons.favorite,
  ];

  final List<Color> colorOptions = [
    const Color(0xFF4DB6AC), const Color(0xFFEF5350), const Color(0xFFFFA726),
    const Color(0xFF42A5F5), const Color(0xFFAB47BC), const Color(0xFF8D6E63),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      final h = widget.habit!;
      _titleController.text = h['title'] ?? '';
      _descController.text = h['description'] ?? '';
      
      selectedPriority = h['priority'] ?? "متوسط";
      selectedFrequency = h['frequency'] ?? "يومي";
      goalTarget = h['goal_target'] ?? 7;
      if (h['color'] != null) selectedColor = h['color'];
      
      // Icon Parsing
      final iconVal = h['icon_name'];
      if (iconVal != null) {
         int? codePoint = int.tryParse(iconVal.toString());
         if (codePoint != null) {
            selectedIcon = IconData(codePoint, fontFamily: 'MaterialIcons');
         }
      }
      
      if (selectedFrequency == 'أسبوعي') {
         _weeklyTargetController.text = goalTarget.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.habit != null;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgTop(context),
        appBar: AppBar(
          title: Text(
            isEditing ? "تعديل العادة" : "إضافة عادة جديدة",
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
            if (!isEditing) ...[
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
            ],

            _buildSectionLabel("تفاصيل العادة"),
            const SizedBox(height: 10),
            buildTitleField(),
            const SizedBox(height: 12),
            buildDescriptionField(),

            const SizedBox(height: 25),
            _buildSectionLabel("التكرار"),
            const SizedBox(height: 10),
            buildFrequencyRow(),
            
            // Conditional Weekly Target Input
            if (selectedFrequency == "أسبوعي") ...[
                const SizedBox(height: 15),
                Container(
                   decoration: BoxDecoration(
                     color: AppStyle.cardBg(context),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: TextField(
                     controller: _weeklyTargetController,
                     keyboardType: TextInputType.number,
                     style: GoogleFonts.cairo(color: AppStyle.textMain(context)),
                     decoration: InputDecoration(
                       labelText: "عدد المرات في الأسبوع",
                       labelStyle: GoogleFonts.cairo(color: AppStyle.textSmall(context)),
                       hintText: "مثلاً: 3",
                       border: InputBorder.none,
                       prefixIcon: const Icon(Icons.repeat, color: Colors.grey),
                       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                     ),
                     onChanged: (val) {
                        goalTarget = int.tryParse(val) ?? 1;
                     },
                   ),
                ),
            ],

            const SizedBox(height: 25),




            const SizedBox(height: 25),
            _buildSectionLabel("أيقونة"),
            const SizedBox(height: 10),
            buildIconsGrid(),

            const SizedBox(height: 40),
            buildSaveButton(isEditing),
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

  // ... (Other widgets like buildHabitChips, buildTitleField etc. can be copied or kept if using replacing strategy)
  // I will assume I am replacing the FULL FILE CONTENT so I need to provide full implementations.
  
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
              onTap: () {
                 setState(() {
                   selectedFrequency = opt;
                   // Reset goal target based on selection default
                   if (opt == "يومي") goalTarget = 7;
                   else if (opt == "أسبوعي") goalTarget = (int.tryParse(_weeklyTargetController.text) ?? 3); // Default 3 if switching
                   else if (opt == "شهري") goalTarget = 1;
                 });
              },
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
      height: 200, 
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

  Widget buildSaveButton(bool isEditing) {
    return Column(
      children: [
        SizedBox(
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
              isEditing ? "حفظ التعديلات" : "حفظ العادة",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (isEditing) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _deleteHabit,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(
                "حذف العادة",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.withOpacity(0.2)),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("حذف العادة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text("هل أنت متأكد من حذف هذه العادة؟", style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("إلغاء", style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text("حذف", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabase = Supabase.instance.client;
      final id = widget.habit!['original_id'] ?? widget.habit!['id'];
      
      // Handle potention "habit_" prefix if passed from home
      String realId = id.toString();
      if (realId.startsWith('habit_')) {
        realId = realId.replaceAll('habit_', '');
      }

      await supabase.from('habits').delete().eq('id', realId);
      
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to refresh
    } catch (e) {
      debugPrint("Error deleting habit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في الحذف: $e")),
      );
    }
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
    if (user == null) return;

    // Final logic for goal
    if (selectedFrequency == 'يومي') goalTarget = 7;
    else if (selectedFrequency == 'شهري') goalTarget = 1;

    try {
      final Map<String, dynamic> data = {
        "user_id": user.id,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "icon_name": selectedIcon.codePoint.toString(),
        // "color": selectedColor, // Column missing or not used
        // "priority": selectedPriority, // Removed from UI
        "frequency": selectedFrequency,
        // "goal_target": goalTarget, // Column missing in DB
        // "updated_at": DateTime.now().toIso8601String(), // Column missing in DB
      };

      if (widget.habit != null) {
          // Update
          final id = widget.habit!['original_id'] ?? widget.habit!['id'];
          // Handle potention "habit_" prefix if passed from home or elsewhere
          String realId = id.toString();
          if (realId.startsWith('habit_')) {
             realId = realId.replaceAll('habit_', '');
          }

          await supabase.from('habits').update(data).eq('id', realId);
          if (!mounted) return;
          Navigator.pop(context, true); // Return true to signal refresh needed
      } else {
          // Insert
          data["completion_count"] = 0;
          data["created_at"] = DateTime.now().toIso8601String();
          await supabase.from('habits').insert(data);
          if (!mounted) return;
          Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error saving habit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }
}

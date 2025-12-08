import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final Color primaryColor = const Color(0xFF5E9E92);

  final List<String> commonHabits = [
    "شرب ماء",
    "رياضة",
    "قراءة",
    "تأمل",
    "نوم مبكر",
    "تنظيم الوقت",
    "تعلم مهارة",
    "مشي يومي",
    "أكل صحي",
    "كتابة مذكرات",
    "شرب قهوة بدون سكر",
    "تقليل السكر",
    "تعلم لغة",
    "الصلاة في وقتها",
    "الأذكار",
    "الاستحمام البارد",
    "تنظيف الغرفة",
    "مراجعة الدراسة",
    "كتابة أهداف اليوم",
    "التقليل من الجوال",
    "عدم السهر",
    "شرب شاي أخضر",
    "ممارسة اليوغا",
    "التواصل مع العائلة",
    "عمل خير/صدقة",
    "الامتنان",
    "تعلم البرمجة",
    "مراجعة الكود",
    "الابتعاد عن السوشيال ميديا",
    "الإقلاع عن عادة سيئة",
    "ترتيب السرير",
    "تحضير وجبة صحية",
    "الخروج للمشي",
    "الابتعاد عن الكافيين",
    "شرب فيتامينات",
    "جلسة استرخاء",
    "مراجعة المصاريف",
    "تحديد أولويات اليوم",
    "أخرى",
  ];

  final Map<String, String> habitDescriptions = {
    "شرب ماء": "اشرب 6-8 أكواب ماء يوميًا لتحسين صحتك.",
    "رياضة": "مارس الرياضة 20-30 دقيقة يوميًا.",
    "قراءة": "اقرأ 10 صفحات يوميًا.",
    "تأمل": "5 دقائق لتصفية ذهنك.",
    "نوم مبكر": "نم قبل 12 لراحة أفضل.",
    "تنظيم الوقت": "رتّب مهام اليوم وحدد أولوياتك.",
    "تعلم مهارة": "تعلم 15 دقيقة من مهارة جديدة.",
    "مشي يومي": "امشِ 3000–8000 خطوة.",
    "أكل صحي": "تناول وجبات متوازنة.",
    "كتابة مذكرات": "اكتب ما حدث اليوم.",
    "شرب قهوة بدون سكر": "قلّل السكر لتحسين صحتك.",
    "تقليل السكر": "قلل الحلويات.",
    "تعلم لغة": "تعلم كلمة جديدة يوميًا.",
    "الصلاة في وقتها": "حافظ على صلواتك.",
    "الأذكار": "اذكر الله صباحًا ومساءً.",
    "الاستحمام البارد": "استحم بماء بارد لتحسين نشاطك.",
    "تنظيف الغرفة": "رتّب غرفتك 5 دقائق.",
    "مراجعة الدراسة": "راجع 20 دقيقة.",
    "كتابة أهداف اليوم": "حدد 3 أهداف فقط.",
    "التقليل من الجوال": "استخدم الجوال أقل من ساعة.",
    "عدم السهر": "تجنب السهر.",
    "شرب شاي أخضر": "كوب يوميًا.",
    "ممارسة اليوغا": "10 دقائق يوميًا.",
    "التواصل مع العائلة": "تواصل يوميًا.",
    "عمل خير/صدقة": "قدّم صدقة بسيطة.",
    "الامتنان": "اكتب 3 أمور ممتن لها.",
    "تعلم البرمجة": "تعلم مفهوم برمجي جديد.",
    "مراجعة الكود": "حسن كود سابق.",
    "الابتعاد عن السوشيال ميديا": "قلل وقتها 50%.",
    "الإقلاع عن عادة سيئة": "خطوة صغيرة يوميًا.",
    "ترتيب السرير": "رتّب سريرك عند الاستيقاظ.",
    "تحضير وجبة صحية": "حضّر وجبة مفيدة.",
    "الخروج للمشي": "امش في الهواء الطلق.",
    "الابتعاد عن الكافيين": "تجنب الكافيين بعد 6 مساءً.",
    "شرب فيتامينات": "خذ مكملاتك.",
    "جلسة استرخاء": "تنفس 10 دقائق.",
    "مراجعة المصاريف": "راجع مصروفاتك.",
    "تحديد أولويات اليوم": "حدد أهم 3 مهام.",
  };

  final List<IconData> iconsList = [
    Icons.water_drop,
    Icons.local_drink,
    Icons.sports_gymnastics,
    Icons.fitness_center,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.book,
    Icons.menu_book,
    Icons.computer,
    Icons.code,
    Icons.school,
    Icons.edit,
    Icons.cleaning_services,
    Icons.bedtime,
    Icons.wb_sunny,
    Icons.nightlight_round,
    Icons.family_restroom,
    Icons.favorite,
    Icons.star,
    Icons.check_circle,
    Icons.task_alt,
    Icons.timelapse,
    Icons.alarm,
    Icons.health_and_safety,
    Icons.spa,
    Icons.face,
    Icons.person,
    Icons.air,
    Icons.handshake,
    Icons.volunteer_activism,
    Icons.mosque,
    Icons.run_circle,
    Icons.directions_walk,
    Icons.fastfood,
    Icons.local_cafe,
    Icons.energy_savings_leaf,
  ];

  @override
  Widget build(BuildContext context) {
    bool isOtherSelected = selectedCommonHabit == "أخرى";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "إضافة عادة جديدة",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "العادات الشائعة",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          buildHabitChips(),

          const SizedBox(height: 20),
          buildTitleField(),
          const SizedBox(height: 10),
          buildDescriptionField(),

          const SizedBox(height: 25),
          const Text(
            "عدد مرات التكرار",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          buildFrequencyRow(),

          const SizedBox(height: 25),
          const Text(
            "اختر أيقونة",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          buildIconsList(),

          const Spacer(),

          buildSaveButton(),
        ],
      ),
    );
  }

  Widget buildHabitChips() {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: commonHabits.map((habit) {
          bool isSelected = selectedCommonHabit == habit;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCommonHabit = habit;
                if (habit != "أخرى") {
                  _titleController.text = habit;
                  _descController.text = habitDescriptions[habit] ?? "";
                } else {
                  _titleController.clear();
                  _descController.clear();
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                habit,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTitleField() {
    return TextField(
      controller: _titleController,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: "اكتب اسم العادة",
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildDescriptionField() {
    return TextField(
      controller: _descController,
      textAlign: TextAlign.right,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "اكتب وصف العادة",
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildFrequencyRow() {
    return Row(
      children: [
        buildFrequencyOption("يومي"),
        const SizedBox(width: 10),
        buildFrequencyOption("أسبوعي"),
        const SizedBox(width: 10),
        buildFrequencyOption("شهري"),
      ],
    );
  }

  Widget buildFrequencyOption(String label) {
    bool isSelected = selectedFrequency == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrequency = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildIconsList() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: iconsList.map((icon) {
          bool isSelected = selectedIcon == icon;
          return GestureDetector(
            onTap: () => setState(() => selectedIcon = icon),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.3)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 28, color: Colors.black87),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "حفظ",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
      ),
    );
  }

  /// حفظ العادة في Supabase مع كل البيانات
  Future<void> _saveHabit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("الرجاء كتابة اسم العادة")));
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("لا يوجد مستخدم مسجل")));
      return;
    }

    final String iconName = selectedIcon.codePoint.toString();

    try {
      final response = await supabase.from('habits').insert({
        "user_id": user.id,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "icon_name": iconName,
        "completion_count": 0,
        "created_at": DateTime.now().toIso8601String(),
      }).select();

      if (!mounted) return;

      Navigator.pop(context, response.first);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ أثناء الحفظ: $e")));
    }
  }
}

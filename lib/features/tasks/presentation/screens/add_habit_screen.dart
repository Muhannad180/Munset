import 'package:flutter/material.dart';

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
    "أخرى",
  ];

  final List<IconData> iconsList = [
    Icons.water_drop,
    Icons.book,
    Icons.run_circle,
    Icons.self_improvement,
    Icons.sunny,
    Icons.nightlight_round,
    Icons.alarm,
    Icons.cleaning_services,
    Icons.favorite,
    Icons.star,
  ];

  @override
  Widget build(BuildContext context) {
    bool isOtherSelected = selectedCommonHabit == "أخرى";

    return Directionality(
      textDirection: TextDirection.rtl, // اجعل كل شيء من اليمين لليسار
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "إضافة عادة جديدة",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "العادات الشائعة",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
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
                          } else {
                            _titleController.clear();
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            habit,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
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
              ),
              const SizedBox(height: 10),
              if (isOtherSelected)
                TextField(
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
                ),
              const SizedBox(height: 25),
              const Text(
                "عدد مرات التكرار",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  buildFrequencyOption("يومي"),
                  const SizedBox(width: 10),
                  buildFrequencyOption("أسبوعي"),
                  const SizedBox(width: 10),
                  buildFrequencyOption("شهري"),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "اختر أيقونة",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  children: iconsList.map((icon) {
                    bool isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIcon = icon);
                      },
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
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(icon, size: 28, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Spacer(),
              SizedBox(
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
              ),
            ],
          ),
        ),
      ),
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

  void _saveHabit() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("الرجاء كتابة اسم العادة")));
      return;
    }

    String habitName = _titleController.text.trim();
    String habitDesc = _descController.text.trim();
    String frequency = selectedFrequency;

    print("العادة: $habitName");
    print("الوصف: $habitDesc");
    print("التكرار: $frequency");
    print("الأيقونة: $selectedIcon");

    Navigator.pop(context, {
      "name": habitName,
      "description": habitDesc,
      "freq": frequency,
      "icon": selectedIcon.codePoint,
    });
  }
}

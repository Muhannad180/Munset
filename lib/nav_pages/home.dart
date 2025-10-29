import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  String _locale = 'en'; // Default locale

  @override
  void initState() {
    super.initState();
    _setLocale();
  }

  void _setLocale() async {
    try {
      _locale = Platform.localeName;
      await initializeDateFormatting(_locale, null);
    } catch (e) {
      _locale = 'ar'; // Fallback to Arabic if localeName is not supported
      await initializeDateFormatting(_locale, null);
    }
    setState(() {});
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var currentMonth = DateFormat.MMMM(_locale).format(_selectedDate);
    var daysInWeek = _getDaysInWeek(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Calendar Widget
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month - 1,
                                1,
                              );
                            });
                          },
                          child: Icon(Icons.arrow_back_ios, size: 16),
                        ),
                        Text(
                          currentMonth,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month + 1,
                                1,
                              );
                            });
                          },
                          child: Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Days of week
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDayColumn(daysInWeek[0], now),
                        _buildDayColumn(daysInWeek[1], now),
                        _buildDayColumn(daysInWeek[2], now),
                        _buildDayColumn(daysInWeek[3], now),
                        _buildDayColumn(daysInWeek[4], now),
                        _buildDayColumn(daysInWeek[5], now),
                        _buildDayColumn(daysInWeek[6], now),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Good Evening Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'سيئ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Text(
                                'حذف',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'تعديل',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'شعرت بـ: خيبة أمل، ارتباك\nبسبب: العمل',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Connect with Neighbors Section
              Container(
                width: 400,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تواصل مع الطبيعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اقضِ وقتًا ممتعًا في الهواء الطلق، محاطًا بالخضرة والهواء النقي.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'اقرا المزيد',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Prayer Times Section
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            'عظيم! لقد اقتربت من انجاز جميع مهامك.',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Spacer(),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '50%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Habits Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العادات المستهدفة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildHabitItem('الذهاب إلى النادي', 1),
                    _buildHabitItem('النوم المبكر', 1),
                    _buildHabitItem('المذاكرة', 1),
                    _buildHabitItem('تعلم البرمجة', 1),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime date, DateTime today) {
    var isSelectedDay =
        date.day == _selectedDate.day &&
        date.month == _selectedDate.month &&
        date.year == _selectedDate.year;

    var isToday =
        date.day == today.day &&
        date.month == today.month &&
        date.year == today.year;

    // Dynamically get the Arabic day name from the date object
    var dayName = DateFormat.E(_locale).format(date);

    return GestureDetector(
      onTap: () {
        _onDaySelected(date);
      },
      child: Column(
        children: [
          Text(
            dayName,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelectedDay
                  ? Colors.blue
                  : (isToday ? Colors.grey[300] : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                DateFormat.d(_locale).format(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelectedDay ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(String title, int count) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    List<DateTime> days = [];
    var startOfWeek = _getStartOfWeek(date);
    for (int i = 0; i < 7; i++) {
      days.add(startOfWeek.add(Duration(days: i)));
    }
    return days;
  }

  DateTime _getStartOfWeek(DateTime date) {
    var day = date.weekday;
    var daysToSubtract = (day + 6) % 7;
    return date.subtract(Duration(days: daysToSubtract));
  }
}

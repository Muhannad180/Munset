import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test1/core/theme/app_style.dart';

class CalendarCard extends StatelessWidget {
  final DateTime selectedDate;
  final String locale;
  final Function(DateTime) onDateSelected;

  const CalendarCard({
    super.key,
    required this.selectedDate,
    required this.locale,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    var currentMonth = DateFormat.MMMM(locale).format(selectedDate);
    var daysInWeek = _getDaysInWeek(selectedDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyle.cardBg(context).withOpacity(0.9), 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: AppStyle.cardShadow(context)
      ),
      child: Column(
        children: [
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: Icon(Icons.chevron_left_rounded, color: AppStyle.textMain(context)), onPressed: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1, 1))),
            Text(currentMonth, style: AppStyle.cardTitle(context)),
            IconButton(icon: Icon(Icons.chevron_right_rounded, color: AppStyle.textMain(context)), onPressed: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1, 1))),
          ]),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: daysInWeek.map((d) => _dayItem(context, d)).toList())
        ],
      ),
    );
  }

  Widget _dayItem(BuildContext context, DateTime date) {
    bool isSelected = date.day == selectedDate.day;
    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
             Text(DateFormat.E(locale).format(date), style: AppStyle.bodySmall(context).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
             const SizedBox(height: 8),
             Container(
               width: 36, height: 36,
               decoration: BoxDecoration(
                 color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent, // Cyan for selection
                 shape: BoxShape.circle,
                 boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
               ),
               child: Center(child: Text(DateFormat.d(locale).format(date), style: TextStyle(color: isSelected ? Colors.white : AppStyle.textMain(context), fontWeight: FontWeight.bold))),
             )
          ],
        ),
      ),
    );
  }

  List<DateTime> _getDaysInWeek(DateTime date) {
    var start = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}

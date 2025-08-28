import 'package:flutter/material.dart';
import 'package:test1/style.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.answerText,
    required this.onTap,
  });

  final String answerText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 70),
      ),
      child: Text(
        answerText,
        textAlign: TextAlign.center,
        style: AppStyle.button.copyWith(color: Colors.black),
      ),
    );
  }
}

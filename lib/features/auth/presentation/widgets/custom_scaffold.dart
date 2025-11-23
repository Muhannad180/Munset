import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext constent) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/wallpaper.png',
            fit: BoxFit.cover, // cover behind app bar also
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(child: child!),
        ],
      ),
    );
  }
}

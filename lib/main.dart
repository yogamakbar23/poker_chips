import 'package:flutter/material.dart';
import 'package:poker_chips/pages/setup.dart';

void main() {
  runApp(const PokerApp());
}

class PokerApp extends StatelessWidget {
  const PokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poker Chips',
      theme: ThemeData(colorSchemeSeed: Colors.white, useMaterial3: true),
      home: const SetupPage(),
    );
  }
}

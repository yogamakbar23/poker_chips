import 'package:flutter/material.dart';

class GameWinnerDialog extends StatelessWidget {
  final String winnerName;
  final VoidCallback onOk;

  const GameWinnerDialog({
    super.key,
    required this.winnerName,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Game Selesai",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        "$winnerName memenangkan permainan!",
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onOk();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/player.dart';

class WinnerDialog extends StatefulWidget {
  final List<Player> players;

  const WinnerDialog({super.key, required this.players});

  @override
  State<WinnerDialog> createState() => _WinnerDialogState();
}

class _WinnerDialogState extends State<WinnerDialog> {
  final Set<int> selected = {};

  @override
  Widget build(BuildContext context) {
    final activePlayers = widget.players
        .asMap()
        .entries
        .where((entry) => !entry.value.folded)
        .toList();
    return AlertDialog(
      title: const Text("Pilih Pemenang"),
      content: SizedBox(
        width: 350,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: activePlayers.length,
          itemBuilder: (context, index) {
            final entry = activePlayers[index];

            final originalIndex = entry.key;
            final player = entry.value;

            return CheckboxListTile(
              title: Text(player.name),
              subtitle: Text("${player.chips} Chips"),
              value: selected.contains(originalIndex),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selected.add(originalIndex);
                  } else {
                    selected.remove(originalIndex);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        FilledButton(
          onPressed: selected.isEmpty
              ? null
              : () {
                  Navigator.pop(context, selected.toList());
                },
          child: const Text("Selesai"),
        ),
      ],
    );
  }
}

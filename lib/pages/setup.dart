import 'package:flutter/material.dart';
import 'package:poker_chips/pages/poker.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int playerCount = 4;

  final List<int> chipOptions = [500, 1000, 2000, 5000, 10000];

  int startingChips = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.casino, size: 80, color: Colors.lightBlue),

                const SizedBox(height: 12),

                const Text(
                  "POKER CHIPS",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Jumlah Player",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (playerCount > 2) {
                          setState(() => playerCount--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle, size: 40),
                    ),

                    Text(
                      "$playerCount Player",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        if (playerCount < 8) {
                          setState(() => playerCount++);
                        }
                      },
                      icon: const Icon(Icons.add_circle, size: 40),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // DropdownButtonFormField<int>(
                //   initialValue: startingChips,
                //   decoration: const InputDecoration(
                //     labelText: "Starting Chips",
                //     border: OutlineInputBorder(),
                //   ),
                //   items: chipOptions.map((chip) {
                //     return DropdownMenuItem(
                //       value: chip,
                //       child: Text("$chip Chips"),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       startingChips = value!;
                //     });
                //   },
                // ),
                TextFormField(
                  initialValue: startingChips.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Starting Chips",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      startingChips = int.tryParse(value) ?? startingChips;
                    });
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PokerPage(
                            playerCount: playerCount,
                            startingChips: startingChips,
                          ),
                        ),
                      );
                    },
                    child: const Text("START GAME"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

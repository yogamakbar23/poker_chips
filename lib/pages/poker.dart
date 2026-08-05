import 'package:flutter/material.dart';
import 'package:poker_chips/models/player.dart';
import 'package:poker_chips/widgets/game_winner_dialog.dart';
import 'package:poker_chips/widgets/select_winner_dialog.dart';

class PokerPage extends StatefulWidget {
  final int playerCount;
  final int startingChips;

  const PokerPage({
    super.key,
    required this.playerCount,
    required this.startingChips,
  });

  @override
  State<PokerPage> createState() => _PokerPageState();
}

class _PokerPageState extends State<PokerPage> {
  late List<int> chips;
  int dealerIndex = 0;
  int pot = 0;
  int currentPlayer = 0;
  final TextEditingController callController = TextEditingController();
  int get highestBet {
    return players.map((player) => player.bet).reduce((a, b) => a > b ? a : b);
  }

  late List<Player> players;

  @override
  void initState() {
    super.initState();

    players = List.generate(
      widget.playerCount,
      (index) =>
          Player(name: "Player ${index + 1}", chips: widget.startingChips),
    );
  }

  void nextPlayer() {
    int next = currentPlayer;

    do {
      next = (next + 1) % players.length;
    } while (players[next].folded || players[next].eliminated);

    setState(() {
      currentPlayer = next;
    });
  }

  void nextRound() {
    setState(() {
      for (final player in players) {
        player.bet = 0;
        if (!player.eliminated) {
          player.folded = false;
          player.checked = false;
        }
      }

      dealerIndex = (dealerIndex + 1) % players.length;

      while (players[dealerIndex].eliminated) {
        dealerIndex = (dealerIndex + 1) % players.length;
      }

      currentPlayer = dealerIndex;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Next Round"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  bool isCheckRoundFinished() {
    final activePlayers = players.where((p) => !p.folded).toList();

    return activePlayers.every((p) => p.checked);
  }

  bool isRoundFinished() {
    final activePlayers = players.where((player) => !player.folded).toList();

    if (activePlayers.isEmpty) return false;

    final targetBet = activePlayers.first.bet;

    return activePlayers.every((player) => player.bet == targetBet);
  }

  bool isZeroBetRound() {
    return players.every((player) => player.bet == 0);
  }

  bool get hasAllInPlayer {
    return players.any((player) => player.chips == 0 && !player.folded);
  }

  int get maxRaiseBet {
    final current = players[currentPlayer];

    int limit = current.bet + current.chips;

    for (final player in players) {
      if (player == current || player.folded) continue;

      final maxBet = player.bet + player.chips;

      if (maxBet < limit) {
        limit = maxBet;
      }
    }

    return limit;
  }

  void callRaise() {
    final targetBet = int.tryParse(callController.text);

    if (targetBet == null || targetBet <= 0) {
      return;
    }

    final player = players[currentPlayer];

    // Nilai sama dengan bet saat ini, tidak ada perubahan
    if (targetBet == player.bet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Masukkan nilai yang lebih besar dari bet Anda saat ini.",
          ),
        ),
      );
      return;
    }

    if (targetBet < highestBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bet harus minimal sama dengan bet tertinggi."),
        ),
      );
      return;
    }

    if (targetBet > maxRaiseBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Bet maksimal $maxRaiseBet chips karena ada pemain yang tidak memiliki chip mencukupi.",
          ),
        ),
      );
      return;
    }

    final needChip = targetBet - player.bet;

    if (needChip > player.chips) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Chip tidak mencukupi.")));
      return;
    }

    setState(() {
      player.chips -= needChip;
      player.bet = targetBet;
      pot += needChip;

      // Raise atau Call baru membatalkan semua status Check
      for (final p in players) {
        p.checked = false;
      }
    });

    callController.clear();

    // Belum memilih pemenang, lanjut ke pemain berikutnya
    nextPlayer();
  }

  void check() {
    final player = players[currentPlayer];

    if (player.bet != highestBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tidak bisa Check, lakukan Call atau Raise terlebih dahulu.",
          ),
        ),
      );
      return;
    }

    setState(() {
      player.checked = true;
    });

    if (isRoundFinished() && isCheckRoundFinished()) {
      if (isZeroBetRound()) {
        nextRound();
      } else {
        selectWinner();
      }
    } else {
      nextPlayer();
    }
  }

  void fold() {
    setState(() {
      players[currentPlayer].folded = true;
    });

    if (!checkLastPlayerStanding()) {
      nextPlayer();
    }
  }

  void startNextRound() {
    for (final player in players) {
      player.bet = 0;
      if (!player.eliminated) {
        player.folded = false;
        player.checked = false;
      }
    }

    dealerIndex = (dealerIndex + 1) % players.length;

    while (players[dealerIndex].eliminated) {
      dealerIndex = (dealerIndex + 1) % players.length;
    }

    currentPlayer = dealerIndex;
  }

  void distributePot(List<int> winners) {
    final share = pot ~/ winners.length;
    final remainder = pot % winners.length;

    setState(() {
      for (final index in winners) {
        players[index].chips += share;
      }

      if (remainder > 0) {
        players[winners.first].chips += remainder;
      }

      pot = 0;
      checkElimination();
      checkGameWinner();
      startNextRound();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          winners.length == 1
              ? "${players[winners.first].name} memenangkan pot."
              : "${winners.length} pemain berbagi pot.",
        ),
      ),
    );
  }

  Future<void> selectWinner() async {
    final winners = await showDialog<List<int>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WinnerDialog(players: players),
    );

    if (winners == null || winners.isEmpty) return;

    distributePot(winners);
  }

  void checkElimination() {
    for (final player in players) {
      if (player.chips <= 0) {
        player.chips = 0;
        player.eliminated = true;
        player.folded = true;
        player.checked = false;
        player.bet = 0;
      }
    }
  }

  bool checkLastPlayerStanding() {
    final activePlayers = players
        .asMap()
        .entries
        .where((entry) => !entry.value.folded)
        .toList();

    if (activePlayers.length != 1) {
      return false;
    }

    final winnerIndex = activePlayers.first.key;

    setState(() {
      players[winnerIndex].chips += pot;
      pot = 0;
      checkElimination();
      checkGameWinner();
      startNextRound();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${players[winnerIndex].name} menang karena semua pemain lain Fold.",
        ),
      ),
    );

    return true;
  }

  void checkGameWinner() {
    final remainingPlayers = players.where((p) => !p.eliminated).toList();

    if (remainingPlayers.length != 1) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameWinnerDialog(
        winnerName: remainingPlayers.first.name,
        onOk: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Poker Table")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];

                    return Card(
                      color: player.eliminated
                          ? Colors.redAccent
                          : index == currentPlayer
                          ? Colors.cyanAccent
                          : Colors.white,
                      child: ListTile(
                        title: Row(
                          children: [
                            if (index == dealerIndex)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.workspace_premium,
                                  color: Colors.amberAccent,
                                ),
                              ),

                            Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            if (player.eliminated)
                              Text(
                                " - Eliminated",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          player.eliminated
                              ? "${player.chips} Chips    ${player.bet} Bet"
                              : player.folded
                              ? "${player.chips} Chips    ${player.bet} Bet    (Folded)"
                              : player.checked
                              ? "${player.chips} Chips    ${player.bet} Bet    (Checked)"
                              : "${player.chips} Chips    ${player.bet} Bet",
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: check,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Check"),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: TextField(
                        controller: callController,
                        decoration: const InputDecoration(
                          labelText: "Bet Amount",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        callRaise();
                      },
                      child: const Text("Call/Raise"),
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: fold,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Fold"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

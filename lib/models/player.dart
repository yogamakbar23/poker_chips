class Player {
  String name;
  int chips;
  int bet;
  bool folded;
  bool checked;
  bool eliminated;

  Player({
    required this.name,
    required this.chips,
    this.bet = 0,
    this.folded = false,
    this.checked = false,
    this.eliminated = false,
  });
}

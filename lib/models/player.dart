class Player {
  final String id;
  final String symbol;

  Player({
    required this.id,
    required this.symbol,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
    };
  }
}

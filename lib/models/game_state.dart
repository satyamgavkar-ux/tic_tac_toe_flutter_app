class GameState {
  final List<String> board;
  final String currentTurn;
  final String? winner;
  final String status; // 'waiting', 'playing', 'game_over'
  final String roomId;

  GameState({
    required this.board,
    required this.currentTurn,
    this.winner,
    required this.status,
    required this.roomId,
  });

  factory GameState.initial({String roomId = ''}) {
    return GameState(
      board: List<String>.filled(9, ''),
      currentTurn: 'X',
      winner: null,
      status: 'waiting',
      roomId: roomId,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    List<String> boardList = [];
    if (json['board'] != null) {
      boardList = List<String>.from(
        (json['board'] as List).map((e) => e.toString()),
      );
    } else {
      boardList = List<String>.filled(9, '');
    }

    return GameState(
      board: boardList,
      currentTurn: json['currentTurn'] as String? ?? 'X',
      winner: json['winner'] as String?,
      status: json['status'] as String? ?? 'waiting',
      roomId: json['roomId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'currentTurn': currentTurn,
      'winner': winner,
      'status': status,
      'roomId': roomId,
    };
  }

  GameState copyWith({
    List<String>? board,
    String? currentTurn,
    String? winner,
    String? status,
    String? roomId,
  }) {
    return GameState(
      board: board ?? List<String>.from(this.board),
      currentTurn: currentTurn ?? this.currentTurn,
      winner: winner ?? this.winner,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
    );
  }
}

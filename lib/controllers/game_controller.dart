import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../services/socket_service.dart';

class GameController extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  GameState _gameState = GameState.initial();
  String? _playerSymbol; // "X" or "O"
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _opponentLeft = false;

  // Stream Subscriptions
  final List<StreamSubscription> _subscriptions = [];

  // Getters
  GameState get gameState => _gameState;
  List<String> get board => _gameState.board;
  String get currentTurn => _gameState.currentTurn;
  String? get winner => _gameState.winner;
  String get status => _gameState.status;
  String get roomId => _gameState.roomId;
  String? get playerSymbol => _playerSymbol;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get opponentLeft => _opponentLeft;
  SocketService get socketService => _socketService;

  bool get isMyTurn =>
      _playerSymbol != null &&
      _playerSymbol == _gameState.currentTurn &&
      _gameState.status == 'playing';

  GameController() {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _subscriptions.add(
      _socketService.onConnectionChange.listen((connected) {
        _isConnected = connected;
        if (!connected) {
          _isLoading = false;
        }
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onGameCreated.listen((data) {
        _isLoading = false;
        final room = data['roomId'] as String? ?? '';
        final symbol = data['player'] as String? ?? 'X';
        _playerSymbol = symbol;
        _opponentLeft = false;
        _gameState = GameState(
          board: List<String>.filled(9, ''),
          currentTurn: 'X',
          winner: null,
          status: 'waiting',
          roomId: room,
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onGameStarted.listen((data) {
        _isLoading = false;
        final room = data['roomId'] as String? ?? _gameState.roomId;
        final assignedPlayer = data['player'] as String?;
        if (assignedPlayer != null) {
          _playerSymbol = assignedPlayer;
        }
        final turn = data['currentTurn'] as String? ?? 'X';
        List<String> boardList = List<String>.filled(9, '');
        if (data['board'] != null) {
          boardList = List<String>.from(
            (data['board'] as List).map((e) => e.toString()),
          );
        }

        _opponentLeft = false;
        _gameState = GameState(
          board: boardList,
          currentTurn: turn,
          winner: null,
          status: 'playing',
          roomId: room,
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onMoveMade.listen((data) {
        List<String> updatedBoard = _gameState.board;
        if (data['board'] != null) {
          updatedBoard = List<String>.from(
            (data['board'] as List).map((e) => e.toString()),
          );
        }
        final nextTurn = data['currentTurn'] as String? ?? _gameState.currentTurn;

        _gameState = _gameState.copyWith(
          board: updatedBoard,
          currentTurn: nextTurn,
          status: 'playing',
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onGameOver.listen((data) {
        List<String> updatedBoard = _gameState.board;
        if (data['board'] != null) {
          updatedBoard = List<String>.from(
            (data['board'] as List).map((e) => e.toString()),
          );
        }
        final winningPlayer = data['winner'] as String?;

        _gameState = _gameState.copyWith(
          board: updatedBoard,
          winner: winningPlayer,
          status: 'game_over',
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onGameRestarted.listen((data) {
        List<String> emptyBoard = List<String>.filled(9, '');
        if (data['board'] != null) {
          emptyBoard = List<String>.from(
            (data['board'] as List).map((e) => e.toString()),
          );
        }
        final turn = data['currentTurn'] as String? ?? 'X';

        _gameState = GameState(
          board: emptyBoard,
          currentTurn: turn,
          winner: null,
          status: 'playing',
          roomId: _gameState.roomId,
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onOpponentLeft.listen((_) {
        _opponentLeft = true;
        _gameState = _gameState.copyWith(status: 'game_over');
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _socketService.onError.listen((msg) {
        _isLoading = false;
        _errorMessage = msg;
        notifyListeners();
      }),
    );
  }

  void connectServer([String? customUrl]) {
    _errorMessage = null;
    _socketService.connect(customUrl);
  }

  void createGame() {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    if (!_socketService.isConnected) {
      connectServer();
      // Delay emit briefly to ensure socket connection completes if connecting first time
      Future.delayed(const Duration(milliseconds: 500), () {
        _socketService.createGame();
      });
    } else {
      _socketService.createGame();
    }
  }

  void joinGame(String roomCode) {
    if (roomCode.trim().isEmpty) {
      _errorMessage = 'Please enter a room code';
      notifyListeners();
      return;
    }
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    if (!_socketService.isConnected) {
      connectServer();
      Future.delayed(const Duration(milliseconds: 500), () {
        _socketService.joinGame(roomCode.trim().toUpperCase());
      });
    } else {
      _socketService.joinGame(roomCode.trim().toUpperCase());
    }
  }

  void makeMove(int index) {
    if (!isMyTurn) return;
    if (index < 0 || index >= 9) return;
    if (_gameState.board[index].isNotEmpty) return;

    _socketService.makeMove(_gameState.roomId, index);
  }

  void restartGame() {
    _socketService.restartGame(_gameState.roomId);
  }

  void leaveGame() {
    if (_gameState.roomId.isNotEmpty) {
      _socketService.leaveGame(_gameState.roomId);
    }
    resetState();
  }

  void resetState() {
    _gameState = GameState.initial();
    _playerSymbol = null;
    _isLoading = false;
    _errorMessage = null;
    _opponentLeft = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _socketService.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get socketId => _socket?.id;

  // Event Stream Controllers / Callback Handlers
  final _connectionController = StreamController<bool>.broadcast();
  final _gameCreatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _gameStartedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _moveMadeController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _gameOverController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _gameRestartedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _opponentLeftController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<bool> get onConnectionChange => _connectionController.stream;
  Stream<Map<String, dynamic>> get onGameCreated =>
      _gameCreatedController.stream;
  Stream<Map<String, dynamic>> get onPlayerJoined =>
      _playerJoinedController.stream;
  Stream<Map<String, dynamic>> get onGameStarted =>
      _gameStartedController.stream;
  Stream<Map<String, dynamic>> get onMoveMade => _moveMadeController.stream;
  Stream<Map<String, dynamic>> get onGameOver => _gameOverController.stream;
  Stream<Map<String, dynamic>> get onGameRestarted =>
      _gameRestartedController.stream;
  Stream<Map<String, dynamic>> get onOpponentLeft =>
      _opponentLeftController.stream;
  Stream<String> get onError => _errorController.stream;

  void connect([String? url]) {
    if (_socket != null && _socket!.connected) {
      if (kDebugMode) print('[Socket] Already connected');
      return;
    }

    final serverUrl = url ?? 'https://tic-tac-toe-server-ki0i.onrender.com';
    if (kDebugMode) print('[Socket] Connecting to $serverUrl...');

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .build(),
    );

    _registerListeners();
    _socket!.connect();
  }

  void _registerListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      if (kDebugMode) print('[Socket] Connected (ID: ${_socket?.id})');
      _connectionController.add(true);
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) print('[Socket] Disconnected');
      _connectionController.add(false);
    });

    _socket?.onConnectError((err) {
      _isConnected = false;
      if (kDebugMode) print('[Socket] Connection Error: $err');
      _connectionController.add(false);
      _errorController.add('Server unavailable or connection error');
    });

    _socket?.on('game_created', (data) {
      if (kDebugMode) {
        print(
          '[Socket] Room created: ${data['roomId']}, player: ${data['player']}',
        );
      }
      _gameCreatedController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('player_joined', (data) {
      if (kDebugMode) print('[Socket] Player joined: ${data['roomId']}');
      _playerJoinedController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('game_started', (data) {
      if (kDebugMode) {
        print(
          '[Socket] Game started in room: ${data['roomId']}, role: ${data['player']}',
        );
      }
      _gameStartedController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('move_made', (data) {
      if (kDebugMode) {
        print(
          '[Socket] Move received: index=${data['index']}, turn=${data['currentTurn']}',
        );
      }
      _moveMadeController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('game_over', (data) {
      if (kDebugMode) print('[Socket] Game over: winner=${data['winner']}');
      _gameOverController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('game_restarted', (data) {
      if (kDebugMode) print('[Socket] Game restarted');
      _gameRestartedController.add(Map<String, dynamic>.from(data));
    });

    _socket?.on('opponent_left', (data) {
      if (kDebugMode) print('[Socket] Opponent left game');
      _opponentLeftController.add(Map<String, dynamic>.from(data ?? {}));
    });

    _socket?.on('error', (data) {
      final msg = data is Map
          ? (data['message'] ?? 'An error occurred')
          : data.toString();
      if (kDebugMode) print('[Socket] Error received: $msg');
      _errorController.add(msg);
    });
  }

  void createGame() {
    if (kDebugMode) print('[Socket] Emitting create_game');
    _socket?.emit('create_game');
  }

  void joinGame(String roomId) {
    if (kDebugMode) print('[Socket] Emitting join_game with room $roomId');
    _socket?.emit('join_game', {'roomId': roomId});
  }

  void makeMove(String roomId, int index) {
    if (kDebugMode) print('[Socket] Move sent: index $index in room $roomId');
    _socket?.emit('make_move', {'roomId': roomId, 'index': index});
  }

  void restartGame(String roomId) {
    if (kDebugMode) print('[Socket] Emitting restart_game in room $roomId');
    _socket?.emit('restart_game', {'roomId': roomId});
  }

  void leaveGame(String roomId) {
    if (kDebugMode) print('[Socket] Emitting leave_game in room $roomId');
    _socket?.emit('leave_game', {'roomId': roomId});
  }

  void disconnect() {
    if (_socket != null) {
      if (kDebugMode) print('[Socket] Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  void dispose() {
    disconnect();
    _connectionController.close();
    _gameCreatedController.close();
    _playerJoinedController.close();
    _gameStartedController.close();
    _moveMadeController.close();
    _gameOverController.close();
    _gameRestartedController.close();
    _opponentLeftController.close();
    _errorController.close();
  }
}

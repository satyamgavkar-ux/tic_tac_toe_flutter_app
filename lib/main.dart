import 'package:flutter/material.dart';
import 'controllers/game_controller.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/waiting_screen.dart';
import 'screens/join_game_screen.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OnlineTicTacToeApp());
}

class OnlineTicTacToeApp extends StatefulWidget {
  const OnlineTicTacToeApp({super.key});

  @override
  State<OnlineTicTacToeApp> createState() => _OnlineTicTacToeAppState();
}

class _OnlineTicTacToeAppState extends State<OnlineTicTacToeApp> {
  late final GameController _gameController;

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    // Attempt auto-connecting to Socket server on app startup
    _gameController.connectServer();
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => HomeScreen(controller: _gameController),
        '/waiting': (context) => WaitingScreen(controller: _gameController),
        '/join': (context) => JoinGameScreen(controller: _gameController),
        '/game': (context) => GameScreen(controller: _gameController),
      },
    );
  }
}

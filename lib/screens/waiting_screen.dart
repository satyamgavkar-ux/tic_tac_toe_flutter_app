import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/game_controller.dart';

class WaitingScreen extends StatefulWidget {
  final GameController controller;

  const WaitingScreen({super.key, required this.controller});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkGameStarted);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkGameStarted);
    super.dispose();
  }

  void _checkGameStarted() {
    if (widget.controller.status == 'playing') {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Opponent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.controller.leaveGame();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final roomCode = widget.controller.roomId;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Icons.groups_rounded,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Game Created',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share this room code with your opponent',
                  style: TextStyle(color: colorScheme.outline),
                ),
                const SizedBox(height: 32),

                // Room Code Box with Copy Button
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ROOM CODE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          roomCode.isEmpty ? 'GENERATING...' : roomCode,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: roomCode.isEmpty
                              ? null
                              : () {
                                  Clipboard.setData(
                                    ClipboardData(text: roomCode),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Room code copied!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy Code'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Loading Spinner & Waiting Text
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Waiting for opponent to join...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      widget.controller.leaveGame();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel & Back to Home'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

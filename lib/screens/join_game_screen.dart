import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class JoinGameScreen extends StatefulWidget {
  final GameController controller;

  const JoinGameScreen({super.key, required this.controller});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkGameStarted);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkGameStarted);
    _codeController.dispose();
    super.dispose();
  }

  void _checkGameStarted() {
    if (widget.controller.status == 'playing') {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }

  void _handleJoin() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      widget.controller.joinGame(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Enter Game Code',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-character room code provided by your opponent.',
                  style: TextStyle(color: colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Text Input Field
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. ABC123',
                    hintStyle: TextStyle(
                      color: colorScheme.outlineVariant,
                      letterSpacing: 2,
                      fontSize: 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Error Message Display
                if (widget.controller.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.controller.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Join Game Button
                if (widget.controller.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _handleJoin,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Join Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

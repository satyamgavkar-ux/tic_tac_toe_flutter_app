import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/player_status.dart';

class GameScreen extends StatelessWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final winner = controller.winner;
            final isDraw = winner == 'draw';
            final isOpponentLeft = controller.opponentLeft;

            String title;
            String message;

            if (isOpponentLeft) {
              title = 'Opponent Left';
              message = 'Your opponent disconnected from the game.';
            } else if (isDraw) {
              title = "It's a Draw!";
              message = 'Well played both of you!';
            } else if (winner == controller.playerSymbol) {
              title = '🎉 You Won!';
              message = 'Congratulations on your victory!';
            } else {
              title = 'You Lost';
              message = 'Better luck next time!';
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                if (!isOpponentLeft) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.restartGame();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Play Again'),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.leaveGame();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.leaveGame();
        Navigator.popUntil(context, ModalRoute.withName('/'));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app_rounded),
              tooltip: 'Leave Game',
              onPressed: () {
                controller.leaveGame();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            // Auto open game over / opponent left dialog when status becomes game_over or opponent_left
            if (controller.status == 'game_over' || controller.opponentLeft) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (ModalRoute.of(context)?.isCurrent == true) {
                  _showGameOverDialog(context);
                }
              });
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    PlayerStatus(
                      playerSymbol: controller.playerSymbol ?? '?',
                      currentTurn: controller.currentTurn,
                      roomId: controller.roomId,
                      isMyTurn: controller.isMyTurn,
                    ),
                    const Spacer(),

                    // Game Board Grid
                    GameBoard(
                      board: controller.board,
                      isMyTurn: controller.isMyTurn,
                      onCellTap: (index) {
                        controller.makeMove(index);
                      },
                    ),

                    const Spacer(),

                    // Bottom info indicator
                    if (controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          controller.errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

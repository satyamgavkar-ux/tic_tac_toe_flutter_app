import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/player_status.dart';

class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isDialogShowing = false;

  void _showGameOverDialog(BuildContext context) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final winner = widget.controller.winner;
            final isDraw = winner == 'draw';
            final isOpponentLeft = widget.controller.opponentLeft;

            String title;
            String message;

            if (isOpponentLeft) {
              title = 'Opponent Left';
              message = 'Your opponent disconnected from the game.';
            } else if (isDraw) {
              title = "It's a Draw!";
              message = 'Well played both of you!';
            } else if (winner == widget.controller.playerSymbol) {
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
                      _isDialogShowing = false;
                      Navigator.pop(dialogContext);
                      widget.controller.restartGame();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Play Again'),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    _isDialogShowing = false;
                    Navigator.pop(dialogContext);
                    widget.controller.leaveGame();
                    Navigator.popUntil(context, ModalRoute.withName('/home'));
                  },
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _isDialogShowing = false;
        widget.controller.leaveGame();
        Navigator.popUntil(context, ModalRoute.withName('/home'));
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
                _isDialogShowing = false;
                widget.controller.leaveGame();
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            // Auto open game over / opponent left dialog when status becomes game_over or opponent_left
            if ((widget.controller.status == 'game_over' || widget.controller.opponentLeft) &&
                !_isDialogShowing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted &&
                    (widget.controller.status == 'game_over' || widget.controller.opponentLeft) &&
                    !_isDialogShowing) {
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
                      playerSymbol: widget.controller.playerSymbol ?? '?',
                      currentTurn: widget.controller.currentTurn,
                      roomId: widget.controller.roomId,
                      isMyTurn: widget.controller.isMyTurn,
                    ),
                    const Spacer(),

                    // Game Board Grid
                    GameBoard(
                      board: widget.controller.board,
                      isMyTurn: widget.controller.isMyTurn,
                      onCellTap: (index) {
                        widget.controller.makeMove(index);
                      },
                    ),

                    const Spacer(),

                    // Bottom info indicator
                    if (widget.controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          widget.controller.errorMessage!,
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

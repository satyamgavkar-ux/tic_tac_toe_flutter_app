import 'package:flutter/material.dart';
import 'game_cell.dart';

class GameBoard extends StatelessWidget {
  final List<String> board;
  final Function(int index) onCellTap;
  final bool isMyTurn;

  const GameBoard({
    super.key,
    required this.board,
    required this.onCellTap,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GameCell(
              symbol: board[index],
              enabled: isMyTurn,
              onTap: () => onCellTap(index),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PlayerStatus extends StatelessWidget {
  final String playerSymbol;
  final String currentTurn;
  final String roomId;
  final bool isMyTurn;

  const PlayerStatus({
    super.key,
    required this.playerSymbol,
    required this.currentTurn,
    required this.roomId,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Room ID Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Room Code: $roomId',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Player Symbol Banner
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You are Player ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: playerSymbol == 'X'
                        ? colorScheme.primary
                        : colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    playerSymbol,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Turn Status Pill
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: isMyTurn
                ? Colors.green.shade100
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isMyTurn ? Colors.green.shade600 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMyTurn ? Icons.play_arrow_rounded : Icons.hourglass_empty_rounded,
                size: 20,
                color: isMyTurn ? Colors.green.shade800 : colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                isMyTurn ? 'Your Turn' : "Opponent's Turn ($currentTurn)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isMyTurn ? Colors.green.shade900 : colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

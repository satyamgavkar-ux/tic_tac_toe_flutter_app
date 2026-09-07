import 'package:flutter/material.dart';

class GameCell extends StatelessWidget {
  final String symbol; // "", "X", or "O"
  final VoidCallback? onTap;
  final bool enabled;

  const GameCell({
    super.key,
    required this.symbol,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color symbolColor;
    if (symbol == 'X') {
      symbolColor = colorScheme.primary;
    } else if (symbol == 'O') {
      symbolColor = colorScheme.secondary;
    } else {
      symbolColor = Colors.transparent;
    }

    return Card(
      elevation: symbol.isNotEmpty ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: enabled && symbol.isEmpty
              ? colorScheme.outlineVariant
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: enabled && symbol.isEmpty ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              symbol,
              key: ValueKey(symbol),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: symbolColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

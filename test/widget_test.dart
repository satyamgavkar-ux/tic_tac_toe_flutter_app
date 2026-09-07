import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_onlinegame/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OnlineTicTacToeApp());
    expect(find.text('TIC TAC TOE'), findsOneWidget);
  });
}

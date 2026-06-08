import 'package:flutter_test/flutter_test.dart';

import 'package:origami_tour/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OrigamiTourApp());

    expect(find.text('Origami Tour'), findsOneWidget);
    expect(find.text('Fold. Learn. Master.'), findsOneWidget);
  });
}

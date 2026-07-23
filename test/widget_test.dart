import 'package:flutter_test/flutter_test.dart';
import 'package:qiankunyi_app/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const QiankunyiApp());
    expect(find.text('乾坤易'), findsOneWidget);
  });
}

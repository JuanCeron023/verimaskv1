import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/main.dart';
import 'package:verimask/screens/camera_screen.dart';

void main() {
  testWidgets('VeriMask app renders CameraScreen as home', (WidgetTester tester) async {
    await tester.pumpWidget(const VeriMaskApp());
    await tester.pump();
    await tester.pump();

    expect(find.byType(CameraScreen), findsOneWidget);
  }, skip: true);
}

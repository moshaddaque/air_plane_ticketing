import 'package:air_plane_ticketing/app.dart';
import 'package:air_plane_ticketing/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches with SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const AirplaneTicketingApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Airplane Ticketing System'), findsOneWidget);
  });
}

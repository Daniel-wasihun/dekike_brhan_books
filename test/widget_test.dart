import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senbet_school/main.dart';
import 'package:senbet_school/data/school_provider.dart';
import 'package:senbet_school/data/textbook_data.dart';

void main() {
  setUpAll(() async {
    // Load the JSON library data before any test runs
    TestWidgetsFlutterBinding.ensureInitialized();
    await LibraryLoader.load();
  });

  testWidgets('App smoke test — splash screen shows',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SchoolProvider(),
        child: const SundaySchoolApp(),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}

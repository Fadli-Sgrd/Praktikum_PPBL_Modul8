import 'package:flutter_test/flutter_test.dart';
import 'package:aiot_peringatan_dini_sqlite/main.dart';

void main() {
  testWidgets('Aplikasi peringatan dini displays header and nav', (WidgetTester tester) async {
    await tester.pumpWidget(const AplikasiPeringatanDini());

    expect(find.text('Pantauan'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
  });
}

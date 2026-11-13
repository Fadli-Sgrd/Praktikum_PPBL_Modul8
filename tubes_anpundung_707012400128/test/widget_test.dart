import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tubes_anpundung_707012400128/cubit/laporan_cubit.dart';
import 'package:tubes_anpundung_707012400128/cubit/theme_cubit.dart';
import 'package:tubes_anpundung_707012400128/main.dart';

Widget _buatAplikasiUntukTes() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<LaporanCubit>(create: (_) => LaporanCubit()),
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
    ],
    child: const AnpundungApp(),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Aplikasi Anpundung menampilkan navigasi dan judul beranda', (tester) async {
    await tester.pumpWidget(_buatAplikasiUntukTes());
    await tester.pumpAndSettle();

    expect(find.text('ANPUNDUNG'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Buat Laporan'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
  });

  testWidgets('Sakelar mode gelap mengubah tema aplikasi', (tester) async {
    await tester.pumpWidget(_buatAplikasiUntukTes());
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
  });
}

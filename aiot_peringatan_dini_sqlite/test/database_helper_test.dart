import 'package:flutter_test/flutter_test.dart';
import 'package:aiot_peringatan_dini_sqlite/db/database_helper.dart';
import 'package:aiot_peringatan_dini_sqlite/models/pembacaan_sensor.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseHelper CRUD operations for aiot_peringatan_dini_sqlite', () async {
    final helper = DatabaseHelper.instance;

    // Create
    final sensor = PembacaanSensor(
      jenisSensor: 'ketinggian_air',
      nilai: 120.5,
      lokasiPos: 'Pos Bendungan Katulampa',
      waktu: '2026-11-13T18:30:00.000',
    );
    final id = await helper.tambahPembacaan(sensor);
    expect(id, greaterThan(0));

    // Read
    final daftar = await helper.ambilSemuaPembacaan();
    expect(daftar.any((p) => p.id == id), isTrue);

    final perJenis = await helper.ambilTerbaruPerJenis();
    expect(perJenis.any((p) => p.jenisSensor == 'ketinggian_air'), isTrue);

    // Update
    await helper.ubahNilai(id, 160.0);
    final daftarSetelahUpdate = await helper.ambilSemuaPembacaan();
    final updated = daftarSetelahUpdate.firstWhere((p) => p.id == id);
    expect(updated.nilai, equals(160.0));

    // Delete
    await helper.hapusPembacaan(id);
    final daftarSetelahHapus = await helper.ambilSemuaPembacaan();
    expect(daftarSetelahHapus.any((p) => p.id == id), isFalse);
  });
}


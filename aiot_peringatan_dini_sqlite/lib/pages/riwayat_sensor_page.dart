import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/sensor_card.dart';

class RiwayatSensorPage extends StatefulWidget {
  const RiwayatSensorPage({super.key});

  @override
  State<RiwayatSensorPage> createState() => _RiwayatSensorPageState();
}

class _RiwayatSensorPageState extends State<RiwayatSensorPage> {
  late Future<List<PembacaanSensor>> _pembacaan;

  @override
  void initState() {
    super.initState();
    _pembacaan = DatabaseHelper.instance.ambilSemuaPembacaan();
  }

  void _muatUlang() {
    setState(() {
      _pembacaan = DatabaseHelper.instance.ambilSemuaPembacaan();
    });
  }

  String _status(List<PembacaanSensor> semua) {
    final terbaru = <String, PembacaanSensor>{};
    for (final item in semua) {
      terbaru.putIfAbsent(item.jenisSensor, () => item);
    }
    var level = 0;
    for (final item in terbaru.values) {
      final ambangWaspada = switch (item.jenisSensor) {
        'ketinggian_air' => 100.0,
        'pergeseran_tanah' => 5.0,
        'curah_hujan' => 50.0,
        _ => double.infinity,
      };
      final ambangSiaga = switch (item.jenisSensor) {
        'ketinggian_air' => 150.0,
        'pergeseran_tanah' => 8.0,
        'curah_hujan' => 100.0,
        _ => double.infinity,
      };
      if (item.nilai >= ambangSiaga) {
        level = 2;
      } else if (item.nilai >= ambangWaspada && level < 1) {
        level = 1;
      }
    }
    return switch (level) { 2 => 'SIAGA', 1 => 'WASPADA', _ => 'AMAN' };
  }

  Color _warnaStatus(String status, BuildContext context) => switch (status) {
        'SIAGA' => Theme.of(context).colorScheme.error,
        'WASPADA' => Colors.orange.shade800,
        _ => Colors.green.shade700,
      };

  Future<void> _ubahNilai(PembacaanSensor item) async {
    if (item.id == null) return;
    final controller = TextEditingController(text: item.nilai.toString());
    final nilai = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Koreksi nilai sensor'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Nilai baru'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, double.tryParse(controller.text.trim())),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nilai == null) return;
    await DatabaseHelper.instance.ubahNilai(item.id!, nilai);
    if (mounted) setState(_muatUlang);
  }

  Future<void> _hapus(PembacaanSensor item) async {
    if (item.id == null) return;
    await DatabaseHelper.instance.hapusPembacaan(item.id!);
    if (mounted) setState(_muatUlang);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Sensor'),
          actions: [
            FutureBuilder<List<PembacaanSensor>>(
              future: _pembacaan,
              builder: (context, snapshot) {
                final status = _status(snapshot.data ?? const []);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Chip(
                    avatar: Icon(Icons.warning_amber, color: _warnaStatus(status, context), size: 18),
                    label: Text(status, style: TextStyle(color: _warnaStatus(status, context), fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<PembacaanSensor>>(
          future: _pembacaan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat riwayat: ${snapshot.error}'));
            }
            final daftar = snapshot.data ?? [];
            if (daftar.isEmpty) {
              return const Center(child: Text('Belum ada riwayat pembacaan sensor.'));
            }
            return ListView.builder(
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final item = daftar[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _hapus(item),
                  child: InkWell(
                    onTap: () => _ubahNilai(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SensorCard(pembacaan: item),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(76, 0, 16, 8),
                          child: Text(_formatWaktu(item.waktu), style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );

  String _formatWaktu(String waktu) {
    final parsed = DateTime.tryParse(waktu)?.toLocal();
    if (parsed == null) return waktu;
    String dua(int angka) => angka.toString().padLeft(2, '0');
    return '${dua(parsed.day)}/${dua(parsed.month)}/${parsed.year} ${dua(parsed.hour)}:${dua(parsed.minute)}:${dua(parsed.second)}';
  }
}

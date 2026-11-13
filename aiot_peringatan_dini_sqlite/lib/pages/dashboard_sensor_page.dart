import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pantauan_cubit.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';

class DashboardSensorPage extends StatefulWidget {
  const DashboardSensorPage({super.key});

  @override
  State<DashboardSensorPage> createState() => _DashboardSensorPageState();
}

class _DashboardSensorPageState extends State<DashboardSensorPage> {
  @override
  void initState() {
    super.initState();
    _muatPembacaanTerkini();
  }

  Future<void> _muatPembacaanTerkini() async {
    try {
      final data = await DatabaseHelper.instance.ambilTerbaruPerJenis();
      if (mounted) context.read<PantauanCubit>().muatPembacaanTerkini(data);
    } catch (_) {
      // Kegagalan database tetap dapat dilihat dan dicoba ulang melalui input manual.
    }
  }

  Future<void> _tambahPembacaan(BuildContext context) async {
    final nilaiController = TextEditingController();
    final lokasiController = TextEditingController();
    var jenis = 'ketinggian_air';
    final hasil = await showDialog<PembacaanSensor>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Input pembacaan sensor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: jenis,
                decoration: const InputDecoration(labelText: 'Jenis sensor'),
                items: const [
                  DropdownMenuItem(value: 'ketinggian_air', child: Text('Ketinggian air')),
                  DropdownMenuItem(value: 'pergeseran_tanah', child: Text('Pergeseran tanah')),
                  DropdownMenuItem(value: 'curah_hujan', child: Text('Curah hujan')),
                ],
                onChanged: (value) => setDialogState(() => jenis = value ?? jenis),
              ),
              TextField(
                controller: nilaiController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nilai sensor'),
              ),
              TextField(
                controller: lokasiController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Lokasi pos pemantauan'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final nilai = double.tryParse(nilaiController.text.trim());
                final lokasi = lokasiController.text.trim();
                if (nilai == null || lokasi.isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  PembacaanSensor(
                    jenisSensor: jenis,
                    nilai: nilai,
                    lokasiPos: lokasi,
                    waktu: DateTime.now().toIso8601String(),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    nilaiController.dispose();
    lokasiController.dispose();
    if (hasil == null || !context.mounted) return;

    try {
      final id = await DatabaseHelper.instance.tambahPembacaan(hasil);
      if (!context.mounted) return;
      context.read<PantauanCubit>().tandaiPembacaanBaru(
            PembacaanSensor(
              id: id,
              jenisSensor: hasil.jenisSensor,
              nilai: hasil.nilai,
              lokasiPos: hasil.lokasiPos,
              waktu: hasil.waktu,
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembacaan tersimpan secara lokal.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pembacaan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Pantauan Sensor'),
          actions: const [ThemeToggleButton()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _tambahPembacaan(context),
          icon: const Icon(Icons.add),
          label: const Text('Input sensor'),
        ),
        body: BlocBuilder<PantauanCubit, List<PembacaanSensor>>(
          builder: (context, pembacaan) {
            if (pembacaan.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Belum ada pembacaan sensor. Masukkan pembacaan untuk menyimpannya ke SQLite.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 88),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('Pembacaan terbaru per sensor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                for (final item in pembacaan) SensorCard(pembacaan: item),
              ],
            );
          },
        ),
      );
}

import 'package:flutter/material.dart';

import '../pages/halaman_beranda.dart';
import '../pages/halaman_laporan.dart';
import '../pages/halaman_riwayat.dart';

class KerangkaNavigasi extends StatefulWidget {
  const KerangkaNavigasi({super.key});

  @override
  State<KerangkaNavigasi> createState() => _KerangkaNavigasiState();
}

class _KerangkaNavigasiState extends State<KerangkaNavigasi> {
  int _indeksAktif = 0;

  static const _halaman = [
    HalamanBeranda(),
    HalamanLaporan(),
    HalamanRiwayat(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indeksAktif, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeksAktif,
        onDestinationSelected: (index) => setState(() => _indeksAktif = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Buat Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

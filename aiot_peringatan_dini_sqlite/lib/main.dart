import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/pantauan_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'pages/dashboard_sensor_page.dart';
import 'pages/riwayat_sensor_page.dart';
import 'themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplikasiPeringatanDini());
}

class AplikasiPeringatanDini extends StatelessWidget {
  const AplikasiPeringatanDini({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PantauanCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            title: 'Peringatan Dini AIoT',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: const KerangkaAplikasi(),
          ),
        ),
      );
}

class KerangkaAplikasi extends StatefulWidget {
  const KerangkaAplikasi({super.key});

  @override
  State<KerangkaAplikasi> createState() => _KerangkaAplikasiState();
}

class _KerangkaAplikasiState extends State<KerangkaAplikasi> {
  int _indeks = 0;

  @override
  Widget build(BuildContext context) {
    final halaman = [
      const DashboardSensorPage(),
      const RiwayatSensorPage(),
    ];

    return Scaffold(
      body: halaman[_indeks],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (index) => setState(() => _indeks = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sensors), label: 'Pantauan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}

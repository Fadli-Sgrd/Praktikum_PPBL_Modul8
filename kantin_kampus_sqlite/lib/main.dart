import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'cubit/keranjang_cubit.dart'; 
import 'cubit/theme_cubit.dart'; 
import 'pages/halaman_produk.dart'; 
import 'pages/halaman_keranjang.dart'; 
import 'pages/halaman_riwayat.dart';
import 'themes/app_theme.dart';

void main() { 
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KantinKampusApp()); 
}

class KantinKampusApp extends StatelessWidget { 
  const KantinKampusApp({super.key}); 

  @override 
  Widget build(BuildContext context) {
    return MultiBlocProvider( 
      providers: [
        BlocProvider(create: (_) => KeranjangCubit()), 
        BlocProvider(create: (_) => ThemeCubit()), 
      ], 
      child: BlocBuilder<ThemeCubit, ThemeMode>( 
        builder: (context, themeMode) { 
          return MaterialApp( 
            title: 'Kantin Kampus', 
            theme: AppTheme.lightTheme, 
            darkTheme: AppTheme.darkTheme, 
            themeMode: themeMode, 
            home: const KerangkaUtama(), 
          ); 
        }, 
      ), 
    ); 
  } 
} 
 
class KerangkaUtama extends StatefulWidget { 
  const KerangkaUtama({super.key}); 
 
  @override 
  State<KerangkaUtama> createState() => _KerangkaUtamaState(); 
} 
 
class _KerangkaUtamaState extends State<KerangkaUtama> { 
  int _indeks = 0; 
 
  @override 
  Widget build(BuildContext context) { 
    final halaman = [
      const HalamanProduk(),
      const HalamanKeranjang(),
      const HalamanRiwayat(),
    ];

    return Scaffold( 
      body: halaman[_indeks], 
      bottomNavigationBar: NavigationBar( 
        selectedIndex: _indeks, 
        onDestinationSelected: (i) => setState(() => _indeks = i),
        destinations: const [ 
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Produk'), 
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Keranjang'), 
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
        ], 
      ), 
    ); 
  } 
} 

import 'package:flutter/material.dart';
import 'screens/beranda_screen.dart';
import 'screens/pantau_screen.dart';
import 'screens/nilai_screen.dart';
import 'screens/bayar_screen.dart';
import 'screens/akun_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Jangan gunakan 'final' di sini karena nilai ini akan berubah saat ditekan
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const BerandaScreen(),
    const PantauScreen(),
    const NilaiScreen(),
    const BayarScreen(),
    const AkunScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.blueGrey[300],
        showUnselectedLabels: true,
        // HAPUS kata 'const' di depan kurung siku ini
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled), 
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            // Ganti binoculars menjadi visibility_outlined (yang paling mirip teropong)
            icon: Icon(Icons.visibility_outlined), 
            label: 'Pantau',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment), 
            label: 'Nilai',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on), 
            label: 'Bayar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), 
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
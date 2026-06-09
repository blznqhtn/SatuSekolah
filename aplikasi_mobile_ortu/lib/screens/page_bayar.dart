import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class PageBayar extends StatefulWidget {
  const PageBayar({super.key});

  @override
  State<PageBayar> createState() => _PageBayarState();
}

class _PageBayarState extends State<PageBayar> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildTagihanAktifCard(),
                _buildRincianCard(),
                _buildSectionHeader('Riwayat Pembayaran'),
                _buildRiwayatList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
               final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
               if(parent != null) parent.goBack();
            },
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppTheme.bg2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 16, color: AppTheme.text),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Pembayaran SPP', style: AppTheme.headerTitle),
        ],
      ),
    );
  }

  Widget _buildTagihanAktifCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2744), Color(0xFF2D3F6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tagihan Aktif', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Rp 605.000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 2),
          const Text('SPP Mei 2026 · Aditya Pratama', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: (_isProcessing || _isSuccess) ? null : () {
              setState(() {
                _isProcessing = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _isProcessing = false;
                    _isSuccess = true;
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSuccess ? AppTheme.teal : Colors.white,
              foregroundColor: _isSuccess ? Colors.white : const Color(0xFF1A2744),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isProcessing) ...[
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  const Text('Memproses...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ] else if (_isSuccess) ...[
                  const Text('✅ Pembayaran Berhasil!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ] else ...[
                  const Text('💳 Bayar Sekarang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRincianCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rincian Tagihan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _buildRincianRow('SPP Mei 2026', 'Rp 600.000', AppTheme.text2, AppTheme.text, true),
            _buildRincianRow('Biaya Payment Gateway', 'Rp 4.000', AppTheme.text3, AppTheme.text3, false),
            _buildRincianRow('Biaya Admin Aplikasi', 'Rp 1.000', AppTheme.text3, AppTheme.text3, false),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Tagihan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('Rp 605.000', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.accent, fontFamily: 'DM Mono')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRincianRow(String label, String value, Color labelColor, Color valColor, bool isBoldVal) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          Text(value, style: TextStyle(fontSize: 12, color: valColor, fontWeight: isBoldVal ? FontWeight.w700 : FontWeight.normal, fontFamily: 'DM Mono')),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildRiwayatList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            _buildRiwayatItem('SPP April 2026', '05/04/2026', 'Virtual Account'),
            const Divider(height: 1, color: AppTheme.border),
            _buildRiwayatItem('SPP Maret 2026', '03/03/2026', 'Virtual Account'),
            const Divider(height: 1, color: AppTheme.border),
            _buildRiwayatItem('SPP Februari 2026', '02/02/2026', 'Virtual Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(String title, String date, String method) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('✅', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text('$date · $method', style: const TextStyle(fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('Lunas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.teal, fontFamily: 'DM Mono')),
              SizedBox(height: 2),
              Text('Rp 605.000', style: TextStyle(fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
            ],
          ),
        ],
      ),
    );
  }
}

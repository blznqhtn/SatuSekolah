import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_client.dart';
import '../constants/app_text_styles.dart';

class RiwayatBayarScreen extends StatefulWidget {
  const RiwayatBayarScreen({super.key});

  @override
  State<RiwayatBayarScreen> createState() => _RiwayatBayarScreenState();
}

class _RiwayatBayarScreenState extends State<RiwayatBayarScreen> {
  bool _isLoading = true;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await ApiClient().dio.get('/finance/ledger/history');
      if (mounted) {
        setState(() {
          _history = res.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil riwayat pembayaran'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Pembayaran',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : _history.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: AppColors.text3.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Transaksi',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda belum melakukan pembayaran apapun.',
            style: TextStyle(fontFamily: 'Nunito', color: AppColors.text3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final isCredit = item['transaction_type'] == 'CREDIT';
        final amount = item['amount'] ?? 0.0;
        final desc = item['description'] ?? 'Transaksi';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCredit ? AppColors.green.withOpacity(0.1) : AppColors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? AppColors.green : AppColors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['created_at'] != null ? _formatDate(item['created_at']) : '-',
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.text3),
                    ),
                  ],
                ),
              ),
              Text(
                '${isCredit ? '+' : '-'} Rp ${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.green : AppColors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}

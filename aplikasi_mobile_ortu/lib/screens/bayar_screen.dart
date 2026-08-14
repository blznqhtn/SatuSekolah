import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/app_badge.dart';
import '../widgets/section_header.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';
import 'transfer_screen.dart';

class BayarScreen extends StatefulWidget {
  const BayarScreen({super.key});

  @override
  State<BayarScreen> createState() => _BayarScreenState();
}

class _BayarScreenState extends State<BayarScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  
  List<dynamic> _activeBills = [];
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id');

      Map<String, dynamic> query = {};
      if (childId != null) query['child_id'] = childId;

      final resActive = await ApiClient().dio.get('/payments/active', queryParameters: query);
      final resHistory = await ApiClient().dio.get('/payments/history', queryParameters: query);
      
      if (mounted) {
        setState(() {
          _activeBills = resActive.data['data'] ?? [];
          _history = resHistory.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("API Error (Bayar): $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _bayar(dynamic bill) async {
    // Tampilkan Dialog PIN sebelum melakukan request
    final String? pin = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String enteredPin = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Masukkan PIN', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
          content: TextField(
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (v) => enteredPin = v,
            decoration: const InputDecoration(
              hintText: 'PIN 6 digit Anda',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              onPressed: () => Navigator.pop(ctx, enteredPin),
              child: const Text('Bayar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );

    if (pin == null || pin.isEmpty) return; // User membatalkan

    setState(() => _isProcessing = true);
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id');
      
      // Calculate dynamic total
      double baseAmount = (bill['total_amount'] ?? 0).toDouble();
      double gatewayFee = 4000;
      double adminAppFee = 1000;
      double totalToPay = baseAmount - (bill['paid_amount'] ?? 0).toDouble() + gatewayFee + adminAppFee;

      final response = await ApiClient().dio.post('/payments/pay', data: {
        'child_id': childId,
        'bill_id': bill['id'],
        'amount': totalToPay,
        'pin': pin,
        'payment_method': 'IN_APP_WALLET'
      });
      
      if (response.statusCode == 200) {
        // Refresh data
        await _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran Berhasil!'), backgroundColor: Colors.green));
        }
      } else {
        throw Exception('Gagal bayar');
      }
    } catch (e) {
      debugPrint("Payment Error: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran gagal. Saldo tidak mencukupi atau PIN salah.'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ..._activeBills.map((b) => _buildBillItem(b)).toList(),
            if (_activeBills.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: const Center(child: Text("Hore! Tidak ada tagihan aktif.")),
              ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Riwayat Pembayaran'),
            const SizedBox(height: 10),
            _buildRiwayat(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _buildTransferFab(),
    );
  }

  Widget _buildTransferFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen())),
      backgroundColor: AppColors.teal,
      icon: const Icon(Icons.send, color: Colors.white),
      label: const Text('Kirim Uang Saku', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Widget _buildBillItem(dynamic bill) {
    double totalAmount = (bill['total_amount'] ?? 0).toDouble();
    double paidAmount = (bill['paid_amount'] ?? 0).toDouble();
    double remainingAmount = totalAmount - paidAmount;
    List<dynamic> details = bill['details'] ?? [];

    double gatewayFee = 4000;
    double adminAppFee = 1000;
    double grandTotal = remainingAmount + gatewayFee + adminAppFee;

    String dateStr = bill['due_date'] ?? '';
    String displayDate = dateStr;
    try {
      if (dateStr.isNotEmpty) {
        DateTime d = DateTime.parse(dateStr);
        displayDate = DateFormat('dd MMM yyyy', 'id_ID').format(d);
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a2744), Color(0xFF2d3f6e)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tagihan Aktif', style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(grandTotal),
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                      ),
                      const SizedBox(height: 4),
                      Text('${bill['title']} · Jatuh Tempo: $displayDate', style: const TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
                _buildPayButton(bill)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rincian Tagihan', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                ...details.map((d) {
                   double amt = (d['amount'] ?? 0).toDouble();
                   return _buildRincianRow(d['item_name'], _formatCurrency(amt), false);
                }).toList(),
                _buildRincianRow('Biaya Payment Gateway', _formatCurrency(gatewayFee), true),
                _buildRincianRow('Biaya Admin Aplikasi', _formatCurrency(adminAppFee), true),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.bodyBold),
                    Text(_formatCurrency(grandTotal), style: const TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accent)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRincianRow(String label, String value, bool isSub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Nunito', fontSize: isSub ? 12 : 13, fontWeight: isSub ? FontWeight.w500 : FontWeight.w600, color: isSub ? AppColors.text3 : AppColors.text2)),
          Text(value, style: TextStyle(fontFamily: 'monospace', fontSize: isSub ? 11 : 13, color: isSub ? AppColors.text3 : AppColors.text, fontWeight: isSub ? FontWeight.w400 : FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildPayButton(dynamic bill) {
    return GestureDetector(
      onTap: _isProcessing ? null : () => _bayar(bill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isProcessing)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1a2744)))
            else
              const Text('💳 ', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(_isProcessing ? 'Proses...' : 'Bayar', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1a2744))),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayat() {
    if (_history.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: const Text('Belum ada riwayat pembayaran.', style: TextStyle(color: AppColors.text3)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: _history.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            
            String dateStr = item['paid_at'] ?? '';
            String displayDate = dateStr;
            try {
              if (dateStr.isNotEmpty) {
                DateTime d = DateTime.parse(dateStr);
                displayDate = DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(d);
              }
            } catch (_) {}

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i < _history.length - 1 ? const Border(bottom: BorderSide(color: AppColors.border)) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.tealBg, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: const Text('✅', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['bill_title'] ?? 'Pembayaran', style: AppTextStyles.bodyBold),
                        Text('$displayDate · ${item['payment_method']}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item['status'] == 'SUCCESS' ? 'Lunas' : item['status'], style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.teal)),
                      Text(_formatCurrency((item['amount'] ?? 0).toDouble()), style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
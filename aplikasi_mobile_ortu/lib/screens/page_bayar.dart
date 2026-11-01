import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PageBayar extends StatefulWidget {
  const PageBayar({super.key});

  @override
  State<PageBayar> createState() => _PageBayarState();
}

class _PageBayarState extends State<PageBayar> {
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isSuccess = false;

  String _childName = 'Anak';
  String _childId = '';

  List<Map<String, dynamic>> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });

    final child = ApiService.getSelectedChild();
    if (child != null) {
      _childName = child['name'] ?? 'Anak';
      _childId = child['id']?.toString() ?? '';
    } else {
      final children = await ApiService.getChildren();
      if (children.isNotEmpty) {
        _childName = children.first['name'] ?? 'Anak';
        _childId = children.first['id']?.toString() ?? '';
      }
    }

    if (_childId.isNotEmpty) {
      final invoices = await ApiService.getInvoices(_childId);
      if (mounted) {
        setState(() {
          _invoices = invoices;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processPayment(Map<String, dynamic> invoice, double totalAmount) async {
    setState(() {
      _isProcessing = true;
    });

    final invoiceId = invoice['id']?.toString() ?? '';
    final ok = await ApiService.payInvoice(invoiceId, totalAmount);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = ok;
      });

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pembayaran Berhasil Diproses ke Database!'),
            backgroundColor: AppTheme.teal,
          ),
        );
        // Refresh invoices setelah jeda sebentar
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {
              _isSuccess = false;
            });
            _loadInvoices();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal memproses pembayaran. Coba lagi.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unpaidInvoice = _invoices.cast<Map<String, dynamic>?>().firstWhere(
          (inv) => inv?['status'] == 'UNPAID',
          orElse: () => null,
        );

    final paidInvoices = _invoices.where((inv) => inv['status'] == 'PAID').toList();

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadInvoices,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildTagihanAktifCard(unpaidInvoice),
                        if (unpaidInvoice != null) _buildRincianCard(unpaidInvoice),
                        _buildSectionHeader('Riwayat Pembayaran'),
                        _buildRiwayatList(paidInvoices),
                        const SizedBox(height: 24),
                      ],
                    ),
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
              if (parent != null) parent.goBack();
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

  Widget _buildTagihanAktifCard(Map<String, dynamic>? unpaid) {
    if (unpaid == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            const Text('Semua Tagihan Lunas',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Tidak ada tagihan SPP tertunggak untuk $_childName',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final baseAmount = (unpaid['total_amount'] as num?)?.toDouble() ?? 600000.0;
    final totalAmount = baseAmount + 5000.0;
    final title = unpaid['invoice_name'] ?? 'Tagihan SPP';
    final va = unpaid['transfer_target_account'] ?? 'VA-88880012345678';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tagihan Aktif',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.red.withOpacity(0.5)),
                ),
                child: const Text('Belum Dibayar',
                    style: TextStyle(
                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(ApiService.formatRupiah(totalAmount),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1)),
          const SizedBox(height: 2),
          Text('$title · $_childName',
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 6),
          Text('Virtual Account: $va',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10, fontFamily: 'DM Mono')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_isProcessing || _isSuccess)
                ? null
                : () => _processPayment(unpaid, totalAmount),
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
                  const SizedBox(
                      width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  const Text('Memproses Transaksi...',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ] else if (_isSuccess) ...[
                  const Text('✅ Pembayaran Berhasil!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ] else ...[
                  const Text('💳 Bayar Sekarang',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRincianCard(Map<String, dynamic> unpaid) {
    final baseAmount = (unpaid['total_amount'] as num?)?.toDouble() ?? 600000.0;
    final totalAmount = baseAmount + 5000.0;
    final title = unpaid['invoice_name'] ?? 'Tagihan SPP';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rincian Tagihan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _buildRincianRow(
                title, ApiService.formatRupiah(baseAmount), AppTheme.text2, AppTheme.text, true),
            _buildRincianRow(
                'Biaya Payment Gateway', 'Rp 4.000', AppTheme.text3, AppTheme.text3, false),
            _buildRincianRow(
                'Biaya Admin Aplikasi', 'Rp 1.000', AppTheme.text3, AppTheme.text3, false),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Tagihan',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text(ApiService.formatRupiah(totalAmount),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent,
                          fontFamily: 'DM Mono')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRincianRow(
      String label, String value, Color labelColor, Color valColor, bool isBoldVal) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: valColor,
                  fontWeight: isBoldVal ? FontWeight.w700 : FontWeight.normal,
                  fontFamily: 'DM Mono')),
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

  Widget _buildRiwayatList(List<Map<String, dynamic>> paidInvoices) {
    if (paidInvoices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: const Center(
            child: Text('Belum ada riwayat pembayaran yang lunas',
                style: TextStyle(fontSize: 12, color: AppTheme.text3)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: List.generate(paidInvoices.length, (index) {
            final inv = paidInvoices[index];
            final title = inv['invoice_name'] ?? 'Pembayaran SPP';
            final date = inv['paid_at']?.toString().split(' ').first ?? inv['due_date']?.toString() ?? 'Terkonfirmasi';
            final method = 'Virtual Account';
            final amount = (inv['total_amount'] as num?)?.toDouble() ?? 600000.0;

            return Column(
              children: [
                if (index > 0) const Divider(height: 1, color: AppTheme.border),
                _buildRiwayatItem(title, date, method, ApiService.formatRupiah(amount)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(String title, String date, String method, String amount) {
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text('$date · $method',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Lunas',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.teal,
                      fontFamily: 'DM Mono')),
              const SizedBox(height: 2),
              Text(amount,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
            ],
          ),
        ],
      ),
    );
  }
}

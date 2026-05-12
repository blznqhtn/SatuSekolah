import 'package:flutter/material.dart';

class BayarScreen extends StatelessWidget {
  const BayarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 1. Header Blue Gradient (Konsisten dengan Beranda)
          _buildHeader("Pembayaran"),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. KARTU SALDO / TOTAL TAGIHAN (Gold Coin Style)
                  _buildGoldBalanceCard(),

                  const SizedBox(height: 25),

                  // 3. Tab Sederhana (Custom Design)
                  Row(
                    children: [
                      _buildTabButton("Tagihan Aktif", true),
                      const SizedBox(width: 10),
                      _buildTabButton("Riwayat", false),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. Daftar Tagihan
                  _buildMainCard(
                    title: "Iuran Sekolah",
                    child: Column(
                      children: [
                        _buildPaymentItem(
                          title: "SPP Mei 2024",
                          date: "Jatuh tempo: 10 Mei",
                          amount: "Rp 750.000",
                          isMandatory: true,
                        ),
                        const Divider(),
                        _buildPaymentItem(
                          title: "Uang Kegiatan (Outing)",
                          date: "Jatuh tempo: 20 Mei",
                          amount: "Rp 300.000",
                          isMandatory: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Tombol Bayar Sekaligus
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F86D6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      onPressed: () {},
                      child: const Text("BAYAR SEKALIGUS",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Kartu Gradien Emas (Coin Theme)
  Widget _buildGoldBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        // Gradien Emas Metalik
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDB931), Color(0xFFE7A102), Color(0xFFFDB931)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Tagihan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("PREMIUM",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text("Rp 1.050.000",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text("Metode: Transfer Bank, VA, E-Wallet",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  // HELPER: Judul Halaman
  Widget _buildHeader(String title) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)]),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // HELPER: Kartu Putih Utama
  Widget _buildMainCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  // HELPER: Item Pembayaran
  Widget _buildPaymentItem(
      {required String title,
      required String date,
      required String amount,
      required bool isMandatory}) {
    // PERBAIKAN: Bungkus dengan InkWell
    return InkWell(
      onTap: () {
        // Aksi lihat detail tagihan
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade100, width: 1),
              ),
              child: const Icon(Icons.monetization_on,
                  color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Text(amount,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // HELPER: Tombol Tab
  Widget _buildTabButton(String label, bool isActive) {
    // PERBAIKAN: Gunakan InkWell
    return InkWell(
      onTap: () {
        // Aksi ganti tab
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6F86D6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 5)
                ],
        ),
        child: Text(label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

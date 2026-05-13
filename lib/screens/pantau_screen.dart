import 'package:flutter/material.dart';

class PantauScreen extends StatelessWidget {
  const PantauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            // 1. Header Blue Gradient
            _buildHeader("Pantau Anak"),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // 2. Custom Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelStyle:
                            const TextStyle(fontWeight: FontWeight.normal),
                        tabs: const [
                          Tab(text: "Presensi & Poin"),
                          Tab(text: "Kesehatan"),
                        ],
                      ),
                    ),
                  ),

                  // 3. Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPresensiTab(),
                        _buildKesehatanTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: PRESENSI & POIN ---
  Widget _buildPresensiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Ringkasan Kehadiran Bulanan
          _buildMainCard(
            title: "Statistik Kehadiran",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularStat("95%", "Hadir", Colors.green),
                _buildCircularStat("3%", "Izin", Colors.blue),
                _buildCircularStat("2%", "Alpha", Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detail Poin Pelanggaran
          _buildMainCard(
            title: "Catatan Kedisiplinan",
            child: Column(
              children: [
                _buildLogTile(Icons.warning_amber_rounded, Colors.orange,
                    "Terlambat Masuk", "12 Mei 2024 • Poin +5"),
                const Divider(),
                _buildLogTile(Icons.check_circle_outline, Colors.green,
                    "Siswa Teladan", "01 Mei 2024 • Poin -10"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: KESEHATAN ---
  Widget _buildKesehatanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Info Fisik Anak
          _buildMainCard(
            title: "Kondisi Fisik",
            child: Row(
              children: [
                _buildPhysicalInfo(
                    "Tinggi", "165 cm", Icons.height, Colors.blue),
                _buildPhysicalInfo(
                    "Berat", "55 kg", Icons.monitor_weight, Colors.teal),
                _buildPhysicalInfo(
                    "Gol. Darah", "O", Icons.bloodtype, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Riwayat UKS / Kesehatan
          _buildMainCard(
            title: "Riwayat Kesehatan",
            child: Column(
              children: [
                _buildLogTile(Icons.medical_services_outlined, Colors.red,
                    "Pusing & Demam (UKS)", "10 April 2024 • Istirahat"),
                const Divider(),
                _buildLogTile(Icons.vaccines_outlined, Colors.indigo,
                    "Vaksinasi BIAS", "15 Maret 2024 • Selesai"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeader(String title) {
    return Container(
      height: 240, // 1. Perbesar sedikit tinggi background birunya
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      // 2. Bungkus dengan SafeArea agar teks aman dari poni kamera
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20), // Jarak lega dari atas
          child: Text(
            title, 
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
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

  Widget _buildCircularStat(String value, String label, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                  value: 0.8,
                  color: color,
                  strokeWidth: 6,
                  backgroundColor: color.withOpacity(0.1)),
            ),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPhysicalInfo(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLogTile(IconData icon, Color color, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      // PERBAIKAN: Tambahkan onTap agar ListTile merespons sentuhan
      onTap: () {
        // Aksi ketika log diklik untuk melihat detail
      },
    );
  }
}

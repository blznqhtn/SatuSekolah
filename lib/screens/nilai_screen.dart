import 'package:flutter/material.dart';

class NilaiScreen extends StatelessWidget {
  const NilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Header Gradien
          _buildHeader("Nilai & Rapor"),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                children: [
                  // Kartu Peringkat
                  _buildMainCard(
                    title: "Peringkat Kelas",
                    child: Center(
                      child: Column(
                        children: [
                          const Text("Ananda Andi Perkasa",
                              style: TextStyle(color: Colors.grey)),
                          const Text("03",
                              style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          const Text("Dari 32 Siswa",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kartu Daftar Rapor
                  _buildMainCard(
                    title: "Rapor Digital",
                    child: Column(
                      children: [
                        _buildListItem(Icons.picture_as_pdf,
                            "Semester Ganjil 2023", "Tersedia"),
                        const Divider(),
                        _buildListItem(Icons.picture_as_pdf,
                            "Semester Genap 2022", "Tersedia"),
                      ],
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

  // --- HELPER WIDGETS (Wajib ada di dalam class ini agar tidak error) ---

  Widget _buildHeader(String title) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String status) {
    // PERBAIKAN: Bungkus dengan InkWell
    return InkWell(
      onTap: () {
        // Aksi ketika diklik (misal: download/buka PDF)
      },
      borderRadius: BorderRadius.circular(10), // Agar efek klik membulat
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.red),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(status,
                      style:
                          const TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
            // Bisa juga diubah jadi IconButton jika ingin hanya ikonnya yang bisa diklik
            const Icon(Icons.download, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

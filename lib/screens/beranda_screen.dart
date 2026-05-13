import 'package:flutter/material.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 1. Header Gradient Background
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: SingleChildScrollView(
              // PERBAIKAN: Ganti padding horizontal menjadi fromLTRB untuk menambah jarak atas
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Notif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // PERBAIKAN: Ganti Image.network menjadi Image.asset
                          Image.asset(
                            'assets/images/LogoSatuSekolah.png', // <--- Jalur asset yang didaftarkan
                            height: 30, // Pertahankan ukurannya agar pas
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "SATU SEKOLAH",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      // PERBAIKAN: Gunakan IconButton agar bisa diklik
                      IconButton(
                        icon: const Icon(Icons.notifications_active,
                            color: Colors.orangeAccent),
                        onPressed: () {
                          // Aksi notifikasi di sini
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Beranda",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // 3. Ringkasan Anak Card
                  _buildMainCard(
                    title: "Ringkasan Anak",
                    child: Row(
                      children: [
                        _buildSubCard(
                            "Presensi Hari Ini",
                            "20%",
                            "Kehadiran Hari",
                            Colors.green,
                            const Color(0xFFE8F5E9)),
                        const SizedBox(width: 15),
                        _buildSubCard("Pelanggaran Aktif", "0", "Pelanggaran",
                            Colors.orange, const Color(0xFFFFF3E0)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Jadwal Anak Card
                  _buildMainCard(
                    title: "Jadwal Anak",
                    actionText: "See All",
                    child: Column(
                      children: [
                        _buildJadwalItem("16", "Jadwal Hari Ini",
                            "Jadwal 1 Dakari - 20 lunari", "18 kumtr - 13:30"),
                        const Divider(),
                        _buildJadwalItem(
                            "21", "Jadwal Hari Ini 2", "15 aumtr - 12:30", ""),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Pengumuman Card
                  _buildMainCard(
                    title: "Pengumuman Sekolah",
                    child: Row(
                      children: [
                        const Icon(Icons.campaign,
                            size: 50, color: Colors.blue),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                  "Pengumuman sekolah berhumuran Sebehat Sekolah.",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              Text("[cite: 73, 75, 77, 84]",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spasi bawah
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Kartu Putih Utama
  Widget _buildMainCard(
      {required String title, required Widget child, String? actionText}) {
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
              if (actionText != null)
                // PERBAIKAN: Gunakan TextButton agar "See All" bisa diklik
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(actionText,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w500)),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  // Helper Widget: Kartu Kecil Hijau/Oranye
  Widget _buildSubCard(
      String title, String value, String desc, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(desc,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Item Jadwal
  Widget _buildJadwalItem(String date, String title, String sub, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                const Icon(Icons.calendar_month,
                    size: 16, color: Colors.orange),
                Text(date,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(sub,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (time.isNotEmpty)
                  Text(time,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

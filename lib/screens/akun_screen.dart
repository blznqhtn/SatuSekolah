import 'package:flutter/material.dart';
import '../auth/login_screen.dart'; // Pastikan path import ini benar sesuai struktur folder Anda

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // 1. Header Blue Gradient
          _buildHeader("Akun Saya"),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                children: [
                  // 2. KARTU PROFIL UTAMA
                  _buildProfileCard(),

                  const SizedBox(height: 20),

                  // 3. FITUR AKADEMIK & SEKOLAH
                  _buildMainCard(
                    title: "Layanan Sekolah",
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.rate_review_outlined,
                          iconColor: Colors.teal,
                          title: "Penilaian Kinerja Guru",
                          subtitle: "Evaluasi pengajar semester ini",
                          onTap: () {},
                        ),
                        const Divider(),
                        _buildMenuTile(
                          icon: Icons.person_add_alt_1_outlined,
                          iconColor: Colors.orange,
                          title: "Pendaftaran Siswa Baru (SPMB)",
                          subtitle: "Daftarkan calon siswa baru",
                          isPremium: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. PENGATURAN & KEAMANAN
                  _buildMainCard(
                    title: "Pengaturan Akun",
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.lock_outline,
                          iconColor: Colors.blueGrey,
                          title: "Ubah Password",
                          subtitle: "Perbarui keamanan akun Anda",
                          onTap: () {},
                        ),
                        const Divider(),
                        _buildMenuTile(
                          icon: Icons.help_outline,
                          iconColor: Colors.blueGrey,
                          title: "Pusat Bantuan",
                          subtitle: "FAQ & Hubungi Admin Sekolah",
                          onTap: () {},
                        ),
                        const Divider(),
                        _buildMenuTile(
                          icon: Icons.logout,
                          iconColor: Colors.red,
                          title: "Keluar",
                          subtitle: "Akhiri sesi aplikasi",
                          onTap: () {
                            // Navigasi kembali ke Login
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text("SatuSekolah v1.0.0",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Kartu Profil
  Widget _buildProfileCard() {
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
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=budi'), // Ganti dengan foto lokal jika ada
          ),
          const SizedBox(height: 15),
          const Text("Bpk. Budi Santoso",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Wali Murid dari Andi Perkasa (10-A)",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileBadge(
                  Icons.verified_user, "Terverifikasi", Colors.blue),
              const SizedBox(width: 10),
              _buildProfileBadge(Icons.star, "Premium", Colors.amber),
            ],
          )
        ],
      ),
    );
  }

  // HELPER: Badge di bawah nama profil
  Widget _buildProfileBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // HELPER: Judul Halaman
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

  // HELPER: Kartu Putih Utama
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

  // HELPER: List Tile Menu
  // --- PERBAIKAN PADA lib/screens/akun_screen.dart ---

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isPremium = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min, // Tambahkan ini
        children: [
          // BUNGKUS TEKS DENGAN EXPANDED
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow
                  .ellipsis, // Tambahkan ini agar teks tidak tabrakan
            ),
          ),
          if (isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.amber, borderRadius: BorderRadius.circular(5)),
              child: const Text("PRO",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis, // Tambahkan juga di sini agar aman
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

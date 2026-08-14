import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_client.dart';

class MadingScreen extends StatefulWidget {
  const MadingScreen({super.key});

  @override
  State<MadingScreen> createState() => _MadingScreenState();
}

class _MadingScreenState extends State<MadingScreen> {
  bool _isLoading = true;
  List<dynamic> _announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final response = await ApiClient().dio.get('/communication/announcements');
      if (response.statusCode == 200) {
        setState(() {
          _announcements = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("API Error (Mading): $e. Menggunakan data lokal.");
      setState(() {
        _announcements = [
          {"title": "Libur Nasional Idul Fitri", "date": "10 Mei 2026", "content": "Diberitahukan kepada seluruh orang tua bahwa libur sekolah akan dimulai dari..."},
          {"title": "Pertemuan Orang Tua & Guru", "date": "15 Mei 2026", "content": "Akan diadakan pertemuan evaluasi tengah semester secara online via Zoom."},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        title: const Text('Mading Pengumuman', style: TextStyle(fontFamily: 'Nunito', color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _announcements.length,
            itemBuilder: (context, index) {
              final item = _announcements[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 12),
                      Text(item['content']),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

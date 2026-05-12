import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/career/screens/career_screen.dart';

class SavedJobsScreen extends StatelessWidget {
  final Set<String> savedJobIds;
  final List<Map<String, dynamic>> allJobs;
  final Function(String) onToggleWishlist;

  const SavedJobsScreen({
    Key? key,
    required this.savedJobIds,
    required this.allJobs,
    required this.onToggleWishlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter jobs yang tersimpan
    final savedJobs = allJobs.where((job) => savedJobIds.contains(job['id'])).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Lowongan Tersimpan',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: savedJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: const Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  const Text('Belum ada lowongan yang disimpan', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: savedJobs.length,
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                return _buildJobItem(job);
              },
            ),
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    bool isSaved = savedJobIds.contains(job['id']);
    return GestureDetector(
      onTap: () {
        Get.to(() => JobDetailScreen(
          id: job['id'],
          company: job['company'],
          role: job['role'],
          location: job['location'],
          type: job['type'],
          logoUrl: job['logoUrl'],
          isSaved: isSaved,
          onToggleWishlist: () {
            onToggleWishlist(job['id']);
          },
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    image: DecorationImage(
                      image: NetworkImage(job['logoUrl']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['role'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job['company'],
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    onToggleWishlist(job['id']);
                    // Ini tidak otomatis re-render SavedJobsScreen jika item dihilangkan,
                    // karena stateless, tapi di dunia nyata GetX akan reaktif.
                    Get.snackbar('Berhasil', 'Status penyimpanan diperbarui', backgroundColor: Colors.white);
                  },
                  child: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, 
                    color: isSaved ? const Color(0xFF055D97) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

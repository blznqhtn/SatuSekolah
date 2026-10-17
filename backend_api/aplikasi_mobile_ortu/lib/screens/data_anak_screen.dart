import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_client.dart';
import '../constants/app_text_styles.dart';

class DataAnakScreen extends StatefulWidget {
  const DataAnakScreen({super.key});

  @override
  State<DataAnakScreen> createState() => _DataAnakScreenState();
}

class _DataAnakScreenState extends State<DataAnakScreen> {
  bool _isLoading = true;
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      final res = await ApiClient().dio.get('/spmb/my-applications');
      if (mounted) {
        setState(() {
          _applications = res.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data anak'), backgroundColor: AppColors.red),
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
          'Data Anak (SPMB)',
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
          : _applications.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_retouching_off, size: 80, color: AppColors.text3.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Anak',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda belum mendaftarkan anak Anda ke sekolah manapun.',
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
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final app = _applications[index];
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app['student_name'] ?? 'Siswa',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(app['registration_status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      app['registration_status'] ?? 'UNKNOWN',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(app['registration_status']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 14, color: AppColors.text3),
                  const SizedBox(width: 4),
                  Text('NISN: ${app['nisn'] ?? '-'}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.text2)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 14, color: AppColors.text3),
                  const SizedBox(width: 4),
                  Text('Asal: ${app['previous_school'] ?? '-'}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.text2)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return AppColors.orange;
      case 'DOCUMENT_REVIEW':
        return AppColors.blue;
      case 'TEST':
        return AppColors.purple;
      case 'ACCEPTED':
        return AppColors.green;
      case 'REJECTED':
        return AppColors.red;
      default:
        return AppColors.text3;
    }
  }
}

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_client.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  bool _isLoading = true;
  List<dynamic> _faqs = [];

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    try {
      final res = await ApiClient().dio.get('/faqs');
      if (mounted) {
        setState(() {
          _faqs = res.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Bantuan & FAQ',
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
          : _faqs.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 80, color: AppColors.text3.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada FAQ',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text2),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: ExpansionTile(
            title: Text(
              faq['question'] ?? '',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                faq['answer'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: AppColors.text2,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

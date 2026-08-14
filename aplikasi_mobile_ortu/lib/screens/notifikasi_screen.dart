import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_client.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _isLoading = true;
  bool _emailNotif = true;
  bool _pushNotif = true;
  bool _smsNotif = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final res = await ApiClient().dio.get('/users/notification-settings');
      if (mounted) {
        setState(() {
          final data = res.data['data'];
          _emailNotif = data['email_notif'] ?? true;
          _pushNotif = data['push_notif'] ?? true;
          _smsNotif = data['sms_notif'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSettings(String key, bool value) async {
    // Optimistic update
    setState(() {
      if (key == 'email_notif') _emailNotif = value;
      if (key == 'push_notif') _pushNotif = value;
      if (key == 'sms_notif') _smsNotif = value;
    });

    try {
      await ApiClient().dio.put('/users/notification-settings', data: {
        'email_notif': _emailNotif,
        'push_notif': _pushNotif,
        'sms_notif': _smsNotif,
      });
    } catch (e) {
      // Rollback on error
      if (mounted) {
        setState(() {
          if (key == 'email_notif') _emailNotif = !value;
          if (key == 'push_notif') _pushNotif = !value;
          if (key == 'sms_notif') _smsNotif = !value;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan pengaturan'), backgroundColor: AppColors.red),
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
          'Pengaturan Notifikasi',
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
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSwitchItem('Notifikasi Push', 'Terima pemberitahuan langsung di aplikasi', _pushNotif, (val) => _updateSettings('push_notif', val)),
                const SizedBox(height: 16),
                _buildSwitchItem('Notifikasi Email', 'Terima ringkasan aktivitas via email', _emailNotif, (val) => _updateSettings('email_notif', val)),
                const SizedBox(height: 16),
                _buildSwitchItem('Notifikasi SMS', 'Pemberitahuan darurat via SMS', _smsNotif, (val) => _updateSettings('sms_notif', val)),
              ],
            ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.text3),
        ),
        value: value,
        activeColor: AppColors.accent,
        onChanged: onChanged,
      ),
    );
  }
}

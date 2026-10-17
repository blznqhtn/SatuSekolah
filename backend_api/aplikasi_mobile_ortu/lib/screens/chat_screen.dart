import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/crypto_service.dart';
import '../services/api_client.dart';
import 'package:get_storage/get_storage.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final CryptoService _cryptoService = CryptoService();
  bool _isKeysGenerated = false;
  bool _isLoading = true;
  List<dynamic> _contacts = [];

  @override
  void initState() {
    super.initState();
    _initCryptoAndFetchContacts();
  }

  Future<void> _initCryptoAndFetchContacts() async {
    // 1. Inisialisasi E2EE Keys
    final existingKey = await _cryptoService.getLocalKeyPair();
    if (existingKey == null) {
      final myPublicKey = await _cryptoService.generateAndStoreKeyPair();
      try {
        await ApiClient().dio.put('/users/profile/public-key', data: {'public_key': myPublicKey});
      } catch (e) {
        print("Gagal menyimpan public key ke server: $e");
      }
    }
    
    if (mounted) {
      setState(() => _isKeysGenerated = true);
    }
    
    await _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      final response = await ApiClient().dio.get('/communication/contacts');
      final data = response.data['data'];
      
      List<dynamic> allContacts = [];
      if (data['staff'] != null) allContacts.addAll(data['staff']);
      if (data['parents'] != null) allContacts.addAll(data['parents']);
      if (data['students'] != null) allContacts.addAll(data['students']);
      
      if (mounted) {
        setState(() {
          _contacts = allContacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Gagal fetch kontak: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openChatRoom(dynamic contact) async {
    // Initiate room
    try {
      final response = await ApiClient().dio.post('/communication/rooms/initiate', data: {
        'receiver_id': contact['id']
      });
      final roomData = response.data['data'];
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomId: roomData['room_id'],
              contactName: contact['name'] ?? 'Kontak',
              contactPublicKey: contact['public_key'] ?? '',
              receiverId: contact['id'],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka percakapan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        title: const Text('Pesan (E2EE)', style: TextStyle(fontFamily: 'Nunito', color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (!_isKeysGenerated)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            const Icon(Icons.lock, color: Colors.greenAccent), // Indikator Aman E2EE
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: const Row(
              children: [
                Icon(Icons.shield, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pesan dienkripsi End-to-End. Tidak ada pihak lain, bahkan admin Satu Sekolah, yang dapat membaca percakapan Anda.',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? const Center(child: Text("Tidak ada kontak yang tersedia"))
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          final category = contact['category'] == 'staff' ? 'Guru/Admin' : (contact['category'] == 'student' ? 'Siswa' : 'Wali Murid');
                          final className = contact['class_name'] != null ? ' - ${contact['class_name']}' : '';
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.teal,
                              child: Text(contact['name'] != null ? contact['name'][0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(contact['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                            subtitle: Text('$category$className'),
                            trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.accent),
                            onTap: () => _openChatRoom(contact),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

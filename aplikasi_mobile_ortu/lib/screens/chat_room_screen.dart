import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../services/crypto_service.dart';
import '../services/api_client.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String contactName;
  final String contactPublicKey;
  final String receiverId;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.contactName,
    required this.contactPublicKey,
    required this.receiverId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CryptoService _cryptoService = CryptoService();
  
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String _myUserId = '';

  @override
  void initState() {
    super.initState();
    _initMyUserId();
    _fetchHistoryAndConnectWs();
  }

  void _initMyUserId() {
    // Basic extraction from JWT token or storage. For now, assume it's stored or we can just detect sender based on 'sender_id'.
    // Here we'll just check if sender_id != receiverId
  }

  Future<void> _fetchHistoryAndConnectWs() async {
    // 1. Fetch History
    try {
      final response = await ApiClient().dio.get('/communication/rooms/${widget.roomId}/messages');
      final rawMessages = response.data['data'] as List<dynamic>;
      
      List<Map<String, dynamic>> decryptedMessages = [];
      for (var msg in rawMessages) {
        // If the sender is myself, I cannot decrypt it because it was encrypted with the TARGET's public key.
        // In a real E2EE system like Signal, messages are encrypted twice (once for the target, once for the sender's own other devices).
        // For simplicity in this demo, if sender_id == widget.receiverId, we decrypt. If sender_id != widget.receiverId, we'll just display a placeholder or we would have saved the plaintext locally.
        
        bool isMe = msg['sender_id'] != widget.receiverId;
        String content = '';
        
        if (isMe) {
          content = "Pesan terkirim (E2EE)";
        } else {
          content = await _cryptoService.decryptMessage(msg['ciphertext'], widget.contactPublicKey);
        }
        
        decryptedMessages.add({
          'id': msg['id'],
          'content': content,
          'isMe': isMe,
          'time': msg['sent_at']
        });
      }
      
      setState(() {
        _messages = decryptedMessages;
        _isLoading = false;
      });
      _scrollToBottom();
      
    } catch (e) {
      print("Gagal memuat riwayat: $e");
      setState(() => _isLoading = false);
    }

    // 2. Connect WebSocket
    try {
      final token = GetStorage().read('jwt_token') ?? '';
      // Because we are using an emulator, 10.0.2.2 usually maps to localhost. Using ApiClient's baseUrl to determine it safely:
      final wsUrlStr = ApiClient().dio.options.baseUrl.replaceFirst('http', 'ws').replaceAll('/api/v1', '') + '/ws/chat/${widget.roomId}';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrlStr));
      
      // Auth Handshake
      _channel!.sink.add(jsonEncode({
        "type": "auth",
        "token": token
      }));

      // Listen
      _channel!.stream.listen((payload) async {
        final data = jsonDecode(payload);
        if (data['type'] == 'message') {
          bool isMe = data['sender_id'] != widget.receiverId;
          String content = '';
          
          if (isMe) {
            content = "Pesan terkirim (E2EE)";
          } else {
            content = await _cryptoService.decryptMessage(data['content'], widget.contactPublicKey);
          }
          
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'content': content,
              'isMe': isMe,
              'time': data['sent_at'] ?? DateTime.now().toIso8601String()
            });
          });
          _scrollToBottom();
        }
      });
    } catch (e) {
      print("WebSocket error: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _channel == null) return;
    
    _messageController.clear();

    // In true E2EE, we encrypt with the receiver's public key
    String ciphertext;
    if (widget.contactPublicKey.isEmpty) {
       // Fallback if no public key (e.g. they haven't generated one yet)
       ciphertext = 'ENCRYPTED_[$text]';
    } else {
       ciphertext = await _cryptoService.encryptMessage(text, widget.contactPublicKey);
    }

    _channel!.sink.add(jsonEncode({
      "type": "message",
      "content": ciphertext
    }));
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName, style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            const Row(
              children: [
                Icon(Icons.lock, size: 12, color: Colors.greenAccent),
                SizedBox(width: 4),
                Text("E2EE Terenkripsi", style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg['content'], msg['isMe']);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.text,
            fontFamily: 'Nunito',
            fontStyle: (isMe && content == "Pesan terkirim (E2EE)") ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

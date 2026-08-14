import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  factory CryptoService() {
    return _instance;
  }

  CryptoService._internal();

  Future<String> generateAndStoreKeyPair() async {
    final algorithm = X25519();
    
    // 1. Generate Key Pair
    final keyPair = await algorithm.newKeyPair();
    
    // 2. Extract
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    
    // 3. Store both to easily reconstruct later
    await _secureStorage.write(
      key: 'e2ee_private_key', 
      value: base64Encode(privateKeyBytes)
    );
    await _secureStorage.write(
      key: 'e2ee_public_key', 
      value: base64Encode(publicKey.bytes)
    );
    
    return base64Encode(publicKey.bytes);
  }

  Future<SimpleKeyPair?> getLocalKeyPair() async {
    final privateKeyStr = await _secureStorage.read(key: 'e2ee_private_key');
    final publicKeyStr = await _secureStorage.read(key: 'e2ee_public_key');
    if (privateKeyStr == null || publicKeyStr == null) return null;
    
    final privateKeyBytes = base64Decode(privateKeyStr);
    final publicKeyBytes = base64Decode(publicKeyStr);
    
    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );
  }

  Future<String> encryptMessage(String plainText, String targetPublicKeyBase64) async {
    final myKeyPair = await getLocalKeyPair();
    if (myKeyPair == null) throw Exception("Local keypair not found");
    
    final algorithm = X25519();
    final targetPubKey = SimplePublicKey(base64Decode(targetPublicKeyBase64), type: KeyPairType.x25519);
    
    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: targetPubKey,
    );
    
    final aes = AesGcm.with256bits();
    final secretBox = await aes.encrypt(utf8.encode(plainText), secretKey: sharedSecret);
    
    // Format: nonce:ciphertext:mac
    final nonceStr = base64Encode(secretBox.nonce);
    final cipherStr = base64Encode(secretBox.cipherText);
    final macStr = base64Encode(secretBox.mac.bytes);
    
    return '$nonceStr:$cipherStr:$macStr';
  }

  Future<String> decryptMessage(String encryptedText, String senderPublicKeyBase64) async {
    try {
      final myKeyPair = await getLocalKeyPair();
      if (myKeyPair == null) throw Exception("Local keypair not found");
      
      final parts = encryptedText.split(':');
      if (parts.length != 3) {
        // Fallback for non-encrypted test messages during development
        return encryptedText.replaceAll('ENCRYPTED_[', '').replaceAll(']', '');
      }
      
      final nonce = base64Decode(parts[0]);
      final cipherText = base64Decode(parts[1]);
      final macBytes = base64Decode(parts[2]);
      
      final algorithm = X25519();
      final senderPubKey = SimplePublicKey(base64Decode(senderPublicKeyBase64), type: KeyPairType.x25519);
      
      final sharedSecret = await algorithm.sharedSecretKey(
        keyPair: myKeyPair,
        remotePublicKey: senderPubKey,
      );
      
      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
      
      final aes = AesGcm.with256bits();
      final decryptedBytes = await aes.decrypt(secretBox, secretKey: sharedSecret);
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      print("Decryption error: $e");
      return "[(Pesan terenkripsi) gagal didekripsi]";
    }
  }
}

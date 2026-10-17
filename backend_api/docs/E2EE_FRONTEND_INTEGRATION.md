# 📖 Panduan Integrasi E2EE Chat untuk Frontend Developer

> Dokumen ini menjelaskan cara mengintegrasikan sistem chat **True End-to-End Encrypted (E2EE)**
> pada aplikasi Satu Sekolah di sisi Frontend/Mobile.
>
> Backend berperan sebagai **kurir pesan buta** — ia hanya menyimpan dan meneruskan *ciphertext*
> tanpa pernah bisa membaca isi pesan.

---

## Arsitektur Umum

```
[Pengirim]                     [Backend]                    [Penerima]
   |                               |                              |
   |-- GET /contacts ------------>|                              |
   |<-- contacts + public_keys ---|                              |
   |                              |                              |
   | Enkripsi pesan               |                              |
   | menggunakan public_key       |                              |
   | milik Penerima               |                              |
   |                              |                              |
   |-- WS: send ciphertext ------>|-- WS: broadcast ciphertext ->|
   |                              |-- DB: store ciphertext       |
   |                              |                              |
   |                              |        Dekripsi pesan        |
   |                              |        menggunakan           |
   |                              |        private_key sendiri   |
```

---

## Langkah 1: Generate Key Pair (Saat Login Pertama di Device Baru)

Generate pasangan kunci RSA-OAEP atau X25519 di sisi *client* (browser/app).

**Contoh menggunakan Web Crypto API (RSA-OAEP):**
```javascript
const keyPair = await window.crypto.subtle.generateKey(
  {
    name: "RSA-OAEP",
    modulusLength: 2048,
    publicExponent: new Uint8Array([1, 0, 1]),
    hash: "SHA-256",
  },
  true, // extractable
  ["encrypt", "decrypt"]
);

// Simpan private key di IndexedDB (JANGAN kirim ke server!)
const privateKeyExport = await crypto.subtle.exportKey("pkcs8", keyPair.privateKey);
localStorage.setItem("privateKey", btoa(String.fromCharCode(...new Uint8Array(privateKeyExport))));

// Export public key sebagai Base64 untuk dikirim ke server
const publicKeyExport = await crypto.subtle.exportKey("spki", keyPair.publicKey);
const publicKeyBase64 = btoa(String.fromCharCode(...new Uint8Array(publicKeyExport)));
```

---

## Langkah 2: Upload Public Key ke Server

Setelah berhasil login dan mendapatkan JWT, upload public key ke server:

```
PUT /api/v1/users/profile/public-key
Authorization: Bearer <JWT>
Content-Type: application/json
```

**Request Body:**
```json
{
  "public_key": "<Base64-encoded SPKI public key>"
}
```

**Response:**
```json
{
  "message": "public key updated successfully"
}
```

> ⚠️ **Penting:** Lakukan ini **setiap kali user login di device baru** atau setelah generate ulang key pair.
> Jika user berganti device tanpa upload public key baru, kontak lain tidak bisa mengenkripsi pesan untuknya.

---

## Langkah 3: Ambil Daftar Kontak + Public Key Mereka

```
GET /api/v1/communication/contacts
Authorization: Bearer <JWT>
```

**Response:**
```json
{
  "data": {
    "students": [
      {
        "id": "uuid-...",
        "name": "Budi Santoso",
        "category": "student",
        "class_name": "XII RPL 1",
        "public_key": "MIIBIjANBgkq..."
      }
    ],
    "staff": [
      {
        "id": "uuid-...",
        "name": "Pak Ahmad",
        "category": "staff",
        "public_key": "MIIBIjANBgkq..."
      }
    ],
    "parents": []
  }
}
```

> **Note:** `public_key` akan kosong (`""` atau tidak ada) jika kontak tersebut belum pernah
> upload public key (misalnya belum login setelah fitur ini dirilis).
> Tangani kasus ini di UI — misalnya tampilkan pesan "Enkripsi belum tersedia untuk kontak ini".

---

## Langkah 4: Enkripsi Pesan Sebelum Dikirim

Gunakan `public_key` dari kontak sebagai kunci enkripsi:

```javascript
async function encryptMessage(plaintext, recipientPublicKeyBase64) {
  // Import public key dari Base64
  const binaryKey = Uint8Array.from(atob(recipientPublicKeyBase64), c => c.charCodeAt(0));
  const publicKey = await crypto.subtle.importKey(
    "spki",
    binaryKey.buffer,
    { name: "RSA-OAEP", hash: "SHA-256" },
    false,
    ["encrypt"]
  );

  // Enkripsi
  const encoded = new TextEncoder().encode(plaintext);
  const encrypted = await crypto.subtle.encrypt({ name: "RSA-OAEP" }, publicKey, encoded);

  // Return sebagai Base64
  return btoa(String.fromCharCode(...new Uint8Array(encrypted)));
}
```

> **Group Chat:** Untuk percakapan group, Anda perlu mengenkripsi pesan untuk **setiap anggota**
> menggunakan public key masing-masing, lalu kirim *bundle* yang berisi semua versi terenkripsi.
> Atau gunakan pendekatan **Symmetric Key + per-recipient key wrap** (seperti Signal Protocol)
> untuk efisiensi. Backend hanya menyimpan payload yang Anda kirimkan, apa pun formatnya.

---

## Langkah 5: Koneksi WebSocket & Auth via Payload

WebSocket **tidak lagi** menggunakan token di URL. Auth dilakukan melalui **pesan pertama** setelah koneksi terbuka.

```javascript
const ws = new WebSocket("wss://api.satusekolah.id/ws/chat/<room_id>");

ws.onopen = () => {
  // Pesan PERTAMA harus berupa auth payload
  ws.send(JSON.stringify({
    type: "auth",
    token: "<JWT Token>"
  }));
};

ws.onmessage = (event) => {
  const msg = JSON.parse(event.data);

  if (msg.type === "auth_ok") {
    console.log("WebSocket authenticated! Ready to chat.");
    return;
  }

  if (msg.error) {
    console.error("WS Error:", msg.error, "Code:", msg.code);
    ws.close();
    return;
  }

  // Pesan chat yang masuk — content adalah ciphertext
  decryptAndDisplay(msg.content, msg.sender_id);
};

// Kirim pesan (content harus berupa ciphertext hasil enkripsi)
async function sendMessage(plaintext, recipientPublicKey) {
  const ciphertext = await encryptMessage(plaintext, recipientPublicKey);
  ws.send(JSON.stringify({
    type: "message",
    content: ciphertext
  }));
}
```

**Kode Error WebSocket:**
| Code | Arti |
|------|------|
| `4001` | Pesan pertama bukan `{"type":"auth","token":"..."}` |
| `4003` | Token JWT tidak valid atau sudah kedaluwarsa |

> ⏱️ **Timeout Auth:** Server memberi waktu **10 detik** untuk mengirim pesan auth setelah koneksi terbuka.
> Jika melewati batas waktu, koneksi diputus otomatis.

---

## Langkah 6: Tampilkan Riwayat Chat

```
GET /api/v1/chat/<room_id>/history
Authorization: Bearer <JWT>
```

**Response:**
```json
{
  "data": [
    {
      "id": "uuid-...",
      "room_id": "uuid-...",
      "sender_id": "uuid-...",
      "ciphertext": "base64-ciphertext...",
      "created_at": "2026-06-08T10:00:00Z"
    }
  ],
  "note": "Messages are client-encrypted ciphertext. Decrypt using the recipient's private key on the device."
}
```

**Dekripsi setiap pesan:**
```javascript
async function decryptMessage(ciphertextBase64) {
  // Load private key dari IndexedDB/localStorage
  const privateKeyBase64 = localStorage.getItem("privateKey");
  const binaryKey = Uint8Array.from(atob(privateKeyBase64), c => c.charCodeAt(0));
  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey.buffer,
    { name: "RSA-OAEP", hash: "SHA-256" },
    false,
    ["decrypt"]
  );

  // Dekripsi
  const cipherBuffer = Uint8Array.from(atob(ciphertextBase64), c => c.charCodeAt(0));
  const decrypted = await crypto.subtle.decrypt({ name: "RSA-OAEP" }, privateKey, cipherBuffer.buffer);

  return new TextDecoder().decode(decrypted);
}
```

---

## ⚠️ Hal-Hal Penting untuk Frontend

| Kondisi | Penanganan |
|---------|-----------|
| Kontak belum upload `public_key` | Tampilkan "Enkripsi belum tersedia, minta kontak untuk login ulang" |
| Pesan dari sebelum fitur E2EE aktif | Tampilkan "Pesan ini tidak dapat didekripsi (format lama)" |
| User ganti device | Generate ulang key pair & upload public key baru. Pesan lama **tidak dapat dibaca** di device baru (by design) |
| Private key hilang | Pesan lama permanen tidak bisa dibaca — sama seperti WhatsApp. Sarankan backup key |

---

## Ringkasan Endpoint

| Method | Endpoint | Kegunaan |
|--------|----------|----------|
| `PUT` | `/api/v1/users/profile/public-key` | Upload/update public key device |
| `GET` | `/api/v1/communication/contacts` | Ambil kontak + public key mereka |
| `WS` | `/ws/chat/:room_id` | Koneksi real-time (auth via payload pertama) |
| `GET` | `/api/v1/chat/:room_id/history` | Riwayat pesan (ciphertext, dekripsi di client) |

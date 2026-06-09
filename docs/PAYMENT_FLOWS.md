# Panduan Alur Pembayaran Terpadu (IoT & Midtrans)

Dokumen ini menjelaskan secara rinci seluruh skenario pembayaran dan alur kerja teknis di backend **Satu Sekolah**. Sistem pembayaran dipisahkan secara tegas antara metode fisik (IoT/RFID) dan metode *online* (Midtrans/Transfer).

## 1. Format Kode Pembayaran di Berbagai Modul

Sistem akan melakukan *generate* kode yang berbeda berdasarkan modul dan metode pembayaran yang dipilih oleh user.

### Modul Kantin (POS / Pesan Antar)

| Metode Pembayaran (Kasir/App) | Tujuan / Alat | Format Kode yang Dihasilkan | Contoh Hasil Generate |
| :--- | :--- | :--- | :--- |
| **Tap Mesin RFID** | Terminal Fisik IoT (Mesin EDC Sekolah) | **12 Digit Angka Murni** | `048192348572` |
| **Dynamic QR Code** | Layar Kasir / Aplikasi Siswa | **QR- + UUID** | `QR-8a7b6c5d-4e3f...` |
| **Transfer Langsung** | Aplikasi Siswa | **No. Rekening + 3 Digit Unik** | `1234567890123` |

### Modul Keuangan (Bayar SPP / Tagihan)

| Metode Pembayaran | Tujuan / Alat | Format Kode yang Dihasilkan | Contoh Hasil Generate |
| :--- | :--- | :--- | :--- |
| **Online (Midtrans)** | Virtual Account, QRIS, GoPay, e-Wallet | **NCS + BankCode + YYYYMMDD + 6 Angka** | `NCS12320260609038291` |
| **Tap Mesin RFID** | Terminal Fisik IoT di Loket Tata Usaha | **12 Digit Angka Murni** | `918273645019` |
| **Transfer Bank Manual** | Aplikasi M-Banking Orang Tua | **VA 15 Digit** | `123456789012345` |

### Modul AI (SaaS Billing Sekolah)

| Metode Pembayaran | Tujuan / Alat | Format Kode yang Dihasilkan | Contoh Hasil Generate |
| :--- | :--- | :--- | :--- |
| **Online (Midtrans)** | Pembelian Kuota Token AI oleh Admin | **AI-TOKENS-{TenantID}-{Random}** | `AI-TOKENS-123e45...` |

---

## 2. Alur Pembayaran Menggunakan Terminal IoT RFID (Fisik)

Skenario teknis ini menggambarkan interaksi antara Backend, Kasir (POS), dan Perangkat IoT (RFID Reader & Keypad).

### Langkah 1: Kasir Membuat Pesanan
1. Kasir menginput barang ke keranjang di aplikasi POS.
2. Kasir memilih metode pembayaran: **"RFID"**.
3. *Frontend* mengirim request ke backend `POST /api/v1/canteen/pos/order`.
4. *Backend* membuat *order* dan melakukan *generate* 12 digit angka murni sebagai `rfid_payment_code` (Contoh: `048192348572`).
5. *Frontend* Kasir menampilkan kode ini secara *real-time* di layar komputer/tablet.

### Langkah 2: Interaksi Siswa dengan Alat IoT RFID
1. **Input Kode Pembayaran:**
   Siswa/Petugas mengetikkan kode `048192348572` menggunakan *Keypad* Alat IoT.
   
2. **Validasi Pesanan (Opsional tapi Direkomendasikan):**
   Alat IoT mengirim request ke backend:
   `GET /api/v1/iot/canteen/order/048192348572`
   *Backend* mengembalikan detail order (misal: "Nasi Goreng, Total: Rp 15.000"). Alat IoT menampilkannya di layar LCD.

3. **Tap Kartu Pelajar:**
   Siswa menempelkan kartu (ID Card RFID) ke sensor IoT. Alat IoT membaca UID kartu (misal: `E200001B2`).

4. **Input PIN Keamanan:**
   Layar IoT akan meminta siswa menginput 6-digit PIN. Siswa mengetikkan `123456` di *Keypad*.

### Langkah 3: Eksekusi Pembayaran oleh Alat IoT
Alat IoT merangkum semua input fisik tersebut dan mengirimkannya ke Backend:
`POST /api/v1/iot/canteen/pay-rfid`
**Payload:**
```json
{
  "rfid_payment_code": "048192348572",
  "rfid_tag": "E200001B2",
  "pin": "123456"
}
```

### Langkah 4: Validasi & Proses Transaksi oleh Backend
Di dalam server Backend, alur berikut berjalan secara instan (Atomic Transaction):
1. **Validasi User**: Backend mencari pengguna berdasarkan `rfid_tag` -> Ketemu: Budi.
2. **Validasi PIN**: Backend mencocokkan hash dari `123456` dengan PIN Budi di database -> Valid.
3. **Validasi Order**: Backend mencari order dengan kode `048192348572` -> Ditemukan, status `PENDING`, Total Rp 15.000.
4. **Mutasi Dompet (Ledger)**: 
   - Backend memotong Rp 15.000 dari dompet digital Budi.
   - Backend menambahkan Rp 15.000 ke dompet digital Pemilik Kantin.
5. **Update Status**: Status Order diubah menjadi `COMPLETED`.
6. **Response**: Backend mengembalikan respon `HTTP 200 OK` ke Alat IoT.

### Langkah 5: Penyelesaian
- Alat IoT berbunyi dan menampilkan tulisan "Pembayaran Berhasil. Sisa Saldo: Rp X".
- Aplikasi Kasir (yang mungkin melakukan *polling* atau menerima WebSocket/SSE) otomatis berubah layarnya menjadi "PESANAN LUNAS".
- Siswa menerima barangnya.

---

## 3. Alur Pembayaran Menggunakan Midtrans (Online)

Skenario teknis ini menggambarkan interaksi antara *Frontend* Orang Tua/Siswa, *Backend*, dan Midtrans (API & Webhook).

### Langkah 1: Inisiasi Pembayaran
1. Orang Tua membuka modul Keuangan di aplikasi, memilih Tagihan SPP.
2. Orang Tua menekan tombol **"Bayar via Midtrans"**.
3. *Frontend* memanggil API Backend `POST /api/v1/finance/billing/:invoiceId/pay-cash`.
4. *Backend* melakukan *generate* Midtrans Order ID (Contoh: `NCS12320260609038291`).
5. *Backend* memanggil API Midtrans `snap.CreateTransaction` untuk membuat sesi pembayaran.
6. *Backend* menerima `snap_token` dan `redirect_url` dari Midtrans, lalu mengembalikannya ke *Frontend*.

### Langkah 2: Pembayaran di Antarmuka Midtrans (Snap)
1. *Frontend* menampilkan antarmuka Midtrans Snap Pop-up.
2. Orang Tua memilih metode pembayaran (BCA Virtual Account, GoPay, dll).
3. Orang Tua mentransfer uang sejumlah tagihan.

### Langkah 3: Konfirmasi Otomatis via Webhook
1. Midtrans menerima uang, dan seketika menembak API *Backend* kita: `POST /api/v1/webhooks/midtrans`.
2. *Backend* memverifikasi HMAC SHA512 Signature Key dari Midtrans untuk memastikan permintaan valid.
3. *Backend* mengambil `order_id` (`NCS12320260609038291`) dan status transaksi (`settlement` / `capture`).
4. Backend mencari invoice terkait berdasarkan ID tersebut, memperbarui `paid_amount`, dan jika sudah lunas mengubah status menjadi `PAID`.
5. Uang masuk secara otomatis. Orang tua melihat tagihan telah lunas di aplikasi.

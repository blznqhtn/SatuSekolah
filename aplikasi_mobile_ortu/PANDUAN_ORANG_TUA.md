# Panduan Lengkap Role Orang Tua (Parent)

Dokumen ini adalah kompilasi dari seluruh fitur, arsitektur, dan hak akses yang berkaitan secara spesifik dengan *role* **Orang Tua (Parent)** di dalam sistem ERP "Satu Sekolah". Kompilasi ini ditarik dari 7 dokumen utama sistem backend.

---

## 1. Pendaftaran & Manajemen Akun (SPMB)
- **Orphan Parent**: Orang tua dapat mendaftar melalui aplikasi global (Satu Sekolah Global) tanpa langsung terikat pada satu sekolah (*tenant_id* = `null`). Mereka dapat memanggil *endpoint* `GET /public/schools` untuk melihat dan mencari daftar sekolah yang tersedia.
- **Penerimaan Murid Baru (SPMB)**: 
  1. Orang tua memilih sekolah dan gelombang pendaftaran.
  2. Orang tua membayar biaya formulir pendaftaran melalui integrasi Midtrans.
  3. Setelah siswa/anak lolos seleksi, sistem akan men- *generate* akun siswa baru dengan mengikatkan ID Siswa tersebut ke ID Orang Tua melalui skema *Self-Relation* (`users.parent_id` = ID Orang Tua).
- **Multi-Child Binding**: Satu akun Orang Tua dapat dikaitkan dengan lebih dari satu anak.

## 2. Keuangan & Tagihan (Satu Pay & Midtrans)
- **Tagihan Anak (SPP, Gedung, dll)**: Orang tua memiliki akses ke *endpoint* khusus (misal: `GET /students/me/billing`) untuk memonitor seluruh invoice/tagihan yang dimiliki oleh anak mereka.
- **Top-Up Kantin & Uang Saku**: Orang tua dapat mentransfer uang/top-up ke dompet digital anak (Satu Pay). Uang ini nanti digunakan anak untuk berbelanja di Kantin Digital dengan QR/RFID.
- **Metode Pembayaran SPP**:
  - Jika dompet internal cukup: Bayar langsung dari saldo aplikasi.
  - Jika saldo tidak ada/kurang: Orang tua menekan tombol "Bayar via Midtrans" → Memilih metode seperti Virtual Account Bank, GoPay, Qris, dll → Transfer manual.
  - *Keamanan*: Jumlah tagihan bersifat *Backend-Calculated*. Midtrans memproses uang, dan aplikasi akan menampilkan lunas *hanya* setelah Webhook divalidasi oleh backend.

## 3. Komunikasi & Jaringan Obrolan (True E2EE)
- **Broadcast Pengumuman**: Sekolah dapat menyiarkan pengumuman (Mading Digital) yang secara spesifik menargetkan audiens Orang Tua (`target_audience` = `PARENTS`), atau lebih spesifik seperti "Orang Tua Kelas 12".
- **Visibilitas Kontak Chat**: Berdasarkan *Rule of Contact Visibility*, jika orang tua memanggil `GET /communication/contacts`, mereka **HANYA** akan melihat:
  1. Anak mereka sendiri.
  2. Teman-teman sekelas anaknya.
  3. Orang tua dari teman-teman sekelas anaknya.
  4. Seluruh Staf, Guru, dan Admin.
- **Chat Terenkripsi**: Percakapan orang tua dengan guru atau wali kelas menggunakan teknologi **End-to-End Encryption (E2EE)**. Semua *public key* & *private key* berada di aplikasi mobile (perangkat orang tua). Server Backend (Satu Sekolah) murni hanya sebagai "Kurir Buta" yang menyimpan pesan dalam bentuk *ciphertext* yang tidak bisa dibaca oleh programmer atau pemilik server.

## 4. Akademik, Kesehatan & Kesiswaan
- **Raport Digital**: Orang tua dapat melihat nilai dan ranking (leaderboard) anak secara instan setelah diunggah oleh wali kelas (via `GET /students/me/grades`).
- **Rekam Medis (UKS)**: Orang tua memiliki hak akses untuk melihat data rekam kesehatan rutin anak mereka (seperti Tinggi Badan, Berat Badan, penglihatan mata, dan catatan UKS lainnya).
- **Pelanggaran (Violations)**: Dalam skema *database*, terdapat penanda `parent_notified`. Artinya, jika anak melakukan pelanggaran berat dan di-input oleh staf Kesiswaan, sistem dapat secara otomatis memberi tahu (notifikasi) ke perangkat orang tua bahwa anaknya mendapat poin pelanggaran.

---
*Catatan: Dokumen ini diletakkan di dalam folder `aplikasi_mobile_ortu` untuk memandu pengembangan UI/UX dan alur data khusus bagi aplikasi klien Orang Tua.*

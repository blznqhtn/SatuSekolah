# Implementasi Teknis & Hak Akses Orang Tua (Parent)

Dokumen ini menjelaskan bagaimana hak akses (Otorisasi) untuk *role* **Orang Tua (Parent)** dikelola secara teknis dari sisi kode *Backend* (khususnya di folder `internal/middleware`) dan bagaimana Aplikasi Mobile (Frontend) harus menggunakannya.

---

## 1. Sistem Token (JWT Claims)
Ketika pengguna Orang Tua berhasil *Login* via *endpoint* Autentikasi, backend akan menghasilkan token **JWT (JSON Web Token)**. Di dalam folder `internal/middleware/jwt.go`, struktur token ini mencatat identitas pengguna:
```json
{
  "user_id": "uuid-orangtua",
  "tenant_id": "uuid-sekolah",
  "role": "Parent"
}
```
**Tugas Frontend:** Aplikasi Mobile *wajib* menyimpan token ini secara aman (misal: menggunakan *Secure Storage* atau *GetStorage* di Flutter) dan selalu mengirimkannya di setiap permintaan (HTTP Request) pada *Header*:
`Authorization: Bearer <TOKEN>`

## 2. Pelindung Rute (RBAC Middleware)
Di dalam backend (tepatnya di `internal/middleware/rbac.go`), terdapat pelindung rute yang disebut `RequireRole`.
Fungsi ini digunakan untuk membatasi *endpoint* mana saja yang boleh dimasuki oleh Orang Tua.

Contoh pemakaian di backend:
```go
// Hanya pengguna dengan role "Parent", "Student", atau "Admin" yang bisa melihat pengumuman
router.Get("/announcements", middleware.RequireRole("parent", "student", "admin"), handler.GetAnnouncements)
```
Jika aplikasi mobile mencoba menembak URL yang dikunci dengan `RequireRole("Admin")` namun menggunakan token Orang Tua, backend akan otomatis menolak permintaan dengan kode HTTP `403 Forbidden`.

## 3. Pengecekan Kepemilikan Data (Data Ownership)
Memiliki *role* `Parent` saja tidak cukup! Sistem backend juga mengamankan privasi antar-orang tua. 
Misalnya pada *endpoint* `GET /students/:id/grades`:
- Backend tidak hanya mengecek `RequireRole("Parent")`.
- Backend juga akan mencocokkan apakah `user_id` dari JWT token (yang merupakan ID Orang Tua) sama dengan `parent_id` yang terikat pada data Siswa tersebut di *database*.
- Ini memastikan **Orang Tua A tidak akan pernah bisa melihat nilai, rekam medis, atau tagihan SPP dari Anak B**.

## 4. Cara Aplikasi Mobile Menangani Hak Akses
Berdasarkan arsitektur *backend* di atas, aplikasi mobile orang tua harus mengimplementasikan hal berikut:
1. **Penyimpanan Token**: Simpan token JWT sesaat setelah *Login*.
2. **Interceptor HTTP**: Buat penengah (Dio/Http Interceptor) yang otomatis menyuntikkan `Bearer Token` ke setiap *request* yang mengarah ke server `Satu Sekolah`.
3. **Handling 401 & 403**: 
   - Jika menerima respons `401 Unauthorized`, arahkan (lempar) orang tua kembali ke layar *Login* karena token telah kedaluwarsa (expired).
   - Jika menerima respons `403 Forbidden`, tampilkan pesan ramah "Anda tidak memiliki akses ke halaman ini".
4. **Penyimpanan ID Lokal**: Simpan `user_id` (ID Orang Tua) untuk digunakan pada navigasi seperti mengambil daftar anak yang terkait dengan dirinya.

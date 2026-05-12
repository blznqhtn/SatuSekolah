@extends('layouts.app')

@section('title', 'Terms and Conditions')

@section('content')
    <main class="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 py-12">
        <div class="text-center mb-16">
            <div class="inline-flex items-center justify-center p-3 bg-primary-100 dark:bg-primary-900 rounded-xl mb-4">
                <i class="fa-solid fa-file-contract text-3xl text-primary-600 dark:text-primary-300"></i>
            </div>
            <h2 class="text-3xl font-extrabold tracking-tight text-gray-900 dark:text-white sm:text-4xl">
                Syarat dan Ketentuan SeHadir
            </h2>
            <p class="mt-4 text-lg text-gray-500 dark:text-gray-400 max-w-2xl mx-auto">
                Aturan dan panduan penggunaan layanan sistem presensi SeHadir untuk memastikan kenyamanan dan keamanan
                seluruh pengguna.
            </p>
            <div class="mt-6 flex justify-center items-center text-sm text-gray-400">
                <i class="fa-regular fa-clock mr-2"></i>
                Terakhir diperbarui: {{ date('d F Y') }}
            </div>
        </div>

        <div class="space-y-10">
            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-handshake text-primary-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">1. Penerimaan Ketentuan</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        Dengan mengakses atau menggunakan aplikasi <strong>SeHadir</strong>, Anda menyatakan bahwa Anda
                        telah membaca, memahami, dan setuju untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak
                        setuju, mohon untuk tidak melanjutkan penggunaan layanan kami.
                    </p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div
                    class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 transition-all hover:shadow-md">
                    <div class="flex items-center mb-6">
                        <i class="fa-solid fa-user-check text-blue-500 mr-3 text-xl"></i>
                        <h3 class="text-xl font-bold text-gray-900 dark:text-white">2. Kewajiban Pengguna</h3>
                    </div>
                    <ul class="space-y-4">
                        <li class="flex items-start">
                            <i class="fa-solid fa-check text-green-500 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300">Memberikan data identitas yang akurat dan
                                sah.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-check text-green-500 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300">Menjaga kerahasiaan akun dan kartu RFID milik
                                pribadi.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-check text-green-500 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300">Melakukan presensi sesuai dengan jadwal yang
                                ditentukan.</span>
                        </li>
                    </ul>
                </div>

                <div
                    class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 transition-all hover:shadow-md">
                    <div class="flex items-center mb-6">
                        <i class="fa-solid fa-ban text-red-500 mr-3 text-xl"></i>
                        <h3 class="text-xl font-bold text-gray-900 dark:text-white">3. Pembatasan Penggunaan</h3>
                    </div>
                    <ul class="space-y-4">
                        <li class="flex items-start">
                            <i class="fa-solid fa-xmark text-red-400 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300">Dilarang memanipulasi data Face ID atau sistem
                                RFID.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-xmark text-red-400 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300">Dilarang menitipkan kartu RFID kepada pengguna
                                lain.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-xmark text-red-400 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300">Dilarang melakukan akses ilegal ke API atau
                                sistem backend.</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="bg-primary-600 rounded-2xl p-8 text-white shadow-lg overflow-hidden relative">
                <div class="relative z-10">
                    <div class="flex items-center mb-4">
                        <i class="fa-solid fa-copyright text-white mr-3 text-2xl"></i>
                        <h3 class="text-2xl font-bold">4. Kekayaan Intelektual</h3>
                    </div>
                    <p class="text-primary-100 leading-relaxed mb-4">
                        Seluruh konten, logo, desain, kode sumber, dan algoritma FACE ID yang ada pada aplikasi
                        <strong>SeHadir</strong> adalah milik sah pengembang dan dilindungi oleh undang-undang hak cipta.
                        Penggandaan tanpa izin tertulis merupakan pelanggaran hukum.
                    </p>
                    <div class="inline-flex items-center bg-primary-700 bg-opacity-50 px-4 py-2 rounded-full text-sm">
                        <i class="fa-solid fa-trademark mr-2"></i> All Rights Reserved © 2026 SeHadir Team
                    </div>
                </div>
                <i class="fa-solid fa-gavel text-9xl absolute -bottom-10 -right-10 text-primary-500 opacity-20"></i>
            </div>

            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-triangle-exclamation text-amber-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">5. Batasan Tanggung Jawab</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        SeHadir tidak bertanggung jawab atas kesalahan pencatatan yang disebabkan oleh kegagalan hardware
                        pihak ketiga (pembaca RFID rusak), koneksi internet sekolah yang tidak stabil, atau kelalaian
                        pengguna dalam menjaga fisik kartu RFID.
                    </p>
                </div>
            </div>

            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-screwdriver-wrench text-emerald-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">6. Perubahan Layanan</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        Kami berhak memperbarui fitur, mengubah antarmuka, atau menghentikan sementara layanan untuk
                        keperluan pemeliharaan (maintenance) guna meningkatkan performa sistem tanpa pemberitahuan
                        sebelumnya.
                    </p>
                </div>
            </div>

            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-scale-balanced text-indigo-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">7. Hukum yang Berlaku</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        Syarat dan Ketentuan ini diatur dan ditafsirkan sesuai dengan hukum yang berlaku di <strong>Republik
                            Indonesia</strong>. Segala perselisihan yang timbul akan diselesaikan secara musyawarah mufakat
                        atau melalui yurisdiksi pengadilan yang berwenang.
                    </p>
                </div>
            </div>

            <div
                class="bg-gray-50 dark:bg-gray-900 rounded-3xl border-2 border-dashed border-gray-200 dark:border-gray-700 p-8 text-center">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Ada Pertanyaan Mengenai Aturan Ini?</h3>
                <p class="text-gray-500 dark:text-gray-400 mb-8">Tim kami siap membantu menjelaskan secara detail mengenai
                    implementasi syarat dan ketentuan ini.</p>

                <div class="flex flex-wrap justify-center gap-4">
                    <a href="mailto:kadaviradityaa@gmail.com"
                        class="inline-flex items-center px-6 py-3 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:shadow transition-all border border-gray-200 dark:border-gray-700 group">
                        <i
                            class="fa-solid fa-envelope text-primary-500 mr-2 group-hover:scale-110 transition-transform"></i>
                        Hubungi Support
                    </a>
                    <a href="{{ url('/privacy-policy') }}"
                        class="inline-flex items-center px-6 py-3 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:shadow transition-all border border-gray-200 dark:border-gray-700 group">
                        <i
                            class="fa-solid fa-shield-halved text-blue-500 mr-2 group-hover:scale-110 transition-transform"></i>
                        Kebijakan Privasi
                    </a>
                </div>
            </div>
        </div>
    </main>
@endsection

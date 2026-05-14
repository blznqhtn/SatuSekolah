@extends('layouts.app')

@section('title', 'Help Center')

@section('content')
    <main class="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 py-12 min-h-screen">
        <div class="text-center mb-16">
            <div class="inline-flex items-center justify-center p-3 bg-primary-100 dark:bg-primary-900 rounded-2xl mb-6">
                <i class="fa-solid fa-headset text-3xl text-primary-600 dark:text-primary-300"></i>
            </div>
            <h2 class="text-3xl font-extrabold tracking-tight text-gray-900 dark:text-white sm:text-4xl">
                Pusat Bantuan SeHadir
            </h2>
            <p class="mt-4 text-lg text-gray-500 dark:text-gray-400 max-w-2xl mx-auto leading-relaxed">
                Temukan jawaban cepat untuk pertanyaan Anda atau pelajari cara memaksimalkan penggunaan sistem presensi
                SeHadir.
            </p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-3 gap-8 mb-20">
            <div
                class="bg-white dark:bg-gray-800 p-8 rounded-3xl border border-gray-100 dark:border-gray-700 text-center hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group">
                <div
                    class="w-14 h-14 bg-blue-50 dark:bg-blue-900/30 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform">
                    <i class="fa-solid fa-id-card text-2xl text-blue-500"></i>
                </div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-3 text-lg">Masalah RFID</h4>
                <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed">Kartu tidak terbaca, rusak, atau
                    kehilangan fisik kartu.</p>
            </div>

            <div
                class="bg-white dark:bg-gray-800 p-8 rounded-3xl border border-gray-100 dark:border-gray-700 text-center hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group">
                <div
                    class="w-14 h-14 bg-purple-50 dark:bg-purple-900/30 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform">
                    <i class="fa-solid fa-face-smile text-2xl text-purple-500"></i>
                </div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-3 text-lg">Masalah Face ID</h4>
                <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed">Wajah tidak dikenali atau gagal saat
                    melakukan pemindaian.</p>
            </div>

            <div
                class="bg-white dark:bg-gray-800 p-8 rounded-3xl border border-gray-100 dark:border-gray-700 text-center hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group">
                <div
                    class="w-14 h-14 bg-emerald-50 dark:bg-emerald-900/30 rounded-2xl flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform">
                    <i class="fa-solid fa-user-gear text-2xl text-emerald-500"></i>
                </div>
                <h4 class="font-bold text-gray-900 dark:text-white mb-3 text-lg">Akun & Data</h4>
                <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed">Masalah login, lupa password, atau
                    pembaruan data diri.</p>
            </div>
        </div>

        <div class="max-w-4xl mx-auto">
            <h3
                class="text-2xl font-bold text-gray-900 dark:text-white mb-10 flex items-center justify-center sm:justify-start">
                <span class="w-8 h-8 bg-primary-500 rounded-lg flex items-center justify-center mr-4 text-white text-sm">
                    <i class="fa-solid fa-question"></i>
                </span>
                Pertanyaan Sering Diajukan (FAQ)
            </h3>

            <div class="space-y-4">
                <details
                    class="group bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:border-primary-300">
                    <summary class="flex justify-between items-center p-6 cursor-pointer list-none">
                        <span class="font-semibold text-gray-900 dark:text-white pr-4">Bagaimana jika kartu RFID saya
                            hilang?</span>
                        <div class="text-gray-400 group-open:rotate-180 transition-transform duration-300">
                            <i class="fa-solid fa-chevron-down"></i>
                        </div>
                    </summary>
                    <div
                        class="px-6 pb-6 text-gray-600 dark:text-gray-400 leading-relaxed text-sm border-t border-gray-50 dark:border-gray-700/50 pt-5">
                        Segera laporkan kepada administrator sekolah atau bagian kesiswaan. Kartu lama Anda akan
                        dinonaktifkan untuk mencegah penyalahgunaan, dan Anda akan diberikan kartu pengganti dengan ID yang
                        baru.
                    </div>
                </details>

                <details
                    class="group bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:border-primary-300">
                    <summary class="flex justify-between items-center p-6 cursor-pointer list-none">
                        <span class="font-semibold text-gray-900 dark:text-white pr-4">Mengapa Face ID gagal mengenali wajah
                            saya?</span>
                        <div class="text-gray-400 group-open:rotate-180 transition-transform duration-300">
                            <i class="fa-solid fa-chevron-down"></i>
                        </div>
                    </summary>
                    <div
                        class="px-6 pb-6 text-gray-600 dark:text-gray-400 leading-relaxed text-sm border-t border-gray-50 dark:border-gray-700/50 pt-5">
                        Hal ini bisa disebabkan oleh pencahayaan yang kurang, penggunaan aksesori yang menutupi wajah
                        (seperti masker atau kacamata hitam), atau posisi wajah yang terlalu jauh. Pastikan wajah berada
                        dalam bingkai yang ditentukan.
                    </div>
                </details>

                <details
                    class="group bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:border-primary-300">
                    <summary class="flex justify-between items-center p-6 cursor-pointer list-none">
                        <span class="font-semibold text-gray-900 dark:text-white pr-4">Apakah orang tua bisa melihat jam
                            kehadiran saya?</span>
                        <div class="text-gray-400 group-open:rotate-180 transition-transform duration-300">
                            <i class="fa-solid fa-chevron-down"></i>
                        </div>
                    </summary>
                    <div
                        class="px-6 pb-6 text-gray-600 dark:text-gray-400 leading-relaxed text-sm border-t border-gray-50 dark:border-gray-700/50 pt-5">
                        Ya, jika sekolah mengaktifkan fitur notifikasi, orang tua akan menerima informasi waktu masuk dan
                        pulang secara real-time melalui aplikasi atau dashboard publik yang tersedia.
                    </div>
                </details>

                <details
                    class="group bg-white dark:bg-gray-800 rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300 hover:border-primary-300">
                    <summary class="flex justify-between items-center p-6 cursor-pointer list-none">
                        <span class="font-semibold text-gray-900 dark:text-white pr-4">Bagaimana cara mengunduh laporan
                            presensi bulanan?</span>
                        <div class="text-gray-400 group-open:rotate-180 transition-transform duration-300">
                            <i class="fa-solid fa-chevron-down"></i>
                        </div>
                    </summary>
                    <div
                        class="px-6 pb-6 text-gray-600 dark:text-gray-400 leading-relaxed text-sm border-t border-gray-50 dark:border-gray-700/50 pt-5">
                        Fitur unduh laporan (Export XLSX) hanya tersedia bagi akun dengan level
                        <strong>Administrator</strong> atau <strong>Guru</strong> melalui menu Dashboard Utama.
                    </div>
                </details>
            </div>
        </div>

        <div
            class="mt-24 bg-primary-600 rounded-4xl p-10 md:p-16 text-white text-center relative overflow-hidden shadow-2xl shadow-primary-500/20">
            <div class="relative z-10">
                <h3 class="text-3xl font-bold mb-4">Masih Belum Menemukan Solusi?</h3>
                <p class="text-primary-100 mb-10 max-w-xl mx-auto text-lg opacity-90">Tim teknis kami siap membantu Anda.
                    Kami biasanya membalas dalam waktu kurang dari 24 jam kerja.</p>

                <div class="flex flex-col sm:flex-row justify-center gap-5">
                    <a href="https://wa.me/62895383107479"
                        class="inline-flex items-center justify-center px-8 py-4 rounded-2xl bg-white text-primary-600 font-bold hover:bg-primary-50 transition-all shadow-lg active:scale-95">
                        <i class="fa-brands fa-whatsapp mr-3 text-xl text-green-500"></i> Chat WhatsApp
                    </a>
                    <a href="mailto:kadaviradityaa@gmail.com"
                        class="inline-flex items-center justify-center px-8 py-4 rounded-2xl bg-primary-700 text-white font-bold hover:bg-primary-800 transition-all border border-primary-500 shadow-lg active:scale-95">
                        <i class="fa-solid fa-envelope mr-3 text-xl text-primary-200"></i> Kirim Email
                    </a>
                </div>
            </div>
            <div class="absolute -top-12 -left-12 w-48 h-48 bg-primary-500 rounded-full opacity-30 blur-3xl"></div>
            <div class="absolute -bottom-16 -right-16 w-72 h-72 bg-white/10 rounded-full opacity-20 blur-3xl"></div>
        </div>
    </main>
@endsection

@push('styles')
    <style>
        summary::-webkit-details-marker {
            display: none;
        }

        summary {
            list-style: none;
        }

        details[open] {
            border-color: #3b82f6;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
    </style>
@endpush

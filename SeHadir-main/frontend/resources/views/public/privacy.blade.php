@extends('layouts.app')

@section('title', 'Privacy Policy')

@section('content')
    <main class="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 py-12">
        <div class="text-center mb-16">
            <div class="inline-flex items-center justify-center p-3 bg-primary-100 dark:bg-primary-900 rounded-xl mb-4">
                <i class="fa-solid fa-shield-halved text-3xl text-primary-600 dark:text-primary-300"></i>
            </div>
            <h2 class="text-3xl font-extrabold tracking-tight text-gray-900 dark:text-white sm:text-4xl">
                Kebijakan Privasi SeHadir
            </h2>
            <p class="mt-4 text-lg text-gray-500 dark:text-gray-400 max-w-2xl mx-auto">
                Komitmen kami untuk melindungi data pribadi siswa dan transparansi dalam penggunaan teknologi RFID & Face ID
                sesuai dengan UU Pelindungan Data Pribadi (UU PDP).
            </p>
            <div class="mt-6 flex flex-wrap justify-center items-center gap-4 text-sm text-gray-400">
                <div class="flex items-center">
                    <i class="fa-regular fa-clock mr-2"></i>
                    Terakhir diperbarui: {{ date('d F Y') }}
                </div>
            </div>
        </div>

        <div class="space-y-10">
            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-circle-info text-primary-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">1. Pendahuluan</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        Selamat datang di Kebijakan Privasi <strong>SeHadir</strong>. Dokumen ini menjelaskan bagaimana kami
                        mengumpulkan,
                        menggunakan, dan melindungi data pribadi yang diperoleh melalui sistem presensi berbasis RFID dan
                        FACE ID
                        yang dirancang khusus untuk efisiensi pendidikan.
                    </p>
                    <p>
                        Dengan menggunakan layanan kami, Anda mempercayakan informasi Anda kepada kami dan menyetujui
                        praktik
                        yang dijelaskan dalam kebijakan ini.
                    </p>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div
                    class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 transition-all hover:shadow-md">
                    <div class="flex items-center mb-6">
                        <i class="fa-solid fa-database text-blue-500 mr-3 text-xl"></i>
                        <h3 class="text-xl font-bold text-gray-900 dark:text-white">2. Data yang Dikumpulkan</h3>
                    </div>
                    <ul class="space-y-4">
                        <li class="flex items-start">
                            <i class="fa-solid fa-check text-green-500 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300"><strong
                                    class="text-gray-900 dark:text-white">Identitas:</strong> Nama lengkap, NIS, dan
                                Kelas.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-check text-green-500 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300"><strong
                                    class="text-gray-900 dark:text-white">Biometrik & RFID:</strong> Data Face ID (enkripsi
                                hash) dan ID unik kartu RFID.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-check text-green-500 mt-1 mr-3"></i>
                            <span class="text-gray-600 dark:text-gray-300"><strong class="text-gray-900 dark:text-white">Log
                                    Presensi:</strong> Waktu akses, lokasi terminal, dan status kehadiran.</span>
                        </li>
                    </ul>
                </div>

                <div
                    class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 transition-all hover:shadow-md">
                    <div class="flex items-center mb-6">
                        <i class="fa-solid fa-gears text-purple-500 mr-3 text-xl"></i>
                        <h3 class="text-xl font-bold text-gray-900 dark:text-white">3. Penggunaan Data</h3>
                    </div>
                    <ul class="space-y-4">
                        <li class="flex items-start">
                            <i class="fa-solid fa-circle-dot text-primary-400 mt-1.5 mr-3 text-[10px]"></i>
                            <span class="text-gray-600 dark:text-gray-300">Otomatisasi pencatatan kehadiran siswa.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-circle-dot text-primary-400 mt-1.5 mr-3 text-[10px]"></i>
                            <span class="text-gray-600 dark:text-gray-300">Penyediaan laporan administratif untuk
                                sekolah.</span>
                        </li>
                        <li class="flex items-start">
                            <i class="fa-solid fa-circle-dot text-primary-400 mt-1.5 mr-3 text-[10px]"></i>
                            <span class="text-gray-600 dark:text-gray-300">Notifikasi kehadiran real-time kepada orang
                                tua/wali.</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="bg-primary-600 rounded-2xl p-8 text-white shadow-lg overflow-hidden relative">
                <div class="relative z-10">
                    <div class="flex items-center mb-4">
                        <i class="fa-solid fa-lock text-white mr-3 text-2xl"></i>
                        <h3 class="text-2xl font-bold">4. Keamanan & Penyimpanan</h3>
                    </div>
                    <p class="text-primary-100 leading-relaxed mb-4">
                        Semua data yang ditransmisikan dienkripsi menggunakan protokol <strong>SSL/TLS standar
                            industri</strong>.
                        Data biometrik Face ID diproses dengan algoritma enkripsi satu arah (hashing) sehingga wajah asli
                        tidak dapat direkonstruksi dari data yang disimpan.
                    </p>
                    <div class="inline-flex items-center bg-primary-700 bg-opacity-50 px-4 py-2 rounded-full text-sm">
                        <i class="fa-solid fa-server mr-2"></i> Infrastruktur Cloud terenkripsi dengan backup berkala
                    </div>
                </div>
                <i class="fa-solid fa-shield text-9xl absolute -bottom-10 -right-10 text-primary-500 opacity-20"></i>
            </div>

            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-6">
                    <i class="fa-solid fa-user-shield text-orange-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">5. Hak Anda Sebagai Subjek Data</h3>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 text-sm">
                    <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-100 dark:border-gray-600">
                        <p class="font-bold mb-1">Hak Akses</p>
                        <p class="text-gray-500 dark:text-gray-400">Mendapatkan salinan data pribadi yang kami proses.</p>
                    </div>
                    <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-100 dark:border-gray-600">
                        <p class="font-bold mb-1">Hak Koreksi</p>
                        <p class="text-gray-500 dark:text-gray-400">Memperbarui data yang tidak akurat atau kedaluwarsa.</p>
                    </div>
                    <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-100 dark:border-gray-600">
                        <p class="font-bold mb-1">Hak Penghapusan</p>
                        <p class="text-gray-500 dark:text-gray-400">Menarik persetujuan dan menghapus data (Right to be
                            Forgotten).</p>
                    </div>
                </div>
            </div>

            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-children text-pink-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">6. Pelindungan Data Anak</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        Mengingat layanan kami digunakan di lingkungan sekolah, pemrosesan data pribadi siswa dilakukan
                        berdasarkan persetujuan yang diberikan oleh <strong>Orang Tua atau Wali Sah</strong> melalui pihak
                        Sekolah sebagai penyelenggara pendidikan. Kami tidak mengumpulkan data secara sengaja langsung dari
                        anak tanpa pengawasan institusi.
                    </p>
                </div>
            </div>

            <div
                class="bg-white dark:bg-gray-800 shadow-sm border border-gray-200 dark:border-gray-700 rounded-2xl p-6 sm:p-8 transition-all hover:shadow-md">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-earth-asia text-emerald-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">7. Lokasi Server & Transfer Data</h3>
                </div>
                <div class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed">
                    <p>
                        Data Anda dapat disimpan dan diproses di server yang berlokasi di Indonesia maupun wilayah
                        yurisdiksi lain yang memiliki regulasi pelindungan data yang setara. Kami memastikan perlindungan
                        yang memadai untuk setiap transfer data lintas batas.
                    </p>
                </div>
            </div>

            <div
                class="bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/30 rounded-2xl p-6 sm:p-8 transition-all">
                <div class="flex items-center mb-4">
                    <i class="fa-solid fa-triangle-exclamation text-red-500 mr-3 text-xl"></i>
                    <h3 class="text-xl font-bold text-gray-900 dark:text-white">8. Notifikasi Pelanggaran Data</h3>
                </div>
                <div
                    class="prose prose-blue dark:prose-invert max-w-none text-gray-600 dark:text-gray-300 leading-relaxed text-sm">
                    <p>
                        Dalam hal terjadi kegagalan pelindungan data pribadi, <strong>SeHadir</strong> berkomitmen untuk
                        memberikan pemberitahuan tertulis secara resmi kepada Subjek Data dan Otoritas Pelindungan Data
                        dalam waktu paling lambat 3x24 jam sejak terjadinya insiden.
                    </p>
                </div>
            </div>

            <div
                class="bg-gray-50 dark:bg-gray-900 rounded-3xl border-2 border-dashed border-gray-200 dark:border-gray-700 p-8 text-center">
                <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-4">Butuh Bantuan Lebih Lanjut?</h3>
                <p class="text-gray-500 dark:text-gray-400 mb-8">Hubungi tim kepatuhan data kami jika Anda memiliki
                    pertanyaan mengenai penggunaan informasi Anda.</p>

                <div class="flex flex-wrap justify-center gap-4">
                    <a href="mailto:kadaviradityaa@gmail.com"
                        class="inline-flex items-center px-6 py-3 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:shadow transition-all border border-gray-200 dark:border-gray-700 group">
                        <i
                            class="fa-solid fa-envelope text-primary-500 mr-2 group-hover:scale-110 transition-transform"></i>
                        kadaviradityaa@gmail.com
                    </a>
                    <a href="https://wa.me/62895383107479"
                        class="inline-flex items-center px-6 py-3 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:shadow transition-all border border-gray-200 dark:border-gray-700 group">
                        <i class="fa-brands fa-whatsapp text-green-500 mr-2 group-hover:scale-110 transition-transform"></i>
                        +62 895-3831-07479
                    </a>
                </div>
            </div>
        </div>
    </main>
@endsection

<section id="beranda" class="pt-24 md:pt-32 pb-16 md:pb-20 relative overflow-hidden">
    <div class="absolute inset-0 bg-linear-to-b from-primary-900/30 to-transparent"></div>
    <div class="absolute top-0 left-0 right-0 h-px bg-linear-to-r from-transparent via-primary-500/50 to-transparent">
    </div>

    <!-- Animated background elements -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-1/4 left-1/4 w-64 h-64 bg-primary-500/10 rounded-full filter blur-3xl"></div>
        <div class="absolute bottom-1/3 right-1/3 w-96 h-96 bg-purple-500/10 rounded-full filter blur-3xl"></div>
    </div>

    <div class="container mx-auto px-4 sm:px-6 lg:px-8 relative z-10 mt-12">
        <div class="flex flex-col lg:flex-row items-center gap-8 md:gap-12">
            <div class="w-full lg:w-1/2" data-aos="fade-right" data-aos-duration="1000">
                <h1 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold mb-4 md:mb-6 leading-tight">
                    Sistem Presensi <span class="gradient-text">DIGITAL</span> untuk Sekolah Modern
                </h1>
                <p class="text-base md:text-lg text-gray-300 mb-6 md:mb-8">
                    SeHadir memudahkan pengelolaan kehadiran siswa dengan teknologi kartu RFID dan FACE ID. Pantau,
                    analisis, dan tingkatkan kedisiplinan siswa dengan sistem yang terintegrasi.
                </p>
                <div class="flex flex-col sm:flex-row gap-4">
                    <a href="{{ route('public.presences') }}"
                        class="bg-primary-600 hover:bg-primary-700 text-white px-6 py-3 rounded-lg font-medium text-center transition-colors">
                        Cek Data Hari Ini
                    </a>
                </div>
            </div>

            <div class="w-full lg:w-1/2 relative mt-8 lg:mt-0 card-display-section max-lg:hidden!" data-aos="fade-left"
                data-aos-duration="1000" data-aos-delay="200">
                <div class="relative">
                    <!-- 3D Student Card -->
                    <div class="card-3d-container rfid-pulse" id="card-container">
                        <div class="card-3d" id="card">
                            <div class="card-inner">
                                <div class="card-shine"></div>
                                <div class="hologram"></div>
                                <div class="bg-white rounded-xl overflow-hidden shadow-2xl">
                                    <!-- Header section with school info -->
                                    <div class="p-3 md:p-4 bg-white">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center">
                                                <div
                                                    class="w-10 h-10 md:w-12 lg:w-16 lg:h-16 md:h-12 mr-2 md:mr-3 shrink-0">
                                                    <img src="{{ asset('src/logotelesandi.png') }}" alt=""
                                                        loading="lazy" class="w-full h-full object-contain">
                                                </div>
                                                <div>
                                                    <p class="text-blue-400 id-card-micro">Sekolah Standar Nasional
                                                        (SSN)</p>
                                                    <h3 class="text-blue-600 font-bold id-card-title leading-tight">SMK
                                                        Telekomunikasi</h3>
                                                    <h3 class="text-blue-600 font-bold id-card-title leading-tight">
                                                        Telesandi Bekasi</h3>
                                                    <p class="text-blue-400 id-card-micro">
                                                        www.smktelekomunikasitelesandi.sch.id</p>
                                                </div>
                                            </div>
                                            <!-- Indonesian Flag -->
                                            <div
                                                class="w-10 h-6 md:w-12 md:h-8 relative overflow-hidden rounded-sm border border-gray-300 shrink-0">
                                                <div class="absolute top-0 left-0 right-0 h-1/2 bg-red-600"></div>
                                                <div class="absolute bottom-0 left-0 right-0 h-1/2 bg-white"></div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Main card content with student info -->
                                    <div class="bg-linear-to-b from-blue-500 to-blue-600 p-3 md:p-4 relative">
                                        <div
                                            class="absolute top-0 left-0 right-0 h-8 bg-linear-to-b from-blue-400 to-transparent opacity-30">
                                        </div>

                                        <div class="flex justify-between">
                                            <div class="w-2/3 pr-2">
                                                <h4 class="text-white font-bold id-card-title mb-1">Kadavi Raditya
                                                    Alvino</h4>
                                                <div class="flex flex-col space-y-1 text-white">
                                                    <p class="id-card-text">NIS 2324XXXXX &nbsp; RPL 2023/2024</p>
                                                    <p class="id-card-micro">Tridaya Sakti</p>
                                                    <p class="id-card-micro">Jawa Barat, Desa Tridaya Sakti</p>
                                                    <p class="id-card-micro">Kec. Tambun Selatan, Kab. Bekasi</p>
                                                </div>

                                                <!-- Barcode - Improved version -->
                                                <div class="mt-2 md:mt-3 barcode barcode-scan">
                                                    <div class="barcode-lines" id="barcode-container">
                                                        <!-- Barcode lines will be generated by JavaScript -->
                                                    </div>
                                                </div>

                                                <p class="id-card-micro text-white/80 mt-1">Kartu ini berlaku selama
                                                    menjadi Siswa</p>
                                            </div>

                                            <!-- Student photo -->
                                            <div class="w-1/3 pl-2 shrink-0">
                                                <div class="bg-red-500">
                                                    <img src="{{ asset('src/8b98c84e-7b27-4b03-a9bf-963af9b378b7.png') }}"
                                                        loading="lazy" alt="Student Photo"
                                                        class="w-full aspect-3/4 object-cover rounded">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Card Animation Elements -->
                    <div class="rfid-animation-container">
                        <div
                            class="absolute -top-4 -right-4 w-12 md:w-16 h-12 md:h-16 bg-primary-500/20 rounded-full filter blur-xl floating">
                        </div>
                        <div class="absolute -bottom-6 -left-6 w-16 md:w-20 h-16 md:h-20 bg-purple-500/20 rounded-full filter blur-xl"
                            style="animation: float 5s ease-in-out infinite;"></div>

                        <!-- Card Waves Animation -->
                        <div class="rfid-waves">
                            <div class="relative">
                                <div
                                    class="w-5 h-8 md:w-6 md:h-10 bg-primary-600 rounded-l-md flex items-center justify-center">
                                    <i class="bi bi-wifi text-white text-xs md:text-sm"></i>
                                </div>
                                <div class="absolute top-1/2 right-5 md:right-6 transform -translate-y-1/2">
                                    <div
                                        class="w-3 h-3 md:w-4 md:h-4 border-2 border-primary-400 rounded-full animate-ping opacity-75">
                                    </div>
                                </div>
                                <div class="absolute top-1/2 right-5 md:right-6 transform -translate-y-1/2">
                                    <div class="w-6 h-6 md:w-8 md:h-8 border-2 border-primary-400 rounded-full animate-ping opacity-50"
                                        style="animation-delay: 0.3s"></div>
                                </div>
                                <div class="absolute top-1/2 right-5 md:right-6 transform -translate-y-1/2">
                                    <div class="w-9 h-9 md:w-12 md:h-12 border-2 border-primary-400 rounded-full animate-ping opacity-25"
                                        style="animation-delay: 0.6s"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats -->
        <div class="mt-16 md:mt-20 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-6 md:gap-8" data-aos="fade-up"
            data-aos-duration="1000">
            <div class="bg-gray-800/50 backdrop-blur-sm border border-gray-700 rounded-xl p-5 md:p-6">
                <div class="text-primary-400 text-2xl md:text-3xl font-bold mb-2">Tingkat Akurasi</div>
                <p class="text-gray-400 text-xs md:text-sm">Sistem presensi dengan tingkat akurasi tinggi menggunakan
                    teknologi RFID dan FACE ID pada kartu pelajar. Kartu pelajar hanya untuk satu akun saja untuk sistem
                    keamanan presensi.</p>
            </div>

            <div class="bg-gray-800/50 backdrop-blur-sm border border-gray-700 rounded-xl p-5 md:p-6">
                <div class="text-primary-400 text-2xl md:text-3xl font-bold mb-2">Peningkatan Efisiensi</div>
                <p class="text-gray-400 text-xs md:text-sm">Sangat menghemat waktu dan sumber daya dengan otomatisasi
                    proses presensi dan pelaporan. Laporan dapat diakses oleh guru maupun siswa itu sendiri.</p>
            </div>
        </div>
    </div>
</section>

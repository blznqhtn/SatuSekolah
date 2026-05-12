@php
    // Cek apakah di landing page
    $isLanding = request()->is('/');
    $bgClass = $isLanding
        ? 'bg-gray-900 border-gray-800'
        : 'bg-white dark:bg-gray-900 border-gray-100 dark:border-gray-800';
    $textPrimary = $isLanding ? 'text-white' : 'text-gray-900 dark:text-white';
    $textMuted = $isLanding ? 'text-gray-400' : 'text-gray-500 dark:text-gray-400';
    $textLink = $isLanding
        ? 'text-gray-400 hover:text-white'
        : 'text-gray-500 dark:text-gray-400 dark:hover:text-white hover:text-primary-600';
@endphp

<footer class="{{ $bgClass }} border-t transition-colors duration-300">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-8 mb-12">
            <div class="col-span-2 lg:col-span-2">
                <div class="flex items-center space-x-3 mb-4">
                    <div class="p-2 rounded-xl shadow-lg shadow-primary-500/20 mb-0.5">
                        <img src="{{ asset('src/logo_raadeveloperz.png') }}" loading="lazy" alt="SeHadir Logo"
                            class="w-auto h-8">
                    </div>
                    <span class="{{ $textPrimary }} text-xl font-bold tracking-tight">SeHadir</span>
                </div>
                <p class="{{ $textMuted }} text-sm leading-relaxed max-w-xs">
                    Solusi manajemen presensi berbasis RFID & Face ID yang modern untuk meningkatkan kedisiplinan dan
                    transparansi di institusi pendidikan.
                </p>
            </div>

            <div>
                <h4 class="{{ $textPrimary }} font-bold text-sm uppercase tracking-wider mb-4">Layanan</h4>
                <ul class="space-y-2 text-sm">
                    <li><a href="{{ url('/') }}" class="{{ $textLink }} transition-all">Beranda</a></li>
                    @if (Route::currentRouteName() === 'main' ||
                            Route::currentRouteName() === 'policy' ||
                            Route::currentRouteName() === 'terms' ||
                            Route::currentRouteName() === 'help-center')
                        <li><a href="{{ url('/login') }}" class="{{ $textLink }} transition-all">Masuk/Login</a>
                        </li>
                        <li><a href="{{ url('/presences') }}" class="{{ $textLink }} transition-all">Laporan
                                Presensi</a></li>
                    @else
                        <li><a href="{{ url('/admin/siswa') }}" class="{{ $textLink }} transition-all">Manajemen
                                Siswa</a></li>
                        <li><a href="{{ url('/admin/dashboard') }}" class="{{ $textLink }} transition-all">Laporan
                                Presensi</a></li>
                    @endif
                </ul>
            </div>

            <div>
                <h4 class="{{ $textPrimary }} font-bold text-sm uppercase tracking-wider mb-4">Bantuan</h4>
                <ul class="space-y-2 text-sm">
                    <li><a href="{{ url('/privacy-policy') }}" class="{{ $textLink }} transition-all">Kebijakan
                            Privasi</a></li>
                    <li><a href="{{ url('/terms-and-conditions') }}" class="{{ $textLink }} transition-all">Syarat
                            & Ketentuan</a></li>
                    <li><a href="{{ url('/help-center') }}" class="{{ $textLink }} transition-all">Pusat
                            Bantuan</a></li>
                </ul>
            </div>

            <div class="col-span-2 md:col-span-1">
                <h4 class="{{ $textPrimary }} font-bold text-sm uppercase tracking-wider mb-4">System Status</h4>
                <div
                    class="inline-flex items-center px-3 py-1 rounded-full bg-green-500/10 text-green-500 text-xs font-medium border border-green-500/20">
                    <span class="relative flex h-2 w-2 mr-2">
                        <span
                            class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                    </span>
                    All Systems Operational
                </div>
            </div>
        </div>

        <hr class="{{ $isLanding ? 'border-gray-800' : 'border-gray-100 dark:border-gray-800' }} mb-8">

        <div class="flex flex-col md:flex-row justify-between items-center gap-6">
            <div class="order-2 md:order-1">
                <p class="{{ $textMuted }} text-xs md:text-sm font-medium">
                    &copy; 2025 - {{ date('Y') }} <span class="text-primary-500">raadeveloperz</span>.
                    Dibuat dengan <i class="fa-solid fa-heart text-red-500 mx-1"></i> untuk Pendidikan Digital
                    Indonesia.
                </p>
            </div>

            <div class="flex items-center space-x-5 order-1 md:order-2">
                <a href="https://github.com/dapzz-id" target="_blank" class="{{ $textLink }} text-lg">
                    <i class="fa-brands fa-github"></i>
                </a>
                <a href="https://instagram.com/x.dapzz" class="{{ $textLink }} text-lg">
                    <i class="fa-brands fa-instagram"></i>
                </a>
                <a href="mailto:kadaviradityaa@gmail.com" class="{{ $textLink }} text-lg">
                    <i class="fa-solid fa-envelope"></i>
                </a>
                <div class="h-4 w-px bg-gray-700 mx-2"></div>
                <span
                    class="{{ $textMuted }} text-[10px] font-bold uppercase border {{ $isLanding ? 'border-gray-700' : 'border-gray-200 dark:border-gray-700' }} px-2 py-1 rounded">v2.0.4-stable</span>
            </div>
        </div>
    </div>
</footer>

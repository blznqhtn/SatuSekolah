@php
    $isAdmin =
        request()->is('admin/*') ||
        request()->is('superadmin/*')
@endphp

@if ($isAdmin)
    <div id="sidebar"
        class="fixed top-0 left-0 h-full w-56 sm:w-64 lg:w-72 bg-white dark:bg-gray-800 shadow-2xl transform -translate-x-full transition-transform duration-300 ease-in-out z-60">
        <div class="h-16 flex items-center justify-between py-10 px-6 border-b border-gray-100 dark:border-gray-700">
            <div class="flex items-center">
                <i class="bi bi-credit-card-2-front text-primary-600 text-xl mr-2"></i>
                <span class="text-xl font-bold dark:text-white uppercase tracking-tight">SeHadir</span>
            </div>

            <button onclick="toggleSidebar()"
                class="p-2 -mr-2 rounded-lg text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 cursor-pointer transition-colors duration-300">
                <i class="fa-solid fa-xmark text-xl"></i>
            </button>
        </div>

        <div class="py-6 px-4">
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}"
                    class="flex items-center px-4 py-2.5 text-gray-700 dark:text-gray-200 {{ Route::is('admin.dashboard', 'admin.dashboard.*') ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 border-r-4 border-primary-500' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }} rounded-lg">
                    <i class="fa-solid fa-house mr-3 w-5"></i> Dashboard
                </a>

                <a href="{{ route('admin.days.index') }}"
                    class="flex items-center px-4 py-2.5 text-gray-700 dark:text-gray-200 {{ Route::is('admin.days.*') ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 border-r-4 border-primary-500' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }} rounded-lg">
                    <i class="fa-solid fa-calendar-days mr-3 w-5"></i> Days
                </a>

                <a href="{{ route('admin.siswa.index') }}"
                    class="flex items-center px-4 py-2.5 text-gray-700 dark:text-gray-200 {{ Route::is('admin.siswa.*', 'admin.accounts.*', 'admin.photos.*', 'admin.kelas.*') ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 border-r-4 border-primary-500' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }} rounded-lg">
                    <i class="fa-solid fa-users mr-3 w-5"></i> Members
                </a>

                <a href="{{ route('admin.cards.index') }}"
                    class="flex items-center px-4 py-2.5 text-gray-700 dark:text-gray-200 {{ Route::is('admin.cards.*') ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 border-r-4 border-primary-500' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }} rounded-lg">
                    <i class="fa-solid fa-id-card mr-3 w-5"></i> Cards
                </a>

                <a href="{{ route('admin.faces.index') }}"
                    class="flex items-center px-4 py-2.5 text-gray-700 dark:text-gray-200 {{ Route::is('admin.faces.*') ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 border-r-4 border-primary-500' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }} rounded-lg">
                    <i class="fa-solid fa-face-grin-tongue-squint mr-3 w-5"></i> Faces
                </a>

                <a href="{{ route('admin.settings.index') }}"
                    class="flex items-center px-4 py-2.5 text-gray-700 dark:text-gray-200 {{ Route::is('admin.settings.*') ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 border-r-4 border-primary-500' : 'hover:bg-gray-100 dark:hover:bg-gray-700' }} rounded-lg">
                    <i class="fa-solid fa-gear mr-3 w-5"></i> Settings
                </a>
                
                <hr class="my-4 border-gray-100 dark:border-gray-700">
                <form action="{{ session('role') == 'admin' ? route('admin.logout') : route('superadmin.logout') }}" method="post"
                    class="flex items-center px-4 py-2.5 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg font-medium cursor-pointer">
                    <button type="submit" class="cursor-pointer">
                        <i class="fa-solid fa-right-from-bracket mr-3 w-5 cursor-pointer"></i> Logout
                    </button>
                </form>
            </nav>
        </div>

        <footer class="text-xs text-center text-gray-400 absolute bottom-0 w-full mb-4">
            SEHADIR v3.0 | 2026
        </footer>
    </div>

    <div id="overlay" class="fixed inset-0 bg-black/40 backdrop-blur-sm z-55 hidden transition-opacity"
        onclick="toggleSidebar()"></div>
@endif

<header
    class="sticky top-0 py-2 bg-white/80 dark:bg-gray-800/80 backdrop-blur-md shadow-sm z-40 transition-colors duration-300">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 justify-between items-center">

            <div class="flex items-center">
                @if ($isAdmin)
                    <button onclick="toggleSidebar()"
                        class="p-2 mr-3 cursor-pointer rounded-xl text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 active:scale-95">
                        <i class="fa-solid fa-bars-staggered text-lg"></i>
                    </button>
                @endif

                <a href="{{ route('main') }}" class="flex items-center group">
                    <div
                        class="p-1.5 rounded-lg mr-1 group-hover:rotate-12 transition-transform">
                        <i class="bi bi-credit-card-2-front text-primary-600 text-3xl"></i>
                    </div>
                    <span
                        class="text-xl font-bold tracking-tight text-gray-900 dark:text-white uppercase">SeHadir</span>
                </a>
            </div>

            <div class="flex items-center space-x-3 sm:space-x-5">
                <div class="hidden sm:flex flex-col items-end border-r border-gray-200 dark:border-gray-700 pr-5">
                    <span id="current-time"
                        class="text-sm font-bold text-gray-700 dark:text-gray-200 leading-none"></span>
                    <span class="text-[10px] text-gray-400 uppercase tracking-widest mt-1">{{ date('d M Y') }}</span>
                </div>

                <button onclick="toggleDarkMode()" 
                    class="relative w-14 h-8 rounded-full cursor-pointer p-1 transition-all duration-500 focus:outline-none 
                        bg-yellow-400 dark:bg-slate-700 ring-1 ring-inset ring-black/5 dark:ring-white/10 shadow-inner group">
                    
                    <div class="absolute top-1 left-1 w-6 h-6 rounded-full bg-white shadow-sm transform transition-all duration-500 flex items-center justify-center 
                                translate-x-0 dark:translate-x-6">
                        
                        <i class="fa-solid fa-sun text-[12px] text-yellow-500 transition-all duration-300 opacity-100 dark:opacity-0 dark:scale-0"></i>
                        
                        <i class="fa-solid fa-moon text-[12px] text-slate-600 transition-all duration-300 absolute opacity-0 scale-0 dark:opacity-100 dark:scale-100"></i>
                    </div>
                </button>
            </div>
        </div>
    </div>
</header>

<script>
    function updateTime() {
        const now = new Date();
        const options = {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        };
        const timeEl = document.getElementById('current-time');
        if (timeEl) timeEl.textContent = now.toLocaleTimeString('id-ID', options).replace(/\./g, ':');
    }
    setInterval(updateTime, 1000);
    updateTime();

    if (typeof toggleDarkMode !== 'function') {
        window.toggleDarkMode = function() {
            document.documentElement.classList.toggle('dark');
            localStorage.setItem('theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
        }
    }
</script>

@push('scripts')
    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('overlay');
            const content = document.getElementById('content');

            if (sidebar.classList.contains('-translate-x-full')) {
                sidebar.classList.remove('-translate-x-full');
                overlay.classList.remove('hidden');
                if (window.innerWidth >= 768 && content) {
                    content.classList.add('md:ml-64');
                }
            } else {
                sidebar.classList.add('-translate-x-full');
                overlay.classList.add('hidden');
                if (content) {
                    content.classList.remove('md:ml-64');
                }
            }
        }
    </script>
@endpush

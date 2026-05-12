<nav class="fixed top-0 left-0 right-0 z-50 bg-gray-900/90 backdrop-blur-md border-b border-gray-800">
    <div class="container mx-auto px-4 py-2 sm:px-6 lg:px-7">
        <div class="flex justify-between h-16">
            <div class="flex items-center">
                <a href="{{ route('main') }}" class="flex items-center group cursor-pointer">
                    <i class="bi bi-credit-card-2-front text-primary-400 group-hover:rotate-12 transition-transform text-2xl mr-2"></i>
                    <span class="text-xl max-md:text-base font-bold text-white">SEHADIR</span>
                </a>
            </div>

            <div class="hidden md:flex items-center space-x-8">
                <button data-page="beranda"
                    class="nav-btn text-gray-300 hover:text-white transition-colors cursor-pointer">Beranda</button>
                <button data-page="fitur"
                    class="nav-btn text-gray-300 hover:text-white transition-colors cursor-pointer">Fitur</button>
                <button data-page="tentang"
                    class="nav-btn text-gray-300 hover:text-white transition-colors cursor-pointer">Tentang</button>
                <button data-page="manfaat"
                    class="nav-btn text-gray-300 hover:text-white transition-colors cursor-pointer">Manfaat</button>
                <button data-page="reviews"
                    class="nav-btn text-gray-300 hover:text-white transition-colors cursor-pointer">Ulasan</button>
            </div>

            <div class="flex items-center">
                <button data-page="kontak"
                    class="nav-btn bg-primary-600 hover:bg-primary-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors hidden md:block cursor-pointer">
                    Hubungi Kami
                </button>

                <button type="button" class="md:hidden ml-4 text-gray-300 hover:text-white" id="mobile-menu-button">
                    <i class="bi bi-list text-2xl"></i>
                </button>
            </div>
        </div>
    </div>

    <div class="md:hidden hidden bg-gray-800 border-b border-gray-700" id="mobile-menu">
        <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
            <button data-page="beranda"
                class="nav-btn block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-700 cursor-pointer">Beranda</button>
            <button data-page="fitur"
                class="nav-btn block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-700 cursor-pointer">Fitur</button>
            <button data-page="tentang"
                class="nav-btn block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-700 cursor-pointer">Tentang</button>
            <button data-page="manfaat"
                class="nav-btn block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-700 cursor-pointer">Manfaat</button>
            <button data-page="kontak"
                class="nav-btn block px-3 py-2 rounded-md text-base font-medium text-primary-400 hover:text-primary-300 cursor-pointer">Hubungi
                Kami</button>
        </div>
    </div>
</nav>

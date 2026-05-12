@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
    <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
        <div class="md:flex md:items-center md:justify-between mb-8 relative">
            <div class="min-w-0 flex-1">
                <h2
                    class="text-3xl font-extrabold leading-tight tracking-tight bg-linear-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent">
                    Dasbor Presensi
                </h2>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400 flex items-center gap-2">
                    <i class="fa-regular fa-calendar-alt text-primary-500"></i>
                    {{ \Carbon\Carbon::parse($dateNow)->translatedFormat('l, d F Y') }}
                </p>
            </div>
        </div>

        <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4 mb-8">
            <div
                class="group relative overflow-hidden rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100 dark:border-gray-700">
                <div class="absolute inset-0 bg-linear-to-br from-primary-50/20 to-transparent dark:from-primary-900/20">
                </div>
                <div class="p-5">
                    <div class="flex items-center">
                        <div class="shrink-0 rounded-xl bg-linear-to-br from-primary-500 to-primary-600 p-3 shadow-md">
                            <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M18 18.72a9.094 9.094 0 003.741-.479 3 3 0 00-4.682-2.72m.94 3.198l.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0112 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 016 18.719m12 0a5.971 5.971 0 00-.941-3.197m0 0A5.995 5.995 0 0012 12.75a5.995 5.995 0 00-5.058 2.772m0 0a3 3 0 00-4.681 2.72 8.986 8.986 0 003.74.477m.94-3.197a5.971 5.971 0 00-.94 3.197M15 6.75a3 3 0 11-6 0 3 3 0 016 0zm6 3a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0zm-13.5 0a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z" />
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                                    TOTAL DATANG SISWA {{ $filter ?? 'HARI INI' }}
                                </dt>
                                <dd>
                                    <div
                                        class="text-3xl font-bold text-gray-900 dark:text-white flex items-center flex-wrap gap-2 mt-1">
                                        <span class="tabular-nums">{{ $totalHariIni ?? 0 }}</span>
                                        @if (isset($todayDayType))
                                            @if ($todayDayType == 'Hari Produktif')
                                                <span
                                                    class="text-xs font-medium px-2.5 py-1 rounded-full bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300 backdrop-blur-sm">
                                                    {{ $todayDayType }}
                                                </span>
                                            @elseif($todayDayType == 'Hari Non-Produktif')
                                                <span
                                                    class="text-xs font-medium px-2.5 py-1 rounded-full bg-blue-100 text-blue-700 dark:bg-blue-900/50 dark:text-blue-300">
                                                    {{ $todayDayType }}
                                                </span>
                                            @else
                                                <span
                                                    class="text-xs font-medium px-2.5 py-1 rounded-full bg-red-100 text-red-700 dark:bg-red-900/50 dark:text-red-300">
                                                    {{ $todayDayType }}
                                                </span>
                                            @endif
                                        @endif
                                    </div>
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
                <div
                    class="absolute bottom-0 left-0 right-0 h-1 bg-linear-to-r from-primary-400 to-primary-600 scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left">
                </div>
            </div>

            <!-- Card 2: Izin/Sakit -->
            <div
                class="group relative overflow-hidden rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100 dark:border-gray-700">
                <div class="absolute inset-0 bg-linear-to-br from-yellow-50/20 to-transparent dark:from-yellow-900/20">
                </div>
                <div class="p-5">
                    <div class="flex items-center">
                        <div
                            class="cursor-pointer shrink-0 rounded-xl bg-linear-to-br from-yellow-500 to-amber-600 p-3 shadow-md">
                            <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                                    TOTAL SISWA IZIN/SAKIT
                                </dt>
                                <dd>
                                    <div class="text-3xl font-bold text-gray-900 dark:text-white mt-1 tabular-nums">
                                        {{ $totalTidakHadir ?? 0 }}
                                    </div>
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
                <div
                    class="absolute bottom-0 left-0 right-0 h-1 bg-linear-to-r from-yellow-400 to-amber-500 scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left">
                </div>
            </div>

            <!-- Card 3: Alpa -->
            <div
                class="group relative overflow-hidden rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100 dark:border-gray-700">
                <div class="absolute inset-0 bg-linear-to-br from-red-50/20 to-transparent dark:from-red-900/20"></div>
                <div class="p-5">
                    <div class="flex items-center">
                        <div
                            class="cursor-pointer shrink-0 rounded-xl bg-linear-to-br from-red-500 to-rose-600 p-3 shadow-md">
                            <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                                    TOTAL SISWA TANPA KETERANGAN
                                </dt>
                                <dd>
                                    <div class="text-3xl font-bold text-gray-900 dark:text-white mt-1 tabular-nums">
                                        {{ $totalAlpa ?? 0 }}
                                    </div>
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
                <div
                    class="absolute bottom-0 left-0 right-0 h-1 bg-linear-to-r from-red-400 to-rose-500 scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left">
                </div>
            </div>

            <!-- Card 4: Total Keseluruhan -->
            <div
                class="group relative overflow-hidden rounded-2xl bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 border border-gray-100 dark:border-gray-700">
                <div class="absolute inset-0 bg-linear-to-br from-emerald-50/20 to-transparent dark:from-emerald-900/20">
                </div>
                <div class="p-5">
                    <div class="flex items-center">
                        <div class="shrink-0 rounded-xl bg-linear-to-br from-emerald-500 to-teal-600 p-3 shadow-md">
                            <svg class="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                                    TOTAL SISWA KESELURUHAN
                                </dt>
                                <dd>
                                    <div class="text-3xl font-bold text-gray-900 dark:text-white mt-1 tabular-nums">
                                        {{ $total ?? 0 }}
                                    </div>
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
                <div
                    class="absolute bottom-0 left-0 right-0 h-1 bg-linear-to-r from-emerald-400 to-teal-500 scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left">
                </div>
            </div>
        </div>

        <!-- Main Table Section with Modern Card Design -->
        <div
            class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-xl rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
            <!-- Header with Filter and Refresh -->
            <div
                class="flex flex-col sm:flex-row justify-between items-start sm:items-center p-4 sm:p-6 border-b border-gray-100 dark:border-gray-700 bg-linear-to-r from-gray-50/50 to-transparent dark:from-gray-900/30">
                <div class="mb-3 sm:mb-0">
                    <h3 class="text-xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
                        <i class="fa-solid fa-table-list text-primary-500"></i> Data Presensi Siswa
                    </h3>
                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">Daftar presensi siswa
                        {{ $filter ?? 'hari ini' }}</p>
                </div>
                <div class="flex items-center space-x-3">
                    <!-- Modern Class Filter Dropdown -->
                    @if(isset($listKelas) && count($listKelas) > 0)
                    <div class="relative">
                        <button type="button"
                            class="group inline-flex items-center gap-2 px-4 py-2.5 bg-white dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-xl shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-primary-500/50 transition-all duration-200"
                            id="class-filter-menu-button" aria-expanded="false" aria-haspopup="true">
                            <i class="fa-solid fa-users text-primary-500 group-hover:scale-110 transition-transform"></i>
                            @php
                                $kelasName = 'Semua Kelas';
                                if($kelasFilter) {
                                    $selectedKelas = collect($listKelas)->firstWhere('id', $kelasFilter);
                                    if($selectedKelas) $kelasName = $selectedKelas->name;
                                }
                            @endphp
                            <span class="hidden sm:inline-block">{{ $kelasName }}</span>
                            <i class="fa-solid fa-chevron-down text-xs transition-transform duration-200 group-data-[state=open]:rotate-180"></i>
                        </button>
                        <div class="hidden absolute right-0 mt-2 w-56 rounded-xl shadow-lg bg-white/95 dark:bg-gray-800/95 ring-1 ring-black ring-opacity-5 focus:outline-none z-50 overflow-hidden backdrop-blur-sm"
                            id="class-filter-menu" role="menu" aria-orientation="vertical" aria-labelledby="class-filter-menu-button"
                            tabindex="-1">
                            <div class="py-1 max-h-60 overflow-y-auto custom-scrollbar" role="none">
                                <a href="{{ route('admin.dashboard', ['kelas' => ''] + request()->except(['kelas', 'page'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors {{ $kelasFilter == '' ? 'bg-primary-50 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 font-medium' : '' }}"
                                    role="menuitem">Semua Kelas</a>
                                @foreach($listKelas as $k)
                                <a href="{{ route('admin.dashboard', ['kelas' => $k->id] + request()->except(['kelas', 'page'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors {{ $kelasFilter == $k->id ? 'bg-primary-50 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 font-medium' : '' }}"
                                    role="menuitem">{{ $k->name }}</a>
                                @endforeach
                            </div>
                        </div>
                    </div>
                    @endif

                    <!-- Modern Filter Dropdown -->
                    <div class="relative">
                        <button type="button"
                            class="group inline-flex items-center gap-2 px-4 py-2.5 bg-white dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-xl shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-primary-500/50 transition-all duration-200"
                            id="filter-menu-button" aria-expanded="false" aria-haspopup="true">
                            <i class="fa-solid fa-filter text-primary-500 group-hover:scale-110 transition-transform"></i>
                            <span class="hidden sm:inline-block">{{ $filter ?? 'Hari ini' }}</span>
                            <i
                                class="fa-solid fa-chevron-down text-xs transition-transform duration-200 group-data-[state=open]:rotate-180"></i>
                        </button>
                        <div class="hidden absolute right-0 mt-2 w-56 rounded-xl shadow-lg bg-white/95 dark:bg-gray-800/95 ring-1 ring-black ring-opacity-5 focus:outline-none z-50 overflow-hidden backdrop-blur-sm"
                            id="filter-menu" role="menu" aria-orientation="vertical" aria-labelledby="filter-menu-button"
                            tabindex="-1">
                            <div class="py-1" role="none">
                                <a href="{{ route('admin.dashboard', ['filter' => 'Hari ini'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Hari ini</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Kemarin'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Kemarin</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Minggu Lalu'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Minggu Lalu</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Minggu Ini'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Minggu Ini</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Bulan Lalu'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Bulan Lalu</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Bulan Ini'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Bulan Ini</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Tahun Lalu'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Tahun Lalu</a>
                                <a href="{{ route('admin.dashboard', ['filter' => 'Tahun Ini'] + request()->except(['filter', 'date_from', 'date_to'])) }}"
                                    class="text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">Tahun Ini</a>
                                <hr class="my-1 border-gray-100 dark:border-gray-700">
                                <button id="custom-date-btn"
                                    class="w-full text-left text-gray-700 dark:text-gray-200 block px-4 py-2 text-sm hover:bg-primary-50 dark:hover:bg-primary-900/50 transition-colors"
                                    role="menuitem">
                                    <i class="fa-regular fa-calendar-range mr-2"></i> Pilih Tanggal
                                </button>
                            </div>
                        </div>
                    </div>
                    <!-- Modern Refresh Button with Spin Animation -->
                    <button
                        class="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-linear-to-r from-orange-500 to-amber-600 text-white shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 active:scale-95"
                        title="Refresh Page"
                        onclick="this.classList.add('animate-spin'); setTimeout(() => { window.location.reload(); }, 300);">
                        <i class="fa-solid fa-rotate-right"></i>
                    </button>
                </div>
            </div>

            <!-- Tabs Navigation Modernized -->
            <div class="border-b border-gray-100 dark:border-gray-700">
                <nav class="flex flex-col px-4 sm:px-6 overflow-hidden" aria-label="Tabs">
                    <div class="flex flex-wrap -mb-px overflow-x-auto gap-1 sm:gap-2">
                        <a href="{{ route('admin.dashboard', ['head-tabs' => 'produktif'] + request()->except('head-tabs')) }}"
                            class="tab-link py-2.5 px-4 text-center border-b-2 font-medium text-sm rounded-t-lg transition-all duration-200 whitespace-nowrap
                                {{ $headTab === 'produktif' ? 'tab-active border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/50 dark:bg-primary-900/20' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300' }}">
                            Produktif
                            @if ($filter === 'Hari ini' && isset($dayType) && $dayType === 'Hari Produktif')
                                <span
                                    class="ml-1.5 inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-primary-100 dark:bg-primary-800 text-primary-700 dark:text-primary-300">
                                    Hari Ini
                                </span>
                            @endif
                        </a>
                        <a href="{{ route('admin.dashboard', ['head-tabs' => 'non_produktif'] + request()->except('head-tabs')) }}"
                            class="tab-link py-2.5 px-4 text-center border-b-2 font-medium text-sm rounded-t-lg transition-all duration-200 whitespace-nowrap
                                {{ $headTab === 'non_produktif' ? 'tab-active border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/50 dark:bg-primary-900/20' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300' }}">
                            Non-Produktif
                            @if ($filter === 'Hari ini' && isset($dayType) && $dayType === 'Hari Non-Produktif')
                                <span
                                    class="ml-1.5 inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-primary-100 dark:bg-primary-800 text-primary-700 dark:text-primary-300">
                                    Hari Ini
                                </span>
                            @endif
                        </a>
                    </div>
                    <!-- Sub Tabs -->
                    <div class="flex flex-wrap -mb-px mt-2 gap-1 overflow-x-auto">
                        @php
                            $queryParams = request()->query();
                            unset($queryParams['tab']);
                            $queryString = http_build_query($queryParams);
                        @endphp
                        <a href="{{ route('admin.dashboard', ['tab' => 'all'] + request()->except('tab')) }}"
                            class="sub-tab-link py-2 px-3 text-center border-b-2 text-sm rounded-md transition-all duration-200 whitespace-nowrap {{ $tab === 'all' ? 'border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/30' : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400' }}">
                            Semua
                        </a>
                        <a href="{{ route('admin.dashboard', ['tab' => 'hadir'] + request()->except('tab')) }}"
                            class="sub-tab-link py-2 px-3 text-center border-b-2 text-sm rounded-md transition-all duration-200 whitespace-nowrap {{ $tab === 'hadir' ? 'border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/30' : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400' }}">
                            Hadir
                        </a>
                        <a href="{{ route('admin.dashboard', ['tab' => 'izin'] + request()->except('tab')) }}"
                            class="sub-tab-link py-2 px-3 text-center border-b-2 text-sm rounded-md transition-all duration-200 whitespace-nowrap {{ $tab === 'izin' ? 'border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/30' : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400' }}">
                            Izin
                        </a>
                        <a href="{{ route('admin.dashboard', ['tab' => 'sakit'] + request()->except('tab')) }}"
                            class="sub-tab-link py-2 px-3 text-center border-b-2 text-sm rounded-md transition-all duration-200 whitespace-nowrap {{ $tab === 'sakit' ? 'border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/30' : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400' }}">
                            Sakit
                        </a>
                        <a href="{{ route('admin.dashboard', ['tab' => 'alpa'] + request()->except('tab')) }}"
                            class="sub-tab-link py-2 px-3 text-center border-b-2 text-sm rounded-md transition-all duration-200 whitespace-nowrap {{ $tab === 'alpa' ? 'border-primary-500 text-primary-600 dark:text-primary-400 bg-primary-50/30' : 'border-transparent text-gray-500 hover:text-gray-700 dark:text-gray-400' }}">
                            Alpa
                        </a>
                    </div>
                </nav>
            </div>

            <!-- Content Area with Animations -->
            <div class="transition-all duration-300">
                @if (isset($dayType) && $dayType === 'Hari Libur')
                    <div class="flex flex-col items-center justify-center py-16 animate-fade-in">
                        <div class="text-center">
                            <div
                                class="mx-auto w-20 h-20 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center mb-4">
                                <svg class="h-10 w-10 text-gray-400 dark:text-gray-500" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                        d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M12 13.5V15m-6 4h12a2 2 0 002-2v-12a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <h3 class="mt-2 text-xl font-semibold text-gray-900 dark:text-white">
                                {{ $filter ?? 'Hari ini' }} Libur
                            </h3>
                            <p class="mt-1 text-gray-500 dark:text-gray-400">
                                Tidak ada kegiatan belajar mengajar {{ $filter ?? 'hari ini' }}
                            </p>
                        </div>
                    </div>
                @elseif(isset($dataPresensi) && count($dataPresensi) > 0)
                    <div class="overflow-x-auto custom-scrollbar">
                        <table class="min-w-full divide-y divide-gray-100 dark:divide-gray-700">
                            <thead class="bg-gray-50/80 dark:bg-gray-700/80 backdrop-blur-sm">
                                <tr>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider w-12">
                                        No</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                        No Induk</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                        Nama</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider hidden sm:table-cell">
                                        Kelas</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider hidden md:table-cell">
                                        Tanggal Masuk</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                        Status Masuk</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider hidden md:table-cell">
                                        Tanggal Keluar</th>
                                    <th scope="col"
                                        class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider hidden md:table-cell">
                                        Status Keluar</th>
                                    @if (isset($tab) && ($tab === 'izin' || $tab === 'sakit'))
                                        <th scope="col"
                                            class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider hidden sm:table-cell">
                                            Keterangan</th>
                                        <th scope="col"
                                            class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                            Dokumen</th>
                                    @endif
                                </tr>
                            </thead>
                            <tbody class="bg-white/50 dark:bg-gray-800/50 divide-y divide-gray-100 dark:divide-gray-700">
                                @foreach ($dataPresensi as $dataku)
                                    @php
                                        $leaveDoc = isset($leaveDocuments)
                                            ? $leaveDocuments
                                                ->where('nis', $dataku->nis)
                                                ->where('type', $dataku->status)
                                                ->first()
                                            : null;
                                    @endphp
                                    <tr
                                        class="hover:bg-gray-50/70 dark:hover:bg-gray-700/50 transition-colors duration-150">
                                        <td
                                            class="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100 font-medium">
                                            {{ $loop->iteration }}.</td>
                                        <td
                                            class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300 font-mono">
                                            {{ $dataku->nis }}</td>
                                        <td
                                            class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-100">
                                            {{ $dataku->school_member->name }}</td>
                                        <td
                                            class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300 hidden sm:table-cell">
                                            {{ $dataku->school_member->kelas }}</td>
                                        <td
                                            class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300 hidden md:table-cell">
                                            {{ \Carbon\Carbon::parse($dataku->time_masuk)->format('d M Y (h:i:s A)') ?? '-' }}
                                        </td>
                                        <td class="px-4 py-3 whitespace-nowrap">
                                            @php
                                                $statusClass = match ($dataku->status) {
                                                    'Hadir'
                                                        => 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300',
                                                    'Izin'
                                                        => 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300',
                                                    'Sakit'
                                                        => 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/40 dark:text-yellow-300',
                                                    'Alpa'
                                                        => 'bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-300',
                                                    'Terlambat'
                                                        => 'bg-orange-100 text-orange-700 dark:bg-orange-900/40 dark:text-orange-300',
                                                    default
                                                        => 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300',
                                                };
                                            @endphp
                                            <span
                                                class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full {{ $statusClass }}">{{ $dataku->status }}</span>
                                            @if($dataku->status == 'Terlambat')
                                                <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 whitespace-normal max-w-[150px]">
                                                    Alasan: {{ $dataku->alasan_datang_telat ?? '-' }}
                                                </div>
                                            @endif
                                        </td>
                                        <td
                                            class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300 hidden md:table-cell">
                                            {{ \Carbon\Carbon::parse($dataku->time_keluar)->format('d M Y (h:i:s A)') ?? '-' }}
                                        </td>
                                        <td class="px-2 sm:px-6 py-3 sm:py-4 whitespace-nowrap">
                                            @if ($dataku->status_keluar == 'Tepat Waktu')
                                                <span
                                                    class="px-1.5 sm:px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 mobile-badge">Tepat
                                                    Waktu</span>
                                            @elseif($dataku->status_keluar == 'Belum Waktunya')
                                                <span
                                                    class="px-1.5 sm:px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 mobile-badge">Belum
                                                    Waktunya</span>
                                            @elseif($dataku->status_keluar == 'Terlambat')
                                                <span
                                                    class="px-1.5 sm:px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200 mobile-badge">Terlambat</span>
                                                <div class="text-xs text-gray-500 dark:text-gray-400 mt-1 whitespace-normal max-w-[150px]">
                                                    Alasan: {{ $dataku->alasan_pulang_telat ?? '-' }}
                                                </div>
                                            @else
                                                -
                                            @endif
                                        </td>

                                        @if (isset($tab) && ($tab === 'izin' || $tab === 'sakit'))
                                            <td
                                                class="px-4 py-3 text-sm text-gray-600 dark:text-gray-300 hidden sm:table-cell max-w-xs truncate">
                                                {{ $leaveDoc->reason ?? '-' }}</td>
                                            <td class="px-4 py-3 whitespace-nowrap text-sm">
                                                @if ($leaveDoc && $leaveDoc->document_path)
                                                    @php
                                                        $path = $leaveDoc->document_path;
                                                        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));
                                                    @endphp
                                                    @if (in_array($extension, ['jpg', 'jpeg', 'png', 'gif']))
                                                        <button onclick="showDocument('{{ $leaveDoc->document_path }}')"
                                                            class="text-primary-600 hover:text-primary-800 dark:text-primary-400 transition-colors">
                                                            <i class="fa-regular fa-image mr-1"></i> Lihat
                                                        </button>
                                                    @elseif ($extension === 'pdf')
                                                        <a href="{{ $leaveDoc->document_path }}" target="_blank"
                                                            class="text-red-600 hover:text-red-800 dark:text-red-400 transition-colors">
                                                            <i class="fa-regular fa-file-pdf mr-1"></i> PDF
                                                        </a>
                                                    @elseif (in_array($extension, ['mp4', 'mov', 'avi']))
                                                        <button onclick="showVideo('{{ $leaveDoc->document_path }}')"
                                                            class="text-purple-600 hover:text-purple-800 dark:text-purple-400 transition-colors">
                                                            <i class="fa-regular fa-file-video mr-1"></i> Video
                                                        </button>
                                                    @else
                                                        <span class="text-gray-400">-</span>
                                                    @endif
                                                @else
                                                    <span class="text-gray-400">-</span>
                                                @endif
                                            </td>
                                        @endif
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @else
                    <div class="flex flex-col items-center justify-center py-16 animate-fade-in">
                        <div class="text-center">
                            <div
                                class="mx-auto w-20 h-20 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center mb-4">
                                <svg class="h-10 w-10 text-gray-400 dark:text-gray-500" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                                        d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M12 13.5V15m-6 4h12a2 2 0 002-2v-12a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <h3 class="mt-2 text-xl font-semibold text-gray-900 dark:text-white">
                                @if (isset($dayType) && $dayType === 'Hari Libur')
                                    @if (($filter ?? 'Hari ini') === 'Hari ini')
                                        Hari Ini Libur
                                    @elseif(($filter ?? '') === 'Kemarin')
                                        Kemarin Libur
                                    @else
                                        Libur
                                    @endif
                                @else
                                    Tidak ada data
                                @endif
                            </h3>
                            <p class="mt-1 text-gray-500 dark:text-gray-400">
                                @if (isset($dayType) && $dayType === 'Hari Libur')
                                    Tidak ada kegiatan belajar mengajar pada periode ini.
                                @else
                                    Tidak ada data presensi yang tersedia untuk periode ini.
                                @endif
                            </p>
                        </div>
                    </div>
                @endif

                <!-- Modern Pagination -->
                @if (isset($dataPresensi) && count($dataPresensi) > 0)
                    <div
                        class="bg-white/50 dark:bg-gray-800/50 px-4 py-4 flex items-center justify-between border-t border-gray-100 dark:border-gray-700 sm:px-6">
                        <div class="flex-1 flex justify-between sm:hidden">
                            @if ($dataPresensi->onFirstPage())
                                <span
                                    class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium rounded-lg text-gray-400 bg-gray-50 dark:bg-gray-700 cursor-not-allowed">Previous</span>
                            @else
                                <a href="{{ $dataPresensi->previousPageUrl() }}"
                                    class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium rounded-lg text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-all">Previous</a>
                            @endif
                            @if ($dataPresensi->hasMorePages())
                                <a href="{{ $dataPresensi->nextPageUrl() }}"
                                    class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium rounded-lg text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 transition-all">Next</a>
                            @else
                                <span
                                    class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium rounded-lg text-gray-400 bg-gray-50 dark:bg-gray-700 cursor-not-allowed">Next</span>
                            @endif
                        </div>
                        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                            <div>
                                <p class="text-sm text-gray-600 dark:text-gray-400">
                                    Menampilkan <span
                                        class="font-semibold text-gray-900 dark:text-white">{{ $dataPresensi->firstItem() }}</span>
                                    sampai <span
                                        class="font-semibold text-gray-900 dark:text-white">{{ $dataPresensi->lastItem() }}</span>
                                    dari <span
                                        class="font-semibold text-gray-900 dark:text-white">{{ $dataPresensi->total() }}</span>
                                    hasil
                                </p>
                            </div>
                            <div>
                                <nav class="relative z-0 inline-flex rounded-lg shadow-sm -space-x-px"
                                    aria-label="Pagination">
                                    @if ($dataPresensi->onFirstPage())
                                        <span
                                            class="relative inline-flex items-center px-3 py-2 rounded-l-lg border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-sm font-medium text-gray-400 cursor-not-allowed">
                                            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd"
                                                    d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                                                    clip-rule="evenodd" />
                                            </svg>
                                        </span>
                                    @else
                                        <a href="{{ $dataPresensi->previousPageUrl() }}"
                                            class="relative inline-flex items-center px-3 py-2 rounded-l-lg border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium text-gray-500 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                                            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd"
                                                    d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                                                    clip-rule="evenodd" />
                                            </svg>
                                        </a>
                                    @endif

                                    @php
                                        $currentPage = $dataPresensi->currentPage();
                                        $lastPage = $dataPresensi->lastPage();
                                        $start = max($currentPage - 2, 1);
                                        $end = min($currentPage + 2, $lastPage);
                                    @endphp

                                    @if ($start > 1)
                                        <a href="{{ $dataPresensi->url(1) }}"
                                            class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">1</a>
                                        @if ($start > 2)
                                            <span
                                                class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-sm font-medium text-gray-500">…</span>
                                        @endif
                                    @endif

                                    @for ($page = $start; $page <= $end; $page++)
                                        @if ($page == $currentPage)
                                            <span
                                                class="z-10 relative inline-flex items-center px-4 py-2 border border-primary-500 bg-primary-50 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 text-sm font-medium">{{ $page }}</span>
                                        @else
                                            <a href="{{ $dataPresensi->url($page) }}"
                                                class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">{{ $page }}</a>
                                        @endif
                                    @endfor

                                    @if ($end < $lastPage)
                                        @if ($end < $lastPage - 1)
                                            <span
                                                class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-sm font-medium text-gray-500">…</span>
                                        @endif
                                        <a href="{{ $dataPresensi->url($lastPage) }}"
                                            class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">{{ $lastPage }}</a>
                                    @endif

                                    @if ($dataPresensi->hasMorePages())
                                        <a href="{{ $dataPresensi->nextPageUrl() }}"
                                            class="relative inline-flex items-center px-3 py-2 rounded-r-lg border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-sm font-medium text-gray-500 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                                            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd"
                                                    d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                                                    clip-rule="evenodd" />
                                            </svg>
                                        </a>
                                    @else
                                        <span
                                            class="relative inline-flex items-center px-3 py-2 rounded-r-lg border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-sm font-medium text-gray-400 cursor-not-allowed">
                                            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd"
                                                    d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                                                    clip-rule="evenodd" />
                                            </svg>
                                        </span>
                                    @endif
                                </nav>
                            </div>
                        </div>
                    </div>
                @endif
            </div>
        </div>

        <!-- Modern Export Button -->
        <div class="mt-6 flex justify-end">
            <a href="{{ url(route('admin.export.presences') . '?filter=' . urlencode($filter ?? '') . '&tab=' . ($tab ?? '') . (isset($dateFrom) && $dateFrom ? '&date_from=' . $dateFrom : '') . (isset($dateTo) && $dateTo ? '&date_to=' . $dateTo : '') . (isset($kelasFilter) && $kelasFilter ? '&kelas=' . $kelasFilter : '')) }}"
                class="group inline-flex items-center gap-2 px-5 py-2.5 bg-linear-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white font-medium rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 active:scale-95">
                <img src="{{ asset('src/xlsx.png') }}" alt="Excel" class="w-5 h-5">
                <span>Export to XLSX</span>
                <i class="fa-solid fa-arrow-right-long group-hover:translate-x-1 transition-transform"></i>
            </a>
        </div>
    </main>

    <!-- Modern Date Range Modal -->
    <div id="custom-date-modal" class="fixed inset-0 z-50 hidden overflow-y-auto">
        <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div class="fixed inset-0 transition-opacity" aria-hidden="true">
                <div class="absolute inset-0 bg-gray-900/70 backdrop-blur-md"></div>
            </div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen">&#8203;</span>
            <div id="date-modal-content"
                class="inline-block align-bottom rounded-2xl text-left overflow-hidden shadow-2xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95 bg-white dark:bg-gray-800">
                <div class="bg-linear-to-r from-primary-600 to-primary-700 px-6 py-4">
                    <div class="flex items-center justify-between">
                        <h3 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fa-regular fa-calendar-range"></i> Pilih Rentang Tanggal
                        </h3>
                        <button type="button" id="close-custom-date-x"
                            class="text-white hover:text-gray-200 transition-transform hover:rotate-90">
                            <i class="fa-solid fa-times text-xl"></i>
                        </button>
                    </div>
                </div>
                <div class="px-6 py-5 bg-white dark:bg-gray-800">
                    <div class="space-y-6">
                        <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Tanggal
                                    Mulai</label>
                                <input type="date" id="date-from"
                                    class="block w-full px-4 py-2.5 border border-gray-200 dark:border-gray-600 rounded-xl bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Tanggal
                                    Akhir</label>
                                <input type="date" id="date-to"
                                    class="block w-full px-4 py-2.5 border border-gray-200 dark:border-gray-600 rounded-xl bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                            </div>
                        </div>
                        <div>
                            <p class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">Pilihan Cepat</p>
                            <div class="flex flex-wrap gap-2">
                                <button type="button"
                                    class="quick-date-btn px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-xs hover:bg-primary-100 dark:hover:bg-primary-900 transition-all"
                                    data-days="7">7 Hari</button>
                                <button type="button"
                                    class="quick-date-btn px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-xs hover:bg-primary-100 dark:hover:bg-primary-900 transition-all"
                                    data-days="14">14 Hari</button>
                                <button type="button"
                                    class="quick-date-btn px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-xs hover:bg-primary-100 dark:hover:bg-primary-900 transition-all"
                                    data-days="30">30 Hari</button>
                                <button type="button"
                                    class="quick-date-btn px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-full text-xs hover:bg-primary-100 dark:hover:bg-primary-900 transition-all"
                                    data-days="90">90 Hari</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div
                    class="bg-gray-50 dark:bg-gray-800/50 px-6 py-4 rounded-b-2xl flex flex-col-reverse sm:flex-row sm:justify-end gap-3">
                    <button type="button" id="close-custom-date"
                        class="inline-flex justify-center items-center px-5 py-2 border border-gray-200 dark:border-gray-600 rounded-xl shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 transition-all">Batal</button>
                    <button type="button" id="apply-custom-date"
                        class="inline-flex justify-center items-center px-5 py-2 bg-linear-to-r from-primary-600 to-primary-700 text-white rounded-xl shadow-sm text-sm font-medium hover:from-primary-700 hover:to-primary-800 transition-all">Terapkan</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Document Modal (Image) -->
    <div id="document-modal" class="fixed inset-0 z-50 hidden">
        <!-- Backdrop -->
        <div class="absolute inset-0 bg-gray-900/70 backdrop-blur-md" aria-hidden="true" id="document-modal-backdrop"></div>
        <!-- Modal Content -->
        <div class="relative z-10 flex items-center justify-center min-h-screen p-4">
            <div class="bg-white dark:bg-gray-800 rounded-2xl overflow-hidden shadow-xl w-full max-w-3xl">
                <div class="px-6 pt-5 pb-4">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Dokumen Surat</h3>
                        <button id="close-document-modal"
                            class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                            <i class="fa-solid fa-times text-xl"></i>
                        </button>
                    </div>
                    <div class="flex justify-center">
                        <img id="document-image" alt="Dokumen" class="max-w-full max-h-[70vh] rounded-lg shadow-md object-contain">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Video Modal -->
    <div id="videoModal" class="fixed inset-0 z-50 hidden">
        <!-- Backdrop -->
        <div class="absolute inset-0 bg-gray-900/70 backdrop-blur-md" aria-hidden="true" id="video-modal-backdrop"></div>
        <!-- Modal Content -->
        <div class="relative z-10 flex items-center justify-center min-h-screen p-4">
            <div class="bg-white dark:bg-gray-800 rounded-2xl overflow-hidden shadow-xl w-full max-w-3xl">
                <div class="px-6 pt-5 pb-4">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Video Dokumen</h3>
                        <button id="close-video-modal"
                            class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700">
                            <i class="fa-solid fa-times text-xl"></i>
                        </button>
                    </div>
                    <video id="document-video" controls class="w-full rounded-lg shadow-md">
                        <source type="video/mp4">
                        Browser tidak mendukung video.
                    </video>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Filter dropdown
            const filterButton = document.getElementById('filter-menu-button');
            const filterMenu = document.getElementById('filter-menu');
            if (filterButton && filterMenu) {
                filterButton.addEventListener('click', (e) => {
                    e.preventDefault();
                    filterMenu.classList.toggle('hidden');
                    filterButton.setAttribute('data-state', filterMenu.classList.contains('hidden') ?
                        'closed' : 'open');
                });
                document.addEventListener('click', (event) => {
                    if (!filterButton.contains(event.target) && !filterMenu.contains(event.target)) {
                        filterMenu.classList.add('hidden');
                    }
                });
            }

            // Class Filter dropdown
            const classFilterButton = document.getElementById('class-filter-menu-button');
            const classFilterMenu = document.getElementById('class-filter-menu');
            if (classFilterButton && classFilterMenu) {
                classFilterButton.addEventListener('click', (e) => {
                    e.preventDefault();
                    classFilterMenu.classList.toggle('hidden');
                    classFilterButton.setAttribute('data-state', classFilterMenu.classList.contains('hidden') ? 'closed' : 'open');
                });
                document.addEventListener('click', (event) => {
                    if (!classFilterButton.contains(event.target) && !classFilterMenu.contains(event.target)) {
                        classFilterMenu.classList.add('hidden');
                    }
                });
            }

            // Custom date modal
            const customDateBtn = document.getElementById('custom-date-btn');
            const customDateModal = document.getElementById('custom-date-modal');
            const closeCustomDate = document.getElementById('close-custom-date');
            const closeCustomDateX = document.getElementById('close-custom-date-x');
            const applyCustomDate = document.getElementById('apply-custom-date');
            const dateFromInput = document.getElementById('date-from');
            const dateToInput = document.getElementById('date-to');

            function closeDateModal() {
                const modalContent = document.getElementById('date-modal-content');
                modalContent.classList.remove('opacity-100', 'translate-y-0', 'sm:scale-100');
                modalContent.classList.add('opacity-0', 'translate-y-4', 'sm:translate-y-0', 'sm:scale-95');
                setTimeout(() => {
                    customDateModal.classList.add('hidden');
                    document.body.classList.remove('modal-active');
                }, 300);
            }

            if (customDateBtn) {
                customDateBtn.addEventListener('click', () => {
                    customDateModal.classList.remove('hidden');
                    document.body.classList.add('modal-active');
                    const today = new Date();
                    const nextWeek = new Date();
                    nextWeek.setDate(today.getDate() + 7);
                    const formatDate = (d) =>
                        `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
                    dateFromInput.value = formatDate(today);
                    dateToInput.value = formatDate(nextWeek);
                    dateToInput.min = dateFromInput.value;
                    const modalContent = document.getElementById('date-modal-content');
                    setTimeout(() => {
                        modalContent.classList.remove('opacity-0', 'translate-y-4',
                            'sm:translate-y-0', 'sm:scale-95');
                        modalContent.classList.add('opacity-100', 'translate-y-0', 'sm:scale-100');
                    }, 10);
                });
            }
            if (closeCustomDate) closeCustomDate.addEventListener('click', closeDateModal);
            if (closeCustomDateX) closeCustomDateX.addEventListener('click', closeDateModal);
            if (applyCustomDate) {
                applyCustomDate.addEventListener('click', () => {
                    const dateFrom = dateFromInput.value;
                    const dateTo = dateToInput.value;
                    if (dateFrom && dateTo) {
                        window.location.href =
                            `{{ route('admin.dashboard') }}?filter=Custom&date_from=${dateFrom}&date_to=${dateTo}&tab={{ $tab ?? 'all' }}`;
                    } else {
                        alert('Silakan pilih kedua tanggal.');
                    }
                });
            }

            document.querySelectorAll('.quick-date-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    const days = parseInt(btn.getAttribute('data-days'));
                    const end = new Date();
                    const start = new Date();
                    start.setDate(end.getDate() - days);
                    const format = (d) =>
                        `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
                    dateFromInput.value = format(start);
                    dateToInput.value = format(end);
                    dateToInput.min = dateFromInput.value;
                });
            });

            if (dateFromInput && dateToInput) {
                dateFromInput.addEventListener('change', () => {
                    dateToInput.min = dateFromInput.value;
                });
            }

            window.showDocument = (url) => {
                document.getElementById('document-image').src = url;
                document.getElementById('document-modal').classList.remove('hidden');
            };
            window.showVideo = (url) => {
                const video = document.getElementById('document-video');
                video.src = url;
                document.getElementById('videoModal').classList.remove('hidden');
            };
            document.getElementById('close-document-modal')?.addEventListener('click', () => {
                document.getElementById('document-modal').classList.add('hidden');
                document.getElementById('document-image').src = '';
            });
            document.getElementById('close-video-modal')?.addEventListener('click', () => {
                const video = document.getElementById('document-video');
                video.pause();
                video.src = '';
                document.getElementById('videoModal').classList.add('hidden');
            });
        });
    </script>
@endpush

@push('styles')
    <style>
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-fade-in {
            animation: fadeIn 0.5s ease-out forwards;
        }

        .tab-link,
        .sub-tab-link {
            transition: all 0.2s ease;
        }

        .tab-active {
            border-bottom-width: 2px;
        }

        .custom-scrollbar::-webkit-scrollbar {
            height: 6px;
            width: 6px;
        }

        .custom-scrollbar::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        .custom-scrollbar::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 10px;
        }

        .dark .custom-scrollbar::-webkit-scrollbar-track {
            background: #1f2937;
        }

        .dark .custom-scrollbar::-webkit-scrollbar-thumb {
            background: #4b5563;
        }
    </style>
@endpush

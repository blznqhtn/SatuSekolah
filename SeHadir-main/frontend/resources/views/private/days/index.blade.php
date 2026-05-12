@extends('layouts.app')

@section('title', 'Days Management')

@section('content')
    <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-4 sm:py-8">
        <!-- Header Modern dengan Gradien -->
        <div class="md:flex md:items-center md:justify-between mb-8 relative">
            <div class="min-w-0 flex-1">
                <h2 class="text-2xl sm:text-3xl font-extrabold tracking-tight bg-linear-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent">
                    Kelola Jadwal Hari
                </h2>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400 flex items-center gap-2">
                    <i class="fa-regular fa-calendar-alt text-primary-500"></i>
                    Atur jadwal hari produktif, non-produktif, dan libur
                </p>
            </div>
            <div class="mt-4 flex md:mt-0 md:ml-4">
                <a href="{{ route('admin.days.create', ['bulan' => $bulan, 'tahun' => $tahun]) }}"
                    class="group inline-flex items-center w-full sm:w-auto justify-center gap-2 px-4 py-2.5 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white text-sm font-medium rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 active:scale-95 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500">
                    <i class="fa-solid fa-calendar-plus"></i>
                    <span>Atur Jadwal Bulan Ini</span>
                    <i class="fa-solid fa-arrow-right-long group-hover:translate-x-1 transition-transform"></i>
                </a>
            </div>
        </div>

        <!-- Card Utama dengan Glassmorphism -->
        <div class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-xl rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
            <!-- Header Card dengan Filter -->
            <div class="px-4 py-4 sm:px-6 border-b border-gray-100 dark:border-gray-700 bg-linear-to-r from-gray-50/50 to-transparent dark:from-gray-900/30">
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                    <h3 class="text-lg sm:text-xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
                        <i class="fa-solid fa-calendar-week text-primary-500"></i>
                        Jadwal Bulan {{ Carbon\Carbon::createFromDate(null, $bulan, 1)->locale('id')->monthName }}
                        {{ $tahun }}
                    </h3>
                    <div class="w-full sm:w-auto z-50">
                        <form id="filterForm" action="{{ route('admin.days.index') }}" method="GET" class="w-full">
                            <input type="hidden" id="bulanInput" name="bulan" value="{{ $bulan }}">
                            <input type="hidden" id="tahunInput" name="tahun" value="{{ $tahun }}">

                            <!-- Modern Date Picker dengan efek glass & support light/dark mode -->
                            <div class="date-picker-container">
                                <div class="date-picker-month" id="monthPicker">
                                    <span id="selectedMonth">{{ Carbon\Carbon::createFromDate(null, $bulan, 1)->locale('id')->monthName }}</span>
                                    <i class="fa-solid fa-chevron-down date-picker-icon" id="monthIcon"></i>
                                </div>
                                <div class="date-picker-divider"></div>
                                <div class="date-picker-year" id="yearPicker">
                                    <span id="selectedYear">{{ $tahun }}</span>
                                    <i class="fa-solid fa-chevron-down date-picker-icon" id="yearIcon"></i>
                                </div>

                                <!-- Month dropdown -->
                                <div class="date-picker-dropdown" id="monthDropdown">
                                    @for ($m = 1; $m <= 12; $m++)
                                        @php
                                            $monthName = Carbon\Carbon::createFromDate(null, $m, 1)->locale('id')->monthName;
                                        @endphp
                                        <div class="date-picker-option {{ $bulan == $m ? 'selected' : '' }}"
                                            data-value="{{ $m }}" data-name="{{ $monthName }}">
                                            {{ $monthName }}
                                        </div>
                                    @endfor
                                </div>

                                <!-- Year dropdown -->
                                <div class="date-picker-dropdown" id="yearDropdown">
                                    @for ($y = Carbon\Carbon::now()->year - 1; $y <= Carbon\Carbon::now()->year + 1; $y++)
                                        <div class="date-picker-option {{ $tahun == $y ? 'selected' : '' }}"
                                            data-value="{{ $y }}">
                                            {{ $y }}
                                        </div>
                                    @endfor
                                </div>
                            </div>
                            <button type="submit" class="hidden">Filter</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Tabel Modern dengan Hover Effects -->
            <div class="overflow-x-auto custom-scrollbar">
                <table class="min-w-full divide-y divide-gray-100 dark:divide-gray-700">
                    <thead class="bg-gray-50/80 dark:bg-gray-700/80 backdrop-blur-sm">
                        <tr>
                            <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">Tanggal</th>
                            <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">Hari</th>
                            <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">Tipe</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white/50 dark:bg-gray-800/50 divide-y divide-gray-100 dark:divide-gray-700">
                        @foreach ($dates as $dateInfo)
                            @php
                                $date = $dateInfo['date'];
                                $isWeekend = $date->isWeekend();
                            @endphp
                            <tr class="transition-all duration-200 hover:bg-gray-50/70 dark:hover:bg-gray-700/50 {{ $isWeekend ? 'bg-gray-50/40 dark:bg-gray-700/30' : '' }}">
                                <td class="px-4 sm:px-6 py-3 sm:py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                                    {{ $date->format('d M Y') }}
                                </td>
                                <td class="px-4 sm:px-6 py-3 sm:py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
                                    {{ $date->locale('id')->dayName }}
                                </td>
                                <td class="px-4 sm:px-6 py-3 sm:py-4 whitespace-nowrap">
                                    @if ($dateInfo['type'] == 'produktif')
                                        <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full bg-green-100 text-green-700 dark:bg-green-900/60 dark:text-green-300 shadow-sm">
                                            <i class="fa-regular fa-calendar-check mr-2 mt-0.5"></i> Hari Produktif
                                        </span>
                                    @elseif ($dateInfo['type'] == 'non_produktif')
                                        <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full bg-blue-100 text-blue-700 dark:bg-blue-900/60 dark:text-blue-300 shadow-sm">
                                            <i class="fa-regular fa-calendar-xmark mr-2 mt-0.5"></i> Hari Non-Produktif
                                        </span>
                                    @elseif ($dateInfo['type'] == 'libur')
                                        <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full bg-red-100 text-red-700 dark:bg-red-900/60 dark:text-red-300 shadow-sm">
                                            <i class="fa-regular fa-calendar-times mr-2 mt-0.5"></i> Hari Libur
                                        </span>
                                    @else
                                        @if ($isWeekend)
                                            <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300 shadow-sm">
                                                <i class="fa-regular fa-calendar-week mr-2 mt-0.5"></i> Akhir Pekan
                                            </span>
                                        @else
                                            <span class="px-3 py-1 inline-flex text-xs font-semibold rounded-full bg-gray-100 text-gray-500 dark:bg-gray-700 dark:text-gray-400 shadow-sm">
                                                <i class="fa-regular fa-clock mr-2 mt-0.5"></i> Belum Diatur
                                            </span>
                                        @endif
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </main>
@endsection

@push('styles')
    <style>
        /* Date Picker yang mendukung Light & Dark Mode */
        .date-picker-container {
            display: inline-flex;
            align-items: center;
            background: var(--picker-bg, #ffffff);
            backdrop-filter: blur(4px);
            border-radius: 1rem;
            border: 1px solid var(--picker-border, #e5e7eb);
            padding: 0.5rem 1rem;
            width: 100%;
            max-width: 280px;
            position: relative;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            transition: all 0.3s ease;
        }
        /* Light mode (default) */
        .date-picker-container {
            --picker-bg: #ffffff;
            --picker-border: #e5e7eb;
            --picker-text: #1f2937;
            --picker-hover-text: #2563eb;
            --divider-bg: linear-gradient(to bottom, #d1d5db, #9ca3af, #d1d5db);
            --dropdown-bg: rgba(255, 255, 255, 0.98);
            --dropdown-border: #e5e7eb;
            --option-text: #374151;
            --option-hover-bg: rgba(37, 99, 235, 0.1);
            --option-selected-bg: rgba(37, 99, 235, 0.15);
            --option-selected-border: #2563eb;
            --scrollbar-track: rgba(0, 0, 0, 0.05);
            --scrollbar-thumb: #cbd5e1;
        }
        /* Dark mode */
        .dark .date-picker-container {
            --picker-bg: #1e293b;
            --picker-border: #0ea5e9;
            --picker-text: #f1f5f9;
            --picker-hover-text: #38bdf8;
            --divider-bg: linear-gradient(to bottom, rgba(255,255,255,0.1), rgba(255,255,255,0.4), rgba(255,255,255,0.1));
            --dropdown-bg: rgba(30, 41, 59, 0.95);
            --dropdown-border: rgba(14, 165, 233, 0.5);
            --option-text: #e2e8f0;
            --option-hover-bg: rgba(14, 165, 233, 0.25);
            --option-selected-bg: rgba(14, 165, 233, 0.4);
            --option-selected-border: #0ea5e9;
            --scrollbar-track: rgba(255, 255, 255, 0.05);
            --scrollbar-thumb: rgba(14, 165, 233, 0.5);
        }
        .date-picker-container {
            background: var(--picker-bg);
            border-color: var(--picker-border);
        }
        .date-picker-container:hover {
            border-color: #0ea5e9;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        .date-picker-month, .date-picker-year {
            color: var(--picker-text);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex: 1;
            padding: 0.125rem 0;
        }
        .date-picker-month { flex: 3; }
        .date-picker-year { flex: 2; justify-content: flex-end; }
        .date-picker-month:hover, .date-picker-year:hover {
            color: var(--picker-hover-text);
            transform: translateY(-1px);
        }
        .date-picker-divider {
            width: 1px;
            height: 24px;
            background: var(--divider-bg);
            margin: 0 0.75rem;
        }
        .date-picker-dropdown {
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            width: 100%;
            background: var(--dropdown-bg);
            backdrop-filter: blur(8px);
            border: 1px solid var(--dropdown-border);
            border-radius: 0.75rem;
            z-index: 50;
            max-height: 260px;
            overflow-y: auto;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2), 0 10px 10px -5px rgba(0, 0, 0, 0.1);
            display: none;
            transition: opacity 0.2s ease;
        }
        .date-picker-dropdown.show {
            display: block;
            animation: fadeInDown 0.2s ease-out;
        }
        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .date-picker-option {
            padding: 0.6rem 1rem;
            color: var(--option-text);
            cursor: pointer;
            transition: all 0.15s ease;
            font-size: 0.875rem;
            font-weight: 500;
        }
        .date-picker-option:hover {
            background: var(--option-hover-bg);
            color: var(--picker-hover-text);
            padding-left: 1.25rem;
        }
        .date-picker-option.selected {
            background: var(--option-selected-bg);
            color: var(--picker-hover-text);
            font-weight: 600;
            border-left: 3px solid var(--option-selected-border);
        }
        .date-picker-icon {
            margin-left: 0.5rem;
            font-size: 0.7rem;
            transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .date-picker-icon.rotate {
            transform: rotate(180deg);
        }
        /* Scrollbar */
        .date-picker-dropdown::-webkit-scrollbar {
            width: 5px;
        }
        .date-picker-dropdown::-webkit-scrollbar-track {
            background: var(--scrollbar-track);
            border-radius: 10px;
        }
        .date-picker-dropdown::-webkit-scrollbar-thumb {
            background: var(--scrollbar-thumb);
            border-radius: 10px;
        }
        .custom-scrollbar::-webkit-scrollbar {
            height: 5px;
            width: 5px;
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
        /* Responsive */
        @media (max-width: 640px) {
            .date-picker-container {
                max-width: 100%;
                padding: 0.4rem 0.75rem;
            }
            .date-picker-month, .date-picker-year {
                font-size: 0.8rem;
            }
        }
    </style>
@endpush

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const filterForm = document.getElementById('filterForm');
            const bulanInput = document.getElementById('bulanInput');
            const tahunInput = document.getElementById('tahunInput');

            const monthPicker = document.getElementById('monthPicker');
            const monthDropdown = document.getElementById('monthDropdown');
            const monthOptions = monthDropdown.querySelectorAll('.date-picker-option');
            const selectedMonth = document.getElementById('selectedMonth');
            const monthIcon = document.getElementById('monthIcon');

            const yearPicker = document.getElementById('yearPicker');
            const yearDropdown = document.getElementById('yearDropdown');
            const yearOptions = yearDropdown.querySelectorAll('.date-picker-option');
            const selectedYear = document.getElementById('selectedYear');
            const yearIcon = document.getElementById('yearIcon');

            function closeAllDropdowns() {
                monthDropdown.classList.remove('show');
                yearDropdown.classList.remove('show');
                monthIcon.classList.remove('rotate');
                yearIcon.classList.remove('rotate');
            }

            monthPicker.addEventListener('click', function(e) {
                e.stopPropagation();
                const isOpen = monthDropdown.classList.contains('show');
                closeAllDropdowns();
                if (!isOpen) {
                    monthDropdown.classList.add('show');
                    monthIcon.classList.add('rotate');
                }
            });

            yearPicker.addEventListener('click', function(e) {
                e.stopPropagation();
                const isOpen = yearDropdown.classList.contains('show');
                closeAllDropdowns();
                if (!isOpen) {
                    yearDropdown.classList.add('show');
                    yearIcon.classList.add('rotate');
                }
            });

            monthOptions.forEach(option => {
                option.addEventListener('click', function() {
                    const value = this.getAttribute('data-value');
                    const name = this.getAttribute('data-name');
                    bulanInput.value = value;
                    selectedMonth.textContent = name;
                    monthOptions.forEach(opt => opt.classList.remove('selected'));
                    this.classList.add('selected');
                    closeAllDropdowns();
                    filterForm.submit();
                });
            });

            yearOptions.forEach(option => {
                option.addEventListener('click', function() {
                    const value = this.getAttribute('data-value');
                    tahunInput.value = value;
                    selectedYear.textContent = value;
                    yearOptions.forEach(opt => opt.classList.remove('selected'));
                    this.classList.add('selected');
                    closeAllDropdowns();
                    filterForm.submit();
                });
            });

            document.addEventListener('click', function() {
                closeAllDropdowns();
            });

            monthDropdown.addEventListener('click', function(e) {
                e.stopPropagation();
            });

            yearDropdown.addEventListener('click', function(e) {
                e.stopPropagation();
            });
        });
    </script>
@endpush
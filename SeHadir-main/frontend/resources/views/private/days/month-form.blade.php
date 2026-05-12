@extends('layouts.app')

@section('title', 'Days Create')

@section('content')
    <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-4 sm:py-8">
        <div class="md:flex md:items-center md:justify-between mb-8 relative">
            <div class="min-w-0 flex-1">
                <h2
                    class="text-2xl sm:text-3xl font-extrabold tracking-tight bg-linear-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent">
                    Atur Jadwal Bulanan
                </h2>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400 flex items-center gap-2">
                    <i class="fa-regular fa-calendar-alt text-primary-500"></i>
                    Atur jadwal hari produktif, non-produktif, dan libur untuk bulan
                    {{ Carbon\Carbon::createFromDate(null, $bulan, 1)->locale('id')->monthName }} {{ $tahun }}
                </p>
            </div>
            <div class="mt-4 flex md:mt-0 md:ml-4">
                <a href="{{ route('admin.days.index', ['bulan' => $bulan, 'tahun' => $tahun]) }}"
                    class="group inline-flex items-center gap-2 px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-xl shadow-sm text-sm font-medium text-gray-700 dark:text-gray-200 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm hover:bg-gray-50 dark:hover:bg-gray-700 transition-all duration-300 hover:scale-105">
                    <i class="fa-solid fa-arrow-left group-hover:-translate-x-1 transition-transform"></i>
                    Kembali
                </a>
            </div>
        </div>

        <div
            class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-xl rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
            <div
                class="px-4 py-4 sm:px-6 border-b border-gray-100 dark:border-gray-700 bg-linear-to-r from-gray-50/50 to-transparent dark:from-gray-900/30">
                <h3 class="text-lg sm:text-xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
                    <i class="fa-solid fa-calendar-pen text-primary-500"></i>
                    Form Pengaturan Jadwal
                </h3>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                    Pilih tipe hari untuk setiap tanggal dalam bulan
                    {{ Carbon\Carbon::createFromDate(null, $bulan, 1)->locale('id')->monthName }} {{ $tahun }}.
                </p>
            </div>

            <form action="{{ route('admin.days.store') }}" method="POST">
                @csrf
                <input type="hidden" name="bulan" value="{{ $bulan }}">
                <input type="hidden" name="tahun" value="{{ $tahun }}">

                <div class="hidden md:block overflow-x-auto custom-scrollbar">
                    <table class="min-w-full divide-y divide-gray-100 dark:divide-gray-700">
                        <thead class="bg-gray-50/80 dark:bg-gray-700/80 backdrop-blur-sm">
                            <tr>
                                <th
                                    class="px-4 sm:px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Tanggal</th>
                                <th
                                    class="px-4 sm:px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Hari</th>
                                <th
                                    class="px-4 sm:px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Tipe Hari</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white/50 dark:bg-gray-800/50 divide-y divide-gray-100 dark:divide-gray-700">
                            @foreach ($dates as $dateInfo)
                                @php
                                    $date = $dateInfo['date'];
                                    $isWeekend = $date->isWeekend();
                                    $dateStr = $dateInfo['date_str'];
                                @endphp
                                <tr
                                    class="transition-all duration-200 hover:bg-gray-50/70 dark:hover:bg-gray-700/50 {{ $isWeekend ? 'bg-gray-50/40 dark:bg-gray-700/30' : '' }}">
                                    <td
                                        class="px-4 sm:px-6 py-3 sm:py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-gray-100">
                                        {{ $date->format('d M Y') }}</td>
                                    <td
                                        class="px-4 sm:px-6 py-3 sm:py-4 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300">
                                        {{ $date->locale('id')->dayName }}</td>
                                    <td class="px-4 sm:px-6 py-3 sm:py-4 whitespace-nowrap">
                                        <select name="types[{{ $dateStr }}]"
                                            class="type-select block w-full pl-3 pr-8 py-2 text-sm border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent">
                                            <option value="">-- Pilih Tipe Hari --</option>
                                            <option value="produktif"
                                                {{ $dateInfo['type'] == 'produktif' ? 'selected' : '' }}>Hari Produktif
                                            </option>
                                            <option value="non_produktif"
                                                {{ $dateInfo['type'] == 'non_produktif' ? 'selected' : '' }}>Hari
                                                Non-Produktif</option>
                                            <option value="libur" {{ $dateInfo['type'] == 'libur' ? 'selected' : '' }}>
                                                Hari Libur</option>
                                        </select>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                <div class="md:hidden divide-y divide-gray-100 dark:divide-gray-700">
                    @foreach ($dates as $dateInfo)
                        @php
                            $date = $dateInfo['date'];
                            $isWeekend = $date->isWeekend();
                            $dateStr = $dateInfo['date_str'];
                        @endphp
                        <div class="p-4 {{ $isWeekend ? 'bg-gray-50/40 dark:bg-gray-700/30' : '' }}">
                            <div class="flex justify-between items-start mb-2">
                                <div>
                                    <div class="text-base font-bold text-gray-900 dark:text-white">
                                        {{ $date->format('d M Y') }}</div>
                                    <div class="text-sm text-gray-600 dark:text-gray-400">
                                        {{ $date->locale('id')->dayName }}</div>
                                </div>
                            </div>
                            <div class="mt-2">
                                <select name="types[{{ $dateStr }}]"
                                    class="type-select block w-full pl-3 pr-8 py-2 text-sm border-gray-200 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent">
                                    <option value="">-- Pilih Tipe Hari --</option>
                                    <option value="produktif" {{ $dateInfo['type'] == 'produktif' ? 'selected' : '' }}>Hari
                                        Produktif</option>
                                    <option value="non_produktif"
                                        {{ $dateInfo['type'] == 'non_produktif' ? 'selected' : '' }}>Hari Non-Produktif
                                    </option>
                                    <option value="libur" {{ $dateInfo['type'] == 'libur' ? 'selected' : '' }}>Hari Libur
                                    </option>
                                </select>
                            </div>
                        </div>
                    @endforeach
                </div>

                <div
                    class="px-4 py-4 sm:px-6 bg-gray-50/80 dark:bg-gray-800/80 text-right border-t border-gray-100 dark:border-gray-700 rounded-b-2xl">
                    <button type="submit"
                        class="group inline-flex items-center gap-2 px-5 py-2.5 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-medium rounded-xl shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 active:scale-95">
                        <i class="fa-solid fa-save"></i>
                        <span>Simpan Jadwal</span>
                        <i class="fa-solid fa-arrow-right-long group-hover:translate-x-1 transition-transform"></i>
                    </button>
                </div>
            </form>
        </div>

        <div class="mt-8">
            <div
                class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm shadow-xl rounded-2xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                <div
                    class="px-4 py-4 sm:px-6 border-b border-gray-100 dark:border-gray-700 bg-linear-to-r from-gray-50/50 to-transparent dark:from-gray-900/30">
                    <h3 class="text-lg sm:text-xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
                        <i class="fa-solid fa-bolt text-yellow-500"></i>
                        Pengaturan Cepat
                    </h3>
                    <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                        Gunakan tombol di bawah untuk mengatur jadwal dengan cepat.
                    </p>
                </div>
                <div class="p-4 sm:p-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                    <div
                        class="group flex flex-col h-full relative overflow-hidden rounded-xl bg-linear-to-br from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 border border-green-100 dark:border-green-800/50 p-5 transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
                        <div
                            class="absolute inset-0 bg-linear-to-br from-green-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
                        </div>
                        <div class="relative flex flex-col h-full">
                            <div class="flex items-center justify-between mb-3">
                                <h4 class="text-md font-bold text-green-800 dark:text-green-300">Hari Produktif</h4>
                                <i class="fa-solid fa-school text-green-600 dark:text-green-400 text-xl"></i>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-300 grow">Atur semua hari Senin-Jumat sebagai
                                hari produktif (Masuk normal dengan KBM).</p>
                            <div class="mt-4">
                                <button type="button" id="setWorkdays"
                                    class="w-full inline-flex justify-center items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-200 hover:scale-105">
                                    <i class="fa-solid fa-check"></i> Atur Hari Produktif
                                </button>
                            </div>
                        </div>
                    </div>

                    <div
                        class="group flex flex-col h-full relative overflow-hidden rounded-xl bg-linear-to-br from-red-50 to-rose-50 dark:from-red-900/20 dark:to-rose-900/20 border border-red-100 dark:border-red-800/50 p-5 transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
                        <div class="relative flex flex-col h-full">
                            <div class="flex items-center justify-between mb-3">
                                <h4 class="text-md font-bold text-red-800 dark:text-red-300">Akhir Pekan Penuh</h4>
                                <i class="fa-solid fa-umbrella-beach text-red-600 dark:text-red-400 text-xl"></i>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-300 grow">Atur semua hari Sabtu-Minggu sebagai
                                hari libur.</p>
                            <div class="mt-4">
                                <button type="button" id="setWeekendsFully"
                                    class="w-full inline-flex justify-center items-center gap-2 px-4 py-2 bg-red-600 hover:bg-red-700 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-200 hover:scale-105">
                                    <i class="fa-solid fa-check"></i> Atur Akhir Pekan Penuh
                                </button>
                            </div>
                        </div>
                    </div>

                    <div
                        class="group flex flex-col h-full relative overflow-hidden rounded-xl bg-linear-to-br from-gray-100 to-slate-100 dark:from-gray-800/50 dark:to-slate-800/50 border border-gray-200 dark:border-gray-700 p-5 transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
                        <div class="relative flex flex-col h-full">
                            <div class="flex items-center justify-between mb-3">
                                <h4 class="text-md font-bold text-gray-700 dark:text-gray-300">Reset Semua</h4>
                                <i class="fa-solid fa-trash-alt text-gray-500 dark:text-gray-400 text-xl"></i>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-300 grow">Kosongkan semua pengaturan hari pada
                                bulan ini.</p>
                            <div class="mt-4">
                                <button type="button" id="resetAll"
                                    class="w-full inline-flex justify-center items-center gap-2 px-4 py-2 bg-gray-700 hover:bg-gray-800 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-200 hover:scale-105">
                                    <i class="fa-solid fa-undo-alt"></i> Reset Semua
                                </button>
                            </div>
                        </div>
                    </div>

                    <div
                        class="group flex flex-col h-full relative overflow-hidden rounded-xl bg-linear-to-br from-blue-50 to-sky-50 dark:from-blue-900/20 dark:to-sky-900/20 border border-blue-100 dark:border-blue-800/50 p-5 transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
                        <div class="relative flex flex-col h-full">
                            <div class="flex items-center justify-between mb-3">
                                <h4 class="text-md font-bold text-blue-800 dark:text-blue-300">Hari Non-Produktif</h4>
                                <i class="fa-solid fa-calendar-check text-blue-600 dark:text-blue-400 text-xl"></i>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-300 grow">Atur semua hari Sabtu sebagai hari
                                non-produktif (Masuk tanpa KBM).</p>
                            <div class="mt-4">
                                <button type="button" id="setNonWorkdays"
                                    class="w-full inline-flex justify-center items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-200 hover:scale-105">
                                    <i class="fa-solid fa-check"></i> Atur Hari Non-Produktif
                                </button>
                            </div>
                        </div>
                    </div>

                    <div
                        class="group flex flex-col h-full relative overflow-hidden rounded-xl bg-linear-to-br from-orange-50 to-amber-50 dark:from-orange-900/20 dark:to-amber-900/20 border border-orange-100 dark:border-orange-800/50 p-5 transition-all duration-300 hover:shadow-lg hover:-translate-y-1">
                        <div class="relative flex flex-col h-full">
                            <div class="flex items-center justify-between mb-3">
                                <h4 class="text-md font-bold text-orange-800 dark:text-orange-300">Akhir Pekan (Minggu)
                                </h4>
                                <i class="fa-solid fa-calendar-week text-orange-600 dark:text-orange-400 text-xl"></i>
                            </div>
                            <p class="text-sm text-gray-600 dark:text-gray-300 grow">Atur semua hari Minggu sebagai hari
                                libur.</p>
                            <div class="mt-4">
                                <button type="button" id="setWeekends"
                                    class="w-full inline-flex justify-center items-center gap-2 px-4 py-2 bg-orange-600 hover:bg-orange-700 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-200 hover:scale-105">
                                    <i class="fa-solid fa-check"></i> Atur Akhir Pekan
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const selects = () => document.querySelectorAll('select[name^="types"]');

            // --- PERBAIKAN: Sinkronisasi Desktop & Mobile ---
            selects().forEach(select => {
                select.addEventListener('change', function() {
                    const siblingSelects = document.querySelectorAll(`select[name="${this.name}"]`);
                    siblingSelects.forEach(s => {
                        s.value = this.value; // Samakan nilai select desktop & mobile
                    });
                });
            });
            // ------------------------------------------------

            document.getElementById('setWorkdays').addEventListener('click', function() {
                selects().forEach(select => {
                    const dateStr = select.name.match(/\[(.*?)\]/)[1];
                    const date = new Date(dateStr);
                    const day = date.getDay();
                    if (day >= 1 && day <= 5) select.value = 'produktif';
                });
            });

            document.getElementById('setWeekendsFully').addEventListener('click', function() {
                selects().forEach(select => {
                    const dateStr = select.name.match(/\[(.*?)\]/)[1];
                    const date = new Date(dateStr);
                    const day = date.getDay();
                    if (day === 0 || day === 6) select.value = 'libur';
                });
            });

            document.getElementById('setWeekends').addEventListener('click', function() {
                selects().forEach(select => {
                    const dateStr = select.name.match(/\[(.*?)\]/)[1];
                    const date = new Date(dateStr);
                    const day = date.getDay();
                    if (day === 0) select.value = 'libur';
                    if (day === 6) select.value = '';
                });
            });

            document.getElementById('resetAll').addEventListener('click', function() {
                selects().forEach(select => select.value = '');
            });

            document.getElementById('setNonWorkdays').addEventListener('click', function() {
                selects().forEach(select => {
                    const dateStr = select.name.match(/\[(.*?)\]/)[1];
                    const date = new Date(dateStr);
                    const day = date.getDay();
                    if (day === 6) select.value = 'non_produktif';
                });
            });
        });
    </script>
@endpush

@push('styles')
    <style>
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

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .group {
            animation: fadeInUp 0.4s ease-out forwards;
        }
    </style>
@endpush
@extends('private.members.app')

@section('title', 'Data Chart')

@section('content-siswa')
    <div id="presensi-chart" class="tab-content">
        <!-- Filter Bar Modern - Responsif Mobile -->
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 p-5 mb-8 transition-all duration-300">
            <form method="GET" action="{{ route('admin.accounts.charts') }}" class="flex flex-col gap-4">
                <!-- Baris 1: Search -->
                <div class="flex w-full">
                    <div class="relative flex-1">
                        <i
                            class="fa-solid fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-500 text-sm"></i>
                        <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama siswa..."
                            class="w-full pl-10 pr-4 py-3 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                    </div>
                    <button type="submit"
                        class="px-6 py-3 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold rounded-r-xl shadow-md transition-all duration-300">
                        Cari
                    </button>
                </div>

                <div class="flex flex-col sm:flex-row gap-3">
                    <select name="bulan" onchange="this.form.submit()"
                        class="w-full sm:w-auto px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 cursor-pointer transition-all">
                        @foreach ($months as $key => $month)
                            <option value="{{ $key }}"
                                {{ request('bulan', $currentMonth) == $key ? 'selected' : '' }}>
                                {{ $month }}
                            </option>
                        @endforeach
                    </select>

                    <select name="tahun" onchange="this.form.submit()"
                        class="w-full sm:w-auto px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 cursor-pointer transition-all">
                        @foreach ($years as $year)
                            <option value="{{ $year }}"
                                {{ request('tahun', $currentYear) == $year ? 'selected' : '' }}>
                                {{ $year }}
                            </option>
                        @endforeach
                    </select>

                    <select name="kelas" onchange="this.form.submit()"
                        class="w-full sm:w-auto px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 cursor-pointer transition-all">
                        <option value="all">Semua Kelas</option>
                        @foreach ($dataKelas as $kelasOption)
                            <option value="{{ $kelasOption->name }}" {{ request('kelas') == $kelasOption->id ? 'selected' : '' }}>
                                {{ $kelasOption->name }}
                            </option>
                        @endforeach
                    </select>

                    <button type="button" onclick="window.location.href='{{ route('admin.accounts.charts') }}'" title="Refresh"
                        class="w-full sm:w-auto inline-flex items-center justify-center px-4 py-3 rounded-xl bg-linear-to-r from-orange-500 to-amber-600 text-white shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105">
                        <i class="fa-solid fa-rotate-right"></i>
                    </button>
                </div>
            </form>
        </div>

        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 p-6 mb-8 transition-all duration-300">
            <div class="h-96 w-full relative">
                <canvas id="attendanceChart"></canvas>
            </div>
            <div class="flex justify-center mt-6 gap-8">
                <div class="flex items-center gap-2">
                    <div class="w-5 h-5 rounded-full bg-linear-to-r from-blue-500 to-cyan-500 shadow-md"></div>
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Hari Produktif</span>
                </div>
                <div class="flex items-center gap-2">
                    <div class="w-5 h-5 rounded-full bg-linear-to-r from-orange-500 to-red-500 shadow-md"></div>
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Hari Non-Produktif</span>
                </div>
            </div>
        </div>

        <!-- Tabel & Card View (sama seperti sebelumnya, tidak diubah) -->
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
            <!-- Desktop Table -->
            <div class="hidden md:block overflow-x-auto custom-scrollbar">
                <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                    <thead class="bg-gray-50/80 dark:bg-gray-700/80 backdrop-blur-sm">
                        <tr>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                No</th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                Nama</th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                Kelas</th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                Jml Presensi</th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                Persentase MoM</th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                Hari Non-Produktif</th>
                            <th
                                class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                Persentase Bulan Ini</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                        @forelse ($attendanceData as $student)
                            <tr class="group transition-all duration-200 hover:bg-gray-50/70 dark:hover:bg-gray-700/50">
                                <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">
                                    {{ $loop->iteration }}.</td>
                                <td
                                    class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-100">
                                    {{ $student->name }}</td>
                                <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                                    {{ $student->class }}</td>
                                <td
                                    class="px-4 py-3 whitespace-nowrap text-sm font-mono font-medium text-gray-900 dark:text-gray-100">
                                    {{ $student->productive_days }}</td>
                                <td class="px-4 py-3 whitespace-nowrap text-sm">
                                    @if ($student->comparison > 0)
                                        <span
                                            class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300 text-xs font-semibold">+{{ $student->comparison }}%</span>
                                    @elseif ($student->comparison < 0)
                                        <span
                                            class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-red-100 text-red-700 dark:bg-red-900/50 dark:text-red-300 text-xs font-semibold">{{ $student->comparison }}%</span>
                                    @else
                                        <span class="text-gray-500">0%</span>
                                    @endif
                                </td>
                                <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                                    {{ $student->non_productive_days }}</td>
                                <td
                                    class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-primary-600 dark:text-primary-400">
                                    {{ $student->percentage }}%</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">Tidak ada
                                    data presensi yang ditemukan</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            <!-- Mobile Card View -->
            <div class="md:hidden divide-y divide-gray-100 dark:divide-gray-700">
                @forelse ($attendanceData as $student)
                    <div class="p-4 hover:bg-gray-50/70 dark:hover:bg-gray-700/50 transition-colors">
                        <div class="flex justify-between items-start mb-2">
                            <div>
                                <h4 class="text-base font-bold text-gray-900 dark:text-white">{{ $student->name }}</h4>
                                <p class="text-xs text-gray-500 dark:text-gray-400">{{ $student->class }}</p>
                            </div>
                            <span class="text-xs font-mono text-gray-500 dark:text-gray-400">#{{ $loop->iteration }}</span>
                        </div>
                        <div class="grid grid-cols-2 gap-3 mt-3 text-sm">
                            <div><span class="text-gray-500">Jml Presensi:</span> <span
                                    class="font-semibold">{{ $student->productive_days }}</span></div>
                            <div><span class="text-gray-500">Hari Non-Produktif:</span> <span
                                    class="font-semibold">{{ $student->non_productive_days }}</span></div>
                            <div>
                                <span class="text-gray-500">Persentase MoM:</span>
                                @if ($student->comparison > 0)
                                    <span class="text-green-600 font-semibold">+{{ $student->comparison }}%</span>
                                @elseif ($student->comparison < 0)
                                    <span class="text-red-600 font-semibold">{{ $student->comparison }}%</span>
                                @else<span class="text-gray-500">0%</span>
                                @endif
                            </div>
                            <div><span class="text-gray-500">Persentase Bulan Ini:</span> <span
                                    class="text-primary-600 font-semibold">{{ $student->percentage }}%</span></div>
                        </div>
                    </div>
                @empty
                    <div class="p-8 text-center text-gray-500">Tidak ada data</div>
                @endforelse
            </div>

            <!-- Pagination (sama) -->
            <div
                class="bg-white/50 dark:bg-gray-800/50 px-4 py-4 flex items-center justify-between border-t border-gray-100 dark:border-gray-700 sm:px-6">
                <!-- ... (pagination sama seperti sebelumnya, tidak diubah) ... -->
                <div class="flex-1 flex justify-between sm:hidden">
                    @if ($attendanceData->onFirstPage())
                        <span
                            class="px-4 py-2 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-400 text-sm">Previous</span>
                    @else
                        <a href="{{ $attendanceData->previousPageUrl() }}"
                            class="px-4 py-2 rounded-xl bg-white dark:bg-gray-800 text-gray-700 shadow-sm hover:bg-gray-50 transition text-sm">Previous</a>
                    @endif
                    @if ($attendanceData->hasMorePages())
                        <a href="{{ $attendanceData->nextPageUrl() }}"
                            class="px-4 py-2 rounded-xl bg-white dark:bg-gray-800 text-gray-700 shadow-sm hover:bg-gray-50 transition text-sm">Next</a>
                    @else
                        <span class="px-4 py-2 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-400 text-sm">Next</span>
                    @endif
                </div>
                <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                    <div>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Menampilkan <span
                                class="font-semibold">{{ $attendanceData->firstItem() }}</span> sampai <span
                                class="font-semibold">{{ $attendanceData->lastItem() }}</span> dari <span
                                class="font-semibold">{{ $attendanceData->total() }}</span> hasil</p>
                    </div>
                    <div>
                        <nav class="relative z-0 inline-flex rounded-xl shadow-sm -space-x-px">
                            @if ($attendanceData->onFirstPage())
                                <span
                                    class="relative inline-flex items-center px-3 py-2 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-400"><i
                                        class="fa-solid fa-chevron-left text-xs"></i></span>
                            @else
                                <a href="{{ $attendanceData->previousPageUrl() }}"
                                    class="relative inline-flex items-center px-3 py-2 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 hover:bg-gray-50"><i
                                        class="fa-solid fa-chevron-left text-xs"></i></a>
                            @endif
                            @php
                                $currentPage = $attendanceData->currentPage();
                                $lastPage = $attendanceData->lastPage();
                                $start = max($currentPage - 2, 1);
                                $end = min($currentPage + 2, $lastPage);
                            @endphp
                            @if ($start > 1)
                                <a href="{{ $attendanceData->url(1) }}"
                                    class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">1</a>
                                @if ($start > 2)
                                    <span
                                        class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-500">…</span>
                                @endif
                            @endif
                            @for ($page = $start; $page <= $end; $page++)
                                @if ($page == $currentPage)
                                    <span
                                        class="z-10 relative inline-flex items-center px-4 py-2 border border-primary-500 bg-primary-50 dark:bg-primary-900/40 text-primary-600 dark:text-primary-400 text-sm font-medium">{{ $page }}</span>
                                @else
                                    <a href="{{ $attendanceData->url($page) }}"
                                        class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">{{ $page }}</a>
                                @endif
                            @endfor
                            @if ($end < $lastPage)
                                @if ($end < $lastPage - 1)
                                    <span
                                        class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-500">…</span>
                                @endif
                                <a href="{{ $attendanceData->url($lastPage) }}"
                                    class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">{{ $lastPage }}</a>
                            @endif
                            @if ($attendanceData->hasMorePages())
                                <a href="{{ $attendanceData->nextPageUrl() }}"
                                    class="relative inline-flex items-center px-3 py-2 rounded-r-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 hover:bg-gray-50"><i
                                        class="fa-solid-chevron-right text-xs"></i></a>
                            @else
                                <span
                                    class="relative inline-flex items-center px-3 py-2 rounded-r-xl border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-400"><i
                                        class="fa-solid fa-chevron-right text-xs"></i></span>
                            @endif
                        </nav>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const ctx = document.getElementById('attendanceChart').getContext('2d');
            const chartData = @json($chartData);
            const totalProductiveDays = {{ $totalProductiveDays ?? 0 }};

            // Gradien untuk batang (modern crypto style)
            const gradientBlue = ctx.createLinearGradient(0, 0, 0, 400);
            gradientBlue.addColorStop(0, '#3b82f6');
            gradientBlue.addColorStop(1, '#06b6d4');

            const gradientOrange = ctx.createLinearGradient(0, 0, 0, 400);
            gradientOrange.addColorStop(0, '#f97316');
            gradientOrange.addColorStop(1, '#ef4444');

            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: chartData.labels,
                    datasets: [{
                            label: 'Hari Produktif',
                            data: chartData.productiveDays.map(days => totalProductiveDays > 0 ? (days /
                                totalProductiveDays) * 100 : 0),
                            backgroundColor: gradientBlue,
                            borderColor: '#3b82f6',
                            borderWidth: 1,
                            borderRadius: 8,
                            barPercentage: 0.65,
                            categoryPercentage: 0.8
                        },
                        {
                            label: 'Hari Non-Produktif',
                            data: chartData.nonProductiveDays,
                            backgroundColor: gradientOrange,
                            borderColor: '#f97316',
                            borderWidth: 1,
                            borderRadius: 8,
                            barPercentage: 0.65,
                            categoryPercentage: 0.8
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            backgroundColor: 'rgba(0,0,0,0.8)',
                            titleColor: '#fff',
                            bodyColor: '#ccc',
                            borderColor: '#3b82f6',
                            borderWidth: 1,
                            cornerRadius: 8,
                            callbacks: {
                                label: function(context) {
                                    let label = context.dataset.label || '';
                                    if (label) label += ': ';
                                    label += context.parsed.y.toFixed(1) + '%';
                                    return label;
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            title: {
                                display: true,
                                text: 'Nama Siswa',
                                color: '#6b7280',
                                font: {
                                    weight: 'bold'
                                }
                            },
                            grid: {
                                display: false
                            },
                            ticks: {
                                maxRotation: 35,
                                minRotation: 35,
                                autoSkip: true,
                                maxTicksLimit: 10,
                                font: {
                                    size: 10
                                }
                            }
                        },
                        y: {
                            title: {
                                display: true,
                                text: 'Persentase Presensi (%)',
                                color: '#6b7280',
                                font: {
                                    weight: 'bold'
                                }
                            },
                            beginAtZero: true,
                            max: 100,
                            ticks: {
                                callback: (val) => val + '%',
                                stepSize: 20
                            }
                        }
                    },
                    layout: {
                        padding: {
                            top: 20,
                            bottom: 20,
                            left: 10,
                            right: 10
                        }
                    },
                    elements: {
                        bar: {
                            borderSkipped: 'round'
                        }
                    }
                }
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
    </style>
@endpush

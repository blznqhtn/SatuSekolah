@extends('private.members.app')

@section('title', 'Manage Members')

@section('content-siswa')
    <div id="data-siswa" class="tab-content">
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 p-4 sm:p-5 mb-6 sm:mb-8 transition-all duration-300">
            <form method="GET" action="{{ route('admin.siswa.index') }}" class="flex flex-col lg:flex-row gap-3 sm:gap-4">
                <div class="flex flex-1">
                    <div class="relative flex-1">
                        <i
                            class="fa-solid fa-search absolute left-3 sm:left-4 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-500 text-xs sm:text-sm"></i>
                        <input type="text" name="search" value="{{ request('search') }}"
                            placeholder="Cari nama atau no induk..."
                            class="w-full pl-8 sm:pl-10 pr-3 sm:pr-4 py-2 sm:py-3 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm sm:text-base focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                    </div>
                    <button type="submit"
                        class="px-4 sm:px-6 py-2 sm:py-3 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold rounded-r-xl shadow-md transition-all duration-300 text-sm sm:text-base">
                        Cari
                    </button>
                </div>

                <div class="flex flex-wrap gap-2 sm:gap-3 items-center">
                    <select name="kelas" onchange="this.form.submit()"
                        class="px-3 sm:px-4 py-2 sm:py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm sm:text-base focus:ring-2 focus:ring-primary-500 cursor-pointer transition-all">
                        <option value="all" {{ request('kelas') == 'all' ? 'selected' : '' }}>Semua Kelas</option>
                        @foreach ($dataKelas as $kelasItem)
                            <option value="{{ $kelasItem->id }}" {{ request('kelas') == $kelasItem->id ? 'selected' : '' }}>
                                {{ $kelasItem->name }}</option>
                        @endforeach
                    </select>

                    <div class="flex gap-2">
                        <button type="button" onclick="openImportModal()"
                            class="group flex items-center gap-1 sm:gap-2 px-3 sm:px-5 py-2 sm:py-3 bg-linear-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 rounded-xl shadow-md transition-all duration-300 hover:scale-105">
                            <i class="fa-solid fa-upload text-white text-xs sm:text-sm"></i>
                            <span class="text-white font-medium text-sm sm:text-base hidden sm:inline">Import</span>
                        </button>

                        <a href="{{ route('admin.siswa.create') }}"
                            class="group flex items-center gap-1 sm:gap-2 px-3 sm:px-5 py-2 sm:py-3 bg-linear-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 rounded-xl shadow-md transition-all duration-300 hover:scale-105">
                            <i class="fa-solid fa-plus text-white text-xs sm:text-sm"></i>
                            <span class="text-white font-medium text-sm sm:text-base hidden sm:inline">Tambah</span>
                        </a>

                        <div id="deleteSelectedBtn"
                            class="group flex items-center gap-1 sm:gap-2 px-3 sm:px-5 py-2 sm:py-3 bg-linear-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 rounded-xl shadow-md cursor-pointer transition-all duration-300 hover:scale-105">
                            <i class="fa-solid fa-trash-can text-white text-xs sm:text-sm"></i>
                            <span class="text-white font-medium text-sm sm:text-base hidden sm:inline">Hapus</span>
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <!-- Desktop: Tabel Modern (hanya tampil di layar >= md) -->
        <form id="deleteForm" action="{{ route('admin.siswa.delete.multiple') }}" method="POST">
            @csrf
            @method('DELETE')
            <div
                class="hidden md:block bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
                <div class="overflow-x-auto custom-scrollbar">
                    <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                        <thead class="bg-gray-50/80 dark:bg-gray-700/80 backdrop-blur-sm">
                            <tr>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider w-12">
                                    <input type="checkbox" id="selectAll"
                                        class="rounded border-gray-300 dark:border-gray-600 text-primary-600 shadow-sm focus:ring-2 focus:ring-primary-500 w-4 h-4">
                                </th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    No induk</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Nama Lengkap</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Kelas</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider hidden md:table-cell">
                                    Alamat</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Foto</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Face ID</th>
                                <th
                                    class="px-4 py-4 text-center text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                            @forelse ($schoolMembers as $wargaku)
                                <tr class="group transition-all duration-200 hover:bg-gray-50/70 dark:hover:bg-gray-700/50">
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <input type="checkbox" name="selected_ids[]" value="{{ $wargaku->id }}"
                                            class="account-checkbox rounded border-gray-300 dark:border-gray-600 text-primary-600 shadow-sm focus:ring-2 focus:ring-primary-500 w-4 h-4">
                                    </td>
                                    <td
                                        class="px-4 py-3 whitespace-nowrap text-sm font-mono font-medium text-gray-900 dark:text-gray-100">
                                        {{ $wargaku->nomor_induk }}</td>
                                    <td
                                        class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-100">
                                        {{ $wargaku->name }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                                        {{ $wargaku->kelas->name ?? '-' }}</td>
                                    <td
                                        class="px-4 py-3 text-sm text-gray-600 dark:text-gray-300 hidden md:table-cell max-w-50 truncate">
                                        {{ $wargaku->alamat ?? '-' }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        @if ($wargaku->foto_profile)
                                            <img src="{{ $wargaku->foto_profile }}" loading="lazy"
                                                alt="{{ $wargaku->name }}"
                                                class="h-12 w-auto rounded-sm object-cover aspect-3/4 shadow-sm border border-gray-200 dark:border-gray-600">
                                        @else
                                            <div
                                                class="h-12 w-10 bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center justify-center">
                                                <i class="fa-regular fa-user text-gray-400 text-lg"></i>
                                            </div>
                                        @endif
                                    </td>
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        @if ($wargaku->has_face_id)
                                            <span
                                                class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300 shadow-sm">
                                                <i class="fa-solid fa-check-circle text-xs"></i> Terdaftar
                                            </span>
                                        @else
                                            <span
                                                class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400 shadow-sm">
                                                <i class="fa-solid fa-circle-xmark text-xs"></i> Belum
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-4 py-3 whitespace-nowrap text-center">
                                        <div class="flex items-center justify-center gap-3">
                                            <a href="{{ route('admin.siswa.edit', $wargaku->id) }}" title="Edit Siswa"
                                                class="text-amber-500 hover:text-amber-600 dark:text-amber-400 transition-colors">
                                                <i class="fa-solid fa-pen-to-square text-lg"></i>
                                            </a>
                                            <button type="button"
                                                onclick="deleteSingle('{{ $wargaku->id }}', '{{ $wargaku->name }}')"
                                                class="text-red-500 hover:text-red-600 transition-colors cursor-pointer">
                                                <i class="fa-solid fa-trash-can text-lg"></i>
                                            </button>
                                            @if ($wargaku->has_face_id)
                                                <button type="button"
                                                    onclick="resetFaceId('{{ $wargaku->nomor_induk }}', '{{ $wargaku->name }}')"
                                                    title="Reset Face ID"
                                                    class="text-red-500 hover:text-red-600 dark:text-red-400 transition-colors cursor-pointer">
                                                    <i class="fa-solid fa-face-grin-tongue-squint text-lg"></i>
                                                </button>
                                            @endif
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                                        <i class="fa-regular fa-folder-open text-4xl mb-2 block"></i>
                                        Tidak ada data siswa
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Mobile: Card List (tampil hanya di layar < md) -->
            <div class="md:hidden space-y-4">
                @forelse ($schoolMembers as $wargaku)
                    <div
                        class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 p-4 transition-all duration-200 hover:shadow-lg">
                        <div class="flex items-start gap-3">
                            <!-- Checkbox -->
                            <div class="pt-1">
                                <input type="checkbox" name="selected_ids[]" value="{{ $wargaku->id }}"
                                    class="account-checkbox rounded border-gray-300 dark:border-gray-600 text-primary-600 shadow-sm focus:ring-2 focus:ring-primary-500 w-4 h-4">
                            </div>
                            <!-- Foto -->
                            <div class="shrink-0">
                                @if ($wargaku->foto_profile)
                                    <img src="{{ $wargaku->foto_profile }}" loading="lazy" alt="{{ $wargaku->name }}"
                                        class="h-14 w-auto rounded-sm object-cover aspect-3/4 shadow-sm border border-gray-200 dark:border-gray-600">
                                @else
                                    <div
                                        class="h-14 w-12 bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center justify-center">
                                        <i class="fa-regular fa-user text-gray-400 text-xl"></i>
                                    </div>
                                @endif
                            </div>
                            <!-- Informasi -->
                            <div class="flex-1 min-w-0">
                                <div class="flex flex-wrap items-baseline justify-between gap-1 mb-1">
                                    <h4 class="text-base font-bold text-gray-800 dark:text-white truncate">
                                        {{ $wargaku->name }}</h4>
                                    <span
                                        class="text-xs font-mono text-gray-500 dark:text-gray-400">{{ $wargaku->nomor_induk }}</span>
                                </div>
                                <div class="text-sm text-gray-600 dark:text-gray-300 mb-1">
                                    <span class="font-medium">Kelas:</span> {{ $wargaku->kelas->name ?? '-' }}
                                </div>
                                <div class="text-sm text-gray-600 dark:text-gray-300 mb-2 line-clamp-2">
                                    <span class="font-medium">Alamat:</span> {{ $wargaku->alamat ?? '-' }}
                                </div>
                                <div class="flex flex-wrap items-center justify-between gap-2 mt-2">
                                    <div>
                                        @if ($wargaku->has_face_id)
                                            <span
                                                class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300">
                                                <i class="fa-solid fa-check-circle text-xs"></i> Face ID Terdaftar
                                            </span>
                                        @else
                                            <span
                                                class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400">
                                                <i class="fa-solid fa-circle-xmark text-xs"></i> Face ID Belum
                                            </span>
                                        @endif
                                    </div>
                                    <div class="flex gap-3">
                                        <a href="{{ route('admin.siswa.edit', $wargaku->nomor_induk) }}"
                                            title="Edit Siswa"
                                            class="text-amber-500 hover:text-amber-600 dark:text-amber-400 transition-colors">
                                            <i class="fa-solid fa-pen-to-square text-base"></i>
                                        </a>
                                        <button type="button"
                                            onclick="deleteSingle('{{ $wargaku->id }}', '{{ $wargaku->name }}')"
                                            class="text-red-500 hover:text-red-600 transition-colors">
                                            <i class="fa-solid fa-trash-can text-lg"></i>
                                        </button>
                                        @if ($wargaku->has_face_id)
                                            <button type="button"
                                                onclick="resetFaceId('{{ $wargaku->nomor_induk }}', '{{ $wargaku->name }}')"
                                                title="Reset Face ID"
                                                class="text-red-500 hover:text-red-600 dark:text-red-400 transition-colors">
                                                <i class="fa-solid fa-fingerprint text-base"></i>
                                            </button>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                @empty
                    <div
                        class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl p-8 text-center text-gray-500 dark:text-gray-400">
                        <i class="fa-regular fa-folder-open text-5xl mb-3 block"></i>
                        <p class="text-base">Tidak ada data siswa</p>
                    </div>
                @endforelse
            </div>
        </form>

        <!-- Pagination Modern (tetap sama, responsif) -->
        <div
            class="mt-6 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 px-4 py-3 flex items-center justify-between sm:px-6">
            <div class="flex-1 flex justify-between sm:hidden">
                @if ($schoolMembers->onFirstPage())
                    <span class="px-4 py-2 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-400 text-sm">Previous</span>
                @else
                    <a href="{{ $schoolMembers->previousPageUrl() }}"
                        class="px-4 py-2 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:bg-gray-50 transition text-sm">Previous</a>
                @endif
                @if ($schoolMembers->hasMorePages())
                    <a href="{{ $schoolMembers->nextPageUrl() }}"
                        class="px-4 py-2 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:bg-gray-50 transition text-sm">Next</a>
                @else
                    <span class="px-4 py-2 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-400 text-sm">Next</span>
                @endif
            </div>
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-600 dark:text-gray-400">
                        Menampilkan <span
                            class="font-semibold text-gray-900 dark:text-white">{{ $schoolMembers->firstItem() }}</span>
                        sampai
                        <span class="font-semibold text-gray-900 dark:text-white">{{ $schoolMembers->lastItem() }}</span>
                        dari
                        <span class="font-semibold text-gray-900 dark:text-white">{{ $schoolMembers->total() }}</span>
                        hasil
                    </p>
                </div>
                <div>
                    <nav class="relative z-0 inline-flex rounded-xl shadow-sm -space-x-px" aria-label="Pagination">
                        @if ($schoolMembers->onFirstPage())
                            <span
                                class="relative inline-flex items-center px-3 py-2 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-400 cursor-not-allowed">
                                <i class="fa-solid fa-chevron-left text-xs"></i>
                            </span>
                        @else
                            <a href="{{ $schoolMembers->previousPageUrl() }}"
                                class="relative inline-flex items-center px-3 py-2 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 hover:bg-gray-50 transition">
                                <i class="fa-solid fa-chevron-left text-xs"></i>
                            </a>
                        @endif

                        @php
                            $currentPage = $schoolMembers->currentPage();
                            $lastPage = $schoolMembers->lastPage();
                            $start = max($currentPage - 2, 1);
                            $end = min($currentPage + 2, $lastPage);
                        @endphp

                        @if ($start > 1)
                            <a href="{{ $schoolMembers->url(1) }}"
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
                                <a href="{{ $schoolMembers->url($page) }}"
                                    class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">{{ $page }}</a>
                            @endif
                        @endfor

                        @if ($end < $lastPage)
                            @if ($end < $lastPage - 1)
                                <span
                                    class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-500">…</span>
                            @endif
                            <a href="{{ $schoolMembers->url($lastPage) }}"
                                class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">{{ $lastPage }}</a>
                        @endif

                        @if ($schoolMembers->hasMorePages())
                            <a href="{{ $schoolMembers->nextPageUrl() }}"
                                class="relative inline-flex items-center px-3 py-2 rounded-r-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 hover:bg-gray-50">
                                <i class="fa-solid fa-chevron-right text-xs"></i>
                            </a>
                        @else
                            <span
                                class="relative inline-flex items-center px-3 py-2 rounded-r-xl border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-400 cursor-not-allowed">
                                <i class="fa-solid fa-chevron-right text-xs"></i>
                            </span>
                        @endif
                    </nav>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Import (sama seperti sebelumnya, tidak diubah) -->
    <div id="importExcelModal" class="fixed inset-0 z-50 hidden overflow-y-auto backdrop-blur-md">
        <div class="fixed inset-0 bg-gray-900/60 transition-opacity"></div>
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
            <div
                class="relative transform overflow-hidden rounded-2xl bg-white dark:bg-gray-800 text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-lg w-full">
                <div class="bg-linear-to-r from-primary-600 to-primary-700 px-6 py-4">
                    <div class="flex items-center justify-between">
                        <h3 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fa-solid fa-upload"></i> Import Data Siswa
                        </h3>
                        <button onclick="closeImportModal()" class="text-white/80 hover:text-white transition">
                            <i class="fa-solid fa-times text-xl"></i>
                        </button>
                    </div>
                </div>
                <div class="px-6 py-5">
                    <div
                        class="mb-5 p-4 rounded-xl bg-blue-50 dark:bg-blue-900/20 border border-blue-100 dark:border-blue-800/30">
                        <div class="flex gap-3">
                            <i class="fa-regular fa-circle-info text-blue-600 dark:text-blue-400 text-lg"></i>
                            <p class="text-sm text-blue-700 dark:text-blue-300">Unggah file Excel (wajib) dan file ZIP foto
                                (opsional). Pastikan format sesuai template.</p>
                        </div>
                    </div>

                    <form id="importForm" action="{{ route('admin.siswa.import') }}" method="POST"
                        enctype="multipart/form-data" class="space-y-5">
                        @csrf
                        <div>
                            <label class="block mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">File Excel
                                <span class="text-red-500">*</span></label>
                            <div id="excel-drop-area"
                                class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed rounded-xl cursor-pointer transition-all bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 border-gray-300 dark:border-gray-600">
                                <div class="text-center">
                                    <i class="fa-regular fa-file-excel text-4xl text-gray-400 mb-2 block"></i>
                                    <p class="text-sm text-gray-500"><span class="font-semibold">Klik atau seret file
                                            Excel</span><br>Maksimal 10MB</p>
                                </div>
                                <input type="file" name="excel_file" id="excel_file" accept=".xlsx,.xls"
                                    class="hidden" />
                            </div>
                            <div id="excelFileSelected"
                                class="hidden mt-2 p-2 rounded-lg bg-green-50 dark:bg-green-900/20">
                                <div class="flex items-center gap-2"><i
                                        class="fa-regular fa-circle-check text-green-600"></i><span
                                        class="text-xs text-green-700">Excel: <span id="selectedExcelName"
                                            class="font-medium"></span></span></div>
                            </div>
                        </div>

                        <div>
                            <label class="block mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">File ZIP Foto
                                (Opsional)</label>
                            <div id="zip-drop-area"
                                class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed rounded-xl cursor-pointer transition-all bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 border-gray-300 dark:border-gray-600">
                                <div class="text-center">
                                    <i class="fa-regular fa-file-zipper text-4xl text-gray-400 mb-2 block"></i>
                                    <p class="text-sm text-gray-500"><span class="font-semibold">Klik atau seret file
                                            ZIP</span><br>Maksimal 10MiB</p>
                                </div>
                                <input type="file" name="photo_zip" id="photo_zip" accept=".zip" class="hidden" />
                            </div>
                            <div id="zipFileSelected" class="hidden mt-2 p-2 rounded-lg bg-green-50 dark:bg-green-900/20">
                                <div class="flex items-center gap-2"><i
                                        class="fa-regular fa-circle-check text-green-600"></i><span
                                        class="text-xs text-green-700">ZIP: <span id="selectedZipName"
                                            class="font-medium"></span></span></div>
                            </div>
                        </div>

                        <div
                            class="p-3 rounded-xl bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-800/30">
                            <p class="text-xs font-semibold text-amber-700 dark:text-amber-300 flex items-center gap-1"><i
                                    class="fa-regular fa-note-sticky"></i> Catatan:</p>
                            <ul class="mt-1 ml-5 list-disc text-xs text-amber-700 dark:text-amber-300 space-y-0.5">
                                <li>Gunakan template Excel yang telah disediakan</li>
                                <li>Nama file foto di Excel harus sama persis dengan nama file di ZIP</li>
                                <li>Data dengan nomor induk yang sama akan diperbarui</li>
                                <li>Pastikan file ZIP tidak memiliki folder internal</li>
                            </ul>
                        </div>

                        <div class="flex flex-col sm:flex-row justify-between gap-3 pt-2">
                            <a href="{{ route('admin.siswa.template') }}"
                                class="inline-flex items-center justify-center gap-2 px-4 py-2.5 text-sm font-medium text-white bg-teal-600 rounded-xl hover:bg-teal-700 transition shadow-md">
                                <i class="fa-solid fa-download"></i> Unduh Template
                            </a>
                            <div class="flex gap-3">
                                <button type="button" onclick="closeImportModal()"
                                    class="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-xl hover:bg-gray-100 transition">Batal</button>
                                <button type="submit" id="submitImport"
                                    class="px-6 py-2.5 text-sm font-medium text-white bg-linear-to-r from-primary-600 to-primary-700 rounded-xl shadow-md hover:shadow-lg transition disabled:opacity-50"
                                    disabled>
                                    <i class="fa-solid fa-upload mr-2"></i> Unggah
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        // (Semua script JavaScript dari kode asli tetap sama, tidak ada perubahan)
        const importModal = document.getElementById('importExcelModal');
        const excelInput = document.getElementById('excel_file');
        const zipInput = document.getElementById('photo_zip');
        const excelDropArea = document.getElementById('excel-drop-area');
        const zipDropArea = document.getElementById('zip-drop-area');
        const excelFileSelected = document.getElementById('excelFileSelected');
        const zipFileSelected = document.getElementById('zipFileSelected');
        const selectedExcelName = document.getElementById('selectedExcelName');
        const selectedZipName = document.getElementById('selectedZipName');
        const submitButton = document.getElementById('submitImport');

        function openImportModal() {
            importModal.classList.remove('hidden');
            document.body.classList.add('overflow-hidden');
        }

        function closeImportModal() {
            importModal.classList.add('hidden');
            document.body.classList.remove('overflow-hidden');
            document.getElementById('importForm').reset();
            excelFileSelected.classList.add('hidden');
            zipFileSelected.classList.add('hidden');
            submitButton.disabled = true;
        }

        function handleExcelFile(files) {
            if (files && files[0]) {
                const file = files[0];
                if (file.size > 10 * 1024 * 1024) {
                    alert('Maksimal 10MB');
                    excelInput.value = '';
                    excelFileSelected.classList.add('hidden');
                    submitButton.disabled = true;
                    return;
                }
                if (file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || file.type ===
                    'application/vnd.ms-excel') {
                    selectedExcelName.textContent = file.name;
                    excelFileSelected.classList.remove('hidden');
                    submitButton.disabled = false;
                } else {
                    alert('Hanya file Excel');
                    excelInput.value = '';
                    excelFileSelected.classList.add('hidden');
                    submitButton.disabled = true;
                }
            } else {
                excelFileSelected.classList.add('hidden');
                submitButton.disabled = true;
            }
        }

        function handleZipFile(files) {
            if (files && files[0]) {
                const file = files[0];
                if (file.size > 150 * 1024 * 1024) {
                    alert('Maksimal 150MB');
                    zipInput.value = '';
                    zipFileSelected.classList.add('hidden');
                    return;
                }
                if (file.type === 'application/zip' || file.type === 'application/x-zip-compressed') {
                    selectedZipName.textContent = file.name;
                    zipFileSelected.classList.remove('hidden');
                } else {
                    alert('Hanya file ZIP');
                    zipInput.value = '';
                    zipFileSelected.classList.add('hidden');
                }
            } else {
                zipFileSelected.classList.add('hidden');
            }
        }
        excelInput.addEventListener('change', function() {
            handleExcelFile(this.files);
        });
        zipInput.addEventListener('change', function() {
            handleZipFile(this.files);
        });
        excelDropArea.addEventListener('click', () => excelInput.click());
        zipDropArea.addEventListener('click', () => zipInput.click());
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(ev => {
            excelDropArea.addEventListener(ev, preventDefaults);
            zipDropArea.addEventListener(ev, preventDefaults);
            document.body.addEventListener(ev, preventDefaults);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }
        ['dragenter', 'dragover'].forEach(ev => {
            excelDropArea.addEventListener(ev, () => excelDropArea.classList.add('border-primary-500',
                'bg-primary-50', 'dark:bg-primary-900/20'));
            zipDropArea.addEventListener(ev, () => zipDropArea.classList.add('border-primary-500', 'bg-primary-50',
                'dark:bg-primary-900/20'));
        });
        ['dragleave', 'drop'].forEach(ev => {
            excelDropArea.addEventListener(ev, () => excelDropArea.classList.remove('border-primary-500',
                'bg-primary-50', 'dark:bg-primary-900/20'));
            zipDropArea.addEventListener(ev, () => zipDropArea.classList.remove('border-primary-500',
                'bg-primary-50', 'dark:bg-primary-900/20'));
        });
        excelDropArea.addEventListener('drop', e => {
            const dt = e.dataTransfer;
            const files = dt.files;
            if (files && files[0]) {
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(files[0]);
                excelInput.files = dataTransfer.files;
                handleExcelFile(files);
            }
        });
        zipDropArea.addEventListener('drop', e => {
            const dt = e.dataTransfer;
            const files = dt.files;
            if (files && files[0]) {
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(files[0]);
                zipInput.files = dataTransfer.files;
                handleZipFile(files);
            }
        });
        window.addEventListener('click', e => {
            if (e.target === importModal) closeImportModal();
        });
        document.getElementById('importForm').addEventListener('submit', function(e) {
            if (!excelInput.files || !excelInput.files[0]) {
                e.preventDefault();
                alert('Pilih file Excel terlebih dahulu');
            }
        });

        document.addEventListener('DOMContentLoaded', function() {
            const selectAll = document.getElementById('selectAll');
            const checkboxes = document.querySelectorAll('.account-checkbox');
            if (selectAll) {
                selectAll.addEventListener('change', function() {
                    checkboxes.forEach(cb => cb.checked = this.checked);
                });
            }
            const deleteBtn = document.getElementById('deleteSelectedBtn');
            const deleteForm = document.getElementById('deleteForm');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', function() {
                    const selected = document.querySelectorAll('.account-checkbox:checked');
                    if (selected.length === 0) {
                        Swal.fire({
                            title: "Peringatan",
                            text: "Pilih minimal satu data siswa",
                            icon: "warning"
                        });
                        return;
                    }
                    Swal.fire({
                        title: "Konfirmasi Hapus",
                        html: `Yakin ingin menghapus <strong>${selected.length}</strong> data siswa?`,
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#d33",
                        cancelButtonColor: "#3085d6",
                        confirmButtonText: "Ya, hapus!",
                        cancelButtonText: "Batal"
                    }).then((result) => {
                        if (result.isConfirmed) deleteForm.submit();
                    });
                });
            }
        });

        function resetFaceId(nomor_induk, name) {
            Swal.fire({
                title: "Reset Face ID",
                html: `Hapus data Face ID untuk <strong>${name}</strong> (${nomor_induk})?`,
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#d33",
                cancelButtonColor: "#3085d6",
                confirmButtonText: "Ya, Reset!",
                cancelButtonText: "Batal"
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Memproses...',
                        text: 'Menghapus Face ID',
                        allowOutsideClick: false,
                        didOpen: () => Swal.showLoading()
                    });
                    fetch(`/admin/face-id/reset/${nomor_induk}`, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute(
                                    'content')
                            }
                        })
                        .then(res => res.json()).then(data => {
                            if (data.success) {
                                Swal.fire({
                                    title: "Berhasil!",
                                    text: data.message,
                                    icon: "success"
                                }).then(() => location.reload());
                            } else {
                                Swal.fire({
                                    title: "Gagal!",
                                    text: data.message,
                                    icon: "error"
                                });
                            }
                        })
                        .catch(() => Swal.fire({
                            title: "Error!",
                            text: "Terjadi kesalahan sistem",
                            icon: "error"
                        }));
                }
            });
        }

        function deleteSingle(id, name) {
            Swal.fire({
                title: "Hapus Data?",
                html: `Apakah Anda yakin ingin menghapus data <strong>${name}</strong>? Tindakan ini tidak dapat dibatalkan.`,
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#d33",
                cancelButtonColor: "#3085d6",
                confirmButtonText: "Ya, Hapus!",
                cancelButtonText: "Batal"
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Memproses...',
                        allowOutsideClick: false,
                        didOpen: () => Swal.showLoading()
                    });

                    // Membuat form dinamis untuk mengirim DELETE request ke controller Laravel
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = "/admin/members/" + id;

                    const csrfInput = document.createElement('input');
                    csrfInput.type = 'hidden';
                    csrfInput.name = '_token';
                    csrfInput.value = '{{ csrf_token() }}';

                    const methodInput = document.createElement('input');
                    methodInput.type = 'hidden';
                    methodInput.name = '_method';
                    methodInput.value = 'DELETE';

                    form.appendChild(csrfInput);
                    form.appendChild(methodInput);
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        }
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

        /* Membatasi teks alamat di mobile */
        .line-clamp-2 {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
    </style>
@endpush

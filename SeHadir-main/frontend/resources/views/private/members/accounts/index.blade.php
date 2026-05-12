@extends('private.members.app')

@section('title', 'Manage Accounts')

@section('content-siswa')
    <div id="akun-siswa" class="tab-content">
        <!-- Filter Bar Modern dengan Glassmorphism -->
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 p-5 mb-8 transition-all duration-300">
            <form method="GET" action="{{ route('admin.accounts.index') }}" class="flex flex-col lg:flex-row gap-4">
                <div class="flex flex-1">
                    <div class="relative flex-1">
                        <i
                            class="fa-solid fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-500 text-sm"></i>
                        <input type="text" name="search" value="{{ request('search') }}"
                            placeholder="Cari akun members..."
                            class="w-full pl-10 pr-4 py-3 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                    </div>
                    <button type="submit"
                        class="px-6 py-3 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold rounded-r-xl shadow-md transition-all duration-300 hover:scale-[1.02]">
                        Cari
                    </button>
                </div>

                <div class="flex flex-wrap gap-3 items-center">
                    <select name="kelas" onchange="this.form.submit()"
                        class="px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 cursor-pointer transition-all">
                        <option value="all" {{ request('kelas') == 'all' ? 'selected' : '' }}>Semua Kelas</option>
                        @foreach ($dataKelas as $kelasOption)
                            <option value="{{ $kelasOption->id }}"
                                {{ request('kelas') == $kelasOption->id ? 'selected' : '' }}>
                                {{ $kelasOption->name }}
                            </option>
                        @endforeach
                    </select>

                    <div class="flex gap-2">
                        <button type="button" onclick="window.location.href='{{ route('admin.accounts.charts') }}'"
                            class="group flex items-center gap-2 px-5 py-3 bg-linear-to-r cursor-pointer from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 rounded-xl shadow-md transition-all duration-300 hover:scale-105">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" class="text-white">
                                <path d="M12 16v5" />
                                <path d="M16 14v7" />
                                <path d="M20 10v11" />
                                <path d="m22 3-8.646 8.646a.5.5 0 0 1-.708 0L9.354 8.354a.5.5 0 0 0-.707 0L2 15" />
                                <path d="M4 18v3" />
                                <path d="M8 14v7" />
                            </svg>
                            <span class="text-white font-medium hidden sm:inline">Chart</span>
                        </button>

                        <button type="button" onclick="window.location.href='{{ route('admin.accounts.create') }}'"
                            class="group flex items-center gap-2 px-5 py-3 bg-linear-to-r cursor-pointer from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 rounded-xl shadow-md transition-all duration-300 hover:scale-105">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" class="text-white">
                                <circle cx="12" cy="12" r="10" />
                                <path d="M8 12h8" />
                                <path d="M12 8v8" />
                            </svg>
                            <span class="text-white font-medium hidden sm:inline">Tambah</span>
                        </button>

                        <div id="deleteSelectedBtn"
                            class="group flex items-center gap-2 px-5 py-3 bg-linear-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 rounded-xl shadow-md cursor-pointer transition-all duration-300 hover:scale-105">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" class="text-white">
                                <path d="M3 6h18" />
                                <path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" />
                                <path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
                                <line x1="10" x2="10" y1="11" y2="17" />
                                <line x1="14" x2="14" y1="11" y2="17" />
                            </svg>
                            <span class="text-white font-medium hidden sm:inline">Hapus</span>
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <!-- Tabel Desktop (hidden di mobile) & Card Mobile -->
        <form id="deleteForm" action="{{ route('admin.accounts.delete.multiple') }}" method="POST">
            @method('DELETE')
            @csrf

            <!-- Desktop Table -->
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
                                    No Induk</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Username</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Email</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Nama</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Kelas</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Role</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Status</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    RFID</th>
                                <th
                                    class="px-4 py-4 text-left text-xs font-semibold text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                                    Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                            @foreach ($schoolAccounts as $akunku)
                                <tr class="group transition-all duration-200 hover:bg-gray-50/70 dark:hover:bg-gray-700/50">
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <input type="checkbox" name="selected_ids[]" value="{{ $akunku->id }}"
                                            class="account-checkbox rounded border-gray-300 dark:border-gray-600 text-primary-600 shadow-sm focus:ring-2 focus:ring-primary-500 w-4 h-4">
                                    </td>
                                    <td
                                        class="px-4 py-3 whitespace-nowrap text-sm font-mono font-medium text-gray-900 dark:text-gray-100">
                                        {{ $akunku->school_member->nomor_induk }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-800 dark:text-gray-200">
                                        {{ $akunku->username }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                                        {{ $akunku->email ?? '-' }}</td>
                                    <td
                                        class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-gray-900 dark:text-gray-100">
                                        {{ $akunku->school_member->name }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                                        {{ $akunku->school_member->kelas->name }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-600 dark:text-gray-300">
                                        {{ ucfirst($akunku->role) }}</td>
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        @if ($akunku->status_ban == 'active')
                                            <span
                                                class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300 shadow-sm">
                                                <i class="fa-solid fa-circle-check text-xs"></i> Aktif
                                            </span>
                                        @else
                                            <span
                                                class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-700 dark:bg-red-900/50 dark:text-red-300 shadow-sm">
                                                <i class="fa-solid fa-circle-exclamation text-xs"></i> Banned
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        @if ($akunku->rfid_id == '' || $akunku->rfid_id == null)
                                            <span
                                                class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-yellow-100 dark:bg-yellow-900/50 text-yellow-600 dark:text-yellow-300 shadow-sm">
                                                <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd"
                                                        d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" />
                                                </svg>
                                            </span>
                                        @else
                                            <span
                                                class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-green-100 dark:bg-green-900/50 text-green-600 dark:text-green-300 shadow-sm">
                                                <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd"
                                                        d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" />
                                                </svg>
                                            </span>
                                        @endif
                                    </td>
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <div class="flex items-center gap-2">
                                            @if ($akunku->status_ban == 'active')
                                                <div data-idAkun="{{ $akunku->id }}"
                                                    data-namaAkun="{{ $akunku->school_member->name }}"
                                                    title="Non-Aktifkan Akun"
                                                    class="btnBan cursor-pointer text-red-600 hover:text-red-800 dark:text-red-400 transition-colors">
                                                    <i class="fa-solid fa-ban text-lg"></i>
                                                </div>
                                            @else
                                                <div data-idAkun="{{ $akunku->id }}"
                                                    data-namaAkun="{{ $akunku->school_member->name }}"
                                                    title="Aktifkan Akun"
                                                    class="btnActive cursor-pointer text-green-600 hover:text-green-800 dark:text-green-400 transition-colors">
                                                    <i class="fa-solid fa-check-circle text-lg"></i>
                                                </div>
                                            @endif
                                            <div onclick="window.location.href='{{ route('admin.accounts.edit', $akunku->id) }}'"
                                                title="Edit Akun"
                                                class="cursor-pointer text-amber-500 hover:text-amber-600 transition-colors">
                                                <i class="fa-solid fa-pen-to-square text-lg"></i>
                                            </div>
                                            {{-- <div data-emailAkun="{{ $akunku->email }}" data-namaAkun="{{ $akunku->school_member->name }}" title="Reset Password" class="btnResetPw cursor-pointer text-blue-500 hover:text-blue-600 transition-colors">
                                                <i class="fa-solid fa-rotate-left text-lg"></i>
                                            </div> --}}
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Mobile Card View -->
            <div class="md:hidden space-y-4">
                @foreach ($schoolAccounts as $akunku)
                    <div
                        class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 p-4 transition-all duration-200 hover:shadow-lg">
                        <div class="flex items-start gap-3">
                            <div class="pt-1">
                                <input type="checkbox" name="selected_ids[]" value="{{ $akunku->id }}"
                                    class="account-checkbox rounded border-gray-300 dark:border-gray-600 text-primary-600 w-4 h-4">
                            </div>
                            <div class="flex-1 min-w-0">
                                <div class="flex flex-wrap justify-between items-baseline gap-1 mb-1">
                                    <h4 class="text-base font-bold text-gray-800 dark:text-white truncate">
                                        {{ $akunku->school_member->name }}</h4>
                                    <span
                                        class="text-xs font-mono text-gray-500 dark:text-gray-400">{{ $akunku->school_member->nomor_induk }}</span>
                                </div>
                                <div class="text-sm text-gray-600 dark:text-gray-300 mb-1">
                                    <span class="font-medium">Username:</span> {{ $akunku->username }}
                                </div>
                                <div class="text-sm text-gray-600 dark:text-gray-300 mb-1">
                                    <span class="font-medium">Email:</span> {{ $akunku->email ?? '-' }}
                                </div>
                                <div class="text-sm text-gray-600 dark:text-gray-300 mb-1">
                                    <span class="font-medium">Kelas:</span> {{ $akunku->school_member->kelas->name }}
                                </div>
                                <div class="text-sm text-gray-600 dark:text-gray-300 mb-2">
                                    <span class="font-medium">Role:</span> {{ ucfirst($akunku->role) }}
                                </div>
                                <div class="flex flex-wrap items-center justify-between gap-2 mt-2">
                                    <div class="flex gap-2">
                                        @if ($akunku->status_ban == 'active')
                                            <span
                                                class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300">
                                                <i class="fa-solid fa-circle-check"></i> Aktif
                                            </span>
                                        @else
                                            <span
                                                class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-red-100 text-red-700 dark:bg-red-900/50 dark:text-red-300">
                                                <i class="fa-solid fa-circle-exclamation"></i> Banned
                                            </span>
                                        @endif
                                        @if ($akunku->rfid_id == '' || $akunku->rfid_id == null)
                                            <span
                                                class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-700 dark:bg-yellow-900/50 dark:text-yellow-300">
                                                <i class="fa-solid fa-id-card"></i> No RFID
                                            </span>
                                        @else
                                            <span
                                                class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300">
                                                <i class="fa-solid fa-id-card"></i> RFID
                                            </span>
                                        @endif
                                    </div>
                                    <div class="flex gap-3">
                                        @if ($akunku->status_ban == 'active')
                                            <div data-idAkun="{{ $akunku->id }}"
                                                data-namaAkun="{{ $akunku->school_member->name }}"
                                                class="btnBan cursor-pointer text-red-600 hover:text-red-800">
                                                <i class="fa-solid fa-ban text-lg"></i>
                                            </div>
                                        @else
                                            <div data-idAkun="{{ $akunku->id }}"
                                                data-namaAkun="{{ $akunku->school_member->name }}"
                                                class="btnActive cursor-pointer text-green-600 hover:text-green-800">
                                                <i class="fa-solid fa-check-circle text-lg"></i>
                                            </div>
                                        @endif
                                        <div onclick="window.location.href='{{ route('admin.accounts.edit', $akunku->id) }}'"
                                            class="cursor-pointer text-amber-500 hover:text-amber-600">
                                            <i class="fa-solid fa-pen-to-square text-lg"></i>
                                        </div>
                                        {{-- <div data-emailAkun="{{ $akunku->email }}" data-namaAkun="{{ $akunku->school_member->name }}" class="btnResetPw cursor-pointer text-blue-500 hover:text-blue-600">
                                            <i class="fa-solid fa-rotate-left text-lg"></i>
                                        </div> --}}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
                @if ($schoolAccounts->isEmpty())
                    <div
                        class="bg-white/90 dark:bg-gray-800/90 rounded-2xl p-8 text-center text-gray-500 dark:text-gray-400">
                        <i class="fa-regular fa-folder-open text-5xl mb-3 block"></i>
                        <p>Tidak ada data akun</p>
                    </div>
                @endif
            </div>
        </form>

        <!-- Pagination Modern -->
        <div
            class="mt-6 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 px-4 py-3 flex items-center justify-between sm:px-6">
            <div class="flex-1 flex justify-between sm:hidden">
                @if ($schoolAccounts->onFirstPage())
                    <span class="px-4 py-2 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-400 text-sm">Previous</span>
                @else
                    <a href="{{ $schoolAccounts->previousPageUrl() }}"
                        class="px-4 py-2 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:bg-gray-50 transition text-sm">Previous</a>
                @endif
                @if ($schoolAccounts->hasMorePages())
                    <a href="{{ $schoolAccounts->nextPageUrl() }}"
                        class="px-4 py-2 rounded-xl bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-200 shadow-sm hover:bg-gray-50 transition text-sm">Next</a>
                @else
                    <span class="px-4 py-2 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-400 text-sm">Next</span>
                @endif
            </div>
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-600 dark:text-gray-400">
                        Menampilkan <span
                            class="font-semibold text-gray-900 dark:text-white">{{ $schoolAccounts->firstItem() }}</span>
                        sampai
                        <span class="font-semibold text-gray-900 dark:text-white">{{ $schoolAccounts->lastItem() }}</span>
                        dari
                        <span class="font-semibold text-gray-900 dark:text-white">{{ $schoolAccounts->total() }}</span>
                        hasil
                    </p>
                </div>
                <div>
                    <nav class="relative z-0 inline-flex rounded-xl shadow-sm -space-x-px" aria-label="Pagination">
                        @if ($schoolAccounts->onFirstPage())
                            <span
                                class="relative inline-flex items-center px-3 py-2 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-400 cursor-not-allowed">
                                <i class="fa-solid fa-chevron-left text-xs"></i>
                            </span>
                        @else
                            <a href="{{ $schoolAccounts->previousPageUrl() }}"
                                class="relative inline-flex items-center px-3 py-2 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-500 hover:bg-gray-50 transition">
                                <i class="fa-solid fa-chevron-left text-xs"></i>
                            </a>
                        @endif

                        @php
                            $currentPage = $schoolAccounts->currentPage();
                            $lastPage = $schoolAccounts->lastPage();
                            $start = max($currentPage - 2, 1);
                            $end = min($currentPage + 2, $lastPage);
                        @endphp

                        @if ($start > 1)
                            <a href="{{ $schoolAccounts->url(1) }}"
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
                                <a href="{{ $schoolAccounts->url($page) }}"
                                    class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">{{ $page }}</a>
                            @endif
                        @endfor

                        @if ($end < $lastPage)
                            @if ($end < $lastPage - 1)
                                <span
                                    class="relative inline-flex items-center px-4 py-2 border border-gray-200 dark:border-gray-600 bg-gray-50 dark:bg-gray-700 text-gray-500">…</span>
                            @endif
                            <a href="{{ $schoolAccounts->url($lastPage) }}"
                                class="relative inline-flex items-center px-4 py-2 border text-sm font-medium bg-white dark:bg-gray-800 text-gray-700 hover:bg-gray-50">{{ $lastPage }}</a>
                        @endif

                        @if ($schoolAccounts->hasMorePages())
                            <a href="{{ $schoolAccounts->nextPageUrl() }}"
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
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const selectAllCheckbox = document.getElementById('selectAll');
            const accountCheckboxes = document.querySelectorAll('.account-checkbox');

            if (selectAllCheckbox) {
                selectAllCheckbox.addEventListener('change', function() {
                    const isChecked = this.checked;
                    accountCheckboxes.forEach(checkbox => {
                        checkbox.checked = isChecked;
                    });
                });
            }

            const deleteSelectedBtn = document.getElementById('deleteSelectedBtn');
            const deleteForm = document.getElementById('deleteForm');

            if (deleteSelectedBtn) {
                deleteSelectedBtn.addEventListener('click', function() {
                    const selectedCheckboxes = document.querySelectorAll('.account-checkbox:checked');

                    if (selectedCheckboxes.length === 0) {
                        Swal.fire({
                            title: "Peringatan",
                            text: "Pilih setidaknya satu akun untuk dihapus.",
                            icon: "warning"
                        });
                        return;
                    }

                    Swal.fire({
                        title: "Konfirmasi Hapus",
                        html: `Apakah Anda yakin ingin menghapus ${selectedCheckboxes.length} akun members?`,
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#d33",
                        cancelButtonColor: "#3085d6",
                        confirmButtonText: "Ya, hapus!",
                        cancelButtonText: "Batal",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                    }).then((result) => {
                        if (result.isConfirmed) {
                            deleteForm.submit();
                        }
                    });
                });
            }

            // Ban / Unban
            document.querySelectorAll('.btnBan').forEach(function(button) {
                button.addEventListener('click', function() {
                    const idAkun = this.getAttribute('data-idAkun');
                    const namaAkun = this.getAttribute('data-namaAkun');

                    Swal.fire({
                        title: "Apakah Anda yakin?",
                        html: "Apakah Anda yakin ingin memblokir: <br><b>" + namaAkun +
                            "</b>?",
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#3085d6",
                        cancelButtonColor: "#d33",
                        confirmButtonText: "Ya, lakukan!",
                        cancelButtonText: "Batal",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                    }).then((result) => {
                        if (result.isConfirmed) {
                            axios.patch("{{ route('admin.accounts.ban', ':id') }}".replace(
                                    ':id', idAkun))
                                .then(response => {
                                    if (response.data?.status == 'success') {
                                        Swal.fire({
                                            title: "Blokir berhasil!",
                                            text: "Akun ini telah berhasil diblokir.",
                                            icon: "success",
                                            timer: 2000,
                                            timerProgressBar: true,
                                            allowOutsideClick: false,
                                            allowEscapeKey: false,
                                            didOpen: () => {
                                                Swal.showLoading();
                                            },
                                            willClose: () => {
                                                window.location.reload();
                                            }
                                        });
                                    } else {
                                        Swal.fire({
                                            title: "Blokir Gagal!",
                                            text: "Akun ini gagal diblokir.",
                                            icon: "error"
                                        });
                                    }
                                })
                                .catch(error => {
                                    Swal.fire('Gagal', error.message, 'error');
                                });
                        }
                    });
                });
            });

            document.querySelectorAll('.btnActive').forEach(function(button) {
                button.addEventListener('click', function() {
                    const idAkun = this.getAttribute('data-idAkun');
                    const namaAkun = this.getAttribute('data-namaAkun');

                    Swal.fire({
                        title: "Apakah Anda yakin?",
                        html: "Apakah Anda yakin ingin membuka blokir: <br><b>" + namaAkun +
                            "</b>?",
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#3085d6",
                        cancelButtonColor: "#d33",
                        confirmButtonText: "Ya, lakukan!",
                        cancelButtonText: "Batal",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                    }).then((result) => {
                        if (result.isConfirmed) {
                            axios.patch("{{ route('admin.accounts.ban', ':id') }}".replace(
                                    ':id', idAkun))
                                .then(response => {
                                    if (response.data?.status == 'success') {
                                        Swal.fire({
                                            title: "Blokir sudah dicabut!",
                                            text: "Akun ini telah berhasil dibuka blokirnya.",
                                            icon: "success",
                                            timer: 2000,
                                            timerProgressBar: true,
                                            allowOutsideClick: false,
                                            allowEscapeKey: false,
                                            didOpen: () => {
                                                Swal.showLoading();
                                            },
                                            willClose: () => {
                                                window.location.reload();
                                            }
                                        });
                                    } else {
                                        Swal.fire({
                                            title: "Buka Blokir Gagal!",
                                            text: "Akun ini gagal dibuka blokirnya.",
                                            icon: "error"
                                        });
                                    }
                                })
                                .catch(error => {
                                    Swal.fire('Gagal', 'Terjadi kesalahan', 'error');
                                });
                        }
                    });
                });
            });

            // Reset password (optional, dikomentari)
            document.querySelectorAll('.btnResetPw').forEach(function(button) {
                button.addEventListener('click', function() {
                    const emailAkun = this.getAttribute('data-emailAkun');
                    const namaAkun = this.getAttribute('data-namaAkun');

                    Swal.fire({
                        title: "Reset Password",
                        html: `Yakin ingin mereset password untuk akun:<br><b>${namaAkun}</b>?`,
                        icon: "warning",
                        showCancelButton: true,
                        confirmButtonColor: "#3085d6",
                        cancelButtonColor: "#d33",
                        confirmButtonText: "Ya, reset!",
                        cancelButtonText: "Batal",
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                    }).then((result) => {
                        if (result.isConfirmed) {
                            axios.post('/api/forgot-password', {
                                    email: emailAkun
                                })
                                .then(response => {
                                    if (response.data?.status == 'success') {
                                        Swal.fire({
                                            title: "Berhasil!",
                                            text: "Link reset password telah dikirim ke email user.",
                                            icon: "success"
                                        });
                                    } else {
                                        Swal.fire({
                                            title: "Gagal!",
                                            text: "Gagal mereset password.",
                                            icon: "error"
                                        });
                                    }
                                })
                                .catch(error => {
                                    Swal.fire('Gagal', 'Terjadi kesalahan', 'error');
                                });
                        }
                    });
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
    </style>
@endpush

@extends('layouts.app')

@section('title', 'Manage RFID Cards')

@section('content')
<main class="min-h-[calc(100vh-200px)] flex flex-col items-center justify-start py-8 sm:py-12 px-4 sm:px-6">
    <!-- Layout 1: Scan RFID -->
    <div id="layoutFirst" class="w-full max-w-md mx-auto flex flex-col items-center justify-center bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm rounded-2xl shadow-xl p-6 sm:p-8 border border-gray-100 dark:border-gray-700 transition-all duration-300">
        <form class="hidden">
            <input type="hidden" id="rfid_input" name="uid" autofocus>
        </form>

        <!-- NFC Icon with Pulse -->
        <div id="nfc-icon" class="mb-6 sm:mb-8 pulse-animation">
            <svg class="w-28 h-28 sm:w-32 sm:h-32 text-primary-600 dark:text-primary-400" viewBox="0 0 24 24" fill="currentColor">
                <path d="M20,2L4,2c-1.1,0 -2,0.9 -2,2v16c0,1.1 0.9,2 2,2h16c1.1,0 2,-0.9 2,-2L22,4c0,-1.1 -0.9,-2 -2,-2zM20,20L4,20L4,4h16v16zM18,6h-5c-1.1,0 -2,0.9 -2,2v2.28c-0.6,0.35 -1,0.98 -1,1.72 0,1.1 0.9,2 2,2s2,-0.9 2,-2c0,-0.74 -0.4,-1.38 -1,-1.72L13,8h3v8L8,16L8,8h2L10,6L6,6v12h12L18,6z"/>
            </svg>
        </div>

        <!-- Success Icon -->
        <div id="success-icon" class="w-24 h-24 sm:w-28 sm:h-28 rounded-full bg-linear-to-br from-green-500 to-emerald-600 flex items-center justify-center mb-6 sm:mb-8 hidden shadow-lg">
            <i class="bi bi-check-lg text-white text-4xl sm:text-5xl"></i>
        </div>

        <!-- UID Display -->
        <div id="uid-container" class="mb-6 hidden text-center">
            <p class="text-sm text-gray-500 dark:text-gray-400 mb-1">UID Card:</p>
            <p id="card-uid" class="font-mono font-bold text-lg text-primary-600 dark:text-primary-400 bg-gray-100 dark:bg-gray-700 px-4 py-2 rounded-lg inline-block">--</p>
        </div>

        <p id="status-text" class="text-center text-base sm:text-lg mb-8 font-medium text-gray-700 dark:text-gray-300">Tempelkan kartu pelajar Anda</p>

        <div class="flex gap-4 w-full">
            <button id="btn-continue"
                class="w-full bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer text-white py-3 px-4 rounded-xl font-semibold shadow-md transition-all duration-300 hover:scale-105"
                disabled>
                Lanjutkan
            </button>
        </div>
    </div>

    <!-- Layout 2: Pilih Akun -->
    <div id="layoutSecond" class="hidden w-full max-w-2xl mx-auto bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
        <!-- Header RFID Card -->
        <div class="bg-linear-to-r from-primary-600 to-primary-700 px-6 py-4">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center">
                    <i class="bi bi-credit-card text-white text-xl"></i>
                </div>
                <div>
                    <p class="text-xs text-primary-100">Kartu RFID Terdeteksi</p>
                    <p class="font-mono font-bold text-white" id="card-uid2">-</p>
                </div>
            </div>
        </div>

        <div class="p-6 space-y-6">
            <!-- Pilih Akun Siswa -->
            <div>
                <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-3 flex items-center gap-2">
                    <i class="bi bi-people text-primary-500"></i> Pilih Akun Siswa
                </h2>

                <!-- Search Bar -->
                <div class="flex flex-col sm:flex-row gap-3 mb-4">
                    <div class="relative flex-1">
                        <i class="bi bi-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input type="search" placeholder="Cari nama, kelas, atau no induk..."
                            class="w-full rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 px-4 py-2.5 pl-10 text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                            id="searchInput" onkeyup="filterAccounts()">
                    </div>
                    <button onclick="refreshPage()"
                        class="inline-flex items-center justify-center px-4 py-2.5 bg-linear-to-r from-orange-500 to-amber-600 hover:from-orange-600 hover:to-amber-700 text-white rounded-xl shadow-md transition-all duration-200 hover:scale-105">
                        <i class="fas fa-rotate-right"></i>
                    </button>
                </div>

                <!-- Accounts List -->
                <div id="accounts-list" class="space-y-3 max-h-96 overflow-y-auto custom-scrollbar pr-2">
                    @if (empty($users))
                        <div class="text-center py-12 flex flex-col items-center text-gray-500 dark:text-gray-400">
                            <i class="fas fa-id-card mx-auto mb-4 text-5xl text-gray-300 dark:text-gray-600"></i>
                            <p class="text-lg font-medium">Semua akun sudah terhubung RFID 🎉</p>
                            <p class="text-sm">Tidak ada akun yang belum memiliki ID RFID.</p>
                        </div>
                    @else
                        @foreach ($users as $user)
                            <label class="account-item block cursor-pointer">
                                <div class="flex items-center border border-gray-200 dark:border-gray-700 rounded-xl p-4 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-all duration-200">
                                    <input type="radio" name="account" value="{{ $user['id'] }}"
                                        class="mr-4 h-5 w-5 text-primary-600 focus:ring-primary-500">
                                    <div class="flex-1">
                                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-1">
                                            <h3 class="font-semibold text-gray-900 dark:text-white account-name">
                                                {{ $user['school_member']['name'] ?? 'Unknown' }}
                                            </h3>
                                            <span class="text-xs font-medium text-gray-500 dark:text-gray-400 account-class">
                                                {{ $user['school_member']['kelas']['name'] ?? '-' }}
                                            </span>
                                        </div>
                                        <p class="text-sm text-gray-500 dark:text-gray-400 account-nis">
                                            No Induk: {{ $user['school_member']['nomor_induk'] ?? '-' }}
                                        </p>
                                    </div>
                                </div>
                            </label>
                        @endforeach
                    @endif
                    <div id="no-results" class="hidden text-center py-6 text-gray-500">Tidak ada akun yang cocok dengan pencarian.</div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="flex flex-col sm:flex-row gap-3 pt-4 border-t border-gray-100 dark:border-gray-700">
                <button id="btn-cancel"
                    class="w-full sm:w-auto flex-1 bg-linear-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white py-3 px-4 cursor-pointer rounded-xl font-semibold shadow-md transition-all duration-300 hover:scale-105">
                    Batalkan
                </button>
                <button id="btn-continue2"
                    class="w-full sm:w-auto flex-1 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer text-white py-3 px-4 rounded-xl font-semibold shadow-md transition-all duration-300 hover:scale-105"
                    disabled>
                    Simpan Data
                </button>
            </div>
        </div>
    </div>
</main>
@endsection

@push('styles')
<style>
    @keyframes pulse {
        0% { transform: scale(0.95); opacity: 0.7; }
        70% { transform: scale(1); opacity: 1; }
        100% { transform: scale(0.95); opacity: 0.7; }
    }
    .pulse-animation {
        animation: pulse 1.5s infinite;
    }
    .custom-scrollbar::-webkit-scrollbar {
        width: 6px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: transparent;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background-color: #cbd5e1;
        border-radius: 20px;
    }
    .dark .custom-scrollbar::-webkit-scrollbar-thumb {
        background-color: #4b5563;
    }
</style>
@endpush

@push('scripts')
<script>
    let rfidBuffer = "";
    let timeout = null;
    let uidConstant;

    function refreshPage() {
        localStorage.setItem("forceUID", "true");
        window.location.reload();
    }

    document.addEventListener("DOMContentLoaded", function() {
        if (localStorage.getItem("forceUID") === "true") {
            localStorage.removeItem("forceUID");
            uidConstant = localStorage.getItem("uid");

            if (uidConstant) {
                document.getElementById('layoutFirst').classList.add('hidden');
                document.getElementById('layoutSecond').classList.remove('hidden');
                document.getElementById('card-uid2').textContent = uidConstant;
            }
        }
    });

    document.addEventListener("keydown", function(e) {
        const layoutFirst = document.getElementById('layoutFirst');
        if (!layoutFirst || layoutFirst.classList.contains('hidden')) return;

        if (timeout) clearTimeout(timeout);

        if (e.key === "Enter") {
            uidConstant = rfidBuffer;
            const baseUrl = "{{ route('admin.cards.status.check', ':id') }}";
            const url = baseUrl.replace(':id', uidConstant);

            axios.get(url)
                .then(function(res) {
                    if (res.data.success) {
                        Swal.fire({
                            title: "Kartu Sudah Dipakai",
                            text: res.data.message,
                            icon: "error"
                        });
                        localStorage.removeItem("uid");
                    } else {
                        document.getElementById('card-uid').textContent = uidConstant;
                        document.getElementById('uid-container').classList.remove('hidden');
                        document.getElementById('nfc-icon').classList.add('hidden');
                        document.getElementById('success-icon').classList.remove('hidden');

                        localStorage.setItem("uid", uidConstant);
                        document.getElementById('status-text').textContent = 'Kartu berhasil terdeteksi!';
                        document.getElementById('rfid_input').value = uidConstant;
                        document.getElementById('btn-continue').disabled = false;
                    }
                })
                .catch(function(error) {
                    console.error('Error checking card:', error);
                });

            rfidBuffer = "";
            return;
        }

        rfidBuffer += e.key;
        timeout = setTimeout(() => { rfidBuffer = ""; }, 1000);
    });

    // Pindah ke Layout 2
    document.getElementById('btn-continue').addEventListener("click", function() {
        document.getElementById('layoutFirst').classList.add('hidden');
        document.getElementById('layoutSecond').classList.remove('hidden');
        document.getElementById('card-uid2').textContent = uidConstant;
    });

    // Batal & Kembali ke Layout 1
    document.getElementById('btn-cancel').addEventListener("click", function() {
        document.getElementById('status-text').textContent = 'Tempelkan kartu pelajar Anda';
        document.getElementById('uid-container').classList.add('hidden');
        document.getElementById('nfc-icon').classList.remove('hidden');
        document.getElementById('success-icon').classList.add('hidden');
        document.getElementById('btn-continue').disabled = true;

        uidConstant = "";
        localStorage.removeItem("uid");

        document.getElementById('layoutFirst').classList.remove('hidden');
        document.getElementById('layoutSecond').classList.add('hidden');
    });

    const accountRadios = document.querySelectorAll('input[name="account"]');
    const continueBtn = document.getElementById('btn-continue2');

    accountRadios.forEach(radio => {
        radio.addEventListener('change', function() {
            document.querySelectorAll('.account-item .flex').forEach(item => {
                item.classList.remove('bg-primary-50', 'dark:bg-primary-900/20', 'border-primary-300');
            });
            if (this.checked) {
                this.closest('.flex').classList.add('bg-primary-50', 'dark:bg-primary-900/20', 'border-primary-300');
            }
            continueBtn.disabled = false;
        });
    });

    document.getElementById('btn-continue2').addEventListener('click', function() {
        const selectedAccount = document.querySelector('input[name="account"]:checked');
        if (selectedAccount) {
            const userId = selectedAccount.value;
            const accountName = selectedAccount.closest('.account-item').querySelector('.account-name').textContent;

            Swal.fire({
                title: "Konfirmasi",
                text: `Hubungkan kartu ini ke akun ${accountName}?`,
                icon: "question",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Ya, Hubungkan",
                cancelButtonText: "Batal"
            }).then((result) => {
                if (result.isConfirmed) {
                    kirimData(uidConstant, userId);
                }
            });
        }
    });

    function kirimData(rfid_id, user_id) {
        axios.post("{{ route('admin.cards.store') }}", {
                uid: rfid_id,
                user_id: user_id
            })
            .then(function(response) {
                if (response.data?.success) {
                    Swal.fire({
                        icon: "success",
                        title: "Berhasil",
                        text: response.data.message,
                        timer: 2000,
                        showConfirmButton: false
                    }).then(() => {
                        localStorage.removeItem("uid");
                        window.location.reload();
                    });
                } else {
                    Swal.fire({
                        title: "Gagal",
                        text: response.data?.message,
                        icon: "error"
                    });
                }
            })
            .catch(function(error) {
                Swal.fire({
                    title: "Error",
                    text: "Terjadi kesalahan pada server",
                    icon: "error"
                });
            });
    }

    function filterAccounts() {
        const filter = document.getElementById('searchInput').value.toUpperCase();
        const accountItems = document.querySelectorAll('.account-item');
        let visibleCount = 0;

        accountItems.forEach(item => {
            const name = item.querySelector('.account-name')?.textContent.toUpperCase() || '';
            const kelas = item.querySelector('.account-class')?.textContent.toUpperCase() || '';
            const nis = item.querySelector('.account-nis')?.textContent.toUpperCase() || '';

            if (name.includes(filter) || kelas.includes(filter) || nis.includes(filter)) {
                item.style.display = '';
                visibleCount++;
            } else {
                item.style.display = 'none';
            }
        });

        const noResults = document.getElementById('no-results');
        if (noResults) {
            noResults.classList.toggle('hidden', visibleCount > 0 || accountItems.length === 0);
        }
    }
</script>
@endpush
@extends('layouts.app')

@section('title', 'Edit Account')

@section('content')
<div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-10">
    <!-- Card Utama dengan Glassmorphism -->
    <div class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
        <!-- Header dengan Gradien -->
        <div class="bg-gradient-to-r from-primary-600 to-primary-700 px-4 sm:px-6 py-4 sm:py-5">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                <h1 class="text-lg sm:text-xl md:text-2xl font-bold text-white flex items-center gap-2">
                    <i class="fa-solid fa-user-pen"></i>
                    Edit Akun Siswa
                </h1>
                <a href="{{ route('admin.accounts.index') }}" 
                    class="self-start sm:self-auto inline-flex items-center gap-2 text-white/90 hover:text-white bg-white/10 hover:bg-white/20 px-3 py-1.5 sm:px-4 sm:py-2 rounded-xl transition-all duration-200 text-xs sm:text-sm">
                    <i class="fa-solid fa-arrow-left"></i> Kembali
                </a>
            </div>
            <p class="text-primary-100 text-xs sm:text-sm mt-2">Ubah data akun siswa dan kelola kartu RFID</p>
        </div>

        <!-- Notifikasi -->
        @if(session('success'))
        <div class="mx-4 sm:mx-6 mt-4 sm:mt-6 bg-green-50 dark:bg-green-900/30 border-l-4 border-green-500 text-green-700 dark:text-green-300 p-3 sm:p-4 rounded-lg shadow-sm flex items-center gap-2 sm:gap-3 animate-fade-in">
            <i class="fa-solid fa-circle-check text-green-500 text-lg sm:text-xl"></i>
            <p class="text-xs sm:text-sm">{{ session('success') }}</p>
        </div>
        @endif
        
        @if(session('error'))
        <div class="mx-4 sm:mx-6 mt-4 sm:mt-6 bg-red-50 dark:bg-red-900/30 border-l-4 border-red-500 text-red-700 dark:text-red-300 p-3 sm:p-4 rounded-lg shadow-sm flex items-center gap-2 sm:gap-3 animate-fade-in">
            <i class="fa-solid fa-circle-exclamation text-red-500 text-lg sm:text-xl"></i>
            <p class="text-xs sm:text-sm">{{ session('error') }}</p>
        </div>
        @endif

        <!-- Informasi Siswa (Card Modern) -->
        <div class="mx-4 sm:mx-6 mt-4 sm:mt-6 bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-700/50 dark:to-gray-800/50 rounded-xl p-3 sm:p-4 border border-gray-200 dark:border-gray-600 shadow-sm">
            <div class="flex flex-col sm:flex-row items-center sm:items-start gap-3 sm:gap-4">
                <div class="shrink-0">
                    <div class="w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-gradient-to-br from-primary-100 to-primary-200 dark:from-gray-600 dark:to-gray-500 flex items-center justify-center shadow-md">
                        @if (isset($user['school_member']['foto_profile']) && $user['school_member']['foto_profile'])
                            <img src="{{ $user['school_member']['foto_profile'] }}" alt="Profile" class="w-full h-full rounded-full object-cover">
                        @else
                            <i class="fa-solid fa-user text-xl sm:text-2xl text-primary-600 dark:text-primary-300"></i>
                        @endif
                    </div>
                </div>
                <div class="text-center sm:text-left">
                    <h2 class="text-base sm:text-lg md:text-xl font-bold text-gray-900 dark:text-white">{{ $user['school_member']['name'] }}</h2>
                    <div class="flex flex-wrap justify-center sm:justify-start gap-x-3 gap-y-1 text-xs sm:text-sm text-gray-600 dark:text-gray-300 mt-1">
                        <div class="flex items-center gap-1"><i class="fa-solid fa-id-card text-primary-500 w-3 sm:w-4"></i> No Induk: <span class="font-mono font-medium">{{ $user['school_member']['nomor_induk'] }}</span></div>
                        <div class="flex items-center gap-1"><i class="fa-solid fa-building text-primary-500 w-3 sm:w-4"></i> Kelas: <span class="font-medium">{{ $user['school_member']['kelas']['name'] }}</span></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Form -->
        <form action="{{ route('admin.accounts.update', $user['id']) }}" method="POST" class="p-4 sm:p-6 md:p-8 space-y-4 sm:space-y-6">
            @csrf
            @method('PUT')

            <!-- Username & Email -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
                <div class="space-y-1 sm:space-y-2">
                    <label for="username" class="block text-xs sm:text-sm font-semibold text-gray-700 dark:text-gray-300">
                        <i class="fa-solid fa-user mr-1 sm:mr-2 text-primary-500"></i>Username
                    </label>
                    <input type="text" id="username" name="username" value="{{ old('username', $user['username']) }}"
                        class="w-full px-3 py-2 sm:px-4 sm:py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all text-xs sm:text-sm">
                    <p class="text-[11px] sm:text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i class="fa-solid fa-circle-info"></i> Username digunakan untuk login</p>
                    @error('username')
                    <p class="text-[11px] sm:text-xs text-red-600 flex items-center gap-1"><i class="fa-solid fa-circle-exclamation"></i>{{ $message }}</p>
                    @enderror
                </div>
                
                <div class="space-y-1 sm:space-y-2">
                    <label for="email" class="block text-xs sm:text-sm font-semibold text-gray-700 dark:text-gray-300">
                        <i class="fa-solid fa-envelope mr-1 sm:mr-2 text-primary-500"></i>Email
                    </label>
                    <input type="email" id="email" name="email" value="{{ old('email', $user['email']) }}"
                        class="w-full px-3 py-2 sm:px-4 sm:py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all text-xs sm:text-sm">
                    <p class="text-[11px] sm:text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i class="fa-solid fa-circle-info"></i> Email untuk verifikasi dan reset password</p>
                    @error('email')
                    <p class="text-[11px] sm:text-xs text-red-600 flex items-center gap-1"><i class="fa-solid fa-circle-exclamation"></i>{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <!-- Nomor HP -->
            <div class="space-y-1 sm:space-y-2">
                <label for="nomor" class="block text-xs sm:text-sm font-semibold text-gray-700 dark:text-gray-300">
                    <i class="fa-brands fa-whatsapp mr-1 sm:mr-2 text-green-500"></i>Nomor HP/WhatsApp Wali Murid
                </label>
                <input type="text" id="nomor" name="nomor" value="{{ old('nomor', $user['school_member']['nomor']) }}"
                    class="w-full px-3 py-2 sm:px-4 sm:py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all text-xs sm:text-sm"
                    placeholder="08xxxxxxxxxx">
                <p class="text-[11px] sm:text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i class="fa-solid fa-circle-info"></i> Nomor HP orang tua untuk notifikasi via WhatsApp</p>
                @error('nomor')
                <p class="text-[11px] sm:text-xs text-red-600 flex items-center gap-1"><i class="fa-solid fa-circle-exclamation"></i>{{ $message }}</p>
                @enderror
            </div>

            <!-- RFID Card Management -->
            <div class="space-y-3 sm:space-y-4">
                <h3 class="text-sm sm:text-base font-semibold text-gray-900 dark:text-white flex items-center gap-2">
                    <i class="fa-solid fa-credit-card text-primary-500"></i> RFID Card
                </h3>

                <!-- Status RFID -->
                <div id="rfid-status">
                    @if ($user['rfid_id'])
                        <div class="bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 border border-green-200 dark:border-green-800 rounded-xl p-3 sm:p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                            <div class="flex items-center gap-3">
                                <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-green-100 dark:bg-green-800 flex items-center justify-center">
                                    <i class="fa-solid fa-credit-card text-green-600 dark:text-green-300 text-base sm:text-lg"></i>
                                </div>
                                <div>
                                    <p class="text-[11px] sm:text-xs text-gray-500 dark:text-gray-400">Kartu RFID Terhubung</p>
                                    <p class="font-mono font-medium text-xs sm:text-sm">{{ $user['rfid_id'] }}</p>
                                </div>
                            </div>
                            <button type="button" id="btn-remove-rfid"
                                class="inline-flex items-center justify-center gap-2 px-3 py-1.5 sm:px-4 sm:py-2 bg-red-100 hover:bg-red-200 dark:bg-red-900/30 dark:hover:bg-red-900/50 text-red-700 dark:text-red-300 rounded-lg transition text-xs sm:text-sm">
                                <i class="fa-solid fa-trash-can"></i> Hapus
                            </button>
                        </div>
                    @else
                        <div class="bg-gray-50 dark:bg-gray-700/50 border border-gray-200 dark:border-gray-600 rounded-xl p-3 sm:p-4">
                            <div class="flex items-center gap-3">
                                <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gray-100 dark:bg-gray-600 flex items-center justify-center">
                                    <i class="fa-solid fa-credit-card-slash text-gray-500 dark:text-gray-400 text-base sm:text-lg"></i>
                                </div>
                                <div>
                                    <p class="text-xs sm:text-sm text-gray-500 dark:text-gray-400">Tidak ada kartu RFID yang terhubung</p>
                                </div>
                            </div>
                        </div>
                    @endif
                </div>

                <!-- Area Scan RFID -->
                <div class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden">
                    <div class="bg-gray-50/80 dark:bg-gray-700/30 px-3 py-2 sm:px-4 sm:py-3 border-b border-gray-200 dark:border-gray-700">
                        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 sm:gap-3">
                            <h4 class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white">Hubungkan Kartu RFID</h4>
                            <button type="button" id="btn-scan-rfid"
                                class="self-start sm:self-auto inline-flex items-center gap-2 px-3 py-1 sm:px-4 sm:py-1.5 bg-primary-100 hover:bg-primary-200 dark:bg-primary-900/30 dark:hover:bg-primary-900/50 text-primary-700 dark:text-primary-300 rounded-lg transition text-xs sm:text-sm">
                                <i class="fa-solid fa-upc-scan"></i> Scan Kartu
                            </button>
                        </div>
                    </div>
                    
                    <div class="p-3 sm:p-4">
                        <!-- Scan Area (hidden by default) -->
                        <div id="rfid-scan-area" class="hidden">
                            <div class="flex flex-col items-center justify-center py-4 sm:py-6">
                                <div id="nfc-icon" class="mb-3 sm:mb-4 pulse-animation">
                                    <svg class="w-20 h-20 sm:w-28 sm:h-28 text-gray-600 dark:text-gray-300" viewBox="0 0 24 24" fill="currentColor">
                                        <path d="M20,2L4,2c-1.1,0 -2,0.9 -2,2v16c0,1.1 0.9,2 2,2h16c1.1,0 2,-0.9 2,-2L22,4c0,-1.1 -0.9,-2 -2,-2zM20,20L4,20L4,4h16v16zM18,6h-5c-1.1,0 -2,0.9 -2,2v2.28c-0.6,0.35 -1,0.98 -1,1.72 0,1.1 0.9,2 2,2s2,-0.9 2,-2c0,-0.74 -0.4,-1.38 -1,-1.72L13,8h3v8L8,16L8,8h2L10,6L6,6v12h12L18,6z"/>
                                    </svg>
                                </div>
                                <div id="success-icon" class="w-12 h-12 sm:w-16 sm:h-16 rounded-full bg-green-500 flex items-center justify-center mb-3 sm:mb-4 hidden">
                                    <i class="fa-solid fa-check text-white text-xl sm:text-2xl"></i>
                                </div>
                                <p id="scan-status" class="text-center text-xs sm:text-sm text-gray-600 dark:text-gray-300 mb-3 sm:mb-4">Tempelkan kartu RFID</p>
                                <div class="flex gap-2 sm:gap-3">
                                    <button type="button" id="btn-cancel-scan"
                                        class="px-3 py-1.5 sm:px-4 sm:py-2 bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-800 dark:text-gray-200 rounded-lg text-xs sm:text-sm transition">
                                        Batal
                                    </button>
                                    <button type="button" id="btn-confirm-rfid"
                                        class="px-3 py-1.5 sm:px-4 sm:py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg text-xs sm:text-sm transition hidden">
                                        Gunakan Kartu Ini
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Manual Input RFID -->
                        <div id="rfid-manual-input">
                            <label for="rfid_id" class="block text-xs sm:text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">ID RFID (Manual Input)</label>
                            <input type="text" id="rfid_id" name="rfid_id" value="{{ old('rfid_id', $user['rfid_id']) }}"
                                class="w-full px-3 py-2 sm:px-4 sm:py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all text-xs sm:text-sm">
                            <p class="mt-1 text-[11px] sm:text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i class="fa-solid fa-circle-info"></i> Masukkan ID RFID secara manual jika diperlukan</p>
                            @error('rfid_id')
                            <p class="mt-1 text-[11px] sm:text-xs text-red-600 flex items-center gap-1"><i class="fa-solid fa-circle-exclamation"></i>{{ $message }}</p>
                            @enderror
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tombol Submit - Responsif: Full width di mobile, horizontal di desktop -->
            <div class="flex flex-col sm:flex-row justify-end gap-3 pt-4 border-t border-gray-100 dark:border-gray-700">
                <a href="{{ route('admin.accounts.index') }}" 
                    class="inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-600 transition-all shadow-sm text-sm sm:text-base w-full sm:w-auto">
                    <i class="fa-solid fa-arrow-left"></i> Batal
                </a>
                <button type="submit" 
                    class="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 text-sm sm:text-base w-full sm:w-auto">
                    <i class="fa-solid fa-save"></i> Simpan Perubahan
                </button>
            </div>
        </form>
    </div>
</div>
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
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .animate-fade-in {
        animation: fadeIn 0.3s ease-out forwards;
    }
</style>
@endpush

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function() {
        let rfidBuffer = "";
        let timeout = null;
        let scannedRfid = "";

        const btnScanRfid = document.getElementById('btn-scan-rfid');
        const btnCancelScan = document.getElementById('btn-cancel-scan');
        const btnConfirmRfid = document.getElementById('btn-confirm-rfid');
        const btnRemoveRfid = document.getElementById('btn-remove-rfid');
        const rfidScanArea = document.getElementById('rfid-scan-area');
        const rfidManualInput = document.getElementById('rfid-manual-input');
        const nfcIcon = document.getElementById('nfc-icon');
        const successIcon = document.getElementById('success-icon');
        const scanStatus = document.getElementById('scan-status');
        const rfidInput = document.getElementById('rfid_id');
        const currentUserId = "{{ $user['id'] }}";

        btnScanRfid.addEventListener('click', function() {
            rfidScanArea.classList.remove('hidden');
            rfidManualInput.classList.add('hidden');
            nfcIcon.classList.remove('hidden');
            successIcon.classList.add('hidden');
            btnConfirmRfid.classList.add('hidden');
            scanStatus.textContent = 'Tempelkan kartu RFID';
            scannedRfid = "";
        });

        btnCancelScan.addEventListener('click', function() {
            rfidScanArea.classList.add('hidden');
            rfidManualInput.classList.remove('hidden');
            scannedRfid = "";
        });

        btnConfirmRfid.addEventListener('click', function() {
            axios.post('{{ route('admin.accounts.rfid.status') }}', {
                    rfid_id: scannedRfid,
                    current_user_id: currentUserId
                })
                .then(function(response) {
                    if (response.data.success) {
                        rfidInput.value = scannedRfid;
                        rfidScanArea.classList.add('hidden');
                        rfidManualInput.classList.remove('hidden');
                        Swal.fire({
                            icon: 'success',
                            title: 'RFID Terdeteksi',
                            text: 'RFID berhasil ditambahkan ke form',
                            confirmButtonText: 'OK'
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'RFID Sudah Digunakan',
                            html: `RFID ini sudah digunakan oleh:<br><b>${response.data.user.name}</b> (${response.data.user.kelas})`,
                            confirmButtonText: 'OK'
                        });
                    }
                })
                .catch(function(error) {
                    console.error('Error:', error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Terjadi kesalahan saat memeriksa RFID',
                        confirmButtonText: 'OK'
                    });
                });
        });

        if (btnRemoveRfid) {
            btnRemoveRfid.addEventListener('click', function() {
                Swal.fire({
                    title: 'Hapus RFID?',
                    text: 'Yakin ingin menghapus kartu RFID dari akun ini?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'Ya, hapus!',
                    cancelButtonText: 'Batal'
                }).then((result) => {
                    if (result.isConfirmed) {
                        axios.post('{{ route('admin.accounts.rfid.remove', $user['id']) }}')
                            .then(function(response) {
                                if (response.data.status === true) {
                                    const rfidStatus = document.getElementById('rfid-status');
                                    rfidStatus.innerHTML = `
                                        <div class="bg-gray-50 dark:bg-gray-700/50 border border-gray-200 dark:border-gray-600 rounded-xl p-3 sm:p-4">
                                            <div class="flex items-center gap-3">
                                                <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gray-100 dark:bg-gray-600 flex items-center justify-center">
                                                    <i class="fa-solid fa-credit-card-slash text-gray-500 dark:text-gray-400 text-base sm:text-lg"></i>
                                                </div>
                                                <div>
                                                    <p class="text-xs sm:text-sm text-gray-500 dark:text-gray-400">Tidak ada kartu RFID yang terhubung</p>
                                                </div>
                                            </div>
                                        </div>
                                    `;
                                    rfidInput.value = '';
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Berhasil',
                                        text: 'RFID berhasil dihapus dari akun ini',
                                        confirmButtonText: 'OK'
                                    });
                                } else {
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Gagal',
                                        text: response.data.message,
                                        confirmButtonText: 'OK'
                                    });
                                }
                            })
                            .catch(function(error) {
                                console.error('Error:', error);
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: 'Terjadi kesalahan saat menghapus RFID',
                                    confirmButtonText: 'OK'
                                });
                            });
                    }
                });
            });
        }

        // Listen for RFID scan
        document.addEventListener("keydown", function(e) {
            if (rfidScanArea.classList.contains('hidden')) return;
            if (timeout) clearTimeout(timeout);
            if (e.key === "Enter") {
                scannedRfid = rfidBuffer;
                axios.post('{{ route('admin.accounts.rfid.status') }}', {
                        rfid_id: scannedRfid,
                        current_user_id: currentUserId
                    })
                    .then(function(response) {
                        if (!response.data.success) {
                            Swal.fire({
                                icon: 'warning',
                                title: 'RFID Sudah Digunakan',
                                html: `RFID ini sudah digunakan oleh:<br><b>${response.data.user.name}</b> (${response.data.user.kelas})`,
                                confirmButtonText: 'OK'
                            });
                        } else {
                            nfcIcon.classList.add('hidden');
                            successIcon.classList.remove('hidden');
                            scanStatus.textContent = 'Kartu RFID terdeteksi';
                            btnConfirmRfid.classList.remove('hidden');
                        }
                    })
                    .catch(function(error) {
                        console.error('Error:', error);
                    });
                rfidBuffer = "";
                return;
            }
            rfidBuffer += e.key;
            timeout = setTimeout(() => { rfidBuffer = ""; }, 1000);
        });

        // Manual RFID validation
        rfidInput.addEventListener('change', function() {
            if (this.value) {
                axios.post('{{ route('admin.accounts.rfid.status') }}', {
                        rfid_id: this.value,
                        current_user_id: currentUserId
                    })
                    .then(function(response) {
                        if (!response.data.success) {
                            Swal.fire({
                                icon: 'warning',
                                title: 'RFID Sudah Digunakan',
                                html: `RFID ini sudah digunakan oleh:<br><b>${response.data.user.name}</b> (${response.data.user.kelas})`,
                                confirmButtonText: 'OK'
                            });
                        }
                    })
                    .catch(function(error) {
                        console.error('Error:', error);
                    });
            }
        });
    });
</script>
@endpush
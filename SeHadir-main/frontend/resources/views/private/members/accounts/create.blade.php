@extends('layouts.app')

@section('title', 'Create Account')

@section('content')
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-10">
        <!-- Card Utama dengan Glassmorphism -->
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
            <!-- Header Card dengan Gradien -->
            <div class="bg-gradient-to-r from-primary-600 to-primary-700 px-6 py-5 sm:px-8">
                <h1 class="text-xl sm:text-2xl font-bold text-white flex items-center gap-2">
                    <i class="fa-solid fa-user-plus"></i>
                    Tambah Akun Member Baru
                </h1>
                <p class="text-primary-100 text-sm mt-1">Buat akun untuk siswa yang akan digunakan untuk login aplikasi</p>
            </div>

            <!-- Notifikasi -->
            @if (session('success'))
                <div
                    class="mx-6 sm:mx-8 mt-6 bg-green-50 dark:bg-green-900/30 border-l-4 border-green-500 text-green-700 dark:text-green-300 p-4 rounded-lg shadow-sm flex items-center gap-3 animate-fade-in">
                    <i class="fa-solid fa-circle-check text-green-500 text-xl"></i>
                    <p class="text-sm">{{ session('success') }}</p>
                </div>
            @endif

            @if (session('error'))
                <div
                    class="mx-6 sm:mx-8 mt-6 bg-red-50 dark:bg-red-900/30 border-l-4 border-red-500 text-red-700 dark:text-red-300 p-4 rounded-lg shadow-sm flex items-center gap-3 animate-fade-in">
                    <i class="fa-solid fa-circle-exclamation text-red-500 text-xl"></i>
                    <p class="text-sm">{{ session('error') }}</p>
                </div>
            @endif

            <!-- Form -->
            <form action="{{ route('admin.accounts.store') }}" method="POST" class="p-6 sm:p-8 space-y-6">
                @csrf

                <!-- Pilih Siswa dengan Select2 Modern -->
                <div class="space-y-2">
                    <label for="noinduk" class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                        <i class="fa-regular fa-id-card mr-2 text-primary-500"></i>Pilih Siswa (No Induk)
                    </label>
                    <select id="noinduk" name="noinduk"
                        class="select2-noinduk w-full rounded-xl border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100">
                        <option value="">-- Pilih Siswa --</option>
                        @foreach ($siswa as $s)
                            <option value="{{ $s->id }}" data-name="{{ $s->name }}"
                                data-kelas="{{ $s->kelas['name'] ?? 'N/A' }}"
                                data-profile="{{ $s->foto_profile != null && $s->foto_profile != '' ? $s->foto_profile : asset('src/LOGO RAADEVELOPERZ (SUPER HD).png') }}"
                                {{ old('noinduk') == $s->nomor_induk ? 'selected' : '' }}>
                                {{ $s->nomor_induk }} - {{ $s->name }} ({{ $s->kelas['name'] ?? 'N/A' }})
                            </option>
                        @endforeach
                    </select>
                    @error('noinduk')
                        <p class="mt-1 text-xs text-red-600 flex items-center gap-1"><i
                                class="fa-regular fa-circle-exclamation"></i>{{ $message }}</p>
                    @enderror
                </div>

                <!-- Student Info Card (Muncul setelah pilih siswa) -->
                <div id="student-info"
                    class="hidden bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-700/50 dark:to-gray-800/50 rounded-xl p-4 border border-gray-200 dark:border-gray-600 shadow-sm transition-all duration-300">
                    <div class="flex items-center gap-4">
                        <div class="shrink-0">
                            <img id="student-profile"
                                class="w-16 h-20 object-cover rounded-lg shadow-md border-2 border-white dark:border-gray-600">
                        </div>
                        <div class="flex-1">
                            <h3 id="student-name" class="text-lg font-bold text-gray-900 dark:text-white"></h3>
                            <div class="flex flex-wrap gap-x-4 gap-y-1 text-sm text-gray-600 dark:text-gray-300 mt-1">
                                <div class="flex items-center gap-1"><i
                                        class="fa-regular fa-id-card text-primary-500 w-4"></i> <span id="student-noinduk"
                                        class="font-mono"></span></div>
                                <div class="flex items-center gap-1"><i
                                        class="fa-regular fa-building text-primary-500 w-4"></i> Kelas: <span
                                        id="student-kelas" class="font-medium"></span></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Username & Email (grid 2 kolom) -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="space-y-2">
                        <label for="username" class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                            <i class="fa-regular fa-user mr-2 text-primary-500"></i>Username
                        </label>
                        <input type="text" id="username" value="{{ old('username') }}" name="username"
                            class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                            placeholder="Masukkan username">
                        <p class="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i
                                class="fa-solid fa-circle-info"></i> Username akan digunakan untuk login</p>
                        @error('username')
                            <p class="text-xs text-red-600 flex items-center gap-1"><i
                                    class="fa-regular fa-circle-exclamation"></i>{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="space-y-2">
                        <label for="email" class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                            <i class="fa-regular fa-envelope mr-2 text-primary-500"></i>Email
                        </label>
                        <input type="email" id="email" value="{{ old('email') }}" name="email"
                            class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                            placeholder="contoh@email.com">
                        <p class="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i
                                class="fa-solid fa-circle-info"></i> Email untuk verifikasi dan reset password</p>
                        @error('email')
                            <p class="text-xs text-red-600 flex items-center gap-1"><i
                                    class="fa-regular fa-circle-exclamation"></i>{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <!-- Nomor HP -->
                <div class="space-y-2">
                    <label for="no_hp" class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                        <i class="fa-brands fa-whatsapp mr-2 text-green-500"></i>Nomor HP
                    </label>
                    <input type="text" id="no_hp" value="{{ old('no_hp') }}" name="no_hp"
                        class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
                        placeholder="08xxxxxxxxxx">
                    <p class="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1"><i
                            class="fa-solid fa-circle-info"></i> Nomor HP untuk notifikasi via WhatsApp</p>
                    @error('no_hp')
                        <p class="text-xs text-red-600 flex items-center gap-1"><i
                                class="fa-regular fa-circle-exclamation"></i>{{ $message }}</p>
                    @enderror
                </div>

                <!-- Password & Konfirmasi Password -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="space-y-2">
                        <label for="password" class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                            <i class="fa-solid fa-lock mr-2 text-primary-500"></i>Password
                        </label>
                        <div class="relative">
                            <input type="password" id="password" value="{{ old('password') }}" name="password"
                                class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all pr-10"
                                placeholder="Masukkan password">
                            <button type="button"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 toggle-password">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                        @error('password')
                            <p class="text-xs text-red-600 flex items-center gap-1"><i
                                    class="fa-regular fa-circle-exclamation"></i>{{ $message }}</p>
                        @enderror
                    </div>

                    <div class="space-y-2">
                        <label for="password_confirmation"
                            class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                            <i class="fa-solid fa-lock mr-2 text-primary-500"></i>Konfirmasi Password
                        </label>
                        <div class="relative">
                            <input type="password" id="password_confirmation" name="password_confirmation"
                                class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all pr-10"
                                placeholder="Konfirmasi password">
                            <button type="button"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 toggle-password-confirm">
                                <i class="fa-regular fa-eye"></i>
                            </button>
                        </div>
                        @error('password_confirmation')
                            <p class="text-xs text-red-600 flex items-center gap-1"><i
                                    class="fa-regular fa-circle-exclamation"></i>{{ $message }}</p>
                        @enderror
                    </div>
                </div>

                <!-- Tombol Aksi -->
                <div class="flex justify-end gap-3 pt-4 border-t border-gray-100 dark:border-gray-700">
                    <a href="{{ route('admin.accounts.index') }}"
                        class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-600 transition-all shadow-sm">
                        <i class="fa-solid fa-arrow-left"></i> Batal
                    </a>
                    <button type="submit"
                        class="inline-flex items-center gap-2 px-6 py-2.5 rounded-xl bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105">
                        <i class="fa-solid fa-save"></i> Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>
@endsection

@push('styles')
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <style>
        /* Animasi fade-in */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-fade-in {
            animation: fadeIn 0.3s ease-out forwards;
        }

        /* Select2 Modern Styling */
        .select2-container--default .select2-selection--single {
            height: 44px;
            padding: 8px 12px;
            border-color: #e5e7eb;
            border-radius: 0.75rem;
            font-size: 0.875rem;
            background-color: #ffffff;
            transition: all 0.2s;
        }

        .dark .select2-container--default .select2-selection--single {
            background-color: #374151;
            border-color: #4b5563;
        }

        .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 28px;
            color: #111827;
        }

        .dark .select2-container--default .select2-selection--single .select2-selection__rendered {
            color: #f3f4f6;
        }

        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 44px;
            right: 10px;
        }

        .select2-dropdown {
            border-radius: 0.75rem;
            border-color: #e5e7eb;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        .dark .select2-dropdown {
            background-color: #374151;
            border-color: #4b5563;
        }

        .select2-results__option {
            padding: 8px 12px;
            font-size: 0.875rem;
        }

        .dark .select2-results__option {
            color: #e5e7eb;
        }

        .select2-container--default .select2-results__option--highlighted[aria-selected] {
            background-color: #2563eb;
        }

        .select2-search--dropdown .select2-search__field {
            border-radius: 0.5rem;
            border-color: #e5e7eb;
            padding: 6px 10px;
        }

        .dark .select2-search--dropdown .select2-search__field {
            background-color: #4b5563;
            border-color: #6b7280;
            color: #f3f4f6;
        }

        /* Responsive Select2 */
        @media (max-width: 640px) {
            .select2-container--default .select2-selection--single {
                height: 38px;
                padding: 5px 10px;
                font-size: 0.8125rem;
            }

            .select2-container--default .select2-selection--single .select2-selection__arrow {
                height: 38px;
            }

            .select2-container--default .select2-selection--single .select2-selection__rendered {
                line-height: 26px;
                font-size: 0.8125rem;
            }

            .select2-results__option {
                padding: 6px 10px;
                font-size: 0.8125rem;
            }
        }
    </style>
@endpush

@push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Inisialisasi Select2 dengan opsi mencegah auto-select saat scroll
            $('.select2-noinduk').select2({
                placeholder: "Cari member berdasarkan no induk atau nama...",
                allowClear: true,
                width: '100%',
                selectOnClose: false, // 🔥 Mencegah auto-select item pertama saat dropdown tertutup karena scroll
                closeOnSelect: true,
                language: {
                    noResults: function() {
                        return "Tidak ada member yang ditemukan";
                    },
                    searching: function() {
                        return "Mencari...";
                    }
                }
            });

            // Event change Select2
            $('.select2-noinduk').on('change', function() {
                const selectedOption = $(this).find('option:selected');
                const studentInfo = document.getElementById('student-info');
                const studentName = document.getElementById('student-name');
                const studentNoInduk = document.getElementById('student-noinduk');
                const studentKelas = document.getElementById('student-kelas');
                const studentProfile = document.getElementById('student-profile');
                const defaultProfile = "{{ asset('src/LOGO RAADEVELOPERZ (SUPER HD).png') }}";
                const usernameInput = document.getElementById('username');

                if (this.value) {
                    studentName.textContent = selectedOption.data('name');
                    studentNoInduk.textContent = this.value;
                    studentKelas.textContent = selectedOption.data('kelas');
                    studentProfile.src = selectedOption.data('profile') || defaultProfile;
                    studentInfo.classList.remove('hidden');

                    // Auto generate username
                    const nameParts = selectedOption.data('name').toLowerCase().split(' ');
                    let username = '';
                    if (nameParts.length > 1) {
                        username = nameParts[0].charAt(0) + nameParts[nameParts.length - 1];
                    } else {
                        username = nameParts[0];
                    }
                    username += this.value.slice(-4);
                    usernameInput.value = username;
                } else {
                    studentInfo.classList.add('hidden');
                    usernameInput.value = '';
                }
            });

            // Toggle password visibility
            const togglePassword = document.querySelector('.toggle-password');
            const togglePasswordConfirm = document.querySelector('.toggle-password-confirm');
            const passwordField = document.getElementById('password');
            const confirmField = document.getElementById('password_confirmation');

            if (togglePassword && passwordField) {
                togglePassword.addEventListener('click', function() {
                    const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
                    passwordField.setAttribute('type', type);
                    this.querySelector('i').classList.toggle('fa-eye');
                    this.querySelector('i').classList.toggle('fa-eye-slash');
                });
            }

            if (togglePasswordConfirm && confirmField) {
                togglePasswordConfirm.addEventListener('click', function() {
                    const type = confirmField.getAttribute('type') === 'password' ? 'text' : 'password';
                    confirmField.setAttribute('type', type);
                    this.querySelector('i').classList.toggle('fa-eye');
                    this.querySelector('i').classList.toggle('fa-eye-slash');
                });
            }

            // Kirim kode verifikasi (opsional)
            const sendCodeBtn = document.getElementById('send-code-btn');
            const emailInput = document.getElementById('email');
            if (sendCodeBtn && emailInput) {
                sendCodeBtn.addEventListener('click', function() {
                    const email = emailInput.value;
                    if (!email) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Perhatian',
                            text: 'Masukkan email terlebih dahulu',
                            confirmButtonText: 'OK'
                        });
                        return;
                    }
                    const originalText = this.textContent;
                    this.disabled = true;
                    this.innerHTML =
                        `<svg class="animate-spin -ml-1 mr-1 h-3 w-3 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg> Mengirim...`;

                    fetch('/api/send-verification-code', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')
                                    .getAttribute('content')
                            },
                            body: JSON.stringify({
                                email: email
                            })
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                emailInput.readOnly = true;
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Berhasil',
                                    text: 'Kode verifikasi telah dikirim ke email',
                                    confirmButtonText: 'OK'
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Gagal',
                                    text: data.message || 'Gagal mengirim kode verifikasi',
                                    confirmButtonText: 'OK'
                                });
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: 'Terjadi kesalahan saat mengirim kode verifikasi',
                                confirmButtonText: 'OK'
                            });
                        })
                        .finally(() => {
                            setTimeout(() => {
                                this.disabled = false;
                                this.textContent = originalText;
                            }, 3000);
                        });
                });
            }
        });
    </script>
@endpush

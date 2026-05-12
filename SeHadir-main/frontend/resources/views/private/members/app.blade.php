@extends('layouts.app')

@section('content')
    <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8 content">
        @if (session('success'))
            <div id="success-alert"
                class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <span class="block sm:inline">{{ session('success') }}</span>
                <span class="absolute top-0 bottom-0 right-0 px-4 py-3">
                    <svg class="fill-current h-6 w-6 text-green-500" role="button" onclick="closeAlert('success-alert')"
                        xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                        <title>Close</title>
                        <path
                            d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z" />
                    </svg>
                </span>
            </div>
        @endif

        @if (session('error'))
            <div id="error-alert" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4"
                role="alert">
                <span class="block sm:inline">{{ session('error') }}</span>
                <span class="absolute top-0 bottom-0 right-0 px-4 py-3">
                    <svg class="fill-current h-6 w-6 text-red-500" role="button" onclick="closeAlert('error-alert')"
                        xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                        <title>Close</title>
                        <path
                            d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z" />
                    </svg>
                </span>
            </div>
        @endif

        <div class="md:flex md:items-center md:justify-between mb-8">
            <div class="min-w-0 flex-1">
                <div class="flex flex-row items-center justify-between">
                    <h2 class="max-md:text-xl font-bold leading-7 sm:truncate text-2xl">Kelola Data Members</h2>
                    @if (request()->path() === 'admin/accounts/charts')
                        <a href="{{ route('admin.siswa.index') }}"
                            class="text-primary-600 hover:text-primary-700 mr-2 dark:text-primary-400 dark:hover:text-primary-300 flex items-center text-sm">
                            <i class="bi bi-arrow-left mr-1"></i> Kembali
                        </a>
                    @endif
                </div>
                <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                    Kelola data member dan akun member
                </p>
            </div>
        </div>

        <!-- Tabs -->
        <div class="mb-6">
            <div class="border-b border-gray-200 dark:border-gray-700">
                <nav class="-mb-px flex flex-wrap gap-2 sm:gap-4 sm:flex-nowrap sm:space-x-8">
                    <button id="btn-dataSiswa"
                        class="border-primary-600 cursor-pointer text-primary-600 dark:text-primary-400 dark:border-primary-400 hover:text-primary-700 dark:hover:text-primary-300 whitespace-nowrap py-2 px-3 border-b-2 font-medium text-sm sm:py-4 sm:px-1"
                        onclick="showTab('data-siswa')">
                        Data Members
                    </button>

                    <button id="btn-akunSiswa"
                        class="border-transparent cursor-pointer text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 dark:hover:border-gray-600 whitespace-nowrap py-2 px-3 border-b-2 font-medium text-sm sm:py-4 sm:px-1"
                        onclick="showTab('akun-siswa')">
                        Data Akun
                    </button>

                    <button id="btn-fotoSiswa"
                        class="border-transparent cursor-pointer text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 dark:hover:border-gray-600 whitespace-nowrap py-2 px-3 border-b-2 font-medium text-sm sm:py-4 sm:px-1"
                        onclick="showTab('photos.index')">
                        Data Foto
                    </button>

                    <button id="btn-kelasSiswa"
                        class="border-transparent cursor-pointer text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 dark:hover:border-gray-600 whitespace-nowrap py-2 px-3 border-b-2 font-medium text-sm sm:py-4 sm:px-1"
                        onclick="showTab('daftar-kelas')">
                        Data Kelas
                    </button>
                </nav>
            </div>
        </div>
        @yield('content-siswa')
    </main>
@endsection

@push('scripts')
    <script>
        function closeAlert(alertId) {
            const alertElement = document.getElementById(alertId);
            if (alertElement) {
                alertElement.style.display = 'none';
            }
        }

        function showTab(tabId) {
            if (tabId === 'akun-siswa') {
                window.location.href = '{{ route('admin.accounts.index') }}'
            } else if (tabId === 'data-siswa') {
                window.location.href = '{{ route('admin.siswa.index') }}'
            } else if (tabId === 'photos.index') {
                window.location.href = '{{ route('admin.photos.index') }}'
            } else if (tabId === 'daftar-kelas') {
                window.location.href = '{{ route('admin.kelas.index') }}'
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            const currentPath = '{{ request()->route()->getName() }}';

            if (currentPath === 'admin.siswa.index' || currentPath === 'admin.siswa.create' || currentPath ===
                'admin.siswa.edit') {
                document.getElementById('btn-dataSiswa').classList.remove('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-dataSiswa').classList.add('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300');
                document.getElementById('btn-akunSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-akunSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-fotoSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-fotoSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
            } else if (currentPath === 'admin.accounts.index' || currentPath === 'admin.accounts.create' ||
                currentPath === 'admin.accounts.edit' || currentPath === 'admin.accounts.presences' || currentPath === 'admin.accounts.charts') {
                document.getElementById('btn-akunSiswa').classList.remove('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-akunSiswa').classList.add('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300');
                document.getElementById('btn-dataSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-dataSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-fotoSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-fotoSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-kelasSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
            } else if (currentPath === 'admin.photos.index') {
                document.getElementById('btn-dataSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300');
                document.getElementById('btn-dataSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-akunSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-akunSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-fotoSiswa').classList.remove('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-fotoSiswa').classList.add('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-kelasSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
            } else if (currentPath === 'admin.kelas.index' || currentPath === 'admin.kelas.create' ||
                currentPath === 'admin.kelas.edit') {
                document.getElementById('btn-dataSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300');
                document.getElementById('btn-dataSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-akunSiswa').classList.remove('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
                document.getElementById('btn-akunSiswa').classList.add('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-kelasSiswa').classList.remove('border-transparent', 'text-gray-500',
                    'dark:text-gray-400', 'hover:text-gray-700', 'dark:hover:text-gray-300',
                    'hover:border-gray-300', 'dark:hover:border-gray-600');
                document.getElementById('btn-kelasSiswa').classList.add('border-primary-600', 'text-primary-600',
                    'dark:text-primary-400', 'dark:border-primary-400', 'hover:text-primary-700',
                    'dark:hover:text-primary-300')
            }
        });
    </script>
@endpush

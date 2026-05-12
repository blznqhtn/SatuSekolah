@extends('private.members.app')

@section('title', 'Manage Class')

@section('content-siswa')
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-10">
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
            <div class="bg-linear-to-r from-primary-600 to-primary-700 px-6 py-5 sm:px-8">
                <h1 class="text-xl sm:text-2xl font-bold text-white flex items-center gap-2">
                    <i class="fa-solid fa-layer-group"></i>
                    Kelola Kelas
                </h1>
                <p class="text-primary-100 text-sm mt-1">Input beberapa kelas sekaligus (nama kelas & tingkatan)</p>
            </div>

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

            <form action="{{ route('admin.kelas.store') }}" method="POST" class="p-6 sm:p-8 space-y-6" id="kelasForm">
                @csrf

                <div id="kelas-container">
                    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-4 gap-3">
                        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300">
                            <i class="fa-solid fa-school mr-2 text-primary-500"></i>Data Kelas
                        </label>

                        <button type="button" id="tambah-kelas"
                            class="inline-flex items-center justify-center gap-2 px-4 py-2 bg-linear-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-200 hover:scale-105 w-full sm:w-auto">
                            <i class="fa-solid fa-plus"></i> Tambah Kelas
                        </button>
                    </div>

                    <div id="kelas-rows" class="space-y-4">
                        @forelse ($dataKelas as $index => $kelas)
                            <div
                                class="kelas-row bg-gray-50/80 dark:bg-gray-700/50 rounded-xl p-4 border border-gray-200 dark:border-gray-600 relative transition-all">
                                <input type="hidden" name="kelas[{{ $index }}][id]" value="{{ $kelas['id'] }}">

                                <div class="grid grid-cols-1 md:grid-cols-12 gap-4">
                                    <div class="md:col-span-5">
                                        <label class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">Nama
                                            Kelas <span class="text-red-500">*</span></label>
                                        <input type="text" name="kelas[{{ $index }}][name]"
                                            value="{{ $kelas['name'] }}" placeholder="Contoh: XII RPL 1"
                                            class="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm">
                                    </div>

                                    <div class="md:col-span-5">
                                        <label
                                            class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">Tingkatan
                                            <span class="text-red-500">*</span></label>
                                        <input type="text" name="kelas[{{ $index }}][jenjang]"
                                            value="{{ $kelas['jenjang'] }}" placeholder="Contoh: 7, 8, 9, X, XI, XII"
                                            class="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm">
                                    </div>

                                    <div class="md:col-span-2 flex items-end justify-end">
                                        <button type="button"
                                            class="hapus-kelas cursor-pointer text-red-600 hover:text-red-800 dark:text-red-400 p-2 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                                            title="Hapus baris">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        @empty
                            <div
                                class="kelas-row bg-gray-50/80 dark:bg-gray-700/50 rounded-xl p-4 border border-gray-200 dark:border-gray-600 relative transition-all">
                                <div class="grid grid-cols-1 md:grid-cols-12 gap-4">
                                    <div class="md:col-span-5">
                                        <label class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">Nama
                                            Kelas <span class="text-red-500">*</span></label>
                                        <input type="text" name="kelas[0][name]" placeholder="Contoh: XII RPL 1"
                                            class="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm">
                                    </div>

                                    <div class="md:col-span-5">
                                        <label
                                            class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">Tingkatan
                                            <span class="text-red-500">*</span></label>
                                        <input type="text" name="kelas[0][jenjang]"
                                            placeholder="Contoh: 7, 8, 9, X, XI, XII"
                                            class="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm">
                                    </div>

                                    <div class="md:col-span-2 flex items-end justify-end">
                                        <button type="button"
                                            class="hapus-kelas cursor-pointer text-red-600 hover:text-red-800 dark:text-red-400 p-2 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
                                            title="Hapus baris">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        @endforelse
                    </div>
                </div>

                <div class="flex flex-col sm:flex-row justify-end gap-3 pt-4 border-t border-gray-100 dark:border-gray-700">
                    <button type="submit"
                        class="inline-flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold shadow-md hover:shadow-lg transition-all duration-300 hover:scale-105 w-full sm:w-auto">
                        <i class="fa-solid fa-save"></i> Simpan Semua
                    </button>
                </div>
            </form>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const container = document.getElementById('kelas-rows');
            const tambahBtn = document.getElementById('tambah-kelas');
            let rowCount = {{ count($dataKelas) > 0 ? count($dataKelas) : 1 }};

            function tambahBaris() {
                const newRow = document.createElement('div');
                newRow.className =
                    'kelas-row bg-gray-50/80 dark:bg-gray-700/50 rounded-xl p-4 border border-gray-200 dark:border-gray-600 relative transition-all';
                newRow.innerHTML = `
                <div class="grid grid-cols-1 md:grid-cols-12 gap-4">
                    <div class="md:col-span-5">
                        <label class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">Nama Kelas <span class="text-red-500">*</span></label>
                        <input type="text" name="kelas[${rowCount}][name]" placeholder="Contoh: XII RPL 1" 
                            class="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm">
                    </div>
                    <div class="md:col-span-5">
                        <label class="block text-xs font-medium text-gray-600 dark:text-gray-400 mb-1">Tingkatan <span class="text-red-500">*</span></label>
                        <input type="text" name="kelas[${rowCount}][jenjang]" placeholder="Contoh: 7, 8, 9, X, XI, XII" 
                            class="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent text-sm">
                    </div>
                    <div class="md:col-span-2 flex items-end justify-end">
                        <button type="button" class="hapus-kelas text-red-600 hover:text-red-800 dark:text-red-400 p-2 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors" title="Hapus baris">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </div>
                </div>
            `;
                container.appendChild(newRow);
                rowCount++;

                attachHapusEvent(newRow);
            }

            function hapusBaris(button) {
                const row = button.closest('.kelas-row');
                if (container.children.length > 1) {
                    row.remove();
                } else {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Tidak bisa menghapus',
                        text: 'Minimal harus ada satu baris kelas',
                        confirmButtonText: 'OK'
                    });
                }
            }

            function attachHapusEvent(row) {
                const hapusBtn = row.querySelector('.hapus-kelas');
                if (hapusBtn) {
                    hapusBtn.addEventListener('click', function(e) {
                        e.preventDefault();
                        hapusBaris(this);
                    });
                }
            }

            tambahBtn.addEventListener('click', function(e) {
                e.preventDefault();
                tambahBaris();
            });

            const existingRows = document.querySelectorAll('.kelas-row');
            existingRows.forEach(row => {
                attachHapusEvent(row);
            });
        });
    </script>
@endpush

@push('styles')
    <style>
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

        .kelas-row {
            transition: all 0.2s ease;
        }

        .kelas-row:hover {
            border-color: #cbd5e1;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .dark .kelas-row:hover {
            border-color: #6b7280;
        }
    </style>
@endpush

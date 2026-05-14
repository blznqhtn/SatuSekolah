@extends('layouts.app')

@section('title', "Late attendance form for today's arrival")

@section('content')
    <div
        class="min-h-screen flex items-center justify-center py-8 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md mx-auto">
            <!-- Card Utama dengan Glassmorphism -->
            <div
                class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-2xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
                <!-- Header dengan Gradien -->
                <div class="bg-linear-to-r from-amber-500 to-orange-600 px-6 py-5 text-center">
                    <div class="flex justify-center mb-3">
                        <div class="p-3 bg-white/20 rounded-full backdrop-blur-sm">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-white" fill="none"
                                viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                    <h2 class="text-xl sm:text-2xl font-bold text-white tracking-tight">
                        Form Keterlambatan Datang
                    </h2>
                    <p class="text-amber-100 text-sm mt-1">Isi alasan keterlambatan Anda</p>
                </div>

                <!-- Form Body -->
                <div class="p-6 sm:p-8">
                    <form action="{{ route('forms.late.submit_arrival') }}" method="POST" class="space-y-5">
                        @csrf
                        <input type="hidden" name="token" value="{{ $lateEntry->token }}" readonly autocomplete="off">

                        <!-- Jam Datang -->
                        <div class="group">
                            <label
                                class="flex items-center gap-2 text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">
                                <i class="fa-regular fa-clock text-amber-500"></i>
                                Jam Datang
                            </label>
                            <div class="relative">
                                <input type="text" value="{{ \Carbon\Carbon::parse($lateEntry->time)->format('d M Y (h:i:s A)') }}" readonly
                                    class="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 text-gray-800 dark:text-gray-200 text-sm cursor-not-allowed shadow-inner">
                                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                                    <i class="fa-regular fa-calendar-alt text-gray-400"></i>
                                </div>
                            </div>
                        </div>

                        <!-- No Induk -->
                        <div class="group">
                            <label
                                class="flex items-center gap-2 text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">
                                <i class="fa-regular fa-id-card text-amber-500"></i>
                                No Induk
                            </label>
                            <div class="relative">
                                <input type="text" value="{{ $user->school_member->nomor_induk }}" readonly
                                    class="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 text-gray-800 dark:text-gray-200 text-sm cursor-not-allowed shadow-inner font-mono">
                            </div>
                        </div>

                        <!-- Nama Lengkap -->
                        <div class="group">
                            <label
                                class="flex items-center gap-2 text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">
                                <i class="fa-regular fa-user text-amber-500"></i>
                                Nama Lengkap
                            </label>
                            <div class="relative">
                                <input type="text" value="{{ $user->school_member->name }}" readonly
                                    class="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 text-gray-800 dark:text-gray-200 text-sm cursor-not-allowed shadow-inner font-medium">
                            </div>
                        </div>

                        <!-- Alasan Telat -->
                        <div class="group">
                            <label
                                class="flex items-center gap-2 text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5">
                                <i class="fa-regular fa-message text-amber-500"></i>
                                Alasan Telat Datang <span class="text-red-500 text-xs">*</span>
                            </label>
                            <div class="relative">
                                <textarea name="alasan" rows="4"
                                    class="w-full px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-all resize-none"
                                    placeholder="Contoh: Terjadi kendala di perjalanan, ban bocor, dll..."></textarea>
                                <div class="absolute bottom-3 right-3 pointer-events-none text-gray-400 text-xs">
                                    <i class="fa-regular fa-pen-to-square"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Tombol Submit -->
                        <div class="pt-4">
                            <button type="submit"
                                class="group relative cursor-pointer w-full flex justify-center py-3 px-4 border border-transparent rounded-xl text-sm font-semibold text-white bg-linear-to-r from-amber-600 to-orange-600 hover:from-amber-700 hover:to-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 transition-all duration-300 transform hover:scale-[1.02] shadow-md">
                                <i
                                    class="fa-regular fa-paper-plane mr-2 group-hover:translate-x-0.5 transition-transform"></i>
                                Kirim Laporan
                            </button>
                        </div>

                        <!-- Info tambahan -->
                        <div class="text-center text-xs text-gray-500 dark:text-gray-400 pt-2">
                            <i class="fa-solid fa-circle-info mr-1"></i> Data tidak dapat diubah, pastikan alasan sudah
                            benar
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('styles')
    <style>
        /* Animasi halus untuk input focus */
        input:focus,
        textarea:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.1);
        }

        /* Custom scrollbar untuk textarea */
        textarea::-webkit-scrollbar {
            width: 4px;
        }

        textarea::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        textarea::-webkit-scrollbar-thumb {
            background: #f59e0b;
            border-radius: 10px;
        }

        .dark textarea::-webkit-scrollbar-track {
            background: #374151;
        }
    </style>
@endpush

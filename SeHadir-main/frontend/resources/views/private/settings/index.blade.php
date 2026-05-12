@extends('layouts.app')

@section('title', 'Settings')

@section('content')
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 py-6">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
                    <i class="fas fa-cog mr-3 text-primary-600"></i>Pengaturan Sistem
                </h1>
                <p class="mt-2 text-gray-600 dark:text-gray-400">
                    Kelola identitas sekolah dan pengaturan presensi SeHadir.
                </p>
            </div>

            @if (session('success'))
                <div
                    class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative animate-fade-in">
                    <span class="block sm:inline"><i class="fas fa-check-circle mr-2"></i>{{ session('success') }}</span>
                </div>
            @endif

            <div class="max-w-4xl mx-auto">
                <div class="flex border-b border-gray-200 dark:border-gray-700 mb-6">
                    <button onclick="switchTab('tab-info')" id="btn-tab-info"
                        class="tab-btn px-6 py-3 text-sm cursor-pointer font-medium border-b-2 border-primary-600 text-primary-600 transition-all">
                        <i class="fas fa-school mr-2"></i>Informasi Sekolah
                    </button>

                    <button onclick="switchTab('tab-others')" id="btn-tab-others"
                        class="tab-btn px-6 py-3 text-sm cursor-pointer font-medium border-b-2 border-transparent text-gray-500 hover:text-gray-700 transition-all">
                        <i class="fas fa-cogs mr-2"></i>Lainnya
                    </button>
                </div>

                <form action="{{ route('admin.settings.update') }}" method="POST" enctype="multipart/form-data"
                    class="space-y-6">
                    @csrf

                    <div id="tab-info" class="tab-content block animate-fade-in">
                        <div class="bg-white dark:bg-gray-800 shadow-lg rounded-lg p-6 space-y-6">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <div
                                    class="md:col-span-2 flex items-center space-x-6 pb-4 border-b border-gray-100 dark:border-gray-700">
                                    <div class="shrink-0">
                                        <img id="logo-preview"
                                            class="h-20 w-20 object-cover rounded-lg border-2 border-gray-200"
                                            src="{{ $settings->ikon ? asset('storage/' . $settings->ikon) : asset('images/default-logo.png') }}"
                                            alt="Logo">
                                    </div>

                                    <label class="block">
                                        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Logo
                                            Sekolah</span>
                                        <input type="file" name="ikon" onchange="previewImage(event)"
                                            class="block w-full text-sm text-gray-500 mt-1 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary-50 file:text-primary-700 hover:file:bg-primary-100">
                                    </label>
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Nama
                                        Sekolah</label>

                                    <input type="text" name="nama_sekolah"
                                        value="{{ old('nama_sekolah', $settings->nama_sekolah ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Nama
                                        Kepala Sekolah</label>

                                    <input type="text" name="kepala_sekolah"
                                        value="{{ old('kepala_sekolah', $settings->kepala_sekolah ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white">
                                </div>

                                <div>
                                    <label
                                        class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Perwakilan
                                        Tata Usaha (TU)</label>

                                    <input type="text" name="nama_perwakilan_tu"
                                        value="{{ old('nama_perwakilan_tu', $settings->nama_perwakilan_tu ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Nomor
                                        WhatsApp Sekolah</label>

                                    <input type="text" name="whatsapp_number"
                                        value="{{ old('whatsapp_number', $settings->whatsapp_number ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white"
                                        placeholder="Contoh: 0812...">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Email
                                        Sekolah</label>

                                    <input type="email" name="email" value="{{ old('email', $settings->email ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Website
                                        Sekolah</label>

                                    <input type="url" name="website"
                                        value="{{ old('website', $settings->website ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white"
                                        placeholder="https://...">
                                </div>

                                <div class="md:col-span-2">
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Alamat
                                        Sekolah</label>
                                    <textarea name="alamat" rows="3" class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white">{{ old('alamat', $settings->alamat ?? '') }}</textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="tab-others" class="tab-content hidden animate-fade-in">
                        <div class="bg-white dark:bg-gray-800 shadow-lg rounded-lg p-6 space-y-8">
                            <section>
                                <label class="block text-sm font-bold text-gray-900 dark:text-white mb-4">Metode
                                    Presensi</label>

                                <div class="p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg mb-4">
                                    <div class="flex items-start">
                                        <i class="fas fa-info-circle text-blue-600 mt-0.5 mr-3"></i>
                                        <div class="text-sm text-blue-800 dark:text-blue-200" id="menuInfo"></div>
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 gap-3">
                                    @foreach (['rfid' => ['RFID Only', 'fas fa-credit-card', 'blue'], 'face_id' => ['Face ID Only', 'fas fa-user-circle', 'green'], 'both' => ['Keduanya', 'fas fa-id-badge', 'purple']] as $val => $data)
                                        <label
                                            class="flex items-center cursor-pointer p-4 border-2 border-gray-200 dark:border-gray-700 rounded-xl hover:border-primary-500 transition-all">
                                            <input type="radio" name="attendance_method" value="{{ $val }}"
                                                {{ ($settings->attendance_method ?? 'rfid') == $val ? 'checked' : '' }}
                                                class="radio-custom">

                                            <span class="ml-4">
                                                <span class="block text-sm font-bold text-gray-900 dark:text-white"><i
                                                        class="{{ $data[1] }} mr-2 text-{{ $data[2] }}-500"></i>{{ $data[0] }}</span>
                                            </span>
                                        </label>
                                    @endforeach
                                </div>
                            </section>

                            <div id="faceIdSettingsPanel"
                                class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-200 dark:border-gray-600 hidden">
                                <h3 class="text-sm font-bold text-gray-900 dark:text-white mb-4"><i
                                        class="fas fa-user-shield mr-2 text-primary-500"></i>AWS Rekognition & Liveness</h3>

                                <div class="space-y-6">
                                    <div class="flex items-center justify-between">
                                        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Anti-Spoofing
                                            (Liveness Check)</span>

                                        <input type="checkbox" name="anti_spoofing_enabled" value="1"
                                            {{ $settings->anti_spoofing_enabled ?? false ? 'checked' : '' }}
                                            class="w-11 h-6 rounded-full appearance-none bg-gray-300 checked:bg-primary-600 relative cursor-pointer transition-all after:content-[''] after:absolute after:top-0.5 after:left-0.5 after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all checked:after:translate-x-5">
                                    </div>

                                    <div>
                                        <div class="flex justify-between mb-2">
                                            <label class="text-sm font-medium">Similarity Threshold</label>
                                            <span id="confidenceValue"
                                                class="text-sm font-bold text-primary-600">{{ round(($settings->face_confidence_threshold ?? 0.8) * 100) }}%</span>
                                        </div>

                                        <input type="range" id="confidenceRange" name="face_confidence_threshold"
                                            min="0.1" max="1.0" step="0.05"
                                            value="{{ $settings->face_confidence_threshold ?? 0.8 }}"
                                            class="w-full h-2 bg-gray-200 rounded-lg appearance-none accent-primary-600">
                                    </div>
                                </div>
                            </div>

                            <section class="pt-6 border-t border-gray-100 dark:border-gray-700">
                                <h3 class="text-sm font-bold text-gray-900 dark:text-white mb-4">Sistem Notifikasi & SP</h3>

                                <div class="flex items-center mb-4">
                                    <input type="checkbox" name="sp_enabled" id="sp_enabled" value="1"
                                        {{ $settings->sp_enabled ? 'checked' : '' }}
                                        class="h-4 w-4 text-primary-600 rounded">

                                    <label for="sp_enabled" class="ml-3 text-sm text-gray-700 dark:text-gray-300">Aktifkan
                                        Pengiriman Surat Peringatan (SP) Otomatis</label>
                                </div>

                                <div class="flex items-center">
                                    <input type="checkbox" name="whatsapp_notification_enabled" id="wa_notif"
                                        value="1" {{ $settings->whatsapp_notification_enabled ? 'checked' : '' }}
                                        class="h-4 w-4 text-primary-600 rounded">

                                    <label for="wa_notif" class="ml-3 text-sm text-gray-700 dark:text-gray-300">Kirim
                                        Notifikasi via WhatsApp</label>
                                </div>

                                <div class="mt-4 p-4 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-200 dark:border-gray-600">
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                                        API Key WhatsApp Gateway (Fonnte API)
                                    </label>
                                    <input type="text" name="apikey_whatsapp"
                                        value="{{ old('apikey_whatsapp', $settings->apikey_whatsapp ?? '') }}"
                                        class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white"
                                        placeholder="Masukkan API Token dari Fonnte.com">
                                    <p class="text-xs mt-2 text-gray-500">
                                        <i class="fas fa-info-circle mr-1"></i> Sistem ini menggunakan API dari <a href="https://fonnte.com" target="_blank" class="text-primary-600 hover:underline">Fonnte</a>. Biarkan kosong jika fitur notifikasi whatsapp tidak diaktifkan.
                                    </p>
                                </div>

                                <div class="mt-4 flex items-center space-x-3">
                                    <span class="text-sm text-gray-600">Batas Telat:</span>

                                    <input type="number" name="sp_max_late_per_month"
                                        value="{{ $settings->sp_max_late_per_month ?? 3 }}"
                                        class="w-16 px-2 py-1 border rounded dark:bg-gray-700 text-center">
                                    <span class="text-sm text-gray-600">kali / bulan</span>
                                </div>
                            </section>
                        </div>
                    </div>

                    <div class="flex justify-end pt-4">
                        <button type="submit"
                            class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-3 px-10 rounded-xl shadow-lg transition-all transform hover:scale-105">
                            <i class="fas fa-save mr-2"></i>Simpan Semua Perubahan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

@push('styles')
    <style>
        .radio-custom {
            appearance: none;
            width: 1.2rem;
            height: 1.2rem;
            border: 2px solid #d1d5db;
            border-radius: 50%;
            position: relative;
        }

        .radio-custom:checked {
            border-color: #0ea5e9;
            background-color: #0ea5e9;
        }

        .radio-custom:checked::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background-color: white;
        }

        .animate-fade-in {
            animation: fadeIn 0.3s ease-in-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(5px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
@endpush

@push('scripts')
    <script>
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.replace('block', 'hidden'));
            document.getElementById(tabId).classList.replace('hidden', 'block');

            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('border-primary-600', 'text-primary-600');
                btn.classList.add('border-transparent', 'text-gray-500');
            });

            const activeBtn = document.getElementById('btn-' + tabId);
            activeBtn.classList.add('border-primary-600', 'text-primary-600');
            activeBtn.classList.remove('border-transparent', 'text-gray-500');
        }

        function previewImage(event) {
            const reader = new FileReader();
            reader.onload = () => document.getElementById('logo-preview').src = reader.result;
            reader.readAsDataURL(event.target.files[0]);
        }

        document.addEventListener('DOMContentLoaded', function() {
            const methodRadios = document.querySelectorAll('input[name="attendance_method"]');
            const facePanel = document.getElementById('faceIdSettingsPanel');
            const menuInfo = document.getElementById('menuInfo');
            const confidenceRange = document.getElementById('confidenceRange');
            const confidenceValue = document.getElementById('confidenceValue');

            confidenceRange.addEventListener('input', function() {
                confidenceValue.textContent = Math.round(this.value * 100) + '%';
            });

            function updateUI(method) {
                facePanel.classList.toggle('hidden', method === 'rfid');
                let info = method === 'rfid' ? 'RFID' : (method === 'face_id' ? 'Wajah' : 'RFID & Wajah');
                menuInfo.innerHTML = `Metode <strong>${info}</strong> aktif.`;
            }

            methodRadios.forEach(r => r.addEventListener('change', e => updateUI(e.target.value)));
            updateUI(document.querySelector('input[name="attendance_method"]:checked').value);
        });
    </script>
@endpush

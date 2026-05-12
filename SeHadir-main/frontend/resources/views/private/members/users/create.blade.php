@extends('layouts.app')

@section('title', 'Create Member')

@section('content')
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 py-6 mt-6 sm:mt-10">
        <div class="mb-8 text-center sm:text-left">
            <h1
                class="text-3xl sm:text-4xl font-extrabold tracking-tight bg-linear-to-r from-gray-900 to-gray-600 dark:from-white dark:to-gray-300 bg-clip-text text-transparent">
                Tambah Member Baru Sekolah
            </h1>
            <p class="text-gray-500 dark:text-gray-400 mt-1 flex items-center justify-center sm:justify-start gap-2">
                <i class="fa-solid fa-user-plus text-primary-500"></i>
                Tambahkan data member baru ke dalam sistem
            </p>
        </div>

        <div class="max-w-5xl mx-auto">
            <form action="{{ route('admin.siswa.store') }}" method="POST" enctype="multipart/form-data" class="space-y-8">
                <input type="hidden" id="existing_photo" name="existing_photo" value="">

                <!-- Card Form Modern dengan Glassmorphism -->
                <div
                    class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 overflow-hidden">
                    <div class="p-6 sm:p-8">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                            <!-- Kolom Kiri (sama seperti sebelumnya) -->
                            <div class="space-y-6">
                                <!-- No Induk -->
                                <div>
                                    <label for="no_induk"
                                        class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1 required-field">
                                        No Induk <span class="text-red-500">*</span>
                                    </label>
                                    <input type="text" id="no_induk" name="no_induk" placeholder="Masukkan No Induk"
                                        class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200 @error('no_induk') border-red-500 @enderror"
                                        required value="{{ old('no_induk') }}" />
                                    @error('no_induk')
                                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                    @enderror
                                </div>

                                <!-- Nama Lengkap -->
                                <div>
                                    <label for="name"
                                        class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1 required-field">
                                        Nama Lengkap <span class="text-red-500">*</span>
                                    </label>
                                    <input type="text" id="name" name="name" placeholder="Masukkan nama lengkap"
                                        class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200 @error('name') border-red-500 @enderror"
                                        required value="{{ old('name') }}" />
                                    @error('name')
                                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                    @enderror
                                </div>

                                <!-- Kelas -->
                                <div>
                                    <label for="kelas"
                                        class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1 required-field">
                                        Kelas <span class="text-red-500">*</span>
                                    </label>
                                    <select id="kelas" name="kelas"
                                        class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200 cursor-pointer @error('kelas') border-red-500 @enderror"
                                        required>
                                        <option value="" disabled selected>Pilih kelas</option>
                                        @foreach ($dataKelas as $kelasOption)
                                            <option value="{{ $kelasOption->id }}"
                                                {{ old('kelas') == $kelasOption->id ? 'selected' : '' }}>
                                                {{ $kelasOption->name }}
                                            </option>
                                        @endforeach
                                    </select>
                                    @error('kelas')
                                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                    @enderror
                                </div>

                                <!-- Alamat -->
                                <div>
                                    <label for="alamat"
                                        class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1 required-field">
                                        Alamat
                                    </label>
                                    <textarea name="alamat" id="alamat" rows="4"
                                        class="w-full px-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all duration-200 @error('alamat') border-red-500 @enderror"
                                        placeholder="Masukkan alamat rumah">{{ old('alamat') }}</textarea>
                                    @error('alamat')
                                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                    @enderror
                                </div>
                            </div>

                            <!-- Kolom Kanan: Upload Foto -->
                            <div class="space-y-4">
                                <label
                                    class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1 required-field">
                                    Foto <span class="text-red-500">*</span>
                                </label>
                                <div class="relative">
                                    <div id="photo-container"
                                        class="relative border-2 border-dashed rounded-2xl transition-all duration-300 p-4
                                        @error('photo') border-red-500 @else border-gray-300 dark:border-gray-600 @enderror
                                        hover:border-primary-500 dark:hover:border-primary-500 group inline-block w-full">

                                        <!-- Placeholder Upload -->
                                        <div id="upload-placeholder"
                                            class="flex flex-col items-center justify-center cursor-pointer">
                                            <div
                                                class="w-16 h-16 bg-gray-100 dark:bg-gray-700 rounded-full flex items-center justify-center mb-3 shadow-inner">
                                                <i
                                                    class="fa-solid fa-cloud-arrow-up text-2xl text-gray-400 dark:text-gray-500"></i>
                                            </div>
                                            <input type="file" id="photo-upload" name="photo" class="hidden"
                                                accept="image/png, image/jpeg">

                                            <button type="button" onclick="openPhotoBrowser()"
                                                class="px-4 py-1.5 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white text-sm font-medium rounded-lg shadow-md transition-all duration-300 hover:scale-105">
                                                Pilih Foto
                                            </button>
                                        </div>

                                        <!-- Preview Image  -->
                                        <div id="photo-preview-container" class="hidden relative w-36 mx-auto">
                                            <img id="photo-preview" src="/placeholder.svg" alt="Preview"
                                                class="w-full h-full object-cover rounded-xl cursor-pointer aspect-3/4"
                                                onclick="openPhotoBrowser()" />
                                            <button type="button" id="remove-photo"
                                                class="absolute top-1 right-1 bg-black/60 hover:bg-black/80 text-white p-1 rounded-full backdrop-blur-sm transition-all duration-200">
                                                <i class="fa-solid fa-xmark text-xs"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <span id="current_photo_name"
                                        class="text-sm text-gray-500 dark:text-gray-400 mt-2 inline-block">No photo
                                        selected</span>
                                    @error('photo')
                                        <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                                    @enderror
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Tombol Aksi -->
                    <div
                        class="px-6 sm:px-8 py-5 bg-gray-50/80 dark:bg-gray-800/50 border-t border-gray-100 dark:border-gray-700 flex flex-col sm:flex-row justify-end gap-3">
                        <a href="{{ route('admin.siswa.index') }}"
                            class="inline-flex justify-center items-center px-5 py-2.5 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 transition-all duration-200 hover:scale-105">
                            <i class="fa-regular fa-circle-xmark mr-2"></i> Batal
                        </a>
                        <button type="submit"
                            class="inline-flex justify-center items-center px-6 py-2.5 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold rounded-xl shadow-md transition-all duration-300 hover:scale-105 active:scale-95">
                            <i class="fa-regular fa-floppy-disk mr-2"></i> Simpan
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Browser Foto Modern (sama seperti sebelumnya) -->
    <div id="photoBrowserModal" class="fixed inset-0 z-50 hidden overflow-y-auto backdrop-blur-md">
        <div class="fixed inset-0 bg-gray-900/60 transition-opacity"></div>
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
            <div
                class="relative transform overflow-hidden rounded-2xl bg-white dark:bg-gray-800 text-left shadow-2xl transition-all sm:my-8 sm:w-full sm:max-w-3xl w-full">
                <div class="bg-linear-to-r from-primary-600 to-primary-700 px-6 py-4">
                    <div class="flex items-center justify-between">
                        <h3 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fa-regular fa-images"></i> Browse Photos
                        </h3>
                        <button onclick="closePhotoBrowser()"
                            class="text-white/80 hover:text-white transition-transform hover:rotate-90">
                            <i class="fa-solid fa-times text-xl"></i>
                        </button>
                    </div>
                </div>
                <div class="p-6">
                    <!-- Search Bar -->
                    <div class="mb-5">
                        <div class="relative">
                            <i
                                class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
                            <input type="text" id="photo-search" placeholder="Cari foto..."
                                class="w-full pl-11 pr-4 py-2.5 rounded-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                        </div>
                    </div>

                    <!-- Loading -->
                    <div id="photos-loading" class="py-12 text-center">
                        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                        <p class="mt-2 text-gray-600 dark:text-gray-400">Memuat foto...</p>
                    </div>

                    <!-- Grid Foto -->
                    <div id="photos-container"
                        class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-5 max-h-[60vh] overflow-y-auto p-1 hidden custom-scrollbar">
                    </div>

                    <!-- No Photos -->
                    <div id="no-photos" class="py-12 text-center hidden">
                        <i class="fa-regular fa-folder-open text-5xl text-gray-400 mb-3 block"></i>
                        <p class="text-gray-600 dark:text-gray-400">Tidak ada foto ditemukan</p>
                    </div>
                </div>
                <div
                    class="px-6 py-4 bg-gray-50 dark:bg-gray-800/50 border-t border-gray-100 dark:border-gray-700 flex justify-end">
                    <button onclick="closePhotoBrowser()"
                        class="px-5 py-2.5 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600 transition">
                        Tutup
                    </button>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        // ==================== LOGIKA UPLOAD FOTO & PREVIEW (SAMA, TIDAK BERUBAH) ====================
        const photoUpload = document.getElementById('photo-upload');
        const uploadPlaceholder = document.getElementById('upload-placeholder');
        const photoPreviewContainer = document.getElementById('photo-preview-container');
        const photoPreview = document.getElementById('photo-preview');
        const removePhotoBtn = document.getElementById('remove-photo');
        const currentPhotoName = document.getElementById('current_photo_name');

        if (photoUpload) {
            photoUpload.addEventListener('change', function(e) {
                if (e.target.files && e.target.files[0]) {
                    const file = e.target.files[0];
                    const maxSize = 2 * 1024 * 1024;
                    if (file.size > maxSize) {
                        alert('Ukuran file tidak boleh lebih dari 2 MiB');
                        photoUpload.value = '';
                        return;
                    }
                    if (!file.type.match('image/jpeg') && !file.type.match('image/png')) {
                        alert('Hanya file JPG dan PNG yang diperbolehkan');
                        photoUpload.value = '';
                        return;
                    }
                    const reader = new FileReader();
                    reader.onload = function(event) {
                        photoPreview.src = event.target.result;
                        uploadPlaceholder.classList.add('hidden');
                        photoPreviewContainer.classList.remove('hidden');
                        if (currentPhotoName) {
                            currentPhotoName.textContent = file.name;
                        }
                        const existingPhoto = document.getElementById('existing_photo');
                        if (existingPhoto) {
                            existingPhoto.value = '';
                        }
                    }
                    reader.readAsDataURL(file);
                }
            });
        }

        if (removePhotoBtn) {
            removePhotoBtn.addEventListener('click', function() {
                if (photoUpload) photoUpload.value = '';
                if (photoPreview) photoPreview.src = '';
                if (photoPreviewContainer) photoPreviewContainer.classList.add('hidden');
                if (uploadPlaceholder) uploadPlaceholder.classList.remove('hidden');
                if (currentPhotoName) currentPhotoName.textContent = 'No photo selected';
                const existingPhoto = document.getElementById('existing_photo');
                if (existingPhoto) {
                    existingPhoto.value = '';
                }
            });
        }

        const photoBrowserModal = document.getElementById('photoBrowserModal');
        const photosContainer = document.getElementById('photos-container');
        const photosLoading = document.getElementById('photos-loading');
        const noPhotos = document.getElementById('no-photos');
        const photoSearch = document.getElementById('photo-search');
        const browsePhotosBtn = document.getElementById('browse-photos-btn');
        let allPhotos = [];

        if (browsePhotosBtn) {
            browsePhotosBtn.addEventListener('click', function() {
                openPhotoBrowser();
            });
        }

        function openPhotoBrowser() {
            if (photoBrowserModal) {
                photoBrowserModal.classList.remove('hidden');
                document.body.classList.add('overflow-hidden');
                loadPhotos();
            }
        }

        function closePhotoBrowser() {
            if (photoBrowserModal) {
                photoBrowserModal.classList.add('hidden');
                document.body.classList.remove('overflow-hidden');
            }
        }

        function loadPhotos() {
            if (photosContainer) photosContainer.classList.add('hidden');
            if (photosLoading) photosLoading.classList.remove('hidden');
            if (noPhotos) noPhotos.classList.add('hidden');

            fetch('{{ route('admin.siswa.photos') }}')
                .then(response => response.json())
                .then(data => {
                    allPhotos = data;
                    renderPhotos(data);
                    if (photosLoading) photosLoading.classList.add('hidden');
                    if (data.length === 0) {
                        if (noPhotos) noPhotos.classList.remove('hidden');
                    } else {
                        if (photosContainer) photosContainer.classList.remove('hidden');
                    }
                })
                .catch(error => {
                    console.error('Error loading photos:', error);
                    if (photosLoading) photosLoading.classList.add('hidden');
                    if (noPhotos) noPhotos.classList.remove('hidden');
                });
        }

        function renderPhotos(photos) {
            if (!photosContainer) return;
            photosContainer.innerHTML = '';
            photos.forEach(photo => {
                const photoElement = document.createElement('div');
                photoElement.className =
                    'border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden cursor-pointer hover:border-primary-500 dark:hover:border-primary-500 transition-all duration-200 hover:shadow-md';
                photoElement.innerHTML = `
                <div class="aspect-[3/4] relative">
                    <img src="${photo.url}" alt="${photo.name}" loading="lazy" class="w-full h-full object-cover">
                </div>
                <div class="p-2 text-xs truncate bg-white/50 dark:bg-gray-800/50" title="${photo.name}">${photo.name}</div>
                <div class="px-2 pb-2 text-xs text-gray-500 dark:text-gray-400">${photo.size}</div>
            `;
                photoElement.addEventListener('click', function() {
                    selectPhoto(photo);
                });
                photosContainer.appendChild(photoElement);
            });
        }

        function selectPhoto(photo) {
            if (photoPreview) photoPreview.src = photo.url;
            if (photoPreviewContainer) photoPreviewContainer.classList.remove('hidden');
            if (uploadPlaceholder) uploadPlaceholder.classList.add('hidden');
            const existingPhoto = document.getElementById('existing_photo');
            if (existingPhoto) {
                existingPhoto.value = photo.name;
            }
            if (currentPhotoName) {
                currentPhotoName.textContent = photo.name + ' (selected from library)';
            }
            if (photoUpload) {
                photoUpload.value = '';
            }
            closePhotoBrowser();
        }

        if (photoSearch) {
            photoSearch.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                if (searchTerm === '') {
                    renderPhotos(allPhotos);
                } else {
                    const filteredPhotos = allPhotos.filter(photo => photo.name.toLowerCase().includes(searchTerm));
                    renderPhotos(filteredPhotos);
                    if (filteredPhotos.length === 0) {
                        if (noPhotos) noPhotos.classList.remove('hidden');
                    } else {
                        if (noPhotos) noPhotos.classList.add('hidden');
                    }
                }
            });
        }

        window.addEventListener('click', function(event) {
            if (event.target === photoBrowserModal) {
                closePhotoBrowser();
            }
        });
    </script>
@endpush

@push('styles')
    <style>
        .custom-scrollbar::-webkit-scrollbar {
            width: 5px;
            height: 5px;
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

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .bg-white\/80 {
            animation: fadeInUp 0.4s ease-out forwards;
        }
    </style>
@endpush

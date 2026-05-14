@extends('private.members.app')

@section('title', 'Manage Photos')

@section('content-siswa')
    <div id="data-siswa" class="tab-content">
        <div
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 p-5 mb-8 transition-all duration-300">
            <div class="flex flex-col md:flex-row justify-between gap-4">
                <div class="flex flex-1">
                    <div class="relative flex-1">
                        <i
                            class="fa-solid fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-500 text-sm"></i>
                        <input type="text" id="search-input" placeholder="Cari file foto..."
                            class="w-full pl-10 pr-4 py-3 rounded-l-xl border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
                    </div>
                    <button type="button" id="search-button"
                        class="px-6 py-3 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold rounded-r-xl shadow-md transition-all duration-300 hover:scale-[1.02]">
                        Cari
                    </button>
                </div>

                <div class="flex gap-3">
                    <button type="button" onclick="openUploadModal()"
                        class="group flex items-center gap-2 px-6 py-3 bg-linear-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 rounded-xl shadow-md transition-all duration-300 hover:scale-105 text-white font-semibold">
                        <i class="fa-solid fa-upload"></i>
                        <span>Upload Foto</span>
                    </button>
                </div>
            </div>
        </div>

        <!-- Photo Grid Modern -->
        <div id="photo-grid"
            class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-5 mb-6">
            @foreach ($photos as $index => $photo)
                <div class="photo-card group bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl overflow-hidden shadow-md hover:shadow-2xl transition-all duration-300 hover:-translate-y-2 border border-gray-100 dark:border-gray-700"
                    data-filename="{{ $photo->name }}">
                    <!-- Nomor urut badge -->
                    <div
                        class="absolute top-3 left-3 z-10 bg-primary-600/90 backdrop-blur-sm text-white text-xs font-bold px-2.5 py-1 rounded-full shadow-md">
                        {{ $index + 1 }}
                    </div>

                    <div class="aspect-3/4 w-full overflow-hidden bg-gray-100 dark:bg-gray-700">
                        <img src="{{ $photo->url }}" loading="lazy" alt="{{ $photo->name }}"
                            class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                            onerror="this.src='{{ asset('src/file-not-found.jpg') }}'; this.onerror=null;">
                    </div>
                    
                    <div class="px-3 pt-2 pb-1 bg-white/50 dark:bg-gray-800/50">
                        <p class="text-xs text-gray-600 dark:text-gray-300 truncate font-mono" title="{{ $photo->name }}">
                            {{ $photo->name }}
                        </p>
                    </div>
                    
                    <div class="flex gap-2 p-3 bg-white dark:bg-gray-800">
                        <button type="button" onclick="copyFilename('{{ $photo->name }}')" title="Copy Filename"
                            class="flex-1 flex items-center justify-center gap-1 py-2 rounded-xl bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 transition-all duration-200">
                            <i class="fa-regular fa-copy text-sm"></i>
                            <span class="text-xs font-medium hidden sm:inline">Salin</span>
                        </button>

                        <button type="button" onclick="confirmDelete('{{ $photo->name }}', '{{ $photo->url }}')" title="Delete File"
                            class="flex-1 flex items-center justify-center gap-1 py-2 rounded-xl bg-red-50 hover:bg-red-100 dark:bg-red-900/30 dark:hover:bg-red-900/50 text-red-600 dark:text-red-400 transition-all duration-200">
                            <i class="fa-regular fa-trash-can text-sm"></i>
                            <span class="text-xs font-medium hidden sm:inline">Hapus</span>
                        </button>
                    </div>
                </div>
            @endforeach
        </div>

        <!-- Empty State Modern -->
        <div id="empty-state"
            class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 p-12 text-center mb-6 {{ count($photos) > 0 ? 'hidden' : '' }}">
            <div
                class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-linear-to-br from-gray-100 to-gray-200 dark:from-gray-700 dark:to-gray-600 mb-5">
                <i class="fa-regular fa-image text-3xl text-gray-500 dark:text-gray-400"></i>
            </div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">Tidak ada foto</h3>
            <p class="text-gray-500 dark:text-gray-400 mb-6">Belum ada file foto di direktori storage/profile.</p>
            <button onclick="openUploadModal()"
                class="inline-flex items-center gap-2 px-5 py-2.5 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white font-semibold rounded-xl shadow-md transition-all duration-300 hover:scale-105">
                <i class="fa-solid fa-upload"></i> Upload Foto
            </button>
        </div>
    </div>

    <!-- Upload Photo Modal Modern -->
    <div id="uploadModal" class="fixed inset-0 z-50 hidden overflow-hidden">
        <div class="fixed inset-0 bg-gray-900/70 backdrop-blur-md transition-opacity"></div>

        <div class="relative h-full overflow-y-auto">
            <div class="flex items-center justify-center min-h-full px-4 pt-4 pb-20 text-center sm:block sm:p-0">
                <div
                    class="inline-block w-full max-w-md p-6 my-8 overflow-hidden text-left align-middle transition-all transform bg-white dark:bg-gray-800 rounded-2xl shadow-2xl border border-gray-200 dark:border-gray-700">
                    <div class="flex items-center justify-between mb-5">
                        <h3 class="text-xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                            <i class="fa-solid fa-cloud-upload-alt text-primary-500"></i> Upload Foto
                        </h3>
                        <button onclick="closeUploadModal()"
                            class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition">
                            <i class="fa-solid fa-times text-xl"></i>
                        </button>
                    </div>

                    <div class="mb-5">
                        <form id="uploadForm" action="{{ route('admin.photos.upload') }}" method="POST"
                            enctype="multipart/form-data" class="space-y-5">
                            @csrf
                            <div>
                                <label class="block mb-2 text-sm font-semibold text-gray-700 dark:text-gray-300">File Foto
                                    <span class="text-red-500">*</span></label>
                                <div id="photo-drop-area"
                                    class="flex flex-col items-center justify-center w-full h-36 border-2 border-dashed rounded-xl cursor-pointer transition-all bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-100 dark:hover:bg-gray-700 border-gray-300 dark:border-gray-600">
                                    <div class="text-center">
                                        <i class="fa-regular fa-images text-4xl text-gray-400 mb-2 block"></i>
                                        <p class="text-sm text-gray-500"><span class="font-semibold">Klik atau seret
                                                foto</span><br>JPG, PNG (Max 2MiB per file)</p>
                                    </div>
                                    <input type="file" name="photo_files[]" id="photo_files" accept=".jpg,.jpeg,.png"
                                        class="hidden" multiple>
                                </div>
                                <div id="selectedFiles"
                                    class="hidden mt-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-200 dark:border-gray-600">
                                    <p class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">File terpilih:
                                        <span id="fileCount">0</span></p>
                                    <ul id="fileList"
                                        class="text-xs text-gray-600 dark:text-gray-400 space-y-1 max-h-32 overflow-y-auto">
                                    </ul>
                                </div>
                            </div>

                            <div class="flex justify-end gap-3 pt-2">
                                <button type="button" onclick="closeUploadModal()"
                                    class="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-xl hover:bg-gray-100 transition">Batal</button>

                                <button type="submit" id="submitUpload"
                                    class="px-6 py-2.5 text-sm font-medium text-white bg-linear-to-r from-primary-600 to-primary-700 rounded-xl shadow-md hover:shadow-lg transition disabled:opacity-50"
                                    disabled>
                                    <i class="fa-solid fa-upload mr-2"></i> Upload
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('styles')
    <style>
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

        @keyframes fadeOut {
            from {
                opacity: 1;
            }

            to {
                opacity: 0;
            }
        }

        .animate-fade-in-up {
            animation: fadeInUp 0.3s ease-out forwards;
        }

        .animate-fade-out {
            animation: fadeOut 0.3s ease-out forwards;
        }

        .aspect-3\/4 {
            aspect-ratio: 3 / 4;
        }
    </style>
@endpush

@push('scripts')
    <script>
        document.getElementById('uploadForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const form = e.target;
            const formData = new FormData(form);
            const submitBtn = document.getElementById('submitUpload');
            const originalText = submitBtn.innerHTML;
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-2"></i> Mengupload...';

            try {
                const response = await fetch(form.action, {
                    method: 'POST',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest',
                        'X-CSRF-TOKEN': document.querySelector('input[name="_token"]').value
                    },
                    body: formData
                });

                const result = await response.json();

                if (result.success) {
                    Swal.mixin({
                        toast: true,
                        position: "top-end",
                        showConfirmButton: false,
                        timer: 3000,
                        timerProgressBar: true,
                        didOpen: (toast) => {
                            toast.onmouseenter = Swal.stopTimer;
                            toast.onmouseleave = Swal.resumeTimer;
                        },
                        didClose: () => {
                            closeUploadModal();
                            location.reload();
                        }
                    }).fire({
                        icon: "success",
                        title: "Foto berhasil diupload"
                    });
                } else {
                    Swal.mixin({
                        toast: true,
                        position: "top-end",
                        showConfirmButton: false,
                        timer: 3000,
                        timerProgressBar: true
                    }).fire({
                        icon: "error",
                        title: result.message || "Gagal upload"
                    });
                }
            } catch (error) {
                Swal.mixin({
                    toast: true,
                    position: "top-end",
                    showConfirmButton: false,
                    timer: 3000,
                    timerProgressBar: true,
                    didClose: () => location.reload()
                }).fire({
                    icon: "error",
                    title: error.message || "Terjadi kesalahan"
                });
            } finally {
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalText;
            }
        });

        const searchInput = document.getElementById('search-input');
        const searchButton = document.getElementById('search-button');
        const photoGrid = document.getElementById('photo-grid');
        const emptyState = document.getElementById('empty-state');
        const photoCards = document.querySelectorAll('.photo-card');
        const uploadModal = document.getElementById('uploadModal');
        const photoDropArea = document.getElementById('photo-drop-area');
        const photoFilesInput = document.getElementById('photo_files');
        const selectedFiles = document.getElementById('selectedFiles');
        const fileCount = document.getElementById('fileCount');
        const fileList = document.getElementById('fileList');
        const submitUpload = document.getElementById('submitUpload');

        function filterPhotos() {
            const searchTerm = searchInput.value.toLowerCase();
            let visibleCount = 0;
            photoCards.forEach(card => {
                const filename = card.dataset.filename.toLowerCase();
                if (filename.includes(searchTerm)) {
                    card.classList.remove('hidden');
                    visibleCount++;
                } else {
                    card.classList.add('hidden');
                }
            });
            emptyState.classList.toggle('hidden', visibleCount > 0);
        }

        searchButton.addEventListener('click', filterPhotos);
        searchInput.addEventListener('keyup', e => {
            if (e.key === 'Enter') filterPhotos();
        });

        function copyFilename(filename) {
            navigator.clipboard.writeText(filename).then(() => {
                const toast = document.createElement('div');
                toast.className =
                    'fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-fade-in-up text-sm';
                toast.innerHTML = `<i class="fa-regular fa-copy mr-2"></i> Nama file disalin: ${filename}`;
                document.body.appendChild(toast);
                setTimeout(() => {
                    toast.classList.add('animate-fade-out');
                    setTimeout(() => toast.remove(), 300);
                }, 3000);
            }).catch(() => alert('Gagal menyalin nama file'));
        }

        function confirmDelete(filename) {
            Swal.fire({
                title: "Hapus Foto?",
                text: `Yakin ingin menghapus "${filename}"?`,
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#d33",
                cancelButtonColor: "#3085d6",
                confirmButtonText: "Ya, hapus!",
                cancelButtonText: "Batal"
            }).then((result) => {
                if (result.isConfirmed) {
                    fetch('{{ route('admin.photos.delete') }}', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': '{{ csrf_token() }}'
                            },
                            body: JSON.stringify({
                                filename: filename
                            })
                        })
                        .then(res => res.json())
                        .then(data => {
                            if (data.success) {
                                const card = document.querySelector(`.photo-card[data-filename="${filename}"]`);
                                if (card) card.remove();
                                const toast = document.createElement('div');
                                toast.className =
                                    'fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg z-50 animate-fade-in-up';
                                toast.innerHTML =
                                    `<i class="fa-regular fa-trash-can mr-2"></i> File berhasil dihapus: ${filename}`;
                                document.body.appendChild(toast);
                                setTimeout(() => {
                                    toast.classList.add('animate-fade-out');
                                    setTimeout(() => toast.remove(), 300);
                                }, 3000);
                                if (document.querySelectorAll('.photo-card').length === 0) emptyState.classList
                                    .remove('hidden');
                            } else {
                                Swal.fire("Error!", "Gagal menghapus file: " + data.message, "error");
                            }
                        })
                        .catch(error => Swal.fire("Error!", "Terjadi kesalahan", "error"));
                }
            });
        }

        function openUploadModal() {
            uploadModal.classList.remove('hidden');
            document.body.classList.add('overflow-hidden');
        }

        function closeUploadModal() {
            uploadModal.classList.add('hidden');
            document.body.classList.remove('overflow-hidden');
            resetUploadForm();
        }

        function resetUploadForm() {
            document.getElementById('uploadForm').reset();
            selectedFiles.classList.add('hidden');
            fileList.innerHTML = '';
            fileCount.textContent = '0';
            submitUpload.disabled = true;
        }

        photoFilesInput.addEventListener('change', () => handleFileSelection(photoFilesInput.files));

        function handleFileSelection(files) {
            if (files && files.length > 0) {
                selectedFiles.classList.remove('hidden');
                fileCount.textContent = files.length;
                fileList.innerHTML = '';
                let validFiles = true;
                const maxSize = 2 * 1024 * 1024;
                for (let i = 0; i < files.length; i++) {
                    const file = files[i];
                    const li = document.createElement('li');
                    if (file.size > maxSize) {
                        li.className = 'text-red-500';
                        li.textContent = `${file.name} (${formatFileSize(file.size)}) - Terlalu besar`;
                        validFiles = false;
                    } else {
                        li.textContent = `${file.name} (${formatFileSize(file.size)})`;
                    }
                    fileList.appendChild(li);
                }
                submitUpload.disabled = !validFiles || files.length === 0;
            } else {
                selectedFiles.classList.add('hidden');
                submitUpload.disabled = true;
            }
        }

        function formatFileSize(bytes) {
            if (bytes < 1024) return bytes + ' B';
            else if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
            else return (bytes / 1048576).toFixed(1) + ' MB';
        }

        photoDropArea.addEventListener('click', () => photoFilesInput.click());
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(ev => {
            photoDropArea.addEventListener(ev, preventDefaults);
            document.body.addEventListener(ev, preventDefaults);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }
        ['dragenter', 'dragover'].forEach(ev => photoDropArea.addEventListener(ev, () => photoDropArea.classList.add(
            'border-primary-500', 'bg-primary-50', 'dark:bg-primary-900/20')));
        ['dragleave', 'drop'].forEach(ev => photoDropArea.addEventListener(ev, () => photoDropArea.classList.remove(
            'border-primary-500', 'bg-primary-50', 'dark:bg-primary-900/20')));
        photoDropArea.addEventListener('drop', e => {
            const files = e.dataTransfer.files;
            photoFilesInput.files = files;
            handleFileSelection(files);
        });
        window.addEventListener('click', e => {
            if (e.target === uploadModal) closeUploadModal();
        });
    </script>
@endpush

@extends('layouts.app')

@section('title', 'Manage Faces')

@section('content')
    <div class="min-h-screen bg-linear-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 py-6 sm:py-10">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <!-- Header with Back Button -->
            <div class="mb-6 sm:mb-8">
                <div class="flex flex-wrap items-center gap-3">
                    <div>
                        <h1
                            class="text-2xl sm:text-3xl font-extrabold bg-linear-to-r from-primary-600 to-primary-800 dark:from-primary-400 dark:to-primary-600 bg-clip-text text-transparent">
                            <i class="fas fa-user-plus mr-2 text-primary-600 dark:text-primary-400"></i>Daftar Face ID
                        </h1>
                        <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                            Daftarkan wajah siswa untuk menggunakan Face ID dalam sistem absensi
                        </p>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 lg:gap-8">
                <!-- Main Registration Card -->
                <div class="lg:col-span-2">
                    <div
                        class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 overflow-hidden transition-all duration-300">
                        <div class="bg-linear-to-r from-primary-600 to-primary-700 px-6 py-4">
                            <h2 class="text-xl font-bold text-white flex items-center gap-2">
                                <i class="fas fa-camera"></i> Registrasi Wajah
                            </h2>
                        </div>

                        <div class="p-5 sm:p-6 space-y-6">
                            <!-- Select Student -->
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                    Pilih Akun Siswa
                                </label>
                                <button id="studentSelectBtn" type="button"
                                    class="w-full px-4 py-3 bg-white dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-xl shadow-sm text-left flex items-center justify-between hover:border-primary-400 transition-all">
                                    <span id="selectedStudentText" class="text-gray-700 dark:text-gray-300">-- Pilih Siswa
                                        --</span>
                                    <i class="fas fa-chevron-down text-gray-400"></i>
                                </button>
                                <input type="hidden" id="selectedStudentID" value="">
                            </div>

                            <!-- Camera & Capture Area -->
                            <div class="relative bg-gray-900 rounded-2xl overflow-hidden shadow-2xl mx-auto"
                                style="max-width: 500px; aspect-ratio: 4/3;">
                                <video id="video" autoplay muted playsinline class="w-full h-full object-cover"></video>
                                <canvas id="canvas" class="hidden"></canvas>

                                <!-- Face Overlay Ring -->
                                <div id="faceOverlay"
                                    class="absolute inset-0 pointer-events-none flex items-center justify-center">
                                    <div id="faceRing" class="relative w-64 h-80 sm:w-72 sm:h-96">
                                        <svg class="absolute inset-0 w-full h-full" viewBox="0 0 280 350">
                                            <ellipse cx="140" cy="175" rx="130" ry="165"
                                                fill="none" stroke="#10b981" stroke-width="3" stroke-dasharray="10,5"
                                                opacity="0.8" id="ringStroke" />
                                        </svg>
                                        <!-- Corner brackets -->
                                        <div
                                            class="absolute top-0 left-0 w-6 h-6 border-t-3 border-l-3 border-green-500 rounded-tl-lg">
                                        </div>
                                        <div
                                            class="absolute top-0 right-0 w-6 h-6 border-t-3 border-r-3 border-green-500 rounded-tr-lg">
                                        </div>
                                        <div
                                            class="absolute bottom-0 left-0 w-6 h-6 border-b-3 border-l-3 border-green-500 rounded-bl-lg">
                                        </div>
                                        <div
                                            class="absolute bottom-0 right-0 w-6 h-6 border-b-3 border-r-3 border-green-500 rounded-br-lg">
                                        </div>
                                    </div>
                                </div>

                                <!-- Photo Progress Indicator -->
                                <div id="photoProgress" class="absolute top-3 left-3 hidden">
                                    <div
                                        class="bg-black/70 backdrop-blur-sm text-white px-3 py-2 rounded-xl text-xs font-medium">
                                        <div id="currentPhotoIndicator">Foto 1 dari 4</div>
                                        <div class="flex gap-1 mt-1">
                                            <div id="progress1" class="w-2 h-1 bg-gray-400 rounded-full"></div>
                                            <div id="progress2" class="w-2 h-1 bg-gray-400 rounded-full"></div>
                                            <div id="progress3" class="w-2 h-1 bg-gray-400 rounded-full"></div>
                                            <div id="progress4" class="w-2 h-1 bg-gray-400 rounded-full"></div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Capture Instructions -->
                                <div id="captureInstructions" class="absolute bottom-3 left-3 right-3 hidden">
                                    <div
                                        class="bg-green-500/90 backdrop-blur-sm text-white px-4 py-2 rounded-xl text-center text-sm font-medium">
                                        <i class="fas fa-camera mr-1"></i> Deteksi Otomatis Aktif
                                        <div id="captureStatus" class="text-xs mt-1">Foto: 0/4</div>
                                        <div id="captureMessage" class="text-xs opacity-90">Menunggu wajah...</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="flex flex-col sm:flex-row gap-3">
                                <button id="startCamera"
                                    class="flex-1 bg-linear-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold py-3 px-6 rounded-xl shadow-md transition-all duration-300 hover:scale-[1.02] flex items-center justify-center gap-2"
                                    disabled>
                                    <i class="fas fa-camera"></i> Mulai Registrasi Wajah
                                </button>
                                <button id="stopCamera"
                                    class="flex-1 bg-linear-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-semibold py-3 px-6 rounded-xl shadow-md transition-all duration-300 hover:scale-[1.02] hidden items-center justify-center gap-2">
                                    <i class="fas fa-stop"></i> Stop Kamera
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Preview Sidebar -->
                <div class="lg:col-span-1">
                    <div
                        class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm rounded-2xl shadow-xl border border-gray-100 dark:border-gray-700 overflow-hidden sticky top-6">
                        <div class="bg-linear-to-r from-green-600 to-teal-600 px-5 py-3">
                            <h3 class="text-sm font-bold text-white flex items-center gap-2">
                                <i class="fas fa-images"></i> Preview Foto (4x)
                            </h3>
                        </div>
                        <div class="p-4">
                            <div id="photoPreview" class="grid grid-cols-2 gap-3">
                                @for ($i = 0; $i < 4; $i++)
                                    <div
                                        class="aspect-square bg-gray-100 dark:bg-gray-700 rounded-xl flex items-center justify-center text-xs shadow-inner">
                                        <i class="fas fa-camera text-gray-400 text-2xl"></i>
                                    </div>
                                @endfor
                            </div>
                            <p class="text-center text-xs text-gray-500 dark:text-gray-400 mt-3">
                                Foto akan muncul otomatis saat wajah terdeteksi
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Student Selection Modal Modern -->
    <div id="studentModal"
        class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4 transition-all">
        <div
            class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md max-h-[80vh] flex flex-col overflow-hidden">
            <div
                class="p-5 border-b border-gray-100 dark:border-gray-700 bg-linear-to-r from-primary-50 to-primary-100 dark:from-primary-900/30 dark:to-primary-800/30">
                <h3 class="text-lg font-bold text-gray-900 dark:text-white">Pilih Siswa</h3>
                <div class="mt-3">
                    <div class="relative">
                        <i class="fas fa-search absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i>
                        <input type="text" id="studentSearch" placeholder="Cari nama atau Nomor Induk..."
                            class="w-full pl-9 pr-3 py-2 border border-gray-200 dark:border-gray-600 rounded-xl bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-primary-500">
                    </div>
                </div>
            </div>
            <div class="flex-1 overflow-y-auto p-2">
                <div id="studentList" class="space-y-2">
                    @forelse ($students as $student)
                        <div class="student-item p-3 hover:bg-gray-50 dark:hover:bg-gray-700/50 rounded-xl cursor-pointer transition-all border border-transparent hover:border-primary-300"
                            data-id="{{ $student->id }}" data-name="{{ $student->name }}"
                            data-induk="{{ $student->nomor_induk }}">
                            <div class="flex items-center gap-3">
                                <div
                                    class="w-10 h-10 rounded-full bg-linear-to-br from-primary-100 to-primary-200 dark:from-gray-600 dark:to-gray-500 flex items-center justify-center overflow-hidden shadow-sm">
                                    @if (!empty($student->foto_profile))
                                        <img src="{{ $student->foto_profile }}" alt="{{ $student->name }}"
                                            class="w-full h-full object-cover">
                                    @else
                                        <i class="fas fa-user text-primary-600 dark:text-primary-300 text-lg"></i>
                                    @endif
                                </div>
                                <div class="flex-1">
                                    <div class="flex flex-wrap items-center justify-between gap-1">
                                        <span class="font-medium text-gray-900 dark:text-white">{{ $student->name }}</span>
                                        @if (isset($student->has_face_id) && $student->has_face_id)
                                            <span
                                                class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full flex items-center gap-1">
                                                <i class="fas fa-check-circle text-xs"></i> Terdaftar
                                            </span>
                                        @endif
                                    </div>
                                    <div class="text-xs text-gray-500 dark:text-gray-400">No. Induk:
                                        {{ $student->nomor_induk ?? '-' }}</div>
                                </div>
                            </div>
                        </div>
                    @empty
                        <div class="text-center py-8 text-gray-500">Tidak ada data siswa.</div>
                    @endforelse
                </div>
            </div>
            <div class="p-4 border-t border-gray-100 dark:border-gray-700">
                <button id="closeStudentModal"
                    class="w-full bg-gray-600 hover:bg-gray-700 text-white py-2.5 rounded-xl font-medium transition">Tutup</button>
            </div>
        </div>
    </div>
@endsection

@push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
    <script>
        class FaceRegistrationSystem {
            constructor() {
                this.video = document.getElementById('video');
                this.canvas = document.getElementById('canvas');
                this.ctx = this.canvas.getContext('2d');
                this.stream = null;
                this.isModelLoaded = false;
                this.detectionInterval = null;
                this.capturedPhotos = [];
                this.maxPhotos = 4;
                this.captureInProgress = false;
                this.lastCaptureTime = 0;
                this.captureDelay = 800;

                this.initializeElements();
                this.initializeSystem();
            }

            initializeElements() {
                this.startBtn = document.getElementById('startCamera');
                this.stopBtn = document.getElementById('stopCamera');
                this.photoPreview = document.getElementById('photoPreview');
                this.captureInstructions = document.getElementById('captureInstructions');
                this.captureStatus = document.getElementById('captureStatus');
                this.captureMessage = document.getElementById('captureMessage');
                this.ringStroke = document.getElementById('ringStroke');
                this.photoProgress = document.getElementById('photoProgress');

                if (this.startBtn) this.startBtn.addEventListener('click', () => this.startCamera());
                if (this.stopBtn) this.stopBtn.addEventListener('click', () => this.stopCamera());
            }

            async initializeSystem() {
                this.startBtn.disabled = true;
                this.startBtn.innerHTML = '<i class="fas fa-user-plus mr-2"></i>Pilih Siswa Terlebih Dahulu';
                this.loadModels();
            }

            async loadModels() {
                try {
                    if (typeof faceapi === 'undefined') {
                        this.isModelLoaded = false;
                        return;
                    }

                    const isWebGLAvailable = (() => {
                        try {
                            const canvas = document.createElement('canvas');
                            return !!(
                                window.WebGLRenderingContext &&
                                (canvas.getContext('webgl') || canvas.getContext('experimental-webgl'))
                            );
                        } catch (e) {
                            return false;
                        }
                    })();

                    if (isWebGLAvailable) {
                        try {
                            await faceapi.tf.setBackend('webgl');
                        } catch (err) {
                            await faceapi.tf.setBackend('cpu');
                        }
                    } else {
                        await faceapi.tf.setBackend('cpu');
                    }

                    await faceapi.tf.ready();

                    await faceapi.nets.tinyFaceDetector.loadFromUri(
                        'https://cdn.jsdelivr.net/npm/@vladmandic/face-api@latest/model'
                    );

                    this.isModelLoaded = true;

                } catch (error) {
                    this.isModelLoaded = false;
                }
            }

            async startCamera() {
                try {
                    const selectedStudentID = document.getElementById('selectedStudentID');
                    if (!selectedStudentID.value) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Peringatan',
                            text: 'Pilih akun siswa terlebih dahulu!',
                            confirmButtonText: 'OK'
                        });
                        return;
                    }
                    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                        throw new Error('Browser tidak mendukung akses kamera');
                    }
                    this.stream = await navigator.mediaDevices.getUserMedia({
                        video: {
                            width: 640,
                            height: 480,
                            facingMode: 'user'
                        }
                    });
                    this.video.srcObject = this.stream;
                    this.video.onloadedmetadata = () => {
                        this.canvas.width = this.video.videoWidth;
                        this.canvas.height = this.video.videoHeight;
                        this.startBtn.classList.add('hidden');
                        this.stopBtn.classList.remove('hidden');
                        this.captureInstructions.classList.remove('hidden');
                        if (this.photoProgress) this.photoProgress.classList.remove('hidden');
                        this.startAutoCapture();
                    };
                } catch (error) {
                    console.error('Error starting camera:', error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Gagal',
                        text: 'Gagal mengakses kamera. Pastikan browser mengizinkan akses.',
                        confirmButtonText: 'OK'
                    });
                }
            }

            startAutoCapture() {
                this.updateProgressIndicator();
                this.detectionInterval = setInterval(async () => {
                    await this.detectAndCapture();
                }, 200);
            }

            async detectAndCapture() {
                try {
                    if (this.captureInProgress || this.capturedPhotos.length >= this.maxPhotos) {
                        if (this.capturedPhotos.length >= this.maxPhotos) this.completeCapture();
                        return;
                    }
                    const now = Date.now();
                    if (now - this.lastCaptureTime < this.captureDelay) return;

                    let faceInPosition = false;
                    if (this.isModelLoaded && this.video.videoWidth > 0) {
                        const detection = await faceapi.detectSingleFace(this.video, new faceapi
                            .TinyFaceDetectorOptions());
                        if (detection) {
                            const box = detection.box;
                            const videoWidth = this.video.videoWidth;
                            const videoHeight = this.video.videoHeight;
                            const faceCenterX = box.x + box.width / 2;
                            const faceCenterY = box.y + box.height / 2;
                            const videoCenterX = videoWidth / 2;
                            const videoCenterY = videoHeight / 2;
                            const centerThresholdX = videoWidth * 0.25;
                            const centerThresholdY = videoHeight * 0.25;
                            const isCentered = Math.abs(faceCenterX - videoCenterX) < centerThresholdX &&
                                Math.abs(faceCenterY - videoCenterY) < centerThresholdY;
                            const minSize = videoHeight * 0.3;
                            const maxSize = videoHeight * 0.7;
                            const isGoodSize = box.height > minSize && box.height < maxSize;
                            faceInPosition = isCentered && isGoodSize;

                            if (faceInPosition) {
                                this.ringStroke.setAttribute('stroke', '#10b981');
                                this.captureMessage.textContent = '✅ Posisi sempurna! Mengambil foto...';
                                this.captureMessage.className = 'mt-2 text-sm text-green-600 font-bold';
                            } else if (isCentered) {
                                this.ringStroke.setAttribute('stroke', '#f59e0b');
                                this.captureMessage.textContent = isGoodSize ? 'Posisikan wajah lebih pas' :
                                    'Atur jarak kamera';
                                this.captureMessage.className = 'mt-2 text-sm text-orange-600';
                            } else {
                                this.ringStroke.setAttribute('stroke', '#ef4444');
                                this.captureMessage.textContent = 'Posisikan wajah di tengah ring';
                                this.captureMessage.className = 'mt-2 text-sm text-red-600';
                            }
                        } else {
                            this.ringStroke.setAttribute('stroke', '#6b7280');
                            this.captureMessage.textContent = 'Menunggu wajah terdeteksi...';
                            this.captureMessage.className = 'mt-2 text-sm text-gray-600';
                        }
                    } else {
                        faceInPosition = true;
                    }

                    if (faceInPosition) await this.capturePhoto();
                } catch (error) {
                    console.error('Detection error:', error);
                }
            }

            async capturePhoto() {
                if (this.captureInProgress || this.capturedPhotos.length >= this.maxPhotos) return;
                this.captureInProgress = true;
                this.lastCaptureTime = Date.now();
                try {
                    this.ctx.drawImage(this.video, 0, 0, this.canvas.width, this.canvas.height);
                    const imageData = this.canvas.toDataURL('image/jpeg', 0.9);
                    this.capturedPhotos.push({
                        imageData,
                        timestamp: Date.now()
                    });
                    this.updatePhotoPreview();
                    this.updateProgressIndicator();
                    if (this.captureStatus) this.captureStatus.textContent =
                        `Foto: ${this.capturedPhotos.length}/${this.maxPhotos}`;
                    this.ringStroke.setAttribute('opacity', '1');
                    setTimeout(() => this.ringStroke.setAttribute('opacity', '0.8'), 100);
                } catch (error) {
                    console.error('Capture error:', error);
                } finally {
                    this.captureInProgress = false;
                }
            }

            completeCapture() {
                if (this.detectionInterval) clearInterval(this.detectionInterval);
                this.detectionInterval = null;
                this.stopCamera();
                this.captureInstructions.classList.add('hidden');
                setTimeout(() => this.autoRegisterFace(), 1000);
            }

            async autoRegisterFace() {
                try {
                    const selectedStudentID = document.getElementById('selectedStudentID').value;
                    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
                    const faceData = this.capturedPhotos.map(photo => photo.imageData);

                    // Tampilkan loading SweetAlert
                    Swal.fire({
                        title: 'Menyimpan Data...',
                        text: 'Sedang memproses registrasi wajah, mohon tunggu.',
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    const response = await fetch('{{ url('/admin/face-id/register') }}', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': csrfToken,
                            'Accept': 'application/json'
                        },
                        body: JSON.stringify({
                            face_images: faceData,
                            student_id: selectedStudentID
                        })
                    });
                    const result = await response.json();

                    // Tutup loading SweetAlert
                    Swal.close();

                    if (result.success) {
                        await Swal.fire({
                            icon: 'success',
                            title: 'Registrasi Berhasil!',
                            text: result.message,
                            confirmButtonText: 'OK'
                        });
                        // Update badge di modal
                        const studentItems = document.querySelectorAll('.student-item');
                        studentItems.forEach(item => {
                            if (item.dataset.id == result.student_id) {
                                const nameDiv = item.querySelector('.font-medium');
                                if (nameDiv && !nameDiv.innerHTML.includes('Terdaftar')) {
                                    nameDiv.innerHTML +=
                                        ` <span class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full ml-1"><i class="fas fa-check-circle"></i> Terdaftar</span>`;
                                }
                            }
                        });
                        this.resetForNextRegistration();
                    } else {
                        await Swal.fire({
                            icon: 'error',
                            title: 'Registrasi Gagal',
                            text: result.message || 'Terjadi kesalahan saat menyimpan data.',
                            confirmButtonText: 'Coba Lagi'
                        });
                        // Reload halaman atau biarkan form tetap?
                        // Biarkan form agar bisa coba lagi tanpa reload
                        this.stopCamera();
                        this.capturedPhotos = [];
                        this.updatePhotoPreview();
                        this.updateProgressIndicator();
                        this.startBtn.classList.remove('hidden');
                        this.startBtn.disabled = false; // tetap aktif karena siswa sudah dipilih
                        this.stopBtn.classList.add('hidden');
                        if (this.photoProgress) this.photoProgress.classList.add('hidden');
                        this.captureInstructions.classList.add('hidden');
                        // Jangan reset selected student
                    }
                } catch (error) {
                    console.error('API Error:', error);
                    Swal.close();
                    await Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Terjadi kesalahan sistem saat mengirim data.',
                        confirmButtonText: 'OK'
                    });
                }
            }

            updatePhotoPreview() {
                const previewDivs = this.photoPreview.children;
                for (let i = 0; i < previewDivs.length; i++) {
                    if (i < this.capturedPhotos.length) {
                        previewDivs[i].innerHTML =
                            `<img src="${this.capturedPhotos[i].imageData}" class="w-full h-full object-cover rounded-xl" alt="Foto ${i+1}">`;
                    } else {
                        previewDivs[i].innerHTML =
                            `<div class="aspect-square bg-gray-100 dark:bg-gray-700 rounded-xl flex items-center justify-center"><i class="fas fa-camera text-gray-400 text-2xl"></i></div>`;
                    }
                }
            }

            updateProgressIndicator() {
                const capturedCount = this.capturedPhotos.length;
                const indicator = document.getElementById('currentPhotoIndicator');
                if (indicator) indicator.textContent = `Foto ${capturedCount + 1} dari ${this.maxPhotos}`;
                for (let i = 1; i <= this.maxPhotos; i++) {
                    const pb = document.getElementById(`progress${i}`);
                    if (pb) {
                        if (i <= capturedCount) pb.className = 'w-2 h-1 bg-green-500 rounded-full';
                        else if (i === capturedCount + 1) pb.className = 'w-2 h-1 bg-blue-500 rounded-full';
                        else pb.className = 'w-2 h-1 bg-gray-400 rounded-full';
                    }
                }
            }

            resetForNextRegistration() {
                this.stopCamera();
                this.capturedPhotos = [];
                this.updatePhotoPreview();
                this.updateProgressIndicator();
                document.getElementById('selectedStudentText').textContent = '-- Pilih Siswa --';
                document.getElementById('selectedStudentID').value = '';
                this.startBtn.classList.remove('hidden');
                this.startBtn.disabled = true;
                this.startBtn.innerHTML = '<i class="fas fa-user-plus mr-2"></i>Pilih Siswa Terlebih Dahulu';
                this.stopBtn.classList.add('hidden');
                if (this.photoProgress) this.photoProgress.classList.add('hidden');
            }

            stopCamera() {
                if (this.stream) {
                    this.stream.getTracks().forEach(track => track.stop());
                    this.stream = null;
                }
                if (this.detectionInterval) {
                    clearInterval(this.detectionInterval);
                    this.detectionInterval = null;
                }
                this.stopBtn.classList.add('hidden');
                if (this.photoProgress) this.photoProgress.classList.add('hidden');
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            const system = new FaceRegistrationSystem();
            const studentSelectBtn = document.getElementById('studentSelectBtn');
            const studentModal = document.getElementById('studentModal');
            const closeStudentModal = document.getElementById('closeStudentModal');
            const studentSearch = document.getElementById('studentSearch');

            studentSelectBtn.addEventListener('click', () => {
                studentModal.classList.remove('hidden');
                studentSearch.focus();
            });
            closeStudentModal.addEventListener('click', () => studentModal.classList.add('hidden'));
            studentSearch.addEventListener('input', function() {
                const term = this.value.toLowerCase();
                document.querySelectorAll('.student-item').forEach(item => {
                    const name = item.dataset.name?.toLowerCase() || '';
                    const induk = item.dataset.induk?.toLowerCase() || '';
                    item.style.display = (name.includes(term) || induk.includes(term)) ? 'block' :
                        'none';
                });
            });
            document.querySelectorAll('.student-item').forEach(item => {
                item.addEventListener('click', function() {
                    const name = this.dataset.name;
                    const id = this.dataset.id;
                    const induk = this.dataset.induk;
                    document.getElementById('selectedStudentText').textContent =
                        `${name} (${induk || 'No Induk Kosong'})`;
                    document.getElementById('selectedStudentID').value = id;
                    const startBtn = document.getElementById('startCamera');
                    startBtn.disabled = false;
                    startBtn.innerHTML =
                        `<i class="fas fa-camera mr-2"></i>Mulai Registrasi untuk ${name}`;
                    studentModal.classList.add('hidden');
                });
            });
        });
    </script>
@endpush
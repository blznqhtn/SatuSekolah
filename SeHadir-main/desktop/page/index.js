const API_URL = window.env.APP_URL;
const DEFAULT_PHOTO = "/placeholder.svg?height=120&width=100";

const State = {
    cardUID: "",
    isProcessing: false,
    isQrShow: false,
    positionPresence: 0, // 0: Masuk, 1: Keluar
    resetTimer: null,
    isInitialized: false,
    presenceMethod: "rfid",      // "rfid" | "face"
    cameraStream: null,
    faceCaptureInterval: null,
    faceSuccessCooldown: false,
};

localStorage.clear();

const SecretStorage = {
    getKey() {
        const data = localStorage.getItem('app_secret_data');
        if (!data) return null;
        try {
            const parsed = JSON.parse(data);
            // Expire at 12 AM (midnight)
            if (new Date().getTime() > parsed.expiresAt) {
                localStorage.removeItem('app_secret_data');
                return null;
            }
            return parsed.secret;
        } catch (e) {
            return null;
        }
    },
    getSettings() {
        const data = localStorage.getItem('app_secret_data');
        if (!data) return null;
        try {
            const parsed = JSON.parse(data);
            return parsed.settings || null;
        } catch(e) {
            return null;
        }
    },
    setKey(secret, settings = null) {
        const now = new Date();
        const expiresAt = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999).getTime();
        localStorage.setItem('app_secret_data', JSON.stringify({
            secret,
            settings,
            expiresAt
        }));
    }
};

const httpClient = {
    async request(url, options = {}) {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 10000);

        let finalUrl = url;
        const secret = SecretStorage.getKey();
        if (secret && !options.skipSecret) {
            const separator = finalUrl.includes('?') ? '&' : '?';
            finalUrl = `${finalUrl}${separator}sekolah=${encodeURIComponent(secret)}`;
        }

        try {
            const response = await fetch(finalUrl, { ...options, signal: controller.signal });
            clearTimeout(timeout);
            return response;
        } catch (err) {
            clearTimeout(timeout);
            throw err;
        }
    },
    async get(url, options = {}) {
        return await this.request(url, options);
    },
    async post(url, body, options = {}) {
        return await this.request(url, {
            ...options,
            method: 'POST',
            headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
            body: JSON.stringify(body)
        });
    }
};

// 2. SCANNER ENGINE
document.addEventListener("keypress", async (e) => {
    if (!State.isInitialized || State.isProcessing || State.isQrShow || State.presenceMethod !== "rfid") return;

    if (e.key === "Enter") {
        e.preventDefault();
        if (State.cardUID.length < 3) return;

        State.isProcessing = true;
        const finalUID = State.cardUID.trim();
        State.cardUID = ""; 

        await handleAttendance(finalUID);
        State.isProcessing = false;
    } else {
        if (/^[a-zA-Z0-9]$/.test(e.key)) {
            State.cardUID += e.key;
        }
        clearTimeout(State.resetTimer);
        State.resetTimer = setTimeout(() => { State.cardUID = ""; }, 200);
    }
});

// 3. CORE ATTENDANCE HANDLER
async function handleAttendance(uid) {
    try {
        const payload = {
            id: uid,
            id_sekolah: SecretStorage.getKey(),
            mode: State.positionPresence === 0 ? "masuk" : "keluar"
        };

        const response = await httpClient.post(`${API_URL}api/presensi/`, payload);
        const text = await response.text();

        let resData;
        try {
            resData = JSON.parse(text);
        } catch (e) {
            showNotification("Respons server tidak valid", "error");
            return;
        }

        if (!response.ok || resData.status === "failed") {
            showNotification(resData.message || "Gagal Absensi", "error");
            if(resData.data) updateStudentDisplay(resData.data, resData.profile);
            return;
        }

        if (["late", "early", "non_productive"].includes(resData.status)) {
            if (resData.redirect_url) showQRCode(resData.redirect_url);
        }

        showNotification(resData.message || "Berhasil!", "success");
        updateStudentDisplay(resData.data, resData.profile);
        
        // Refresh UI Data
        LoadDataAsync(); 
        getDataAll();

    } catch (err) {
        showNotification("Koneksi Server Terputus", "error");
    }
}

// 4. LOAD TABLE DATA (FIXED: SINKRON DENGAN BACKEND GOLANG)
async function LoadDataAsync() {
    try {
        const response = await httpClient.get(`${API_URL}presences/all`);
        const apiResponse = await response.json();

        // Update Statistik sesuai key backend
        document.getElementById("totalToday").textContent = apiResponse.count ?? "0";
        document.getElementById("totalSickPermission").textContent = apiResponse.total_tidak_hadir ?? "0";

        const tableBody = document.getElementById("attendanceTable");
        tableBody.innerHTML = "";

        if (apiResponse.data && apiResponse.data.length > 0) {
            apiResponse.data.forEach((row, index) => {
                const tr = document.createElement("tr");
                tr.className = "hover:bg-muted/50 transition-colors border-b";

                // Map key sesuai struct Item di backend
                tr.innerHTML = `
                    <td class="px-6 py-4 text-sm">${index + 1}</td>
                    <td class="px-6 py-4 text-sm font-medium text-primary">${row["no"] || "-"}</td>
                    <td class="px-6 py-4 text-sm font-semibold">${row["nama_lengkap"] || "-"}</td>
                    <td class="px-6 py-4 text-sm">${row["kelas"] || "-"}</td>
                    <td class="px-6 py-4 text-sm font-mono text-gray-600">${formatOnlyTime(row["waktu_masuk"])}</td>
                    <td class="px-6 py-4 text-sm font-mono text-gray-600">${formatOnlyTime(row["waktu_keluar"])}</td>
                    <td class="px-6 py-4">
                        <span class="px-3 py-1 text-xs font-bold rounded-full ${getStatusClass(row["status_masuk"])}">
                            ${row["status_masuk"] || "Hadir"}
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <span class="px-3 py-1 text-xs font-bold rounded-full ${getStatusClass(row["status_keluar"])}">
                            ${row["status_keluar"] || "-"}
                        </span>
                    </td>
                `;
                tableBody.appendChild(tr);
            });
        } else {
            tableBody.innerHTML = `<tr><td colspan="8" class="px-6 py-10 text-center text-muted-foreground italic">Belum ada data hari ini</td></tr>`;
        }
    } catch (error) {
        // NULL
    }
}

// 5. GET OVERALL STATS
async function getDataAll() {
    try {
        const response = await httpClient.get(`${API_URL}users/total`);
        const json = await response.json();
        document.getElementById("totalOverall").textContent = json.total ?? "0";
    } catch (error) {
        // NULL
    }
}

// 6. UI HELPERS
function updateStudentDisplay(userData, profileUrl) {
    const infoPanel = document.getElementById("studentInfo");

    // Mapping berdasarkan struct SchoolMember backend
    document.getElementById("studentName").textContent = userData?.school_member?.name || userData?.username || "-";
    document.getElementById("studentClass").textContent = userData?.school_member?.kelas?.name || "-";
    document.getElementById("studentNIS").textContent = userData?.school_member?.no_induk || "-";
    
    const imgElement = document.getElementById("studentPhoto");
    imgElement.src = profileUrl || DEFAULT_PHOTO;
    imgElement.onerror = () => { imgElement.src = DEFAULT_PHOTO; };

    const successMsg = document.getElementById("scanSuccessMsg");
    if (successMsg) {
        successMsg.textContent = State.presenceMethod === "face" ? "✓ Wajah berhasil dikenali" : "✓ Kartu berhasil dikenali";
    }

    document.getElementById("nfcScanning").classList.add("hidden");
    document.getElementById("facePanel").classList.add("hidden");
    infoPanel.classList.remove("hidden");

    clearTimeout(window.panelTimer);
    window.panelTimer = setTimeout(() => {
        infoPanel.classList.add("hidden");
        showScanPanel();
    }, 5000);
}

function formatOnlyTime(dateTimeStr) {
    if (!dateTimeStr || dateTimeStr === "-") return "-";
    const parts = dateTimeStr.split(" ");
    return parts.length >= 2 ? parts[1].substring(0, 5) : dateTimeStr;
}

function getStatusClass(status) {
    switch (status) {
        case "Hadir": case "Tepat Waktu": return "bg-green-100 text-green-700";
        case "Terlambat": case "Belum Waktunya": return "bg-red-100 text-red-700";
        case "Izin": case "Sakit": return "bg-amber-100 text-amber-700";
        default: return "bg-gray-100 text-gray-600";
    }
}

function showNotification(msg, type = "error") {
    let toast = document.getElementById("app-toast");
    if (!toast) {
        toast = document.createElement("div");
        toast.id = "app-toast";
        toast.className = "fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-[9999] px-10 py-6 rounded-xl font-bold text-white shadow-2xl transition-all duration-300 scale-90 opacity-0 hidden";
        document.body.appendChild(toast);
    }
    toast.textContent = msg;
    toast.style.backgroundColor = type === "success" ? "#10b981" : "#ef4444";
    toast.classList.remove("hidden", "opacity-0", "scale-90");
    toast.classList.add("opacity-100", "scale-100");
    setTimeout(() => {
        toast.classList.add("opacity-0", "scale-90");
        setTimeout(() => toast.classList.add("hidden"), 300);
    }, 2000);
}

function showQRCode(url) {
    State.isQrShow = true;
    const modal = document.getElementById("qrModal");
    const qrImg = document.getElementById("qrCodeImg");
    const label = document.getElementById("qrLabel");
    
    qrImg.src = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(url)}`;
    modal.classList.remove("hidden");

    let countdown = 10;
    const timer = setInterval(() => {
        countdown--;
        label.textContent = `Tutup otomatis dalam ${countdown} detik...`;
        if (countdown <= 0 || !State.isQrShow) {
            clearInterval(timer);
            modal.classList.add("hidden");
            State.isQrShow = false;
        }
    }, 1000);
}

// 7. FACE RECOGNITION ENGINE
function showScanPanel() {
    const rfidPanel = document.getElementById("nfcScanning");
    const facePanel = document.getElementById("facePanel");
    if (State.presenceMethod === "face") {
        rfidPanel.classList.add("hidden");
        facePanel.classList.remove("hidden");
    } else {
        facePanel.classList.add("hidden");
        rfidPanel.classList.remove("hidden");
    }
}

function setPresenceMethod(method) {
    if (!State.isInitialized) return;
    State.presenceMethod = method;

    const scanTitle  = document.getElementById("scanPanelTitle");
    const toggleText = document.getElementById("methodToggleText");
    const toggleIcon = document.getElementById("methodToggleIcon");
    const methodLabel = document.getElementById("presenceMethodLabel");
    const toggleBtn  = document.getElementById("methodToggleBtn");

    if (method === "face") {
        if (scanTitle)   scanTitle.textContent   = "Face Recognition";
        if (toggleText)  toggleText.textContent  = "Ganti ke RFID";
        if (toggleIcon)  toggleIcon.className    = "fas fa-id-card";
        if (methodLabel) methodLabel.textContent = "Face Recognition";
        if (toggleBtn)   toggleBtn.classList.replace("bg-secondary", "bg-indigo-600");
        showScanPanel();
        startCamera();
    } else {
        stopCamera();
        if (scanTitle)   scanTitle.textContent   = "Scan Kartu Pelajar";
        if (toggleText)  toggleText.textContent  = "Face Recognition";
        if (toggleIcon)  toggleIcon.className    = "fas fa-camera";
        if (methodLabel) methodLabel.textContent = "RFID Tap Kartu";
        if (toggleBtn)   toggleBtn.classList.replace("bg-indigo-600", "bg-secondary");
        showScanPanel();
    }
}

async function startCamera() {
    // Bersihkan interval yang mungkin masih berjalan sebelumnya
    if (State.faceCaptureInterval) {
        clearInterval(State.faceCaptureInterval);
    }
    
    updateFaceStatus("Mengakses kamera...", "processing");
    try {
        const stream = await navigator.mediaDevices.getUserMedia({
            video: { width: { ideal: 640 }, height: { ideal: 480 }, facingMode: "user" },
            audio: false
        });
        State.cameraStream = stream;
        const video = document.getElementById("faceVideo");
        video.srcObject = stream;
        updateFaceStatus("Posisikan wajah di tengah frame...", "idle");

        // Auto-capture setiap 3 detik
        State.faceCaptureInterval = setInterval(async () => {
            if (!State.isProcessing && !State.isQrShow && State.isInitialized &&
                State.presenceMethod === "face" && !State.faceSuccessCooldown) {
                await captureAndSendFace();
            }
        }, 3000);
    } catch (err) {
        showNotification("Gagal mengakses kamera: " + err.message, "error");
        setPresenceMethod("rfid");
    }
}

function stopCamera() {
    if (State.cameraStream) {
        State.cameraStream.getTracks().forEach(t => t.stop());
        State.cameraStream = null;
    }
    if (State.faceCaptureInterval) {
        clearInterval(State.faceCaptureInterval);
        State.faceCaptureInterval = null;
    }
    State.faceSuccessCooldown = false;
}

async function captureAndSendFace() {
    const video = document.getElementById("faceVideo");
    if (!video || video.readyState < 2 || video.videoWidth === 0) return;

    const canvas = document.getElementById("faceCanvas");
    canvas.width  = video.videoWidth;
    canvas.height = video.videoHeight;
    const ctx = canvas.getContext("2d");
    // Un-mirror agar sesuai wajah asli untuk AWS Rekognition
    ctx.translate(canvas.width, 0);
    ctx.scale(-1, 1);
    ctx.drawImage(video, 0, 0);

    const base64 = canvas.toDataURL("image/jpeg", 0.85);
    await handleFaceAttendance(base64);
}

async function handleFaceAttendance(base64) {
    State.isProcessing = true;
    updateFaceStatus("Memindai wajah...", "processing");

    try {
        const payload = {
            face_data: base64,
            id_sekolah: SecretStorage.getKey(),
            mode: State.positionPresence === 0 ? "masuk" : "keluar"
        };

        const response = await httpClient.post(`${API_URL}api/face-recognition/attendance`, payload);
        const text = await response.text();

        let resData;
        try { resData = JSON.parse(text); } catch {
            updateFaceStatus("Respons server tidak valid", "error");
            return;
        }

        if (!response.ok || resData.status === "failed") {
            // Wajah tidak dikenali (401) – silent update, normal saat auto-scan
            if (response.status === 401) {
                updateFaceStatus("Posisikan wajah dengan jelas...", "idle");
            } else {
                const errMsg = resData?.message || "Gagal proses presensi";
                updateFaceStatus(errMsg, "error");
                showNotification(errMsg, "error");
                if (resData.data) updateStudentDisplay(resData.data, resData.profile);
                
                // Tambahkan cooldown agar tidak spam API setiap 3 detik saat gagal/sudah absen
                State.faceSuccessCooldown = true;
                setTimeout(() => {
                    State.faceSuccessCooldown = false;
                    updateFaceStatus("Posisikan wajah di tengah frame...", "idle");
                }, 3500);
            }
            return;
        }

        // Handle Parity Logics (Late / QR Code)
        if (["late", "early", "non_productive"].includes(resData.status)) {
            if (resData.redirect_url) showQRCode(resData.redirect_url);
        }

        const msg = resData.message || "Presensi wajah berhasil!";
        showNotification(msg, "success");
        updateFaceStatus("✓ " + msg, "success");
        updateStudentDisplay(resData.data, resData.profile);
        
        LoadDataAsync();
        getDataAll();

        // Cooldown 8 detik agar tidak double-scan sukses
        State.faceSuccessCooldown = true;
        setTimeout(() => {
            State.faceSuccessCooldown = false;
            updateFaceStatus("Posisikan wajah di tengah frame...", "idle");
        }, 8000);

    } catch (err) {
        updateFaceStatus("Koneksi server terputus", "error");
    } finally {
        State.isProcessing = false;
    }
}

function updateFaceStatus(msg, type) {
    const el = document.getElementById("faceStatus");
    if (!el) return;
    el.textContent = msg;
    const map = {
        success:    "text-center mt-3 text-sm font-semibold text-green-600",
        error:      "text-center mt-3 text-sm font-semibold text-red-500",
        processing: "text-center mt-3 text-sm font-medium text-blue-500 animate-pulse",
        idle:       "text-center mt-3 text-sm text-muted-foreground"
    };
    el.className = map[type] || map.idle;
}

// 8. INITIALIZATION
document.addEventListener("DOMContentLoaded", () => {
    checkAndValidateSecret();

    // Event listener untuk tombol checkout
    const checkOutBtn = document.getElementById("checkOutBtn");
    checkOutBtn.addEventListener("click", () => {
        if (!State.isInitialized) return;
        
        const modeLabel = document.getElementById("attendanceMode");
        const btnText = checkOutBtn.querySelector("span");
        
        if (State.positionPresence === 0) {
            State.positionPresence = 1;
            modeLabel.textContent = "Absensi Keluar";
            btnText.textContent = "Absensi Masuk";
            checkOutBtn.classList.replace("bg-red-600", "bg-green-600");
            checkOutBtn.classList.replace("hover:bg-red-700", "hover:bg-green-700");
        } else {
            State.positionPresence = 0;
            modeLabel.textContent = "Absensi Masuk";
            btnText.textContent = "Absensi Keluar";
            checkOutBtn.classList.replace("bg-green-600", "bg-red-600");
            checkOutBtn.classList.replace("hover:bg-green-700", "hover:bg-red-700");
        }
    });

    // Event listener untuk method toggle (RFID / Face Recognition)
    const methodToggleBtn = document.getElementById("methodToggleBtn");
    if (methodToggleBtn) {
        methodToggleBtn.addEventListener("click", () => {
            setPresenceMethod(State.presenceMethod === "rfid" ? "face" : "rfid");
        });
    }

    const manualCaptureBtn = document.getElementById("manualCaptureBtn");
    if (manualCaptureBtn) {
        manualCaptureBtn.addEventListener("click", () => {
            if (State.isInitialized && State.presenceMethod === "face" && !State.isProcessing) {
                captureAndSendFace();
            }
        });
    }

    // Event listener untuk validasi secret
    document.getElementById('validateSecretBtn').addEventListener('click', handleSecretValidation);
    document.getElementById('secretKeyInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') handleSecretValidation();
    });
});

async function handleSecretValidation() {
    const input = document.getElementById('secretKeyInput').value.trim();
    if (!input) {
        showNotification('Secret key wajib diisi', 'error');
        return;
    }
    
    const btn = document.getElementById('validateSecretBtn');
    const oriText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = 'Memvalidasi...';
    
    try {
        // Gunakan request dengan skipSecret agar tidak melooping auth
        const response = await httpClient.get(`${API_URL}validate?secret=${encodeURIComponent(input)}`, { skipSecret: true });
        const resData = await response.json();
        
        if (response.ok && resData.status === 'success') {
            SecretStorage.setKey(input, resData.settings);
            showNotification(resData.message || 'Validasi berhasil', 'success');
            document.getElementById('secretKeyModal').classList.add('hidden');
            initApp();
        } else {
            showNotification(resData.message || 'Secret Key tidak valid', 'error');
            document.getElementById('secretKeyModal').classList.remove('hidden');
        }
    } catch (err) {
        showNotification('Gagal menghubungi server', 'error');
    } finally {
        btn.disabled = false;
        btn.innerHTML = oriText;
    }
}

function checkAndValidateSecret() {
    const secret = SecretStorage.getKey();
    if (!secret) {
        document.getElementById('secretKeyModal').classList.remove('hidden');
        document.getElementById('secretKeyInput').focus();
    } else {
        initApp();
    }
}

function initApp() {
    State.isInitialized = true;
    applyServerSettings();
    getDataAll();
    LoadDataAsync();
    setInterval(LoadDataAsync, 30000); // Auto-refresh 30s
}

function applyServerSettings() {
    const settings = SecretStorage.getSettings();
    if (!settings) return;

    const method = settings.attendance_method || "rfid";
    const faceEnabled = settings.face_recognition_enabled || false;
    const toggleBtn = document.getElementById("methodToggleBtn");

    if (method === "rfid" && !faceEnabled) {
        // Only RFID is activated
        if (toggleBtn) toggleBtn.classList.add("hidden");
        setPresenceMethod("rfid");
    } else if (method === "face_id" || method === "face") {
        // Only Face ID is activated
        if (toggleBtn) toggleBtn.classList.add("hidden");
        setPresenceMethod("face");
    } else {
        // Both are activated
        if (toggleBtn) toggleBtn.classList.remove("hidden");
        // default to whatever the method is, or rfid
        setPresenceMethod("rfid");
    }
}
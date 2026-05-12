<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ {
    MainController,
    AuthController,
    DashboardController,
    SiswaController,
    HariController,
    AccountController,
    KelasController,
    PhotoController,
    SettingController,
    CardController,
    FaceController,
    FormController
};

Route::get('/', [MainController::class, 'index'])->name('main');
Route::get('/privacy-policy', [MainController::class, 'policy'])->name('policy');
Route::get('/terms-and-conditions', [MainController::class, 'terms'])->name('terms');
Route::get('/help-center', [MainController::class, 'helpCenter'])->name('help-center');
Route::get('/reviews', [MainController::class, 'reviews'])->name('reviews');
Route::get('/attendances', [DashboardController::class, 'view_data_public'])->name('public.presences');

Route::prefix('/forms')->name('forms.')->group(function () {
    Route::prefix('/late')->name('late.')->group(function () {
        Route::get('/arrival', [FormController::class, 'showArrivalForm'])->name('index_arrival');
        Route::post('/arrival', [FormController::class, 'storeArrival'])->name('submit_arrival');

        Route::get('/departure', [FormController::class, 'showDepartureForm'])->name('index_departure');
        Route::post('/departure', [FormController::class, 'storeDeparture'])->name('submit_departure');
    });

    Route::get('/early/departure', [FormController::class, 'showEarlyDepartureForm'])->name('index_early_departures');
    Route::post('/early/departure', [FormController::class, 'storeEarlyDeparture'])->name('submit_early_departures');

    Route::get('/special/attendance', [FormController::class, 'showReasonForm'])->name('special_attendances');
    Route::post('/special/attendance', [FormController::class, 'storeReason'])->name('submit_special_attendances');
});

Route::middleware('guest.session')->prefix('/login')->group(function () {
    Route::get('/', [AuthController::class, 'login'])->name('login');
    Route::post('/', [AuthController::class, 'process_login'])->name('login.process');
});

Route::middleware(['auth.session', 'validate.token', 'role.session:admin'])->name('admin.')->prefix('/admin')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/export/attendances', [DashboardController::class, 'exportPresences'])->name('export.presences');
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

    // Manajemen Hari
    Route::name('days.')->prefix('/days')->group(function () {
        Route::get('/', [HariController::class, 'index'])->name('index');
        Route::get('/create', [HariController::class, 'create'])->name('create');
        Route::post('/store', [HariController::class, 'store'])->name('store');
    });

    // Data Siswa
    Route::name('siswa.')->prefix('/members')->group(function () {
        Route::post('/import', [SiswaController::class, 'import'])->name('import');
        Route::get('/template/download', [SiswaController::class, 'downloadTemplate'])->name('template');
        Route::delete('/delete/multiple', [SiswaController::class, 'destroyMultiple'])->name('delete.multiple');
        Route::get('/photos', [SiswaController::class, 'fetchPhotos'])->name('photos');
        Route::resource('/', SiswaController::class)->parameters([
            '' => 'id'
        ])->except([
            'show'
        ]);
    });

    // Manajemen Akun
    Route::name('accounts.')->prefix('/accounts')->group(function () {
        Route::get('/charts', [AccountController::class, 'charts'])->name('charts');
        Route::delete('/delete/multiple', [AccountController::class, 'destroyMultiple'])->name('delete.multiple');
        Route::post('/reset/password', [AccountController::class, 'resetPassword'])->name('reset-password');
        Route::post('/rfid/remove/{id}', [AccountController::class, 'removeRfid'])->name('rfid.remove');
        Route::post('/rfid/status', [AccountController::class, 'checkRfidStatus'])->name('rfid.status');
        Route::patch('/ban/{id}', [AccountController::class, 'ban'])->name('ban');
        Route::resource('/', AccountController::class)->parameters([
            '' => 'id'
        ])->except([
            'show'
        ]);
    });

    // Manajemen Foto
    Route::name('photos.')->prefix('/photos')->group(function () {
        Route::get('/', [PhotoController::class, 'index'])->name('index');
        Route::post('/upload', [PhotoController::class, 'uploadPhoto'])->name('upload');
        Route::post('/delete', [PhotoController::class, 'destroyPhoto'])->name('delete');
    });

    // Manajemen Kelas
    Route::name('kelas.')->prefix('/kelas')->group(function () {
        Route::resource('/', KelasController::class)->parameters([
            '' => 'id'
        ])->except([
            'create', 'edit', 'update', 'delete', 'show'
        ]);
    });

    // Manajemen Kartu RFID
    Route::name('cards.')->prefix('/kartu')->group(function () {
        Route::get('/', [CardController::class, 'index'])->name('index');
        Route::post('/store', [CardController::class, 'store'])->name('store');
        Route::get('/status/{id}', [CardController::class, 'checkStatus'])->name('status.check');
    });

    // Manajemen Wajah
    Route::name('faces.')->prefix('/face-id')->group(function () {
        Route::get('/', [FaceController::class, 'index'])->name('index');
        Route::post('/register', [FaceController::class, 'store'])->name('store');
        Route::post('/reset/{nomor_induk}', [FaceController::class, 'reset'])->name('reset');
    });

    // Pengaturan
    Route::name('settings.')->prefix('/pengaturan')->group(function () {
        Route::get('/', [SettingController::class, 'index'])->name('index');
        Route::post('/update', [SettingController::class, 'update'])->name('update');
    });
});

Route::middleware(['auth.session', 'validate.token', 'role.session:superadmin'])->name('superadmin.')->prefix('/superadmin')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
});
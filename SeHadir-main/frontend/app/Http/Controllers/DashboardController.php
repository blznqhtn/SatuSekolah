<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Client\Pool;
use Illuminate\Support\Facades\Cache;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Log;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $idInstansi = env('ID_INSTANSI');
        $queryParams = $request->query();

        // Parameter dasar untuk API dashboard
        $apiParams = array_merge($queryParams, ['sekolah' => $idInstansi]);

        // Tangkap parameter kelas dari filter dropdown
        if ($request->has('kelas') && $request->kelas != '') {
            $apiParams['kelas'] = $request->kelas;
        }

        $cacheKey = 'dashboard_data_' . md5(json_encode($apiParams) . session('user_id') . session('session_id'));

        if ($request->boolean('refresh')) {
            Cache::forget($cacheKey);
        }

        $apiData = Cache::remember($cacheKey, 60, function () use ($apiParams, $idInstansi) {
            try {
                // Gunakan Http::pool untuk menarik data Stats Dashboard dan List Kelas secara bersamaan
                $responses = Http::timeout(10)
                    ->retry(2, 100)
                    ->pool(fn (\Illuminate\Http\Client\Pool $pool) => [
                        $pool->as('stats')
                            ->withHeaders([
                                'Authorization' => 'Bearer ' . session('access_token'),
                                'X-Session-ID'  => session('session_id'),
                            ])->get(env('VITE_APP_URL_BACKEND') . '/api/dashboard/stats', $apiParams),
                        $pool->as('kelas')
                            ->withHeaders([
                                'Authorization' => 'Bearer ' . session('access_token'),
                                'X-Session-ID'  => session('session_id'),
                            ])->get(env('VITE_APP_URL_BACKEND') . '/kelas', ['sekolah' => $idInstansi]),
                    ]);

                // Handle respons Unauthorized dari salah satu request
                if ($responses['stats']->status() === 401 || $responses['kelas']->status() === 401) {
                    return ['is_unauthorized' => true];
                }

                $result = [];

                // Parsing data dashboard stats
                if ($responses['stats']->successful()) {
                    $result['dashboard'] = $responses['stats']->json('data');
                } else {
                    Log::error('Dashboard API Error: HTTP ' . $responses['stats']->status(), ['response' => $responses['stats']->body()]);
                    $result['dashboard'] = null;
                }

                // Parsing data kelas
                if ($responses['kelas']->successful()) {
                    $result['kelas'] = $responses['kelas']->json('data');
                } else {
                    Log::error('Kelas API Error: HTTP ' . $responses['kelas']->status(), ['response' => $responses['kelas']->body()]);
                    $result['kelas'] = collect([]);
                }

                // Jika dashboard gagal, return null agar tidak dicache dan mereturn error
                if (!$result['dashboard']) {
                    return null;
                }

                return $result;

            } catch (\Exception $e) {
                Log::error('Dashboard API Exception: ' . $e->getMessage());
                return null;
            }
        });

        if (isset($apiData['is_unauthorized'])) {
            Cache::forget($cacheKey);
            session()->invalidate();
            session()->regenerateToken();
            return redirect('/login')->withErrors(['login' => 'Sesi habis atau tidak valid. Silakan login kembali.']);
        }

        if (!$apiData || !isset($apiData['dashboard'])) {
            return redirect()->back()->with('error', 'Gagal mengambil data dari server backend. Tim teknis sedang menangani masalah ini.');
        }

        // Pecah data yang sudah di-cache
        $dashboardData = $apiData['dashboard'];
        $listKelasRaw  = $apiData['kelas'] ?? [];
        $listKelas     = collect($listKelasRaw)->map(fn($item) => (object) $item);
        // dd($apiData);

        $total           = $dashboardData['total_users'] ?? '0';
        $totalHariIni    = $dashboardData['total_hadir'] ?? '0';
        $totalAlpa       = $dashboardData['total_alpa'] ?? '0';
        $totalTidakHadir = $dashboardData['total_tidak_hadir'] ?? '0';
        
        $filter          = $dashboardData['filter'] ?? 'Hari ini';
        $tab             = $dashboardData['tab'] ?? 'all';
        $todayDayType    = $dashboardData['today_day_type'] ?? null;
        $dateFrom        = $dashboardData['date_from'] ?? null;
        $dateTo          = $dashboardData['date_to'] ?? null;
        $dateNow         = $dashboardData['date_now'] ?? now();
        $kelasFilter     = $request->get('kelas', '');

        if ($request->has('head-tabs')) {
            $headTab = $dashboardData['head_tab'] ?? 'produktif';
        } else {
            $headTab = in_array($todayDayType, ['Hari Non-Produktif', 'Hari Libur']) ? 'non_produktif' : 'produktif';
        }

        $itemsRaw = $dashboardData['data_presensi'] ?? [];
        $itemsCollection = collect($itemsRaw)->map(function ($item) {
            $obj = (object) $item;
            $obj->nis = $item['user']['school_member']['nomor_induk'] ?? null;
            $obj->school_member = (object) [
                'name' => $item['user']['school_member']['name'] ?? '-',
                'kelas' => $item['user']['school_member']['kelas']['name'] ?? '-',
            ];
            return $obj;
        });

        $perPage = 10;
        $currentPage = $request->get('page', 1);
        
        $currentItems = $itemsCollection->slice(($currentPage - 1) * $perPage, $perPage)->values();

        $dataPresensi = new LengthAwarePaginator(
            $currentItems,
            $itemsCollection->count(),
            $perPage,
            $currentPage,
            ['path' => $request->url(), 'query' => $request->query()]
        );

        $leaveDocuments = collect($dashboardData['leave_documents'] ?? [])->map(function ($item) {
            $obj = (object) $item;
            $obj->nis = $item['user']['school_member']['nomor_induk'] ?? null;
            return $obj;
        });
        
        $monthlyStats   = $dashboardData['monthly_stats'] ?? [];
        $totalMasukHariNonProduktif = $dashboardData['total_masuk_non_produktif'] ?? 0;
        $dayType        = $dashboardData['day_type'] ?? null;

        // Note: listKelas sudah ditangkap di atas dari $apiData['kelas']

        return view('private.dashboard', compact(
            'total', 'totalHariIni', 'totalAlpa', 'totalTidakHadir',
            'dataPresensi', 'filter', 'tab', 'headTab',
            'dayType', 'todayDayType', 'leaveDocuments', 'monthlyStats',
            'totalMasukHariNonProduktif', 'dateFrom', 'dateTo', 'dateNow',
            'listKelas', 'kelasFilter' // Pastikan ini dikirim ke View
        ));
    }
    
    public function view_data_public(Request $request) 
    {
        $queryParams = $request->query();
        $idInstansi = env('ID_INSTANSI');

        $apiParams = array_merge($queryParams, ['sekolah' => $idInstansi]);

        $dataKelas = [];
        $apiData = null;

        $responses = Http::pool(fn (Pool $pool) => [
            $pool->as('presences')->get(env('VITE_APP_URL_BACKEND') . '/presences', $apiParams),
            $pool->as('kelas')->get(env('VITE_APP_URL_BACKEND') . '/kelas', ['sekolah' => $idInstansi]),
        ]);

        if ($responses['kelas']->successful()) {
            $dataKelas = $responses['kelas']->json('data') ?? [];
            $dataKelas = collect($dataKelas)->map(function($item) {
                return (object) $item;
            });
        }

        if ($responses['presences']->successful()) {
            $apiData = $responses['presences']->json('data');
        }

        if ($apiData) {
            $total = $apiData['total'] ?? '0';
            $totalHariIni = $apiData['total_hari_ini'] ?? '0';
            $totalAlpa = $apiData['total_alpa'] ?? '0';
            $totalTidakHadir = $apiData['total_tidak_hadir'] ?? '0';

            $dataPresensiRaw = $apiData['data_presensi'] ?? [];
            $dataPresensiObj = json_decode(json_encode($dataPresensiRaw));
            
            if (!empty($dataPresensiObj)) {
                foreach ($dataPresensiObj as $dp) {
                    $dp->nis = $dp->user->school_member->nomor_induk ?? ($dp->nis ?? '-');

                    if (!isset($dp->warga_sekolah)) {
                        $dp->warga_sekolah = (object) [
                            'name' => $dp->user->school_member->name ?? ($dp->school_member->name ?? '-'),
                            'kelas' => $dp->user->school_member->kelas->name ?? ($dp->school_member->kelas ?? '-')
                        ];
                    }
                    
                    if (!isset($dp->school_member)) {
                        $dp->school_member = $dp->warga_sekolah;
                    }
                }
            }

            $page = $request->get('page', 1);
            $perPage = 10;

            $totalRows = (int)$totalHariIni + (int)$totalTidakHadir + (int)$totalAlpa;
            if ($totalRows < count($dataPresensiObj)) {
                $totalRows = count($dataPresensiObj);
            }

            $dataPresensi = new LengthAwarePaginator(
                $dataPresensiObj,
                $totalRows,
                $perPage,
                $page,
                ['path' => $request->url(), 'query' => $request->query()]
            );

            $filter = $apiData['filter'] ?? 'Hari ini';
            $tab = $apiData['tab'] ?? 'all';
            $dayType = $apiData['day_type'] ?? null;
            $todayDayType = $apiData['today_day_type'] ?? '';
            $totalMasukHariNonProduktif = $apiData['total_masuk_non_produktif'] ?? '';
            $dateFrom = $apiData['date_from'] ?? null;
            $dateTo = $apiData['date_to'] ?? null;

        } else {
            $total = $totalHariIni = $totalAlpa = $totalTidakHadir = '0';
            $dataPresensi = collect([]);
            $filter = 'Hari ini';
            $tab = 'all';
            $dayType = $todayDayType = $totalMasukHariNonProduktif = $dateFrom = $dateTo = null;
        }

        $leaveDocuments = collect($apiData['leave_documents'] ?? [])->map(function ($item) {
            $obj = (object) $item;
            $obj->nis = $item['user']['school_member']['nomor_induk'] ?? null;
            return $obj;
        });

        // dd($leaveDocuments);

        return view('public.presences', compact(
            'dataKelas',
            'total',
            'totalHariIni',
            'totalAlpa',
            'totalTidakHadir',
            'dataPresensi',
            'leaveDocuments',
            'filter',
            'tab',
            'dayType',
            'todayDayType',
            'totalMasukHariNonProduktif',
            'dateFrom',
            'dateTo'
        ));
    }

    public function exportPresences(Request $request)
    {
        // 1. Ambil parameter filter dari URL
        $filter = $request->query('filter', 'Hari ini');
        $tab = $request->query('tab', 'all');
        $dateFrom = $request->query('date_from', '');
        $dateTo = $request->query('date_to', '');
        $kelas = $request->query('kelas', '');

        try {
            // 2. Request ke Backend Go dengan Response Stream
            // Kita tidak memakai ->json() karena responsnya adalah file biner (.xlsx)
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])
            ->withOptions([
                'stream' => true, // Penting agar file besar tidak memakan memory RAM PHP
            ])
            ->get(env('VITE_APP_URL_BACKEND') . '/api/export/presence', [
                'filter'    => $filter,
                'tab'       => $tab,
                'date_from' => $dateFrom,
                'date_to'   => $dateTo,
                'kelas'     => $kelas,
                'sekolah'   => env('ID_INSTANSI') // Jika diperlukan oleh backend Go
            ]);

            if ($response->successful()) {
                // 3. Ambil nama file dari header Content-Disposition Go, atau buat default
                $disposition = $response->header('Content-Disposition');
                $fileName = 'Export_Presensi.xlsx';
                
                if ($disposition && preg_match('/filename="([^"]+)"/', $disposition, $matches)) {
                    $fileName = $matches[1];
                }

                // 4. Teruskan (Stream) file XLSX ke browser user
                return response()->streamDownload(function () use ($response) {
                    echo $response->body();
                }, $fileName, [
                    'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                    'Cache-Control' => 'max-age=0',
                ]);
            }

            // Jika API Go membalas error JSON
            $errorMsg = $response->json('message') ?? 'Gagal menghubungi server Go.';
            return back()->with('error', 'Gagal mengekspor data: ' . $errorMsg);

        } catch (\Exception $e) {
            Log::error('Gagal export presensi XLSX: ' . $e->getMessage());
            return back()->with('error', 'Terjadi kesalahan sistem saat mencoba mengekspor data.');
        }
    }
}

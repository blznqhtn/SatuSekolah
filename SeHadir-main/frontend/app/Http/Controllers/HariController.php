<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class HariController extends Controller
{
    private function baseUrl()
    {
        return env('VITE_APP_URL_BACKEND') . '/api/hari/';
    }

    public function index(Request $request)
    {
        $bulan = $request->input('bulan', Carbon::now()->month);
        $tahun = $request->input('tahun', Carbon::now()->year);

        $apiParams = array_merge([
            'bulan' => $bulan,
            'tahun' => $tahun,
            'sekolah' => env('ID_INSTANSI')
        ]);

        $cacheKey = 'days_data_' . md5(
            json_encode($apiParams) . session('user_id') . session('session_id')
        );

        $apiData = Cache::remember($cacheKey, 30, function () use ($apiParams) {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->get($this->baseUrl(), $apiParams);

            if ($response->successful()) {
                return $response->json('data');
            }

            return null;
        });

        $jadwalHari = null;
        if ($apiData) {
            $jadwalHari = json_decode(json_encode($apiData));
        }

        if (!$jadwalHari) {
            $jadwalHari = (object)[
                'bulan' => $bulan,
                'tahun' => $tahun,
                'hari_produktif' => [],
                'hari_tambahan' => [],
                'hari_libur' => []
            ];
        }

        $dates = $this->generateDatesForMonth($bulan, $tahun, $jadwalHari);

        return view('private.days.index', compact('jadwalHari', 'dates', 'bulan', 'tahun'));
    }

    public function create(Request $request)
    {
        $bulan = $request->input('bulan', \Carbon\Carbon::now()->month);
        $tahun = $request->input('tahun', \Carbon\Carbon::now()->year);
        
        $apiParams = [
            'bulan'   => $bulan,
            'tahun'   => $tahun,
            'sekolah' => env('ID_INSTANSI')
        ];

        $jadwalHari = null;

        $response = \Illuminate\Support\Facades\Http::withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->get($this->baseUrl(), $apiParams); 

        if ($response->successful() && $response->json('data')) {
            $jadwalHari = (object) $response->json('data');
        }
        
        if (!$jadwalHari) {
            $jadwalHari = (object) [
                'bulan'          => $bulan,
                'tahun'          => $tahun,
                'hari_produktif' => [],
                'hari_tambahan'  => [],
                'hari_libur'     => []
            ];
        }
        
        $dates = $this->generateDatesForMonth($bulan, $tahun, $jadwalHari);
        
        return view('private.days.month-form', compact('jadwalHari', 'dates', 'bulan', 'tahun'));
    }

    public function store(Request $request)
    {
        $bulan = $request->input('bulan');
        $tahun = $request->input('tahun');
        $types = $request->input('types', []);

        $hariProduktif = [];
        $hariTambahan = [];
        $hariLibur = [];

        foreach ($types as $date => $type) {
            $dayNumber = (string) \Carbon\Carbon::parse($date)->day;

            if ($type === 'produktif') {
                $hariProduktif[] = $dayNumber;
            } elseif ($type === 'non_produktif') {
                $hariTambahan[] = $dayNumber;
            } elseif ($type === 'libur') {
                $hariLibur[] = $dayNumber;
            }
        }

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->post($this->baseUrl(), [
            'bulan'          => (int)$bulan,
            'tahun'          => (int)$tahun,
            'hari_produktif' => $hariProduktif,
            'hari_tambahan'  => $hariTambahan,
            'hari_libur'     => $hariLibur,
            'sekolah'        => env('ID_INSTANSI')
        ]);

        if ($response->successful()) {
            return redirect()->route('admin.days.index', ['bulan' => $bulan, 'tahun' => $tahun])
                ->with('success', 'Jadwal hari berhasil disimpan.');
        }

        // Mengambil pesan error dari Go jika ada
        $errorMessage = $response->json('message') ?? 'Terjadi kesalahan pada server backend.';

        return redirect()->route('admin.days.index', ['bulan' => $bulan, 'tahun' => $tahun])
            ->with('error', 'Gagal menyimpan jadwal: ' . $errorMessage);
    }

    private function generateDatesForMonth($bulan, $tahun, $jadwalHari = null)
    {
        $startDate = Carbon::createFromDate($tahun, $bulan, 1);
        $endDate = Carbon::createFromDate($tahun, $bulan, 1)->endOfMonth();

        $dates = [];
        $currentDate = $startDate->copy();

        $produktif = $jadwalHari->hari_produktif ?? [];
        $tambahan = $jadwalHari->hari_tambahan ?? [];
        $libur = $jadwalHari->hari_libur ?? [];

        while ($currentDate <= $endDate) {
            $dateStr = $currentDate->format('Y-m-d');
            
            $dayStr = (string) $currentDate->day; 
            
            $type = null;

            if (in_array($dayStr, $produktif)) {
                $type = 'produktif';
            } elseif (in_array($dayStr, $tambahan)) {
                $type = 'non_produktif';
            } elseif (in_array($dayStr, $libur)) {
                $type = 'libur';
            }

            $dates[] = [
                'date' => $currentDate->copy(),
                'date_str' => $dateStr,
                'day' => $currentDate->day,
                'type' => $type
            ];

            $currentDate->addDay();
        }

        return $dates;
    }
}

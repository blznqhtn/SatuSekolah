<?php

namespace App\Http\Controllers;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Client\Pool;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use Illuminate\Pagination\LengthAwarePaginator;

class AccountController extends Controller
{
    private function baseUrl()
    {
        return env('VITE_APP_URL_BACKEND') . '/api/users';
    }

    public function index(Request $request)
    {
        $search = request()->query('search', '');
        $kelas  = request()->query('kelas', 'all');
        $page   = request()->query('page', 1);

        $apiParams = [
            'search'   => $search,
            'kelas_id' => $kelas, 
            'page'     => $page,
        ];

        $responses = Http::timeout(10)
        ->retry(2, 100)->pool(fn (\Illuminate\Http\Client\Pool $pool) => [
            $pool->as('accounts')
                ->withHeaders([
                    'Authorization' => 'Bearer ' . session('access_token'),
                    'X-Session-ID'  => session('session_id'),
                ])->get($this->baseUrl(), $apiParams),
            $pool->as('kelas')
                ->withHeaders([
                    'Authorization' => 'Bearer ' . session('access_token'),
                    'X-Session-ID'  => session('session_id'),
                ])->get(env('VITE_APP_URL_BACKEND') . '/kelas', ['sekolah' => env('ID_INSTANSI')]),
        ]);

        $dataKelas = [];
        if (isset($responses['kelas']) && $responses['kelas']->successful()) {
            $kelasRaw = $responses['kelas']->json('data') ?? [];
            $dataKelas = collect($kelasRaw)->map(fn($item) => (object) $item);
        }

        if (isset($responses['accounts']) && $responses['accounts']->successful()) {
            $usersArray = $responses['accounts']->json('data') ?? [];
            $metaObj = $responses['accounts']->json('meta') ?? [];
            
            $accounts = json_decode(json_encode($usersArray));
            
            $schoolAccounts = new \Illuminate\Pagination\LengthAwarePaginator(
                $accounts,
                $metaObj['total_data'] ?? 0,
                $metaObj['per_page'] ?? 20,
                $metaObj['current_page'] ?? 1,
                [
                    'path' => $request->url(),
                    'query' => $request->query()
                ]
            );
        } else {
            $schoolAccounts = new \Illuminate\Pagination\LengthAwarePaginator([], 0, 20, 1);
        }

        return view('private.members.accounts.index', compact('schoolAccounts', 'dataKelas'));
    }

    public function create()
    {
        $responses = Http::timeout(10)
            ->retry(2, 100)
            ->withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->get(env('VITE_APP_URL_BACKEND') . '/api/school-members');

        $siswaRaw = $responses->json('data.members') ?? [];
        $siswa = collect($siswaRaw)->map(fn($item) => (object) $item);

        return view('private.members.accounts.create', compact('siswa'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'noinduk'  => 'required|uuid',
            'username' => 'required|string|max:255',
            'email'    => 'nullable|email',
            'password' => 'required|string|min:8|confirmed',
        ], [
            'noinduk.required'   => 'Silakan pilih siswa terlebih dahulu.',
            'noinduk.uuid'       => 'ID Siswa tidak valid (Harus UUID).',
            'password.min'       => 'Password minimal 8 karakter.',
            'password.confirmed' => 'Konfirmasi password tidak cocok.',
        ]);

        try {
            $response = Http::timeout(10)->withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->post(env('VITE_APP_URL_BACKEND') . '/api/users', [
                'id_school_member' => $request->noinduk, 
                'username'         => $request->username,
                'password'         => $request->password,
                'email'            => $request->email,
                'role'             => 'user'
            ]);

            if ($response->successful()) {
                return redirect()->route('admin.accounts.index')
                    ->with('success', 'Akun siswa berhasil dibuat.');
            }

            $errorMessage = $response->json('message') ?? 'Terjadi kesalahan pada server backend';
            
            return back()
                ->withInput($request->except(['password', 'password_confirmation']))
                ->with('error', 'Gagal membuat akun: ' . $errorMessage);

        } catch (\Exception $e) {
            return back()
                ->withInput($request->except(['password', 'password_confirmation']))
                ->with('error', 'Koneksi ke server gagal: ' . $e->getMessage());
        }
    }

    public function edit($id)
    {
        $response = Http::timeout(10)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->get($this->baseUrl() . '/' . $id);

        if ($response->successful()) {
            $user = $response->json('data');

            return view('private.members.accounts.edit', compact('user'));
        }

        return back()->with('error', 'Gagal mengambil data akun: ' . $response->json('message', 'Error unknown'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'email'     => 'required|email',
            'nomor'     => 'nullable|string|max:20',
            'username'  => 'required|string|max:255',
            'rfid_id'   => 'nullable|string',
        ], [
            'email.email' => 'Format email tidak valid.',
            'nomor.max'   => 'Nomor HP maksimal 20 karakter.',
            'username.required' => 'Username wajib diisi.',
            'username.max' => 'Username maksimal 255 karakter.',
            'rfid_id.string' => 'RFID ID harus berupa string.',
        ]);

        $response = Http::timeout(10)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->put($this->baseUrl() . '/' . $id, [
            'email'     => $request->email,
            'nomor'     => $request->nomor,
            'username'  => $request->username,
            'rfid_id'   => $request->rfid_id,
        ]);

        if ($response->successful()) {
            return redirect()->route('admin.accounts.index')->with('success', 'Akun berhasil diperbarui');
        }

        return back()->with('error', 'Gagal memperbarui akun: ' . $response->json('message', 'Error unknown'));
    }

    public function destroy($id)
    {
        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->delete($this->baseUrl() . '/' . $id);
        
        if ($response->successful()) {
            return redirect()->route('admin.accounts.index')->with('success', 'Users berhasil dihapus');
        }
        
        return back()->with('error', 'Gagal menghapus user: ' . $response->json('message', 'Error unknown'));
    }

    public function destroyMultiple(Request $request)
    {
        $idList = $request->input('selected_ids', []);
        
        if (empty($idList)) {
            return back()->with('error', 'Tidak ada user yang dipilih untuk dihapus');
        }

        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->delete($this->baseUrl() . '/multiple', [
            'ids' => $idList,
        ]);


        if ($response->successful()) {
            return redirect()->route('admin.accounts.index')->with('success', 'Users berhasil dihapus');
        }
        
        return back()->with('error', 'Gagal menghapus user: ' . $response->json('message', 'Error unknown'));
    }

    public function ban($id)
    {
        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->patch($this->baseUrl() . "/{$id}/ban");

        if ($response->successful()) {
            return response()->json([
                'status' => 'success', 
                'message' => 'Status akun berhasil diperbarui'
            ]);
        }

        return response()->json([
            'status' => 'error', 
            'message' => 'Gagal memperbarui status akun: ' . $response->json('message', 'Error unknown')
        ], $response->status()); 
    }

    public function checkRfidStatus(Request $request)
    {
        $request->validate([
            'rfid_id' => 'required|string',
            'current_user_id' => 'required|string',
        ]);

        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->post($this->baseUrl() . '/check-rfid-status', [ // Sesuaikan dengan route Go
            'rfid_id' => $request->rfid_id,
            'current_user_id' => $request->current_user_id
        ]);

        // Cegah crash jika backend Go merespon dengan error (misal 404/500)
        if (!$response->successful()) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal terhubung ke backend Go (Status: ' . $response->status() . ')'
            ]);
        }

        return response()->json($response->json(), $response->status());
    }

    public function removeRfid($id)
    {
        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->post($this->baseUrl() . "/{$id}/remove-rfid");

        if (!$response->successful()) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal terhubung ke backend Go (Status: ' . $response->status() . ')'
            ]);
        }

        return response()->json($response->json(), $response->status());
    }

    public function charts(Request $request)
    {
        $currentMonth = Carbon::now()->month;
        $currentYear = Carbon::now()->year;
        
        $month = $request->input('bulan', $currentMonth);
        $year = $request->input('tahun', $currentYear);
        $class = $request->input('kelas', 'all');
        $search = $request->input('search', '');
        $page = $request->input('page', 1);
        
        $months = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember'
        ];
        
        $years = range($currentYear - 4, $currentYear);

        // Set Default Response Variables (Fallback jika error)
        $attendanceData = new LengthAwarePaginator([], 0, 10, 1);
        $chartData = ['labels' => [], 'productiveDays' => [], 'nonProductiveDays' => []];
        $totalProductiveDays = 0;
        $dataKelas = [];

        try {
            // Eksekusi HTTP Request secara paralel menggunakan Pool
            $responses = Http::timeout(10)
                ->retry(2, 100)
                ->pool(fn (\Illuminate\Http\Client\Pool $pool) => [
                    $pool->as('charts')
                        ->withHeaders([
                            'Authorization' => 'Bearer ' . session('access_token'),
                            'X-Session-ID'  => session('session_id'),
                        ])->get(env('VITE_APP_URL_BACKEND') . '/api/presensi/charts', [
                            'bulan'  => $month,
                            'tahun'  => $year,
                            'kelas'  => $class,
                            'search' => $search,
                            'page'   => $page,
                        ]),
                    $pool->as('kelas')
                        ->withHeaders([
                            'Authorization' => 'Bearer ' . session('access_token'),
                            'X-Session-ID'  => session('session_id'),
                        ])->get(env('VITE_APP_URL_BACKEND') . '/kelas', [
                            'sekolah' => env('ID_INSTANSI') // Sesuaikan param ini jika di-pass ke Go
                        ]),
                ]);

            // Proses Respons 'charts'
            if (isset($responses['charts']) && $responses['charts']->successful() && $responses['charts']->json('status') === 'success') {
                $apiData = $responses['charts']->json('data');

                $chartData = $apiData['chartData'] ?? $chartData;
                $totalProductiveDays = $apiData['totalProductiveDays'] ?? 0;

                $items = collect($apiData['attendanceData'] ?? [])->map(function($item) {
                    return (object) $item;
                });

                $meta = $apiData['meta'] ?? ['total_data' => 0, 'per_page' => 10, 'current_page' => 1];
                
                $attendanceData = new LengthAwarePaginator(
                    $items,
                    $meta['total_data'],
                    $meta['per_page'],
                    $meta['current_page'],
                    [
                        'path' => url()->current(), 
                        'query' => $request->query()
                    ]
                );
            } else {
                Log::warning("Gagal mengambil data charts dari API: " . ($responses['charts']->body() ?? 'No response body'));
            }

            // Proses Respons 'kelas'
            if (isset($responses['kelas']) && $responses['kelas']->successful()) {
                $kelasRaw = $responses['kelas']->json('data') ?? [];
                $dataKelas = collect($kelasRaw)->map(fn($item) => (object) $item);
            } else {
                Log::warning("Gagal mengambil data kelas dari API: " . ($responses['kelas']->body() ?? 'No response body'));
            }

        } catch (\Exception $e) {
            Log::error('Gagal mengambil data (Pool) untuk halaman chart presensi: ' . $e->getMessage());
        }
        
        return view('private.members.accounts.charts', compact(
            'attendanceData', 
            'chartData', 
            'months', 
            'years', 
            'currentMonth',
            'currentYear',
            'totalProductiveDays',
            'dataKelas' // Pastikan ini dikirim ke blade
        ));
    }
}

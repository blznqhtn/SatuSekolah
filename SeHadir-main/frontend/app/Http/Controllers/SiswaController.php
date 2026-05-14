<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\Client\Pool;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;
use Illuminate\Pagination\LengthAwarePaginator;

class SiswaController extends Controller
{
    private function baseUrl()
    {
        return env('VITE_APP_URL_BACKEND') . '/api/school-members';
    }

    public function index(Request $request)
    {
        $search = $request->query('search', '');
        $kelas  = $request->query('kelas', 'all');
        $page   = $request->query('page', 1);

        $apiParams = [
            'search'   => $search,
            'kelas_id' => $kelas, 
            'page'     => $page,
        ];

        $responses = Http::timeout(10)
        ->retry(2, 100)->pool(fn (\Illuminate\Http\Client\Pool $pool) => [
            $pool->as('members')
                ->withHeaders([
                    'Authorization' => 'Bearer ' . session('access_token'),
                    'X-Session-ID'  => session('session_id'),
                ])->get($this->baseUrl(), $apiParams),
            $pool->as('kelas')
                ->withHeaders([
                    'Authorization' => 'Bearer ' . session('access_token'),
                    'X-Session-ID'  => session('session_id'),
                ])
                ->get(env('VITE_APP_URL_BACKEND') . '/kelas', ['sekolah' => env('ID_INSTANSI')]),
        ]);

        $dataKelas = [];
        if (isset($responses['kelas']) && $responses['kelas']->successful()) {
            $kelasRaw = $responses['kelas']->json('data') ?? [];
            $dataKelas = collect($kelasRaw)->map(fn($item) => (object) $item);
        }

        if (isset($responses['members']) && $responses['members']->successful()) {
            $data = $responses['members']->json('data');
            $members = json_decode(json_encode($data['members'] ?? []));
            
            $schoolMembers = new \Illuminate\Pagination\LengthAwarePaginator(
                $members,
                $data['total'] ?? 0,
                $data['per_page'] ?? 10,
                $data['page'] ?? 1,
                [
                    'path' => $request->url(),
                    'query' => $request->query()
                ]
            );
        } else {
            $schoolMembers = new \Illuminate\Pagination\LengthAwarePaginator([], 0, 10, 1);
        }

        return view('private.members.users.index', compact('search', 'kelas', 'schoolMembers', 'dataKelas'));
    }

    public function create()
    {
        $response = Http::timeout(10)
            ->retry(2, 100)->withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->get(env('VITE_APP_URL_BACKEND') . '/kelas', ['sekolah' => env('ID_INSTANSI')]);

        $dataKelas = [];
        if ($response->successful()) {
            $kelasRaw = $response->json('data') ?? [];
            $dataKelas = collect($kelasRaw)->map(fn($item) => (object) $item);
        }

        return view('private.members.users.create', compact('dataKelas'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'no_induk' => 'required',
            'name' => 'required',
            'kelas' => 'required',
            'alamat' => 'nullable',
            'photo'          => 'required_without:existing_photo|image|max:2048|nullable',
            'existing_photo' => 'required_without:photo|string|nullable'
        ]);
        // dd('LOLOS VALIDASI!', $request->all());

        $http = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ]);

        if ($request->hasFile('photo')) {
            $file = $request->file('photo');
            $http = $http->attach('photo', file_get_contents($file), $file->getClientOriginalName());
        }else {
            $http = $http->asForm();
        }
        
        $response = $http->post($this->baseUrl(), [
            'no_induk'       => $request->no_induk,
            'name'           => $request->name,
            'id_kelas'       => $request->kelas,
            'alamat'         => $request->alamat,
            'sekolah'        => env('ID_INSTANSI'),
            'existing_photo' => $request->existing_photo 
        ]);

        if ($response->successful()) {
            return redirect()->route('admin.siswa.index')->with('success', 'Siswa berhasil ditambahkan');
        }

        return back()->with('error', 'Gagal menambahkan data: ' . $response->json('message', 'Error unknown'))->withInput();
    }

    public function edit($no_induk)
    {
        $responses = Http::timeout(10)
        ->retry(2, 100)->pool(fn (\Illuminate\Http\Client\Pool $pool) => [
            $pool->as('members')
                ->withHeaders([
                    'Authorization' => 'Bearer ' . session('access_token'),
                    'X-Session-ID'  => session('session_id'),
                ])->get($this->baseUrl() . '/' . $no_induk, ['sekolah' => env('ID_INSTANSI')]),
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

        if (isset($responses['members']) && $responses['members']->successful()) {
            $siswaRaw = $responses['members']->json('data');
            $siswa = json_decode(json_encode($siswaRaw));
        } else {
            return back()->with('error', 'Gagal mengambil data siswa: ' . ($responses['members']->json('message', 'Error unknown')));
        }

        return view('private.members.users.edit', compact('siswa', 'dataKelas'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required',
            'class' => 'required',
            'address' => 'nullable',
            'photo' => 'nullable|image|max:2048',
            'existing_photo' => 'required_without:photo|string|nullable'
        ]);            

        $http = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ]);

        $payload = [
            'name'           => $request->name,
            'id_kelas'       => $request->class,
            'alamat'         => $request->address,
            'existing_photo' => $request->existing_photo,
        ];
        
        if ($request->hasFile('photo')) {
            $file = $request->file('photo');
            $response = $http->attach('photo', file_get_contents($file), $file->getClientOriginalName())
                ->post($this->baseUrl() . '/' . $id, $payload);
        }else {
            $response = $http->asForm()->post($this->baseUrl() . '/' . $id, $payload);
        }

        if ($response->successful()) {
            return redirect()->route('admin.siswa.index')->with('success', 'Data siswa berhasil diperbarui');
        }

        return back()->with('error', 'Gagal memperbarui data: ' . $response->json('message', 'Error unknown'))->withInput();
    }

    public function destroy($id)
    {
        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->delete($this->baseUrl() . '/' . $id);
        
        if ($response->successful()) {
            return redirect()->route('admin.siswa.index')->with('success', 'Members berhasil dihapus');
        }
        
        return back()->with('error', 'Gagal menghapus member: ' . $response->json('message', 'Error unknown'));
    }

    public function destroyMultiple(Request $request)
    {
        $idList = $request->input('selected_ids', []);
        
        if (empty($idList)) {
            return back()->with('error', 'Tidak ada member yang dipilih untuk dihapus');
        }

        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->delete($this->baseUrl() . '/multiple', [
            'ids' => $idList,
        ]);

        if ($response->successful()) {
            return redirect()->route('admin.siswa.index')->with('success', 'Members berhasil dihapus');
        }
        
        return back()->with('error', 'Gagal menghapus member: ' . $response->json('message', 'Error unknown'));
    }

    public function fetchPhotos(){
        $response = Http::timeout(10)->retry(2, 100)->withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->get(env('VITE_APP_URL_BACKEND') . '/api/photos');

        if ($response->successful()) {
            $photos = $response->json('data') ?? [];
            return response()->json($photos); 
        }

        return response()->json([]);
    }

    public function downloadTemplate()
    {
        try {
            $response = Http::timeout(20)
                ->withHeaders([
                    'Authorization' => 'Bearer ' . session('access_token'),
                    'X-Session-ID'  => session('session_id'),
                ])
                ->get($this->baseUrl() . '/template');

            if ($response->successful()) {
                $fileContent = $response->body();
                
                $contentType = $response->header('Content-Type') ?? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

                return response($fileContent)
                    ->header('Content-Type', $contentType)
                    ->header('Content-Disposition', 'attachment; filename="template-members.xlsx"');
            }

            return back()->with('error', 'Gagal mengambil template dari server: ' . $response->status());

        } catch (\Exception $e) {
            return back()->with('error', 'Terjadi kesalahan sistem: ' . $e->getMessage());
        }
    }

    public function import(Request $request)
    {
        $request->validate([
            'excel_file' => 'required|mimes:xlsx,xls|max:5120',
            'zip_file'   => 'nullable|mimes:zip|max:20480',
        ]);

        try {
            $http = Http::timeout(120)->withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ]);

            $excel = $request->file('excel_file');
            $http->attach('excel_file', file_get_contents($excel), $excel->getClientOriginalName());

            if ($request->hasFile('zip_file')) {
                $zip = $request->file('zip_file');
                $http->attach('zip_file', file_get_contents($zip), $zip->getClientOriginalName());
            }

            $response = $http->post($this->baseUrl() . '/import');

            if ($response->successful()) {
                return redirect()->route('admin.siswa.index')->with('success', $response->json('message'));
            }

            return back()->with('error', 'Gagal: ' . $response->json('message'));
        } catch (\Exception $e) {
            return back()->with('error', 'Error: ' . $e->getMessage());
        }
    }
}

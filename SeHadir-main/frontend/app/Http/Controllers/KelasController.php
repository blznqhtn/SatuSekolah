<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class KelasController extends Controller
{
    public function index(){
        $response = Http::get(env('VITE_APP_URL_BACKEND') . '/kelas', [
            'sekolah' => env('ID_INSTANSI')
        ]);

        $dataKelas = []; 

        if ($response->successful()) {
            $dataKelas = $response->json('data') ?? []; 
        }

        return view('private.members.class.index', compact('dataKelas'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'kelas.*.name'    => 'required|string|max:255',
            'kelas.*.jenjang' => 'required|string|max:255',
        ]);

        $kelasData = $request->input('kelas', []);

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->post(env('VITE_APP_URL_BACKEND') . '/api/kelas', [
                'sekolah' => env('ID_INSTANSI'),
                'kelas'   => $kelasData,
            ]);

            if ($response->successful()) {
                return redirect()->back()->with('success', 'Data kelas berhasil disimpan!');
            } else {
                $errorMessage = $response->json('message') ?? 'Gagal menyimpan data kelas.';
                return redirect()->back()->with('error', $errorMessage);
            }
            
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Terjadi kesalahan saat menyimpan data kelas: ' . $e->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FaceController extends Controller
{
    private function baseUrl()
    {
        return env('VITE_APP_URL_BACKEND') . '/api';
    }
    
    public function index()
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->get($this->baseUrl() . '/school-members', [
                'method'      => 'face_registration',
            ]);
            
            
            if ($response->successful() && isset($response->json()['data']['members'])) {
                $studentsData = $response->json()['data']['members'];
            } else {
                $studentsData = [];
            }
            
            $students = json_decode(json_encode($studentsData));

        } catch (\Exception $e) {
            Log::error('Gagal mengambil data siswa dari API Go: ' . $e->getMessage());
            $students = [];
        }
        
        return view('private.faces.index', compact('students'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'student_id' => 'required',
            'face_images' => 'required|array|min:1',
        ]);

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->post($this->baseUrl() . '/face-registration/register', [
                'id_user'     => $request->student_id, 
                'face_images' => $request->face_images,
            ]);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => $response->json('message') ?? 'Data wajah berhasil didaftarkan.',
                    'student_id' => $request->student_id,
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'API Error: ' . ($response->json('message') ?? 'Gagal menyimpan data di server utama.')
            ], $response->status());

        } catch (\Exception $e) {
            Log::error('Gagal mengirim Face ID ke API Go: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan koneksi ke server utama.'
            ], 500);
        }
    }

    public function reset($nomor_induk)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])->post($this->baseUrl() . '/face-registration/reset/' . $nomor_induk);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => $response->json('message') ?? 'Face ID berhasil dihapus dari sistem.',
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'API Error: ' . ($response->json('message') ?? 'Gagal menghapus data di server.')
            ], $response->status());

        } catch (\Exception $e) {
            Log::error('Gagal reset Face ID: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan koneksi ke server utama.'
            ], 500);
        }
    }
}

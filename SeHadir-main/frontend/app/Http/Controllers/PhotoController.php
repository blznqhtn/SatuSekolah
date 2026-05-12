<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PhotoController extends Controller
{
    public function index() {
        $siswaController = new SiswaController();
        $response = $siswaController->fetchPhotos();
        $dataArray = $response->getData(true);
        $photos = collect($dataArray)->map(function($item) {
            return (object) $item;
        })->values()->all();

        return view('private.members.photos.index', compact('photos'));
    }

    public function uploadPhoto(Request $request) 
    {
        $request->validate([
            'photo_files'   => 'required|array',
            'photo_files.*' => 'required|image|mimes:jpeg,png,jpg|max:5120',
        ]);

        try {
            $http = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ]);

            $files = $request->file('photo_files');
            foreach ($files as $file) {
                $http->attach(
                    'photo_files', 
                    file_get_contents($file->getPathname()),
                    $file->getClientOriginalName()
                );
            }

            $response = $http->post(env('VITE_APP_URL_BACKEND') . '/api/photos/upload');

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Foto berhasil diunggah ke cloud storage!'
                ]);
            } else {
                $errorMessage = $response->json('message') ?? 'Gagal mengupload foto ke server backend.';
                return response()->json([
                    'success' => false,
                    'message' => $errorMessage
                ], $response->status());
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan sistem: ' . $e->getMessage()
            ], 500);
        }
    }

    public function destroyPhoto(Request $request) 
    {
        $request->validate([
            'filename' => 'required|string',
        ]);

        $filename = $request->input('filename');

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])
            ->asJson()
            ->delete(env('VITE_APP_URL_BACKEND') . '/api/photos/delete', [
                'filename' => $filename,
                'sekolah'  => env('ID_INSTANSI'),
            ]);

            if ($response->successful()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Foto berhasil dihapus!'
                ]);
            } else {
                $errorMessage = $response->json('message') ?? 'Gagal menghapus foto di server backend.';
                return response()->json([
                    'success' => false,
                    'message' => $errorMessage
                ], $response->status());
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan sistem: ' . $e->getMessage()
            ], 500);
        }
    }
}

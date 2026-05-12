<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class SettingController extends Controller
{
    public function index()
    {
        $userId = session('user_id');

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->get(env('VITE_APP_URL_BACKEND') . '/api/settings/' . $userId);

        $settings = (object) [
            'attendance_method'             => 'rfid',
            'sp_enabled'                    => false,
            'whatsapp_notification_enabled' => false,
            'sp_max_late_per_month'         => 3,
            'whatsapp_number'               => '',
            'apikey_whatsapp'               => '',
            'nama_sekolah'                  => '',
            'kepala_sekolah'                => '',
            'nama_perwakilan_tu'            => '',
            'alamat'                        => '',
            'email'                         => '',
            'website'                       => '',
            'ikon'                          => null,
        ];

        if ($response->successful()) {
            $apiData = $response->json();
            
            if (!empty($apiData['data'])) {
                $settings = (object) array_merge((array) $settings, $apiData['data'][0]);
            }

            if (isset($apiData['sekolah'])) {
                $settings->whatsapp_number    = $apiData['sekolah']['whatsapp'] ?? '';
                $settings->apikey_whatsapp    = $apiData['sekolah']['apikey_whatsapp'] ?? '';
                $settings->nama_sekolah       = $apiData['sekolah']['nama_sekolah'] ?? '';
                $settings->kepala_sekolah     = $apiData['sekolah']['kepala_sekolah'] ?? '';
                $settings->nama_perwakilan_tu = $apiData['sekolah']['nama_perwakilan_tu'] ?? '';
                $settings->alamat             = $apiData['sekolah']['alamat'] ?? '';
                $settings->email              = $apiData['sekolah']['email'] ?? '';
                $settings->website            = $apiData['sekolah']['website'] ?? '';
                $settings->ikon               = $apiData['sekolah']['ikon'] ?? null;
            }
        }

        return view('private.settings.index', compact('settings'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'attendance_method'             => 'required|in:rfid,face_id,both',
            'sp_max_late_per_month'         => 'required|integer|min:1|max:31',
            'face_confidence_threshold'     => 'nullable|numeric|min:0.1|max:1',
            
            'nama_sekolah'                  => 'required|string|max:255',
            'kepala_sekolah'                => 'nullable|string|max:191',
            'nama_perwakilan_tu'            => 'nullable|string|max:191',
            'whatsapp_number'               => 'nullable|string|max:20',
            'apikey_whatsapp'               => 'nullable|string|max:255',
            'email'                         => 'nullable|email|max:191',
            'website'                       => 'nullable|url|max:191',
            'alamat'                        => 'nullable|string',
            'ikon'                          => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // Maksimal 2MB
        ]);

        if ($request->has('whatsapp_notification_enabled') && empty($request->whatsapp_number)) {
            return redirect()->back()->with('error', 'Nomor WhatsApp wajib diisi jika notifikasi diaktifkan.')->withInput();
        }

        $userId = session('user_id');

        $logoPath = null;
        if ($request->hasFile('ikon')) {
            $file = $request->file('ikon');
            $logoPath = $file->store('logos', 'public'); 
        }

        $payload = [
            'service'                       => 'attendance_system',
            
            'attendance_method'             => $request->attendance_method,
            'face_recognition_enabled'      => in_array($request->attendance_method, ['face_id', 'both']),
            'anti_spoofing_enabled'         => $request->has('anti_spoofing_enabled'),
            'face_confidence_threshold'     => (float) ($request->face_confidence_threshold ?? 0.8),
            'sp_enabled'                    => $request->has('sp_enabled'),
            'whatsapp_notification_enabled' => $request->has('whatsapp_notification_enabled'),
            'sp_max_late_per_month'         => (int) $request->sp_max_late_per_month,
            
            'nama_sekolah'                  => $request->nama_sekolah,
            'kepala_sekolah'                => $request->kepala_sekolah,
            'nama_perwakilan_tu'            => $request->nama_perwakilan_tu,
            'whatsapp'                      => $request->whatsapp_number,
            'apikey_whatsapp'               => $request->apikey_whatsapp,
            'email'                         => $request->email,
            'website'                       => $request->website,
            'alamat'                        => $request->alamat,
        ];

        if ($logoPath) {
            $payload['ikon'] = $logoPath;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . session('access_token'),
                'X-Session-ID'  => session('session_id'),
            ])
            ->asJson()
            ->post(env('VITE_APP_URL_BACKEND') . '/api/settings/' . $userId, $payload);

            if ($response->successful()) {
                return redirect()->back()->with('success', 'Pengaturan dan Informasi Sekolah berhasil disimpan!');
            }

            $errorMessage = $response->json('message') ?? 'Gagal menyimpan pengaturan ke server.';
            return redirect()->back()->with('error', $errorMessage);

        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Terjadi kesalahan sistem: ' . $e->getMessage());
        }
    }
}
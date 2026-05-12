<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class FormController extends Controller
{
    private function getBackendUrl()
    {
        return env('VITE_APP_URL_BACKEND') . '/api';
    }

    public function showArrivalForm(Request $request)
    {
        $token = $request->query('token');
        // return $token;
        if (!$token) {
            return abort(404, 'Token tidak ditemukan');
        }

        $response = Http::get($this->getBackendUrl() . '/late/arrival', [
            'token' => $token
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return view('public.forms.arrival-late', [
                'user' => json_decode(json_encode($data['user'])),
                'lateEntry' => json_decode(json_encode($data['late_entry'])),
            ]);
        }

        return abort(404, 'Token tidak valid atau kadaluwarsa');
    }

    public function storeArrival(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'alasan' => 'required|string|max:255',
        ]);

        $response = Http::post($this->getBackendUrl() . '/late/arrival', [
            'token' => $request->token,
            'alasan' => $request->alasan,
        ]);

        if ($response->successful()) {
            return redirect()->route('main')->with('success', 'Presensi terlambat berhasil disimpan.');
        }

        return back()->with('error', $response->json('message') ?? 'Gagal menyimpan presensi.');
    }

    public function showDepartureForm(Request $request)
    {
        $token = $request->query('token');
        if (!$token) {
            return abort(404, 'Token tidak ditemukan');
        }

        $response = Http::get($this->getBackendUrl() . '/late/departure', [
            'token' => $token
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return view('public.forms.departure-late', [
                'user' => json_decode(json_encode($data['user'])),
                'lateEntry' => json_decode(json_encode($data['late_entry'])),
            ]);
        }

        return abort(404, 'Token tidak valid atau kadaluwarsa');
    }

    public function storeDeparture(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'alasan' => 'required|string|max:255',
        ]);

        // dd($request->all());

        $response = Http::post($this->getBackendUrl() . '/late/departure', [
            'token' => $request->token,
            'alasan' => $request->alasan,
        ]);

        if ($response->successful()) {
            return redirect()->route('main')->with('success', 'Formulir kepulangan terlambat berhasil disubmit.');
        }

        return back()->with('error', $response->json('message') ?? 'Gagal memproses formulir.');
    }

    public function showReasonForm(Request $request)
    {
        $token = $request->query('token');
        if (!$token) {
            return abort(404, 'Token tidak ditemukan');
        }

        $response = Http::get($this->getBackendUrl() . '/reason/coming', [
            'token' => $token
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return view('public.forms.special-attendance', [
                'user' => json_decode(json_encode($data['user'])),
                'reasonEntry' => json_decode(json_encode($data['reason_entry'])),
            ]);
        }

        return abort(404, 'Token tidak valid atau kadaluwarsa');
    }

    public function storeReason(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'alasan' => 'required|string|max:255',
        ]);

        $response = Http::post($this->getBackendUrl() . '/reason/coming', [
            'token' => $request->token,
            'alasan' => $request->alasan,
        ]);

        if ($response->successful()) {
            return redirect()->route('main')->with('success', 'Presensi alasan berhasil disimpan.');
        }

        return back()->with('error', $response->json('message') ?? 'Gagal memproses formulir.');
    }

    public function showEarlyDepartureForm(Request $request)
    {
        $token = $request->query('token');
        if (!$token) {
            return abort(404, 'Token tidak ditemukan');
        }

        $response = Http::get($this->getBackendUrl() . '/early/departure', [
            'token' => $token
        ]);

        if ($response->successful()) {
            $data = $response->json();
            return view('public.forms.early-departure', [
                'user' => json_decode(json_encode($data['user'])),
                'earlyEntry' => json_decode(json_encode($data['early_entry'])),
            ]);
        }

        return abort(404, 'Token tidak valid atau kadaluwarsa');
    }

    public function storeEarlyDeparture(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'alasan' => 'required|string|max:255',
        ]);

        $response = Http::post($this->getBackendUrl() . '/early/departure', [
            'token' => $request->token,
            'alasan' => $request->alasan,
        ]);

        if ($response->successful()) {
            return redirect()->route('main')->with('success', 'Presensi pulang awal berhasil disimpan.');
        }

        return back()->with('error', $response->json('message') ?? 'Gagal memproses formulir.');
    }
}

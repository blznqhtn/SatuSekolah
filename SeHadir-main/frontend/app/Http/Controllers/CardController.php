<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class CardController extends Controller
{
    public function index()
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->get(env('VITE_APP_URL_BACKEND') . '/api/school-members/no-rfid');

        $users = [];
        if ($response->successful()) {
            $users = $response->json('data') ?? [];
        }

        return view('private.cards.index', compact('users'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'uid'     => 'required|string',
            'user_id' => 'required|string'
        ]);

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->post(env('VITE_APP_URL_BACKEND') . '/api/school-members/rfid-connect', [
            'uid'     => $request->uid,
            'user_id' => $request->user_id
        ]);

        return response()->json($response->json(), $response->status());
    }

    public function checkStatus($id)
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . session('access_token'),
            'X-Session-ID'  => session('session_id'),
        ])->get(env('VITE_APP_URL_BACKEND') . '/api/users/checkStatusCard/' . $id);

        return response()->json($response->json(), $response->status());
    }
}

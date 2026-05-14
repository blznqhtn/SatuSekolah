<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AuthController extends Controller
{
    public function login()
    {
        return view('public.auth.login');
    }

    public function process_login(Request $request)
    {
        $credentials = $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ],
        [
            'username.required' => 'Username wajib diisi',
            'password.required' => 'Password wajib diisi',
        ]);

        $response = Http::withHeaders([
            'Accept' => 'application/json',
        ])
        ->replaceHeaders(['Authorization' => null])
        ->post(env('VITE_APP_URL_BACKEND') . '/api/auth/login', [
            'type'     => 'admin',
            'username' => $credentials['username'],
            'password' => $credentials['password'],
            'sekolah' => env('ID_INSTANSI')
        ]);

        $data = $response->json();
        // dd($data);

        if ($response->failed() || (isset($data['status']) && $data['status'] === 'failed')) {
            return back()
                ->withInput($request->only('username'))
                ->withErrors(['login' => $data['message'] ?? 'Login gagal.']);
        }
        
        session([
            'is_login'      => true,
            'user_id'       => $data['uid'] ?? null,
            'role'          => $data['role'] ?? null,
            'access_token'  => $data['access_token'],
            'refresh_token' => $data['refresh_token'] ?? null,
            'session_id'    => $data['session_id'] ?? null,
        ]);

        return redirect('/admin/dashboard');
    }

    function logout(Request $request)
    {
        $token = session('access_token');

        if ($token) {
            Http::withToken($token)->post(env('VITE_APP_URL_BACKEND') . '/api/auth/logout');
        }

        $request->session()->flush();

        return redirect('/login');
    }
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ValidateToken
{
    public function handle(Request $request, Closure $next)
    {
        if (!session('is_login') || !session('access_token')) {
            return redirect('/login');
        }

        $response = Http::withToken(session('access_token'))
            ->withHeaders(['X-Session-ID' => session('session_id')])
            ->get(env('VITE_APP_URL_BACKEND') . '/api/auth/me');

        if ($response->status() === 401 && session('refresh_token')) {
            $refresh = Http::withHeaders(['X-Session-ID' => session('session_id')])
                ->post(env('VITE_APP_URL_BACKEND') . '/api/auth/refresh', [
                    'refresh_token' => session('refresh_token')
                ]);

            if ($refresh->successful()) {
                session([
                    'access_token'  => $refresh->json('access_token'),
                    'refresh_token' => $refresh->json('refresh_token'),
                ]);

                return $next($request);
            }
        }

        if ($response->status() === 401) {
            session()->invalidate();
            session()->regenerateToken();
            return redirect('/login')->withErrors(['login' => 'Sesi habis atau tidak valid.']);
        }

        return $next($request);
    }
}
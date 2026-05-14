<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class MainController extends Controller
{
    public function index()
    {
        return view('public.main');
    }

    public function reviews()
    {
        $reviews = Cache::remember(md5('google_reviews'), now()->addHours(3), function () {
            $backendUrl = env('VITE_APP_URL_BACKEND', 'http://localhost:8080'); 
            $response = Http::get($backendUrl . '/get-reviews');

            if ($response->successful()) {
                return $response->json();
            }

            return null;
        });

        if (!$reviews) {
            return response()->json(['error' => 'Gagal mengambil ulasan'], 500);
        }

        return response()->json($reviews);
    }

    public function policy()
    {
        return view('public.privacy');
    }

    public function terms()
    {
        return view('public.terms');
    }

    public function helpCenter()
    {
        return view('public.help-center');
    }
}

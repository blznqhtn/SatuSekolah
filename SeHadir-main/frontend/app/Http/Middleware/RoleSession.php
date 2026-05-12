<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleSession
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next, $role): Response
    {
        if (!session('is_login') || !session('access_token')) {
            session()->flush();
            return redirect('/login');
        }

        if (session('role') !== $role) {
            abort(403);
        }

        return $next($request);
    }
}

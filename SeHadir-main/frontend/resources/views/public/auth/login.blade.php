<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | SeHadir</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="icon" href="{{ asset('src/logo_raadeveloperz.png') }}" type="image/png">
    @vite([
        // 'resources/js/layouts.js',
        'resources/css/app.css',
    ])
    <style>
        /* Additional modern styles beyond Tailwind */
        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .dark .glass-card {
            background: rgba(31, 41, 55, 0.85);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .glass-card:hover {
            transform: scale(1.02) translateY(-5px);
            box-shadow: 0 25px 40px -12px rgba(0, 0, 0, 0.25);
        }
        .input-modern:focus {
            box-shadow: 0 0 0 3px rgba(30, 64, 175, 0.3);
        }
        .btn-glow {
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .btn-glow::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s ease;
        }
        .btn-glow:hover::before {
            left: 100%;
        }
        .btn-glow:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -5px rgba(30, 64, 175, 0.4);
        }
        .animate-float {
            animation: float 6s ease-in-out infinite;
        }
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
            100% { transform: translateY(0px); }
        }
        .bg-gradient-animated {
            background: linear-gradient(270deg, #0f2b4d, #1e3a8a, #0f2b4d);
            background-size: 200% 200%;
            animation: gradientShift 8s ease infinite;
        }
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        /* Responsive adjustments */
        @media (max-width: 640px) {
            .glass-card {
                backdrop-filter: blur(5px);
            }
        }
        /* Password toggle button styling */
        .password-toggle {
            cursor: pointer;
            transition: color 0.2s;
        }
        .password-toggle:hover {
            color: #3b82f6;
        }
    </style>
</head>

<body class="antialiased bg-gradient-animated dark:bg-gray-900 min-h-screen flex items-center justify-center p-4 relative overflow-hidden">
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute top-10 left-10 w-64 h-64 bg-blue-700 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-float"></div>
        <div class="absolute bottom-10 right-10 w-80 h-80 bg-indigo-800 rounded-full mix-blend-multiply filter blur-3xl opacity-20 animate-float" style="animation-delay: -2s;"></div>
        <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-full h-full max-w-2xl max-h-2xl bg-linear-to-r from-blue-800 to-indigo-900 rounded-full filter blur-3xl opacity-10"></div>
    </div>

    <div class="w-full max-w-md relative z-10">
        <div class="glass-card rounded-2xl shadow-2xl p-6 sm:p-8 transition-all duration-700 ease-in-out">
            <div class="mb-8 text-center">
                <img src="{{ asset('src/logo_raadeveloperz.png') }}" loading="lazy" class="w-auto h-20 mx-auto mb-2 animate-float" alt="SeHadir Logo">
                <p class="text-gray-600 dark:text-gray-300 text-sm sm:text-base font-medium">Selamat datang! Silakan masuk</p>
            </div>

            @if ($errors->has('login'))
                <div class="mb-4 p-4 bg-red-100/90 dark:bg-red-900/80 backdrop-blur-sm text-red-700 dark:text-red-200 rounded-xl text-sm border border-red-200 dark:border-red-800 shadow-sm">
                    {{ $errors->first('login') }}
                </div>
            @endif

            @if(session('success'))
                <div class="mb-4 p-4 bg-green-100/90 dark:bg-green-900/80 backdrop-blur-sm text-green-700 dark:text-green-200 rounded-xl text-sm border border-green-200 dark:border-green-800 shadow-sm">
                    {{ session('success') }}
                </div>
            @endif

            <form action="{{ route('login.process') }}" method="POST">
                @csrf

                <div class="mb-6">
                    <label for="username" class="block text-sm font-semibold text-gray-700 dark:text-gray-200 mb-2">Nama Pengguna</label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                            <i class="fa-regular fa-user text-gray-400"></i>
                        </div>
                        <input type="text" id="username" name="username"
                            class="input-modern w-full pl-10 pr-4 py-2.5 border rounded-xl focus:ring-2 focus:ring-blue-800 focus:border-blue-800 
                            bg-white/80 dark:bg-gray-700/80 border-gray-300 dark:border-gray-600 text-gray-900
                            placeholder-gray-400 dark:placeholder-gray-400 outline-none transition-all text-sm sm:text-base"
                            placeholder="Masukkan nama pengguna"
                            value="{{ old('username') }}">
                    </div>
                    @error('username')
                        <p class="mt-1 text-xs text-red-600 dark:text-red-400">{{ $message }}</p>
                    @enderror
                </div>

                <div class="mb-6">
                    <div class="flex justify-between mb-2">
                        <label for="password" class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Kata Sandi</label>
                    </div>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                            <i class="fa-solid fa-lock text-gray-400"></i>
                        </div>
                        <input type="password" id="password" name="password"
                            class="input-modern w-full pl-10 pr-10 py-2.5 border rounded-xl focus:ring-2 focus:ring-blue-800 focus:border-blue-800 
                            bg-white/80 dark:bg-gray-700/80 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white 
                            placeholder-gray-400 dark:placeholder-gray-400 outline-none transition-all text-sm sm:text-base"
                            placeholder="Masukkan kata sandi">
                        <div class="absolute inset-y-0 right-0 pr-4 flex items-center">
                            <i class="fa-regular fa-eye password-toggle mt-0.5 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" id="togglePassword"></i>
                        </div>
                    </div>
                    @error('password')
                        <p class="mt-1 text-xs text-red-600 dark:text-red-400">{{ $message }}</p>
                    @enderror
                </div>

                <button type="submit"
                    class="btn-glow w-full bg-linear-to-r from-blue-800 to-indigo-800 hover:from-blue-900 hover:to-indigo-900 text-white font-semibold py-2.5 px-4 rounded-xl transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-blue-800 focus:ring-offset-2 cursor-pointer text-sm sm:text-base shadow-md">
                    <i class="fa-solid fa-arrow-right-to-bracket mr-2"></i> Masuk
                </button>
            </form>

            <div class="mt-6 text-center text-xs text-gray-500 dark:text-gray-400">
                &copy; {{ date('Y') }} SeHadir. Seluruh hak dilindungi undang-undang. <br> v3.0.0
            </div>
        </div>

        <button type="button" onclick="window.location.href='{{ route('main') }}'"
            class="btn-glow w-full bg-linear-to-r from-orange-500 to-red-800 hover:from-orange-600 hover:to-red-800 text-white font-semibold py-2.5 px-4 rounded-xl transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-blue-800 focus:ring-offset-2 cursor-pointer text-sm sm:text-base shadow-md mt-5">
            <i class="fa-solid fa-arrow-left mr-2"></i> Kembali
        </button>
    </div>

    <script>
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');

        if (togglePassword && passwordInput) {
            togglePassword.addEventListener('click', function() {
                const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
                passwordInput.setAttribute('type', type);
                this.classList.toggle('fa-eye');
                this.classList.toggle('fa-eye-slash');
            });
        }
    </script>
</body>

</html>
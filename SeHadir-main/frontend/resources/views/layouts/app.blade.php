<!DOCTYPE html>
<html lang="en" class="h-full">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta property="og:title" content="SeHadir | Sistem Absensi Siswa Modern dengan RFID dan FaceID">
    <meta name="description" content="SeHadir adalah sistem absensi digital berbasis RFID dan FaceID yang dirancang khusus untuk sekolah. Dengan fitur canggih seperti absensi kartu RFID dan face recognition, analisis data kehadiran, dan laporan komprehensif, SeHadir membantu meningkatkan efisiensi dan kedisiplinan siswa.">
    <meta name="keywords" content="SeHadir, sistem absensi digital, RFID, FaceID, sekolah, kehadiran siswa, laporan kehadiran, analisis data kehadiran">
    <meta property="og:description" content="SeHadir adalah sistem absensi digital berbasis RFID dan FaceID yang dirancang khusus untuk sekolah. Dengan fitur canggih seperti absensi kartu RFID dan face recognition, analisis data kehadiran, dan laporan komprehensif, SeHadir membantu meningkatkan efisiensi dan kedisiplinan siswa.">
    <meta name="author" content="raadeveloperz">
    <meta property="og:image" content="{{ asset('src/logo_raadeveloperz.png') }}">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>@yield('title', 'SeHadir | Sistem Absensi Siswa Modern dengan RFID dan FaceID') | SeHadir</title>
    
    <link rel="icon" href="{{ asset('src/logo_raadeveloperz.png') }}" type="image/png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script>
        axios.defaults.headers.common['X-CSRF-TOKEN'] = document.querySelector('meta[name="csrf-token"]').getAttribute(
            'content');
    </script>
    
    @vite([
        'resources/js/layouts.js',
        'resources/css/app.css',
        'resources/css/layouts.css'
    ])  
    
    @stack('styles')
</head>

<body class="antialiased h-full bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <div class="min-h-full">
        @include('public.partials.navbar')

        <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
            @yield('content')
        </main>
    </div>

    @include('public.partials.footer')

    @stack('scripts')
</body>
</html>
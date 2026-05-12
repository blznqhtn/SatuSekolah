<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta property="og:title" content="SeHadir | Sistem Absensi Siswa Modern dengan RFID dan FaceID">
    <meta name="description"
        content="SeHadir adalah sistem absensi digital berbasis RFID dan FaceID yang dirancang khusus untuk sekolah. Dengan fitur canggih seperti absensi kartu RFID dan face recognition, analisis data kehadiran, dan laporan komprehensif, SeHadir membantu meningkatkan efisiensi dan kedisiplinan siswa.">
    <meta name="keywords"
        content="SeHadir, sistem absensi digital, RFID, FaceID, sekolah, kehadiran siswa, laporan kehadiran, analisis data kehadiran">
    <meta property="og:description"
        content="SeHadir adalah sistem absensi digital berbasis RFID dan FaceID yang dirancang khusus untuk sekolah. Dengan fitur canggih seperti absensi kartu RFID dan face recognition, analisis data kehadiran, dan laporan komprehensif, SeHadir membantu meningkatkan efisiensi dan kedisiplinan siswa.">
    <meta name="author" content="raadeveloperz">
    <meta property="og:image" content="{{ asset('src/logo_raadeveloperz.png') }}">

    <title>SeHadir | Sistem Absensi Siswa Modern dengan RFID dan FaceID</title>

    <link rel="icon" href="{{ asset('src/logo_raadeveloperz.png') }}" type="image/png">
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>

    @vite(['resources/css/app.css', 'resources/css/main.css'])
</head>

<body class="bg-gray-900 text-gray-100 font-sans-main custom-scrollbar">
    @include('public.partials.main.navbar')
    @include('public.partials.main.hero')
    @include('public.partials.main.feature')
    @include('public.partials.main.about')
    @include('public.partials.main.benefit')
    @include('public.partials.main.contact')
    @include('public.partials.main.review')
    @include('public.partials.footer')

    @vite(['resources/js/main.js'])
</body>

</html>

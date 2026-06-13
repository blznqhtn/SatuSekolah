const fs = require('fs');
const path = require('path');

const dashboardDir = path.join(__dirname, '../src/app/dashboard');

// Obsolete dirs to delete
const obsoleteDirs = ['akademik', 'finansial', 'khusus', 'manajemen'];
obsoleteDirs.forEach(dir => {
  const p = path.join(dashboardDir, dir);
  if (fs.existsSync(p)) {
    fs.rmSync(p, { recursive: true, force: true });
    console.log(`Deleted obsolete folder: ${dir}`);
  }
});

// The pages we need to create
const pages = [
  { path: 'users', name: 'Manajemen Pengguna', endpoint: '/users' },
  { path: 'communication', name: 'Pesan & Komunikasi', endpoint: '/communication' },
  { path: 'academic', name: 'Jadwal & Kelas', endpoint: '/academic' },
  { path: 'attendance', name: 'Kehadiran / Presensi', endpoint: '/attendance' },
  { path: 'lms', name: 'E-Learning (LMS)', endpoint: '/lms' },
  { path: 'cba', name: 'Ujian Komputer (CBA)', endpoint: '/cba' },
  { path: 'reports', name: 'Rapor Digital', endpoint: '/reports' },
  { path: 'spmb', name: 'Penerimaan Siswa (PPDB)', endpoint: '/spmb' },
  { path: 'calendar', name: 'Kalender Akademik', endpoint: '/calendar' },
  { path: 'inventory', name: 'Inventaris & Aset', endpoint: '/inventory' },
  { path: 'gatepass', name: 'Surat Izin (Gatepass)', endpoint: '/gatepass' },
  { path: 'gatepass/scan', name: 'Scan QR Gatepass', endpoint: '/gatepass/scan' },
  { path: 'finance/invoices', name: 'Tagihan & Pembayaran', endpoint: '/finance/invoices' },
  { path: 'finance/payroll', name: 'Penggajian (Payroll)', endpoint: '/finance/payroll' },
  { path: 'canteen', name: 'Manajemen Kantin', endpoint: '/canteen' },
  { path: 'violations', name: 'Poin & Pelanggaran', endpoint: '/violations' },
  { path: 'health', name: 'Kesehatan (UKS)', endpoint: '/health' },
  { path: 'portfolio', name: 'Portofolio Siswa', endpoint: '/portfolio' },
  { path: 'career', name: 'Bursa Kerja (BKK)', endpoint: '/career' },
  { path: 'performance', name: 'Prakerin & PKL', endpoint: '/performance' },
  { path: 'pkg', name: 'Penilaian Kinerja', endpoint: '/pkg' },
  { path: 'library', name: 'Perpustakaan Digital', endpoint: '/library' },
  { path: 'ai', name: 'Pusat Kontrol AI', endpoint: '/ai' },
  { path: 'teacher/rpp', name: 'Perangkat Pembelajaran', endpoint: '/teacher/rpp' },
  { path: 'teacher/media', name: 'Media & Dokumentasi', endpoint: '/teacher/media' },
  { path: 'teacher/monitoring-pkl', name: 'Laporan Monitoring PKL', endpoint: '/teacher/monitoring-pkl' },
  { path: 'teacher/inventory', name: 'Laporan Sarpras', endpoint: '/teacher/inventory' },
  { path: 'teacher/certificates', name: 'Sertifikat Pelatihan', endpoint: '/teacher/certificates' },
  { path: 'teacher/assignments', name: 'Surat Tugas & SK', endpoint: '/teacher/assignments' },
  { path: 'teacher/observation', name: 'Observasi Kelas', endpoint: '/teacher/observation' }
];

pages.forEach(p => {
  const dirPath = path.join(dashboardDir, p.path);
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }

  const filePath = path.join(dirPath, 'page.tsx');
  
  // Calculate relative path for imports
  const depth = p.path.split('/').length;
  const importPrefix = '@'; // We are using absolute path alias

  const content = `"use client"

import React from "react"
import { DataTableTemplate } from "@/components/dashboard/data-table-template"

export default function Page() {
  return (
    <DataTableTemplate 
      moduleName="${p.name}"
      endpoint="${p.endpoint}"
    />
  )
}
`;

  fs.writeFileSync(filePath, content);
  console.log(`Created page: ${p.path}/page.tsx`);
});

console.log('All pages generated successfully.');

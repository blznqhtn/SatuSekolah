"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { FileText, Download, CheckCircle2, Award, Printer } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  // Sample data fallback for academic report cards
  const sampleReportData = [
    { id: "1", student_name: "Ahmad Rizky Pratama", class_name: "X-MIPA 1", average: 89.5, rank: 1, notes: "Prestasi akademik sangat baik, aktif dalam OSIS", status: "SIAP_CETAK" },
    { id: "2", student_name: "Anisa Putri Rahayu", class_name: "X-MIPA 1", average: 88.2, rank: 2, notes: "Memiliki pemahaman konsep matematika yang kuat", status: "SIAP_CETAK" },
    { id: "3", student_name: "Bayu Saputra", class_name: "X-MIPA 1", average: 85.0, rank: 3, notes: "Tingkatkan ketelitian dalam tugas praktikum fisika", status: "SIAP_CETAK" },
    { id: "4", student_name: "Cantika Dewi", class_name: "X-MIPA 1", average: 84.1, rank: 4, notes: "Sangat antusias dalam pelajaran bahasa inggris", status: "DRAF" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "student",
      label: "Siswa & Kelas",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <FileText className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.student_name}</span>
            <span className="text-[11px] text-muted-foreground">{item.class_name || "Kelas X"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "average",
      label: "Nilai Rata-rata & Peringkat",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-2">
          <span className="font-mono text-sm font-bold text-slate-800">{item.average}</span>
          <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full border border-amber-200">
            <Award className="w-3 h-3 text-amber-500" />
            Rank #{item.rank || 1}
          </span>
        </div>
      ),
    },
    {
      key: "notes",
      label: "Catatan Wali Kelas",
      render: (item) => (
        <span className="text-xs text-slate-600 max-w-sm truncate block">
          {item.notes}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status Rapor",
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" /> Siap Cetak
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-1.5">
          <button
            onClick={() => alert(`Mencetak Rapor Digital PDF resmi ber-barcode untuk ${item.student_name}...`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            <Printer className="w-3 h-3" />
            Cetak PDF
          </button>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Rapor Digital & Buku Induk Nilai"
      description="Penerbitan rapor semester resmi kurikulum nasional ber-barcode, catatan wali kelas otomatis, dan cetak PDF masal."
      endpoint="/reports/academic"
      customData={sampleReportData}
      columns={columns}
      hideAddButton
      headerActions={
        <button
          onClick={() => alert("Mengunduh Template Nilai Excel untuk Import Nilai Massal...")}
          className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-[#4b25bb] hover:bg-[#3d1ea0] rounded-lg shadow-sm transition-colors"
        >
          <Download className="w-3.5 h-3.5" />
          Template Excel Nilai
        </button>
      }
      refreshTrigger={refreshKey}
    />
  )
}

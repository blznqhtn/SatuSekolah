"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { FileText, Download, CheckCircle2, Award, Printer } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

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
          <div className="w-8 h-8 rounded-lg bg-[#2563eb]/10 text-[#2563eb] flex items-center justify-center font-bold text-xs">
            <FileText className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.student_name || item.name || "Nama Siswa"}</span>
            <span className="text-[11px] text-muted-foreground">{item.class_name || item.course_name || "Kelas"}</span>
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
          <span className="font-mono text-sm font-bold text-slate-800">{item.average ?? item.score ?? "—"}</span>
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
          {item.notes || item.feedback || "—"}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status Rapor",
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" /> {item.status || "Siap Cetak"}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-1.5">
          <button
            onClick={() => alert(`Mencetak Rapor Digital PDF resmi ber-barcode untuk ${item.student_name || item.name}...`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#2563eb] hover:bg-[#2563eb]/10 border border-[#2563eb]/20 rounded-lg transition-colors"
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
      description="Penerbitan rapor semester resmi kurikulum nasional ber-barcode, catatan wali kelas otomatis, dan cetak PDF masal dari database API."
      endpoint="/reports/academic"
      columns={columns}
      hideAddButton
      headerActions={
        <button
          onClick={() => alert("Mengunduh Template Nilai Excel untuk Import Nilai Massal...")}
          className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-[#2563eb] hover:bg-[#1e3a8a] rounded-lg shadow-sm transition-colors"
        >
          <Download className="w-3.5 h-3.5" />
          Template Excel Nilai
        </button>
      }
      refreshTrigger={refreshKey}
    />
  )
}

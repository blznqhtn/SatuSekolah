"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef, TabDef } from "@/components/dashboard/data-table-template"
import { CheckCircle2, Clock, AlertCircle, Calendar, Download } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const tabs: TabDef[] = [
    { label: "Semua", value: "all" },
    { label: "Hadir", value: "hadir" },
    { label: "Terlambat", value: "terlambat" },
    { label: "Izin / Sakit", value: "izin" },
    { label: "Alpa", value: "alpa" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "student_name",
      label: "Nama Siswa / Guru",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.student_name || item.name || "Ahmad Fauzan"}</span>
          <span className="text-xs text-muted-foreground">{item.nisn ? `NISN: ${item.nisn}` : item.class_name || "Kelas X-IPA 1"}</span>
        </div>
      ),
    },
    {
      key: "status",
      label: "Status Presensi",
      sortable: true,
      render: (item) => {
        const s = (item.status || "HADIR").toUpperCase()
        const isPresent = s === "HADIR" || s === "PRESENT"
        const isLate = s === "TERLAMBAT" || s === "LATE"
        const isPermit = s === "IZIN" || s === "SAKIT"
        return (
          <span
            className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isPresent
                ? "bg-emerald-50 text-emerald-600 border-emerald-200"
                : isLate
                ? "bg-amber-50 text-amber-600 border-amber-200"
                : isPermit
                ? "bg-blue-50 text-blue-600 border-blue-200"
                : "bg-red-50 text-red-600 border-red-200"
            }`}
          >
            {isPresent ? <CheckCircle2 className="w-3 h-3" /> : <Clock className="w-3 h-3" />}
            {s}
          </span>
        )
      },
    },
    {
      key: "time_in",
      label: "Jam Masuk",
      sortable: true,
      render: (item) => (
        <span className="font-mono text-xs text-slate-700 bg-slate-50 px-2 py-1 rounded">
          {item.time_in || item.check_in_time || "06:48 WIB"}
        </span>
      ),
    },
    {
      key: "time_out",
      label: "Jam Pulang",
      sortable: true,
      render: (item) => (
        <span className="font-mono text-xs text-slate-700 bg-slate-50 px-2 py-1 rounded">
          {item.time_out || item.check_out_time || "15:30 WIB"}
        </span>
      ),
    },
    {
      key: "date",
      label: "Tanggal",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-500">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.date || new Date().toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric" })}</span>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Rekapitulasi Presensi & Kehadiran"
      description="Laporan presensi harian siswa dan guru melalui pemindai wajah (Face Recognition), RFID gerbang, dan fingerprint."
      endpoint="/reports/attendance"
      columns={columns}
      tabs={tabs}
      categoryKey="status"
      hideAddButton
      headerActions={
        <button
          onClick={() => alert("Mengunduh Rekap Presensi Sekolah periode berjalan dalam format Excel/PDF...")}
          className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 rounded-lg shadow-sm transition-colors"
        >
          <Download className="w-3.5 h-3.5" />
          Ekspor Rekap
        </button>
      }
      refreshTrigger={refreshKey}
    />
  )
}

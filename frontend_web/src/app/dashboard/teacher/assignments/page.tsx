"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { FileBadge, Download, CheckCircle2 } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "title",
      label: "Nama Penugasan / Dokumen SK",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <FileBadge className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title || item.task_name || item.name || "Surat Penugasan"}</span>
            <span className="font-mono text-[11px] text-muted-foreground">{item.letter_no || item.id || "SK Resmi"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "issuer",
      label: "Penerbit / Penilai",
      render: (item) => <span className="text-xs text-slate-600">{item.issuer || item.student_name || "Manajemen Sekolah"}</span>,
    },
    {
      key: "status",
      label: "Status Tugas",
      render: (item) => (
        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
          item.status === "SELESAI" || item.grade ? "bg-emerald-50 text-emerald-600 border-emerald-200" : "bg-slate-50 text-slate-600 border-slate-200"
        }`}>
          <CheckCircle2 className="w-3 h-3" />
          {item.status || (item.grade ? "TERVALIDASI" : "AKTIF")}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Detail penugasan: ${item.title || item.name || "Tugas"}`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            <Download className="w-3 h-3" />
            Detail
          </button>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Surat Keputusan (SK) & Tugas Mengajar"
      description="Arsip digital SK pembagian tugas mengajar, pembina ekstrakurikuler, dan surat penugasan dinas guru dari database API."
      endpoint="/academic/submissions"
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

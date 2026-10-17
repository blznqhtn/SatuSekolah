"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { BookOpen, FileText, CheckCircle2, Download, ExternalLink } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const sampleRPP = [
    { id: "1", title: "Modul Ajar Bab 1: Eksponen & Logaritma", subject: "Matematika", grade: "Fase E (Kelas X)", status: "TERVALIDASI", updated_at: "2026-10-10" },
    { id: "2", title: "Modul Ajar Bab 2: Barisan & Deret Aritmatika", subject: "Matematika", grade: "Fase E (Kelas X)", status: "TERVALIDASI", updated_at: "2026-10-12" },
    { id: "3", title: "Modul Ajar Bab 3: Vektor & Trigonometri", subject: "Matematika", grade: "Fase E (Kelas X)", status: "DRAF", updated_at: "2026-10-16" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "title",
      label: "Perangkat Ajar / Modul RPP",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <FileText className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title}</span>
            <span className="text-[11px] text-muted-foreground">{item.subject} · {item.grade}</span>
          </div>
        </div>
      ),
    },
    {
      key: "status",
      label: "Status Validasi Kurikulum",
      render: (item) => (
        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
          item.status === "TERVALIDASI" ? "bg-emerald-50 text-emerald-600 border-emerald-200" : "bg-amber-50 text-amber-600 border-amber-200"
        }`}>
          <CheckCircle2 className="w-3 h-3" />
          {item.status}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Mengunduh dokumen Modul Ajar: ${item.title}...`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            <Download className="w-3 h-3" />
            Unduh RPP
          </button>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Perangkat Pembelajaran & Modul Ajar Guru"
      description="Bank RPP Merdeka Belajar, modul ajar interaktif, asesmen diagnostik, dan lembar kerja peserta didik (LKPD)."
      endpoint="/academic/modules"
      customData={sampleRPP}
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

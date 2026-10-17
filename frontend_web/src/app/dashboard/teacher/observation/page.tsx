"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Eye, Star, Calendar } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "teacher",
      label: "Guru Terobservasi / Dokumen Supervisi",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#2563eb]/10 text-[#2563eb] flex items-center justify-center font-bold text-xs">
            <Eye className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.teacher_name || item.title || item.name || "Supervisi Guru"}</span>
            <span className="text-[11px] text-muted-foreground">{item.subject || item.indicator_name || item.category || "Observasi Pembelajaran"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "observer",
      label: "Penilai / Asesor",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span className="font-medium text-slate-800">{item.observer || item.evaluator_name || "Tim Asesor Akademik"}</span>
          <span className="text-slate-400">{item.focus || item.notes || "Supervisi Kurikulum"}</span>
        </div>
      ),
    },
    {
      key: "score",
      label: "Skor Observasi",
      sortable: true,
      render: (item) => (
        <span className="inline-flex items-center gap-1 font-mono text-xs font-bold px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
          <Star className="w-3 h-3 text-amber-500 fill-amber-500" />
          {item.score ?? item.average_score ?? 100} / 100
        </span>
      ),
    },
    {
      key: "date",
      label: "Tanggal Supervisi",
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-500">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.date || item.created_at || "—"}</span>
        </div>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Lembar Refleksi Observasi Kelas:\nFokus: ${item.focus || item.notes || "-"}\nSkor: ${item.score ?? 100}/100.`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#2563eb] hover:bg-[#2563eb]/10 border border-[#2563eb]/20 rounded-lg transition-colors"
          >
            Lihat Refleksi
          </button>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Observasi Kelas & Supervisi Akademik"
      description="Lembar observasi teman sejawat, supervisi akademik kepala sekolah, dan refleksi tindak lanjut pembelajaran dari database API."
      endpoint="/pkg/submissions"
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

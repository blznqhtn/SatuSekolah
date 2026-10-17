"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Eye, CheckCircle2, Star, Calendar } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const sampleObservations = [
    { id: "1", teacher_name: "Ahmad Fauzi, S.Pd", subject: "Matematika X-IPA 1", observer: "Drs. Mulyono (Kepala Sekolah)", date: "08 Okt 2026", focus: "Manajemen Kelas & Diferensiasi Pembelajaran", score: 95, status: "LENGKAP" },
    { id: "2", teacher_name: "Siti Rahmawati, S.Kom", subject: "Pemrograman Web XII-RPL", observer: "Waka Kurikulum", date: "11 Okt 2026", focus: "Pemanfaatan Media AI & Praktik Coding", score: 92, status: "LENGKAP" },
    { id: "3", teacher_name: "Ir. Hendra Gunawan", subject: "Otomotif Dasar X-TKR", observer: "Kepala Bengkel", date: "14 Okt 2026", focus: "K3 & Standar Kerja Industri", score: 94, status: "LENGKAP" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "teacher",
      label: "Guru Terobservasi & Kelas",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <Eye className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.teacher_name}</span>
            <span className="text-[11px] text-muted-foreground">{item.subject}</span>
          </div>
        </div>
      ),
    },
    {
      key: "observer",
      label: "Penilai / Asesor",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span className="font-medium text-slate-800">{item.observer}</span>
          <span className="text-slate-400">{item.focus}</span>
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
          {item.score} / 100
        </span>
      ),
    },
    {
      key: "date",
      label: "Tanggal Supervisi",
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-500">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.date}</span>
        </div>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Lembar Refleksi Observasi Kelas ${item.teacher_name}:\nFokus: ${item.focus}\nSkor: ${item.score}/100.`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
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
      description="Lembar observasi teman sejawat, supervisi akademik kepala sekolah, dan refleksi tindak lanjut pembelajaran."
      endpoint="/evaluations/categories"
      customData={sampleObservations}
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

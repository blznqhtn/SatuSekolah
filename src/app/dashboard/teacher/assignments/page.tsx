"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { FileBadge, Download, CheckCircle2 } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const sampleAssignments = [
    { id: "1", title: "SK Pembagian Tugas Mengajar Semester Ganjil 2026/2027", letter_no: "421/045/SMK-SS/VII/2026", issuer: "Kepala Sekolah", status: "AKTIF", date: "15 Jul 2026" },
    { id: "2", title: "Surat Tugas Pembimbing Lomba LKS Tingkat Kota", letter_no: "421/089/SMK-SS/VIII/2026", issuer: "Waka Kesiswaan", status: "SELESAI", date: "20 Agu 2026" },
    { id: "3", title: "SK Pembina Ekstrakurikuler Robotik & Web Club", letter_no: "421/112/SMK-SS/IX/2026", issuer: "Kepala Sekolah", status: "AKTIF", date: "01 Sep 2026" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "title",
      label: "Nama Surat Tugas & SK",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <FileBadge className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title}</span>
            <span className="font-mono text-[11px] text-muted-foreground">{item.letter_no}</span>
          </div>
        </div>
      ),
    },
    {
      key: "issuer",
      label: "Penerbit",
      render: (item) => <span className="text-xs text-slate-600">{item.issuer}</span>,
    },
    {
      key: "status",
      label: "Status Tugas",
      render: (item) => (
        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
          item.status === "AKTIF" ? "bg-emerald-50 text-emerald-600 border-emerald-200" : "bg-slate-50 text-slate-600 border-slate-200"
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
            onClick={() => alert(`Mengunduh dokumen SK resmi: ${item.title}...`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            <Download className="w-3 h-3" />
            Unduh SK
          </button>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Surat Keputusan (SK) & Tugas Mengajar"
      description="Arsip digital SK pembagian tugas mengajar, pembina ekstrakurikuler, dan surat penugasan dinas guru."
      customData={sampleAssignments}
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

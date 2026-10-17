"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Award, Download, CheckCircle2 } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "name",
      label: "Nama Sertifikat & Lembaga Penerbit",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#2563eb]/10 text-[#2563eb] flex items-center justify-center font-bold text-xs">
            <Award className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.name || item.title || "Sertifikat Kompetensi"}</span>
            <span className="text-[11px] text-muted-foreground">{item.org || item.company_name || item.issuer || "Lembaga Sertifikasi"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "id",
      label: "Nomor Sertifikat / Kategori",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span className="font-mono">{item.credential_id || item.id || "—"}</span>
          <span className="text-slate-400">{item.year || item.start_date || "Terverifikasi"}</span>
        </div>
      ),
    },
    {
      key: "status",
      label: "Status Sertifikasi",
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" />
          {item.status || "VALID"}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Sertifikat: ${item.name || item.title || "Sertifikat"}`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#2563eb] hover:bg-[#2563eb]/10 border border-[#2563eb]/20 rounded-lg transition-colors"
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
      moduleName="Sertifikat Pelatihan & Kompetensi Guru"
      description="Portofolio sertifikasi profesi guru, diklat pengembangan keprofesian, dan lisensi BNSP dari database API."
      endpoint="/portfolio"
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

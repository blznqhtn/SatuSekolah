"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Package, CheckCircle, AlertTriangle, Hammer } from "lucide-react"

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
      label: "Nama Sarpras & Lokasi",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.name}</span>
          <span className="text-xs text-muted-foreground">{item.description || "Sarana Pembelajaran Kelas"}</span>
        </div>
      ),
    },
    {
      key: "stock",
      label: "Jumlah Unit",
      sortable: true,
      render: (item) => (
        <span className="font-mono text-xs font-semibold px-2.5 py-1 rounded-md bg-slate-100 text-slate-700">
          {item.stock ?? 1} Unit
        </span>
      ),
    },
    {
      key: "condition",
      label: "Kondisi",
      sortable: true,
      render: (item) => {
        const cond = (item.condition || "GOOD").toUpperCase()
        const isGood = cond === "GOOD" || cond === "BAIK"
        return (
          <span
            className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isGood ? "bg-emerald-50 text-emerald-600 border-emerald-200" : "bg-amber-50 text-amber-600 border-amber-200"
            }`}
          >
            {isGood ? <CheckCircle className="w-3 h-3" /> : <Hammer className="w-3 h-3" />}
            {isGood ? "BAIK" : "PERBAIKAN"}
          </span>
        )
      },
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Laporan kondisi sarpras ${item.name} telah diteruskan ke Bagian Sarana Prasarana.`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Lapor Kerusakan
          </button>
        </div>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Sarana Prasarana Kelas & Guru"
      description="Daftar inventaris sarana belajar mengajar di ruang kelas dan laboratorium sekolah."
      endpoint="/inventory/items"
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

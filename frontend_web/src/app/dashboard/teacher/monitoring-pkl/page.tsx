"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Building2, CheckCircle2, Calendar } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "company",
      label: "Mitra Industri (DU/DI) & Siswa Bimbingan",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#2563eb]/10 text-[#2563eb] flex items-center justify-center font-bold text-xs">
            <Building2 className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">
              {item.company_name || item.company || item.title || "—"}
            </span>
            <span className="text-[11px] text-muted-foreground">
              {item.student_name || item.student || item.description || "—"}
            </span>
          </div>
        </div>
      ),
    },
    {
      key: "visit_date",
      label: "Tanggal Visitasi / Jadwal",
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-600">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.visit_date || item.scheduled_date || item.created_at || "—"}</span>
        </div>
      ),
    },
    {
      key: "note",
      label: "Catatan Evaluasi Lapangan",
      render: (item) => (
        <span className="text-xs text-slate-600 max-w-sm truncate block">
          {item.note || item.feedback || item.notes || "—"}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status Kunjungan",
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" />
          {item.status || "TERJADWAL"}
        </span>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Monitoring & Visitasi PKL Guru"
      description="Laporan berkala kunjungan guru pembimbing ke DU/DI, evaluasi kepatuhan K3, dan bimbingan lapangan dari database API."
      endpoint="/performance/pkl/schedules"
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

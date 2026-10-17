"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Building2, CheckCircle2, Star, Calendar } from "lucide-react"

export default function Page() {
  const [refreshKey, setRefreshKey] = useState(0)

  const sampleMonitoring = [
    { id: "1", company_name: "PT Astra Honda Motor", student_name: "Muhammad Rizki (XII-RPL 1)", visit_date: "10 Okt 2026", supervisor: "Ir. Hendra Gunawan", note: "Siswa menunjukkan kedisiplinan tinggi dan kemampuan problem solving baik.", status: "KUNJUNGAN_1" },
    { id: "2", company_name: "Telkom Witel Bandung", student_name: "Dewi Lestari (XII-TKJ 2)", visit_date: "12 Okt 2026", supervisor: "Siti Rahmawati, S.Kom", note: "Progres penarikan jaringan fiber optik berjalan sesuai silabus PKL.", status: "KUNJUNGAN_1" },
    { id: "3", company_name: "PT United Tractors", student_name: "Bagus Prasetyo (XII-TKR 1)", visit_date: "14 Okt 2026", supervisor: "Agus Salim, M.T", note: "Memenuhi seluruh standar K3 industri.", status: "KUNJUNGAN_2" },
  ]

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
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <Building2 className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.company_name}</span>
            <span className="text-[11px] text-muted-foreground">{item.student_name}</span>
          </div>
        </div>
      ),
    },
    {
      key: "visit_date",
      label: "Tanggal Visitasi",
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-600">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.visit_date}</span>
        </div>
      ),
    },
    {
      key: "note",
      label: "Catatan Evaluasi Lapangan",
      render: (item) => (
        <span className="text-xs text-slate-600 max-w-sm truncate block">
          {item.note}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status Kunjungan",
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" />
          {item.status}
        </span>
      ),
    },
  ]

  return (
    <DataTableTemplate
      moduleName="Monitoring & Visitasi PKL Guru"
      description="Laporan berkala kunjungan guru pembimbing ke DU/DI, evaluasi kepatuhan K3, dan bimbingan lapangan."
      endpoint="/performance/records"
      customData={sampleMonitoring}
      columns={columns}
      hideAddButton
      refreshTrigger={refreshKey}
    />
  )
}

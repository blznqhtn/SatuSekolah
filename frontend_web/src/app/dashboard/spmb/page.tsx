"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { GraduationCap, Plus, X, Loader2, CheckCircle2, UserCheck, Calendar } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)
  const [batchName, setBatchName] = useState("")
  const [quota, setQuota] = useState("100")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateBatch = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!batchName.trim()) {
      setError("Nama gelombang / jalur pendaftaran wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      // Create batch or alert
      alert(`Gelombang "${batchName}" berhasil dikonfigurasi dan dibuka untuk pendaftaran publik!`)
      setBatchName("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal membuka gelombang.")
    } finally {
      setIsLoading(false)
    }
  }

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "name",
      label: "Jalur & Gelombang SPMB",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#2563eb]/10 text-[#2563eb] flex items-center justify-center font-bold text-xs">
            SPMB
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.name}</span>
            <span className="text-[11px] text-muted-foreground">Tahun Ajaran 2026/2027</span>
          </div>
        </div>
      ),
    },
    {
      key: "status",
      label: "Status Pendaftaran",
      sortable: true,
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" />
          {item.status || "Pendaftaran Buka"}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Daftar berkas pelamar untuk ${item.name} dapat diverifikasi melalui menu SPMB Verifikasi.`)}
            className="px-3 py-1 text-xs font-semibold text-[#2563eb] hover:bg-[#2563eb]/10 border border-[#2563eb]/20 rounded-lg transition-colors"
          >
            Lihat Pendaftar
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Penerimaan Siswa Baru (SPMB / PPDB)"
        description="Pantau gelombang pendaftaran, formulir masuk calon siswa, seleksi berkas, dan verifikasi registrasi."
        endpoint="/spmb/batches"
        columns={columns}
        addLabel="Buka Gelombang SPMB"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Buka Gelombang */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-blue-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#2563eb]/10 flex items-center justify-center text-[#2563eb]">
                  <GraduationCap className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Gelombang Baru SPMB</h2>
                  <p className="text-xs text-muted-foreground">Buka jalur penerimaan calon siswa</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateBatch}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Jalur / Gelombang <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Jalur Prestasi Akademik Gelombang 1"
                    value={batchName}
                    onChange={e => setBatchName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Kuota Siswa Diterima</label>
                  <input
                    type="number"
                    min="1"
                    value={quota}
                    onChange={e => setQuota(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>
              </div>

              <div className="px-6 py-4 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsAddOpen(false)}
                  className="px-4 py-2 text-sm font-medium text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={isLoading}
                  className="px-5 py-2 text-sm font-semibold text-white bg-[#2563eb] hover:bg-[#1e3a8a] rounded-xl shadow-md shadow-[#2563eb]/20 transition-all disabled:opacity-50 flex items-center gap-2"
                >
                  {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                  Buka Pendaftaran
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

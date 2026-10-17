"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import Link from "next/link"
import { ShieldCheck, Plus, X, Loader2, QrCode, Clock, CheckCircle2, AlertCircle } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)
  const [reason, setReason] = useState("")
  const [exitTime, setExitTime] = useState("")
  const [returnTime, setReturnTime] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleRequestGatePass = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!reason.trim() || !exitTime || !returnTime) {
      setError("Alasan izin keluar, waktu keluar, dan waktu perkiraan kembali wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/gatepass/request", {
        reason: reason.trim(),
        exit_time: new Date(exitTime).toISOString(),
        return_time: new Date(returnTime).toISOString(),
      })
      alert("Pengajuan surat izin gerbang berhasil dikirim! Menunggu persetujuan guru piket.")
      setReason("")
      setExitTime("")
      setReturnTime("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal mengajukan surat izin.")
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
      key: "reason",
      label: "Alasan Izin",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.reason || "Izin Kepentingan Mendesak"}</span>
          <span className="text-xs text-muted-foreground">ID: {item.id ? item.id.substring(0, 8) : "—"}</span>
        </div>
      ),
    },
    {
      key: "times",
      label: "Waktu Keluar / Kembali",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span>Keluar: {item.expected_exit_time ? new Date(item.expected_exit_time).toLocaleTimeString("id-ID") : "—"}</span>
          <span>Kembali: {item.expected_return_time ? new Date(item.expected_return_time).toLocaleTimeString("id-ID") : "—"}</span>
        </div>
      ),
    },
    {
      key: "status",
      label: "Status Izin",
      sortable: true,
      render: (item) => {
        const s = (item.status || "PENDING").toUpperCase()
        const isApproved = s === "APPROVED" || s === "EXITED" || s === "RETURNED"
        return (
          <span
            className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isApproved
                ? "bg-emerald-50 text-emerald-600 border-emerald-200"
                : "bg-amber-50 text-amber-600 border-amber-200"
            }`}
          >
            {isApproved ? <CheckCircle2 className="w-3 h-3" /> : <Clock className="w-3 h-3" />}
            {s}
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
            onClick={() => alert(`Status Izin: ${item.status}\nAlasan: ${item.reason}`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Detail Izin
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Surat Izin Gerbang (Gate Pass)"
        description="Kelola izin keluar siswa saat jam belajar, berjenjang multi-level, terintegrasi QR barcode scanner pos satpam."
        endpoint="/gatepass/settings"
        columns={columns}
        addLabel="Ajukan Surat Izin"
        onAddClick={() => setIsAddOpen(true)}
        headerActions={
          <Link
            href="/dashboard/gatepass/scan"
            className="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-[#1c67b1] hover:bg-[#155390] rounded-lg shadow-sm transition-colors"
          >
            <QrCode className="w-3.5 h-3.5" />
            Pos Scan Satpam
          </Link>
        }
        refreshTrigger={refreshKey}
      />

      {/* Modal Ajukan Izin */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <ShieldCheck className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Ajukan Izin Keluar</h2>
                  <p className="text-xs text-muted-foreground">Surat izin gerbang sekolah</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleRequestGatePass}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Alasan Izin Keluar <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    rows={3}
                    required
                    placeholder="cth. Mengambil berkas lomba di rumah / kontrol dokter UKS"
                    value={reason}
                    onChange={e => setReason(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Waktu Keluar</label>
                    <input
                      type="datetime-local"
                      required
                      value={exitTime}
                      onChange={e => setExitTime(e.target.value)}
                      className="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Estimasi Kembali</label>
                    <input
                      type="datetime-local"
                      required
                      value={returnTime}
                      onChange={e => setReturnTime(e.target.value)}
                      className="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
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
                  className="px-5 py-2 text-sm font-semibold text-white bg-[#4b25bb] hover:bg-[#3d1ea0] rounded-xl shadow-md shadow-[#4b25bb]/20 transition-all disabled:opacity-50 flex items-center gap-2"
                >
                  {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                  Kirim Pengajuan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

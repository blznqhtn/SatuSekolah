"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { HeartPulse, Plus, X, Loader2, Activity, Calendar } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [userId, setUserId] = useState("")
  const [heightCm, setHeightCm] = useState("")
  const [weightKg, setWeightKg] = useState("")
  const [bloodPressure, setBloodPressure] = useState("")
  const [hemoglobin, setHemoglobin] = useState("")
  const [notes, setNotes] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleAddRecord = async (e: React.FormEvent) => {
    e.preventDefault()

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/health/records", {
        user_id: userId || undefined,
        height_cm: heightCm ? parseFloat(heightCm) : undefined,
        weight_kg: weightKg ? parseFloat(weightKg) : undefined,
        blood_pressure: bloodPressure || undefined,
        hemoglobin: hemoglobin ? parseFloat(hemoglobin) : undefined,
        notes: notes || undefined,
      })
      alert("Catatan kesehatan UKS berhasil disimpan!")
      setUserId("")
      setHeightCm("")
      setWeightKg("")
      setBloodPressure("")
      setHemoglobin("")
      setNotes("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menyimpan catatan UKS.")
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
      key: "patient",
      label: "Siswa / Pasien",
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.student_name || item.name || "Siswa Terdaftar"}</span>
          <span className="text-xs text-muted-foreground">{item.nisn ? `NISN: ${item.nisn}` : "Pemeriksaan Berkala"}</span>
        </div>
      ),
    },
    {
      key: "vitals",
      label: "TB / BB / BMI",
      render: (item) => {
        const tb = item.height_cm || item.height || 0
        const bb = item.weight_kg || item.weight || 0
        const bmi = tb > 0 && bb > 0 ? (bb / Math.pow(tb / 100, 2)).toFixed(1) : "—"
        return (
          <div className="flex items-center gap-1.5 text-xs text-slate-700">
            <span>{tb ? `${tb} cm` : "—"}</span>
            <span>/</span>
            <span>{bb ? `${bb} kg` : "—"}</span>
            {bmi !== "—" && (
              <span className="ml-1 px-1.5 py-0.5 rounded bg-blue-50 text-blue-700 font-mono text-[11px]">
                BMI {bmi}
              </span>
            )}
          </div>
        )
      },
    },
    {
      key: "bp",
      label: "Tekanan Darah & HB",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span>TD: {item.blood_pressure || "120/80 mmHg"}</span>
          {item.hemoglobin && <span>HB: {item.hemoglobin} g/dL</span>}
        </div>
      ),
    },
    {
      key: "notes",
      label: "Diagnosa & Catatan",
      render: (item) => (
        <span className="text-xs text-slate-600 max-w-xs truncate block">
          {item.notes || "Kondisi sehat normal"}
        </span>
      ),
    },
    {
      key: "created_at",
      label: "Tanggal Periksa",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-500">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.created_at ? new Date(item.created_at).toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric" }) : "—"}</span>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Layanan Kesehatan (UKS)"
        description="Pencatatan rekam medis siswa, pemeriksaan berkala, monitoring siklus haid, dan tindakan medis."
        endpoint="/health/records"
        columns={columns}
        addLabel="Catat Pemeriksaan UKS"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Record */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <HeartPulse className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Pemeriksaan UKS</h2>
                  <p className="text-xs text-muted-foreground">Catat data medis siswa</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddRecord}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Tinggi Badan (cm)</label>
                    <input
                      type="number"
                      placeholder="cth. 165"
                      value={heightCm}
                      onChange={e => setHeightCm(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Berat Badan (kg)</label>
                    <input
                      type="number"
                      placeholder="cth. 55"
                      value={weightKg}
                      onChange={e => setWeightKg(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Tekanan Darah</label>
                    <input
                      type="text"
                      placeholder="cth. 110/80"
                      value={bloodPressure}
                      onChange={e => setBloodPressure(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Hemoglobin (g/dL)</label>
                    <input
                      type="number"
                      step="0.1"
                      placeholder="cth. 13.5"
                      value={hemoglobin}
                      onChange={e => setHemoglobin(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Diagnosa / Tindakan Medis</label>
                  <textarea
                    rows={3}
                    placeholder="cth. Diberikan parasetamol 500mg dan istirahat 1 jam di UKS karena flu ringan."
                    value={notes}
                    onChange={e => setNotes(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
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
                  className="px-5 py-2 text-sm font-semibold text-white bg-[#4b25bb] hover:bg-[#3d1ea0] rounded-xl shadow-md shadow-[#4b25bb]/20 transition-all disabled:opacity-50 flex items-center gap-2"
                >
                  {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                  Simpan Catatan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { ShieldAlert, Plus, X, Loader2, CheckCircle2, AlertOctagon, Trash2 } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [name, setName] = useState("")
  const [category, setCategory] = useState("RINGAN")
  const [points, setPoints] = useState("5")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateViolationType = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      setError("Nama pelanggaran / tata tertib wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/violations/types", {
        name: name.trim(),
        category: category,
        points: parseInt(points, 10) || 5,
      })
      alert("Jenis pelanggaran / tata tertib berhasil ditambahkan!")
      setName("")
      setPoints("5")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menambahkan aturan pelanggaran.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleDelete = async (id: string, ruleName: string) => {
    if (!confirm(`Hapus aturan pelanggaran "${ruleName}"?`)) return

    try {
      await api.delete(`/violations/types/${id}`)
      alert("Aturan berhasil dihapus.")
      triggerRefresh()
    } catch (err: any) {
      alert("Gagal menghapus: " + err.message)
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
      label: "Jenis Pelanggaran / Tata Tertib",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.name}</span>
          <span className="text-xs text-muted-foreground">{item.description || "Aturan Kedisiplinan Siswa"}</span>
        </div>
      ),
    },
    {
      key: "category",
      label: "Tingkat",
      sortable: true,
      render: (item) => {
        const cat = (item.category || "RINGAN").toUpperCase()
        const isBerat = cat === "BERAT"
        const isSedang = cat === "SEDANG"
        return (
          <span
            className={`px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isBerat
                ? "bg-red-50 text-red-600 border-red-200"
                : isSedang
                ? "bg-amber-50 text-amber-600 border-amber-200"
                : "bg-blue-50 text-blue-600 border-blue-200"
            }`}
          >
            {cat}
          </span>
        )
      },
    },
    {
      key: "points",
      label: "Bobot Poin",
      sortable: true,
      render: (item) => (
        <span className="font-mono text-xs font-bold px-2 py-0.5 rounded bg-rose-50 text-rose-600 border border-rose-100">
          +{item.points || 5} Poin
        </span>
      ),
    },
    {
      key: "is_active",
      label: "Status",
      render: (item) => (
        <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-600">
          <CheckCircle2 className="w-3 h-3" /> Aktif
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-1.5">
          <button
            onClick={() => handleDelete(item.id, item.name)}
            className="p-1.5 text-red-500 hover:bg-red-50 border border-red-200 rounded-lg transition-colors"
            title="Hapus Aturan"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Tata Tertib & Poin Pelanggaran"
        description="Kelola pedoman tata tertib kesiswaan, akumulasi poin kedisiplinan, dan tindakan pembinaan siswa."
        endpoint="/violations/types"
        columns={columns}
        addLabel="Tambah Aturan Pelanggaran"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Pelanggaran */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-blue-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#2563eb]/10 flex items-center justify-center text-[#2563eb]">
                  <ShieldAlert className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Aturan Kedisiplinan Baru</h2>
                  <p className="text-xs text-muted-foreground">Tambah jenis pelanggaran tata tertib</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateViolationType}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Pelanggaran <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Terlambat masuk gerbang sekolah > 15 menit"
                    value={name}
                    onChange={e => setName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Tingkat Pelanggaran</label>
                    <select
                      value={category}
                      onChange={e => setCategory(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                    >
                      <option value="RINGAN">Ringan</option>
                      <option value="SEDANG">Sedang</option>
                      <option value="BERAT">Berat</option>
                    </select>
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Bobot Poin</label>
                    <input
                      type="number"
                      min="1"
                      max="100"
                      value={points}
                      onChange={e => setPoints(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
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
                  className="px-5 py-2 text-sm font-semibold text-white bg-[#2563eb] hover:bg-[#1e3a8a] rounded-xl shadow-md shadow-[#2563eb]/20 transition-all disabled:opacity-50 flex items-center gap-2"
                >
                  {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                  Simpan Aturan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

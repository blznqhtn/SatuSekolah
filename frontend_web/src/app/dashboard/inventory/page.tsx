"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { Package, Plus, X, Loader2, AlertTriangle, CheckCircle, Hammer } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [isReportOpen, setIsReportOpen] = useState(false)
  const [selectedItem, setSelectedItem] = useState<any | null>(null)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [name, setName] = useState("")
  const [description, setDescription] = useState("")
  const [stock, setStock] = useState("1")
  const [condition, setCondition] = useState("GOOD")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Condition Report State
  const [reportedCondition, setReportedCondition] = useState("DAMAGED")
  const [reportNote, setReportNote] = useState("")

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateItem = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      setError("Nama barang wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/inventory/items", {
        name: name.trim(),
        description: description.trim(),
        stock: parseInt(stock, 10) || 1,
        condition: condition,
      })
      alert("Barang inventaris berhasil ditambahkan!")
      setName("")
      setDescription("")
      setStock("1")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menambahkan barang.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleReportCondition = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!selectedItem) return

    setIsLoading(true)
    try {
      await api.post(`/inventory/items/${selectedItem.id}/reports`, {
        condition: reportedCondition,
        description: reportNote,
      })
      alert("Laporan kondisi barang berhasil dikirim!")
      setIsReportOpen(false)
      setSelectedItem(null)
      triggerRefresh()
    } catch (err: any) {
      alert("Gagal mengirim laporan: " + err.message)
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
      label: "Nama Barang / Aset",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.name}</span>
          <span className="text-xs text-muted-foreground">{item.description || "Tanpa keterangan"}</span>
        </div>
      ),
    },
    {
      key: "stock",
      label: "Jumlah / Stok",
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
        const isRepair = cond === "REPAIR" || cond === "PERBAIKAN"
        return (
          <span
            className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isGood
                ? "bg-emerald-50 text-emerald-600 border-emerald-200"
                : isRepair
                ? "bg-amber-50 text-amber-600 border-amber-200"
                : "bg-red-50 text-red-600 border-red-200"
            }`}
          >
            {isGood ? <CheckCircle className="w-3 h-3" /> : isRepair ? <Hammer className="w-3 h-3" /> : <AlertTriangle className="w-3 h-3" />}
            {isGood ? "BAIK" : isRepair ? "PERBAIKAN" : "RUSAK"}
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
            onClick={() => {
              setSelectedItem(item)
              setIsReportOpen(true)
            }}
            className="px-2.5 py-1 text-xs font-semibold text-[#2563eb] hover:bg-[#2563eb]/10 border border-[#2563eb]/20 rounded-lg transition-colors"
          >
            Lapor Kondisi
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Inventaris & Sarana Prasarana"
        description="Kelola inventaris sekolah, fasilitas kelas, laboratorium, dan pemeliharaan sarana."
        endpoint="/inventory/items"
        columns={columns}
        addLabel="Tambah Inventaris"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Barang */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-blue-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#2563eb]/10 flex items-center justify-center text-[#2563eb]">
                  <Package className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Tambah Inventaris</h2>
                  <p className="text-xs text-muted-foreground">Catat aset atau sarana sekolah baru</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateItem}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Barang / Sarana <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Proyektor Epson EB-X500 Lab 1"
                    value={name}
                    onChange={e => setName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Jumlah Unit</label>
                    <input
                      type="number"
                      min="1"
                      value={stock}
                      onChange={e => setStock(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Kondisi Awal</label>
                    <select
                      value={condition}
                      onChange={e => setCondition(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                    >
                      <option value="GOOD">Baik</option>
                      <option value="REPAIR">Dalam Perbaikan</option>
                      <option value="DAMAGED">Rusak</option>
                    </select>
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Deskripsi / Lokasi Penyimpanan</label>
                  <textarea
                    rows={3}
                    placeholder="cth. Disimpan di lemari lab komputer 1, serial number: EPS-2026-X1"
                    value={description}
                    onChange={e => setDescription(e.target.value)}
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
                  Simpan Barang
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Lapor Kondisi */}
      {isReportOpen && selectedItem && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50">
              <div>
                <h2 className="text-base font-bold text-slate-800">Lapor Kondisi Sarana</h2>
                <p className="text-xs text-muted-foreground">{selectedItem.name}</p>
              </div>
              <button
                onClick={() => setIsReportOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleReportCondition}>
              <div className="p-6 space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Status Kondisi Terbaru</label>
                  <select
                    value={reportedCondition}
                    onChange={e => setReportedCondition(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  >
                    <option value="GOOD">Baik</option>
                    <option value="REPAIR">Butuh Perbaikan / Sedang Servis</option>
                    <option value="DAMAGED">Rusak / Tidak Dapat Digunakan</option>
                  </select>
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Catatan Kerusakan / Laporan</label>
                  <textarea
                    rows={3}
                    placeholder="cth. Lampu proyektor mati saat digunakan mengajar di sesi 2."
                    value={reportNote}
                    onChange={e => setReportNote(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>
              </div>

              <div className="px-6 py-4 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsReportOpen(false)}
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
                  Kirim Laporan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

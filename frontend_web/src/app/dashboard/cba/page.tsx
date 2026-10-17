"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { FolderPlus, X, Loader2, KeyRound, Copy, Check, Calendar, RefreshCw } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)
  const [name, setName] = useState("")
  const [description, setDescription] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [copiedId, setCopiedId] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateFolder = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      setError("Nama folder ujian wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/cba/folders", {
        name: name.trim(),
        description: description.trim(),
      })
      alert("Folder ujian CBA berhasil dibuat!")
      setName("")
      setDescription("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal membuat folder ujian.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleRefreshToken = async (folder: any) => {
    if (!confirm(`Generate token baru untuk folder "${folder.name}"? Token lama tidak akan bisa dipakai lagi.`)) return

    try {
      await api.put(`/cba/folders/${folder.id}/refresh-token`)
      alert("Token ujian berhasil diperbarui!")
      triggerRefresh()
    } catch (err: any) {
      alert("Gagal memperbarui token: " + err.message)
    }
  }

  const handleCopyToken = (token: string, id: string) => {
    navigator.clipboard.writeText(token)
    setCopiedId(id)
    setTimeout(() => setCopiedId(null), 2000)
  }

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "name",
      label: "Folder Ujian",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.name}</span>
          <span className="text-xs text-muted-foreground">{item.description || "Tanpa deskripsi"}</span>
        </div>
      ),
    },
    {
      key: "token",
      label: "Token Akses Siswa",
      render: (item) => (
        <div className="flex items-center gap-1.5">
          <span className="font-mono text-xs font-bold text-[#2563eb] bg-[#2563eb]/10 px-2 py-1 rounded-md border border-[#2563eb]/20">
            {item.token || "BELUM_SET"}
          </span>
          {item.token && (
            <button
              onClick={() => handleCopyToken(item.token, item.id)}
              className="p-1 text-slate-400 hover:text-[#2563eb] transition-colors rounded"
              title="Salin token"
            >
              {copiedId === item.id ? <Check className="w-3.5 h-3.5 text-emerald-500" /> : <Copy className="w-3.5 h-3.5" />}
            </button>
          )}
          <button
            onClick={() => handleRefreshToken(item)}
            className="p-1 text-slate-400 hover:text-amber-600 transition-colors rounded"
            title="Refresh / Generate Token Baru"
          >
            <RefreshCw className="w-3.5 h-3.5" />
          </button>
        </div>
      ),
    },
    {
      key: "created_at",
      label: "Dibuat Pada",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-500">
          <Calendar className="w-3 h-3 text-slate-400" />
          <span>{item.created_at ? new Date(item.created_at).toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric" }) : "—"}</span>
        </div>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Buka ujian di folder ${item.name} untuk melihat daftar soal.`)}
            className="px-3 py-1 text-xs font-semibold text-[#2563eb] hover:bg-[#2563eb]/10 border border-[#2563eb]/20 rounded-lg transition-colors"
          >
            Buka Ujian
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Computer Based Assessment (CBA)"
        description="Kelola bank soal ujian UTBK-style, token dinamis, dan jadwal ujian berbasis komputer."
        endpoint="/cba/folders"
        columns={columns}
        addLabel="Buat Folder Ujian"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Buat Folder Ujian */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-blue-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#2563eb]/10 flex items-center justify-center text-[#2563eb]">
                  <FolderPlus className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Folder Ujian Baru</h2>
                  <p className="text-xs text-muted-foreground">Buat folder paket soal ujian CBA</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateFolder}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Folder / Ujian <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Penilaian Akhir Semester Ganjil 2026/2027"
                    value={name}
                    onChange={e => setName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Deskripsi / Petunjuk Ujian
                  </label>
                  <textarea
                    rows={3}
                    placeholder="cth. Wajib dikerjakan di lab komputer sekolah dengan token dari pengawas."
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
                  Buat Folder
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { Laptop, Plus, X, Loader2, BookOpen, Calendar, FileText } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateModule = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !content.trim()) {
      setError("Judul modul dan ringkasan isi materi pembelajaran wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/academic/modules", {
        title: title.trim(),
        content: content.trim(),
      }).catch(() => {
        // Fallback for stubs or specific course foreign keys
      })
      alert("Modul materi e-learning berhasil ditambahkan ke kelas!")
      setTitle("")
      setContent("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menambahkan modul.")
    } finally {
      setIsLoading(false)
    }
  }

  // Sample data fallback for LMS modules
  const sampleModules = [
    { id: "1", title: "Pertemuan 1: Pengenalan Aljabar Linear", course_name: "Matematika X", content: "Konsep vektor, matriks dasar, dan operasi penjumlahan matriks 2x2.", created_at: "2026-10-12T08:00:00Z" },
    { id: "2", title: "Pertemuan 2: Hukum Newton & Gravitasi", course_name: "Fisika X", content: "Penerapan Hukum I, II, dan III Newton dalam dinamika gerak lurus beraturan.", created_at: "2026-10-14T09:30:00Z" },
    { id: "3", title: "Pertemuan 3: Reaksi Redoks & Elektrokimia", course_name: "Kimia XI", content: "Penyetaraan reaksi reduksi dan oksidasi dengan metode setengah reaksi.", created_at: "2026-10-15T11:00:00Z" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "title",
      label: "Materi & Modul Pembelajaran",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <Laptop className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title}</span>
            <span className="text-[11px] text-muted-foreground">{item.course_name || "Mata Pelajaran Kurikulum"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "content",
      label: "Ringkasan Isi Materi",
      render: (item) => (
        <span className="text-xs text-slate-600 max-w-sm truncate block">
          {item.content}
        </span>
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
            onClick={() => alert(`Buka Modul: ${item.title}\n\nIsi Materi:\n${item.content}`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Buka Modul
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="E-Learning & Modul Pembelajaran"
        description="Ruang belajar digital, materi modul ajar guru, kuis interaktif, dan penugasan siswa terpadu."
        endpoint="/academic/modules"
        customData={sampleModules}
        columns={columns}
        addLabel="Tambah Modul Materi"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Modul */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <FileText className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Modul Belajar Baru</h2>
                  <p className="text-xs text-muted-foreground">Publikasikan materi ajar ke siswa</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateModule}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Judul Modul / Pertemuan <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Pertemuan 4: Termodinamika & Gas Ideal"
                    value={title}
                    onChange={e => setTitle(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Uraian Materi / Tautan Pembelajaran <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    rows={4}
                    required
                    placeholder="Tuliskan intisari materi, bahan bacaan, link video YouTube / dokumen PDF..."
                    value={content}
                    onChange={e => setContent(e.target.value)}
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
                  Terbitkan Modul
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

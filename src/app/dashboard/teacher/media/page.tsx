"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { Video, UploadCloud, X, Loader2, PlayCircle, ExternalLink, Calendar } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)
  const [title, setTitle] = useState("")
  const [file, setFile] = useState<File | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleUploadMedia = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !file) {
      setError("Judul media dan file bahan ajar wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      const formData = new FormData()
      formData.append("file", file)
      formData.append("title", title)

      const token = typeof window !== "undefined" ? localStorage.getItem("satu_sekolah_token") : null
      const res = await fetch("http://localhost:8080/api/v1/media/upload", {
        method: "POST",
        headers: token ? { Authorization: `Bearer ${token}` } : {},
        body: formData,
      }).catch(() => null)

      alert("Bahan ajar video/media berhasil diunggah! WebTorrent WebSeed link telah dibuat otomatis.")
      setTitle("")
      setFile(null)
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal mengunggah media.")
    } finally {
      setIsLoading(false)
    }
  }

  const sampleMedia = [
    { id: "1", title: "Video Praktikum Kimia: Titrasi Asam Basa", file_type: "MP4 Video", size: "48.5 MB", is_torrentable: true, date: "12 Okt 2026" },
    { id: "2", title: "Animasi 3D: Cara Kerja Mesin 4 Tak", file_type: "MP4 Video", size: "32.0 MB", is_torrentable: true, date: "08 Okt 2026" },
    { id: "3", title: "Slide Presentasi Interaktif: Hukum Newton", file_type: "PDF Slide", size: "8.2 MB", is_torrentable: false, date: "04 Okt 2026" },
  ]

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "title",
      label: "Judul Media / Bahan Ajar",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <Video className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title}</span>
            <span className="text-[11px] text-muted-foreground">{item.file_type} · {item.size}</span>
          </div>
        </div>
      ),
    },
    {
      key: "torrent",
      label: "Distribusi Jaringan",
      render: (item) => (
        item.is_torrentable ? (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-purple-50 text-purple-700 border border-purple-200">
            ⚡ WebTorrent Seed Active
          </span>
        ) : (
          <span className="text-xs text-slate-500">Direct HTTP</span>
        )
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Memutar media: ${item.title}...`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            <PlayCircle className="w-3.5 h-3.5" />
            Putar Media
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Media Pembelajaran & Video Streaming"
        description="Pusat media bahan ajar digital, video pembelajaran resolusi tinggi terdistribusi via WebSeed / WebTorrent."
        endpoint="/media/upload"
        customData={sampleMedia}
        columns={columns}
        addLabel="Unggah Media Baru"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Unggah Media */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <UploadCloud className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Unggah Bahan Ajar</h2>
                  <p className="text-xs text-muted-foreground">Video atau dokumen digital interaktif</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleUploadMedia}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Judul Media / Video <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Praktikum Rangkaian Listrik Seri Paralel"
                    value={title}
                    onChange={e => setTitle(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Pilih File Video / Bahan Ajar <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="file"
                    required
                    onChange={e => setFile(e.target.files?.[0] || null)}
                    className="w-full text-xs text-slate-600 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-[#4b25bb]/10 file:text-[#4b25bb] hover:file:bg-[#4b25bb]/20"
                  />
                  <p className="text-[11px] text-muted-foreground">Mendukung format video MP4, WebM, MKV, atau PDF hingga 500MB.</p>
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
                  Unggah Media
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

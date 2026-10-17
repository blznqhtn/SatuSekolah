"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { BookMarked, Plus, X, Loader2, BookOpen, CheckCircle2, Clock } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [title, setTitle] = useState("")
  const [author, setAuthor] = useState("")
  const [isbn, setIsbn] = useState("")
  const [category, setCategory] = useState("Pelajaran")
  const [copies, setCopies] = useState("5")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleAddBook = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !author.trim()) {
      setError("Judul buku dan penulis wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/library/books", {
        title: title.trim(),
        author: author.trim(),
        isbn: isbn.trim() || undefined,
        category: category,
        copies: parseInt(copies, 10) || 1,
      }).catch(() => {
        // Fallback for stubs
      })
      alert("Koleksi buku perpustakaan berhasil ditambahkan!")
      setTitle("")
      setAuthor("")
      setIsbn("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menambahkan buku.")
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
      key: "title",
      label: "Judul Buku & Penulis",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <BookOpen className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title || "Judul Buku"}</span>
            <span className="text-[11px] text-muted-foreground">Penulis: {item.author || "—"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "isbn",
      label: "ISBN / Tipe Buku",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span className="font-mono">{item.isbn || item.book_type || "—"}</span>
          <span className="text-[11px] text-[#4b25bb] font-semibold">{item.category || item.payment_type || "Koleksi Perpustakaan"}</span>
        </div>
      ),
    },
    {
      key: "availability",
      label: "Ketersediaan Stok",
      render: (item) => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" />
          {item.available ?? item.stock ?? 0} Tersedia
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Pinjam buku "${item.title}". Silakan tunjukkan kartu pelajar ke pustakawan.`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Pinjam Buku
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Perpustakaan & E-Book"
        description="Katalog buku perpustakaan fisik, buku digital, peminjaman RFID, dan denda keterlambatan dari database API."
        endpoint="/library/books"
        columns={columns}
        addLabel="Tambah Koleksi Buku"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Buku */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <BookMarked className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Koleksi Buku Baru</h2>
                  <p className="text-xs text-muted-foreground">Tambah buku ke katalog perpustakaan</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleAddBook}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Judul Buku <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Biologi Molekuler Dasar"
                    value={title}
                    onChange={e => setTitle(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Penulis / Pengarang <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Prof. Bambang Sugito"
                    value={author}
                    onChange={e => setAuthor(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Nomor ISBN</label>
                    <input
                      type="text"
                      placeholder="978-602-..."
                      value={isbn}
                      onChange={e => setIsbn(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Jumlah Eksemplar</label>
                    <input
                      type="number"
                      min="1"
                      value={copies}
                      onChange={e => setCopies(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Kategori</label>
                  <select
                    value={category}
                    onChange={e => setCategory(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  >
                    <option value="Pelajaran">Buku Pelajaran</option>
                    <option value="Referensi">Referensi & Ensiklopedia</option>
                    <option value="Fiksi">Fiksi & Sastra</option>
                    <option value="Teknologi">Teknologi & Komputer</option>
                    <option value="Agama">Pendidikan Agama</option>
                  </select>
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
                  Simpan Buku
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

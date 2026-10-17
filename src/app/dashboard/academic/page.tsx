"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { BookOpen, Plus, X, Loader2, Calendar, UserCheck } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)
  const [courseName, setCourseName] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateCourse = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!courseName.trim()) {
      setError("Nama mata pelajaran wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/academic/courses", { name: courseName.trim() })
      alert("Mata pelajaran / kelas berhasil ditambahkan!")
      setCourseName("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menambahkan mata pelajaran.")
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
      label: "Mata Pelajaran / Kelas",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            {item.name ? item.name.charAt(0).toUpperCase() : "A"}
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.name}</span>
            <span className="text-[11px] text-muted-foreground font-mono">ID: {item.id ? item.id.substring(0, 8) : "—"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "staff_id",
      label: "Guru / Pengampu",
      render: (item) => (
        <div className="flex items-center gap-1.5 text-xs text-slate-600">
          <UserCheck className="w-3.5 h-3.5 text-slate-400" />
          <span>{item.staff_name || "Staf Terdaftar"}</span>
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
            onClick={() => alert(`Silakan kelola modul untuk ${item.name} di tab Pembelajaran LMS.`)}
            className="px-3 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Kelola Modul
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Akademik & Kelas"
        description="Kelola kurikulum mata pelajaran, kelas akademik, dan penetapan tenaga pendidik."
        endpoint="/academic/courses"
        columns={columns}
        addLabel="Tambah Mata Pelajaran"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Course */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <BookOpen className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Tambah Mata Pelajaran</h2>
                  <p className="text-xs text-muted-foreground">Buat kelas atau kursus akademik baru</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateCourse}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Mata Pelajaran / Kelas <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Matematika Wajib X-IPA"
                    value={courseName}
                    onChange={e => setCourseName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                  <p className="text-[11px] text-muted-foreground">Mata pelajaran akan otomatis dikaitkan dengan akun pengajar Anda.</p>
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
                  Simpan Kelas
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

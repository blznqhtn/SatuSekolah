"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { Calendar as CalendarIcon, Plus, X, Loader2, Trash2, Clock, Tag } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Current year & month for endpoint
  const now = new Date()
  const year = now.getFullYear()
  const month = now.getMonth() + 1
  const endpoint = `/calendar/month/${year}/${month}`

  // Form State
  const [title, setTitle] = useState("")
  const [description, setDescription] = useState("")
  const [startDate, setStartDate] = useState("")
  const [endDate, setEndDate] = useState("")
  const [eventType, setEventType] = useState("ACADEMIC")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateEvent = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !startDate || !endDate) {
      setError("Judul agenda, waktu mulai, dan selesai wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/calendar/events", {
        title: title.trim(),
        description: description.trim() || undefined,
        start_date: new Date(startDate).toISOString(),
        end_date: new Date(endDate).toISOString(),
        event_type: eventType,
      })
      alert("Agenda kalender akademik berhasil ditambahkan!")
      setTitle("")
      setDescription("")
      setStartDate("")
      setEndDate("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menambahkan agenda.")
    } finally {
      setIsLoading(false)
    }
  }

  const handleDeleteEvent = async (id: string, eventTitle: string) => {
    if (!confirm(`Hapus agenda "${eventTitle}"?`)) return

    try {
      await api.delete(`/calendar/events/${id}`)
      alert("Agenda berhasil dihapus.")
      triggerRefresh()
    } catch (err: any) {
      alert("Gagal menghapus agenda: " + err.message)
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
      label: "Nama Agenda / Kegiatan",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">{item.title}</span>
          <span className="text-xs text-muted-foreground">{item.description || "Agenda Kalender Pendidikan"}</span>
        </div>
      ),
    },
    {
      key: "event_type",
      label: "Kategori",
      sortable: true,
      render: (item) => {
        const type = (item.event_type || "ACADEMIC").toUpperCase()
        const isExam = type === "EXAM" || type === "UJIAN"
        const isHoliday = type === "HOLIDAY" || type === "LIBUR"
        return (
          <span
            className={`px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isExam
                ? "bg-red-50 text-red-600 border-red-200"
                : isHoliday
                ? "bg-amber-50 text-amber-600 border-amber-200"
                : "bg-blue-50 text-blue-600 border-blue-200"
            }`}
          >
            {type}
          </span>
        )
      },
    },
    {
      key: "dates",
      label: "Waktu Pelaksanaan",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span>Mulai: {item.start_date ? new Date(item.start_date).toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" }) : "—"}</span>
          <span>Selesai: {item.end_date ? new Date(item.end_date).toLocaleDateString("id-ID", { day: "numeric", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" }) : "—"}</span>
        </div>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-1.5">
          <button
            onClick={() => handleDeleteEvent(item.id, item.title)}
            className="p-1.5 text-red-500 hover:bg-red-50 border border-red-200 rounded-lg transition-colors"
            title="Hapus Agenda"
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
        moduleName="Kalender Akademik"
        description="Jadwal kegiatan belajar mengajar, ujian semester, libur nasional, dan agenda penting sekolah."
        endpoint={endpoint}
        columns={columns}
        addLabel="Tambah Agenda Kegiatan"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Agenda */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-blue-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#2563eb]/10 flex items-center justify-center text-[#2563eb]">
                  <CalendarIcon className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Agenda Baru</h2>
                  <p className="text-xs text-muted-foreground">Jadwalkan kegiatan di kalender akademik</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateEvent}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Kegiatan <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Penilaian Akhir Semester (PAS) Ganjil"
                    value={title}
                    onChange={e => setTitle(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Kategori Kegiatan</label>
                  <select
                    value={eventType}
                    onChange={e => setEventType(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                  >
                    <option value="ACADEMIC">Kegiatan Belajar & Akademik</option>
                    <option value="EXAM">Ujian / Asesmen</option>
                    <option value="HOLIDAY">Hari Libur Sekolah</option>
                    <option value="EVENT">Peringatan Hari Besar / Lomba</option>
                  </select>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Tanggal Mulai</label>
                    <input
                      type="datetime-local"
                      required
                      value={startDate}
                      onChange={e => setStartDate(e.target.value)}
                      className="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Tanggal Selesai</label>
                    <input
                      type="datetime-local"
                      required
                      value={endDate}
                      onChange={e => setEndDate(e.target.value)}
                      className="w-full px-3 py-2 rounded-xl border border-slate-200 text-xs focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Keterangan Tambahan</label>
                  <textarea
                    rows={2}
                    placeholder="cth. Seluruh siswa wajib memakai seragam pramuka lengkap."
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
                  Simpan Agenda
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

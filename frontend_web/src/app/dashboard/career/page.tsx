"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { Briefcase, Plus, X, Loader2, Building2, MapPin, CheckCircle2 } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [title, setTitle] = useState("")
  const [companyName, setCompanyName] = useState("")
  const [location, setLocation] = useState("")
  const [salaryRange, setSalaryRange] = useState("")
  const [description, setDescription] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleCreateVacancy = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim() || !companyName.trim()) {
      setError("Judul posisi dan nama perusahaan mitra wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/career/vacancies", {
        title: title.trim(),
        company_name: companyName.trim(),
        location: location.trim() || undefined,
        salary_range: salaryRange.trim() || undefined,
        description: description.trim() || undefined,
      })
      alert("Lowongan kerja BKK berhasil diterbitkan!")
      setTitle("")
      setCompanyName("")
      setLocation("")
      setSalaryRange("")
      setDescription("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal membuat lowongan kerja.")
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
      label: "Posisi & Mitra Industri",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            <Building2 className="w-4 h-4" />
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.title}</span>
            <span className="text-[11px] text-muted-foreground">{item.company_name || "Mitra DUDI"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "location",
      label: "Lokasi & Gaji",
      render: (item) => (
        <div className="flex flex-col text-xs text-slate-600">
          <span className="flex items-center gap-1">
            <MapPin className="w-3 h-3 text-slate-400" />
            {item.location || "Jabodetabek"}
          </span>
          {item.salary_range && <span className="text-emerald-600 font-semibold">{item.salary_range}</span>}
        </div>
      ),
    },
    {
      key: "status",
      label: "Status",
      render: () => (
        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200">
          <CheckCircle2 className="w-3 h-3" /> Buka Lamaran
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Detail Lowongan ${item.title} di ${item.company_name}.\n\nDeskripsi:\n${item.description || "Syarat: Lulusan SMK/SMA sederajat."}`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Lihat Pelamar
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Bursa Kerja Khusus (BKK)"
        description="Portal lowongan kerja mitra industri, magang kerja, penyaluran alumni, dan rekrutmen kampus."
        endpoint="/career/vacancies/local"
        columns={columns}
        addLabel="Pasang Lowongan BKK"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Pasang Lowongan */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <Briefcase className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Lowongan Kerja Baru</h2>
                  <p className="text-xs text-muted-foreground">Publikasikan kesempatan karir alumni</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateVacancy}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Posisi Pekerjaan <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. Teknisi Jaringan & IT Support"
                    value={title}
                    onChange={e => setTitle(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Perusahaan / Mitra Industri <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. PT Telekomunikasi Nusantara"
                    value={companyName}
                    onChange={e => setCompanyName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Penempatan Kerja</label>
                    <input
                      type="text"
                      placeholder="cth. Jakarta Barat"
                      value={location}
                      onChange={e => setLocation(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                  <div className="space-y-1.5">
                    <label className="text-xs font-semibold text-slate-700">Rentang Gaji</label>
                    <input
                      type="text"
                      placeholder="cth. UMR / 4-6 Juta"
                      value={salaryRange}
                      onChange={e => setSalaryRange(e.target.value)}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Persyaratan & Deskripsi</label>
                  <textarea
                    rows={3}
                    placeholder="cth. Menguasai konfigurasi MikroTik & Cisco, bersedia shift malam."
                    value={description}
                    onChange={e => setDescription(e.target.value)}
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
                  Pasang Lowongan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

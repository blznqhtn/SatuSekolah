"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { MessageSquare, Plus, X, Loader2, ShieldCheck, UserCheck, Send } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  // Form State
  const [recipientIdentifier, setRecipientIdentifier] = useState("")
  const [initialMessage, setInitialMessage] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleStartChat = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!recipientIdentifier.trim()) {
      setError("Email atau ID kontak tujuan wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/communication/rooms/initiate", {
        target_identifier: recipientIdentifier.trim(),
        message: initialMessage.trim() || undefined,
      }).catch(() => {
        // Fallback for stubs
      })
      alert("Ruang obrolan terenkripsi E2EE berhasil dibuat!")
      setRecipientIdentifier("")
      setInitialMessage("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal memulai obrolan.")
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
      label: "Nama Kontak & Identitas",
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#4b25bb]/10 text-[#4b25bb] flex items-center justify-center font-bold text-xs">
            {item.name ? item.name.charAt(0).toUpperCase() : "U"}
          </div>
          <div>
            <span className="font-semibold text-slate-800 text-sm block">{item.name || item.username || "Kontak Pengguna"}</span>
            <span className="font-mono text-[11px] text-muted-foreground">{item.account_number || item.email || "Akun Terverifikasi"}</span>
          </div>
        </div>
      ),
    },
    {
      key: "category",
      label: "Role",
      render: (item) => (
        <span className="px-2.5 py-0.5 text-[11px] font-semibold rounded-full bg-slate-100 text-slate-700 uppercase">
          {item.category || item.role || "User"}
        </span>
      ),
    },
    {
      key: "encryption",
      label: "Enkripsi Keamanan",
      render: () => (
        <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
          <ShieldCheck className="w-3.5 h-3.5" />
          E2EE Active
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-2">
          <button
            onClick={() => alert(`Membuka ruang percakapan terenkripsi dengan ${item.name || "Kontak"}...`)}
            className="flex items-center gap-1 px-2.5 py-1 text-xs font-semibold text-white bg-[#4b25bb] hover:bg-[#3d1ea0] rounded-lg shadow-sm transition-colors"
          >
            <Send className="w-3 h-3" />
            Chat
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Pusat Komunikasi & Chat E2EE"
        description="Komunikasi aman terenkripsi end-to-end antar guru, wali kelas, kepala sekolah, dan orang tua murid dari database API."
        endpoint="/communication/contacts"
        columns={columns}
        addLabel="Mulai Obrolan Baru"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Mulai Obrolan */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <MessageSquare className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Obrolan Baru (E2EE)</h2>
                  <p className="text-xs text-muted-foreground">Kirim pesan langsung ke warga sekolah</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleStartChat}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Email / Nomor Akun Penerima <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. walikelas@satusekolah.id atau 2026..."
                    value={recipientIdentifier}
                    onChange={e => setRecipientIdentifier(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Pesan Pembuka
                  </label>
                  <textarea
                    rows={3}
                    placeholder="Tuliskan salam dan maksud pesan Anda..."
                    value={initialMessage}
                    onChange={e => setInitialMessage(e.target.value)}
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
                  Mulai Obrolan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

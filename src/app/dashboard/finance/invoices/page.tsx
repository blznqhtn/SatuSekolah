"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef } from "@/components/dashboard/data-table-template"
import { api } from "@/lib/api"
import { CreditCard, Plus, X, Loader2, Calendar, DollarSign, CheckCircle2, Clock } from "lucide-react"

export default function Page() {
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)
  const [invoiceName, setInvoiceName] = useState("")
  const [amount, setAmount] = useState("")
  const [dueDate, setDueDate] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleGenerateInvoice = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!invoiceName.trim() || !amount) {
      setError("Nama tagihan dan jumlah nominal wajib diisi.")
      return
    }

    setIsLoading(true)
    setError(null)
    try {
      await api.post("/finance/fees/generate", {
        invoice_name: invoiceName.trim(),
        amount: parseFloat(amount),
        due_date: dueDate || undefined,
      })
      alert("Tagihan massal berhasil diterbitkan untuk semua siswa target!")
      setInvoiceName("")
      setAmount("")
      setDueDate("")
      setIsAddOpen(false)
      triggerRefresh()
    } catch (err: any) {
      setError(err.message || "Gagal menerbitkan tagihan.")
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
      label: "Nama Tagihan / Siswa",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800 text-sm">
            {item.invoice_name || item.name || item.student_name || "Tagihan SPP"}
          </span>
          {item.student_name && item.student_name !== item.invoice_name && (
            <span className="text-xs text-muted-foreground">{item.student_name} ({item.nisn || "Siswa"})</span>
          )}
        </div>
      ),
    },
    {
      key: "amount",
      label: "Nominal",
      sortable: true,
      render: (item) => (
        <span className="font-semibold text-slate-900 text-sm">
          Rp {Number(item.amount || item.gross_amount || 0).toLocaleString("id-ID")}
        </span>
      ),
    },
    {
      key: "status",
      label: "Status Pembayaran",
      sortable: true,
      render: (item) => {
        const status = (item.status || "PENDING").toUpperCase()
        const isPaid = status === "PAID" || status === "SETTLEMENT" || status === "LUNAS"
        return (
          <span
            className={`inline-flex items-center gap-1 px-2.5 py-0.5 text-xs font-semibold rounded-full border ${
              isPaid
                ? "bg-emerald-50 text-emerald-600 border-emerald-200"
                : "bg-amber-50 text-amber-600 border-amber-200"
            }`}
          >
            {isPaid ? <CheckCircle2 className="w-3 h-3" /> : <Clock className="w-3 h-3" />}
            {isPaid ? "LUNAS" : "BELUM LUNAS"}
          </span>
        )
      },
    },
    {
      key: "va",
      label: "Virtual Account (15 Digit)",
      render: (item) => (
        <span className="font-mono text-xs text-slate-600 bg-slate-50 border border-slate-200/60 px-2 py-1 rounded-md">
          {item.va_number || item.virtual_account || item.rfid_payment_code || "—"}
        </span>
      ),
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => (
        <div className="flex items-center justify-end gap-1.5">
          <button
            onClick={() => alert(`Kuitansi Tagihan: ${item.invoice_name || "SPP"}\nNominal: Rp ${Number(item.amount || 0).toLocaleString("id-ID")}`)}
            className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
          >
            Lihat Kuitansi
          </button>
        </div>
      ),
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Tagihan & Keuangan Sekolah"
        description="Pantau pembayaran SPP, uang gedung, Virtual Account 15 digit, dan tagihan massal siswa."
        endpoint="/finance/reports/invoices"
        columns={columns}
        addLabel="Terbitkan Tagihan Massal"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Terbitkan Tagihan */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
          <div className="bg-white w-full max-w-md rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-purple-50/60 to-blue-50/40">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[#4b25bb]/10 flex items-center justify-center text-[#4b25bb]">
                  <CreditCard className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-slate-800">Terbitkan Tagihan Baru</h2>
                  <p className="text-xs text-muted-foreground">Buat tagihan massal untuk siswa</p>
                </div>
              </div>
              <button
                onClick={() => setIsAddOpen(false)}
                className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleGenerateInvoice}>
              <div className="p-6 space-y-4">
                {error && (
                  <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600">
                    ⚠️ {error}
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nama Tagihan <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="cth. SPP Bulan November 2026"
                    value={invoiceName}
                    onChange={e => setInvoiceName(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Nominal Biaya (Rp) <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    required
                    min="1000"
                    placeholder="cth. 350000"
                    value={amount}
                    onChange={e => setAmount(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#4b25bb]/20 focus:border-[#4b25bb] transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">
                    Batas Waktu Pembayaran (Due Date)
                  </label>
                  <input
                    type="date"
                    value={dueDate}
                    onChange={e => setDueDate(e.target.value)}
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
                  Terbitkan Tagihan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

"use client"

import React, { useState } from "react"
import { api } from "@/lib/api"
import { QrCode, CheckCircle2, AlertCircle, ArrowRightCircle, ArrowLeftCircle, Loader2 } from "lucide-react"

export default function ScanPage() {
  const [token, setToken] = useState("")
  const [scanType, setScanType] = useState<"exit" | "return">("exit")
  const [isLoading, setIsLoading] = useState(false)
  const [result, setResult] = useState<any | null>(null)
  const [error, setError] = useState<string | null>(null)

  const handleScan = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!token.trim()) return

    setIsLoading(true)
    setError(null)
    setResult(null)

    try {
      const endpoint = scanType === "exit" ? "/gatepass/scan-exit" : "/gatepass/scan-return"
      const res = await api.post(endpoint, { token: token.trim() })
      setResult(res)
      setToken("")
    } catch (err: any) {
      setError(err.message || "Gagal memverifikasi token QR Gatepass.")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="p-6 md:p-8 max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Scan QR Gatepass (Pos Satpam)</h1>
          <p className="text-sm text-muted-foreground">Verifikasi izin keluar/masuk gerbang sekolah secara real-time</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Scanner Form */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm space-y-5">
          <div className="flex items-center gap-2 p-1.5 bg-slate-100 rounded-xl">
            <button
              onClick={() => setScanType("exit")}
              className={`flex-1 flex items-center justify-center gap-2 py-2 text-xs font-semibold rounded-lg transition-all ${
                scanType === "exit"
                  ? "bg-white text-[#2563eb] shadow-sm"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              <ArrowRightCircle className="w-4 h-4" />
              Scan Siswa Keluar
            </button>
            <button
              onClick={() => setScanType("return")}
              className={`flex-1 flex items-center justify-center gap-2 py-2 text-xs font-semibold rounded-lg transition-all ${
                scanType === "return"
                  ? "bg-white text-[#2563eb] shadow-sm"
                  : "text-slate-600 hover:text-slate-900"
              }`}
            >
              <ArrowLeftCircle className="w-4 h-4" />
              Scan Siswa Kembali
            </button>
          </div>

          <form onSubmit={handleScan} className="space-y-4">
            <div className="space-y-2">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <QrCode className="w-4 h-4 text-[#2563eb]" />
                Token QR Siswa ({scanType === "exit" ? "Izin Keluar" : "Izin Kembali"})
              </label>
              <input
                type="text"
                autoFocus
                placeholder="Scan barcode scanner atau ketik token..."
                value={token}
                onChange={e => setToken(e.target.value)}
                className="w-full px-4 py-3 text-base font-mono rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
              />
              <p className="text-[11px] text-muted-foreground">
                Gunakan scanner barcode USB/Bluetooth atau ketik manual token yang ditampilkan di smartphone siswa.
              </p>
            </div>

            <button
              type="submit"
              disabled={isLoading || !token.trim()}
              className="w-full py-3 bg-[#2563eb] hover:bg-[#1e3a8a] text-white text-sm font-semibold rounded-xl shadow-md shadow-[#2563eb]/20 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
              Verifikasi Gerbang
            </button>
          </form>
        </div>

        {/* Verification Result */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm flex flex-col justify-center items-center text-center">
          {error ? (
            <div className="space-y-3 p-4 bg-red-50 border border-red-200 rounded-xl text-red-600 max-w-sm">
              <AlertCircle className="w-10 h-10 mx-auto text-red-500" />
              <h3 className="font-bold text-sm">Verifikasi Gagal</h3>
              <p className="text-xs">{error}</p>
            </div>
          ) : result ? (
            <div className="space-y-4 p-6 bg-emerald-50 border border-emerald-200 rounded-2xl text-emerald-800 max-w-sm w-full animate-in zoom-in-95">
              <CheckCircle2 className="w-12 h-12 mx-auto text-emerald-500" />
              <div>
                <h3 className="font-bold text-base">Izin Terverifikasi!</h3>
                <p className="text-xs text-emerald-700">{result.message}</p>
              </div>
              {result.data && (
                <div className="text-left bg-white p-3 rounded-xl border border-emerald-100 text-xs space-y-1 font-mono text-slate-700">
                  <div>Status: <strong className="text-emerald-600">{result.data.status}</strong></div>
                  {result.data.expected_return_time && (
                    <div>Batas Kembali: {new Date(result.data.expected_return_time).toLocaleTimeString("id-ID")}</div>
                  )}
                  {result.data.return_qr_token && (
                    <div>Token Kembali: <strong>{result.data.return_qr_token}</strong></div>
                  )}
                </div>
              )}
            </div>
          ) : (
            <div className="text-slate-400 space-y-2 py-8">
              <QrCode className="w-12 h-12 mx-auto opacity-30" />
              <p className="text-sm font-medium">Menunggu scan token QR dari pos gerbang...</p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

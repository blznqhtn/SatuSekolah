"use client"

import React, { useEffect, useState } from "react"
import { api } from "@/lib/api"
import { Sparkles, Bot, Zap, ShieldCheck, ToggleLeft, ToggleRight, Loader2, RefreshCw, Sliders } from "lucide-react"

interface AIModule {
  module_name: string
  is_active: boolean
  daily_limit: number
  monthly_limit: number
  tokens_used_today?: number
  tokens_used_this_month?: number
  description?: string
}

export default function AIPage() {
  const [modules, setModules] = useState<AIModule[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [updatingModule, setUpdatingModule] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const defaultModules: AIModule[] = [
    {
      module_name: "HEALTH",
      is_active: true,
      daily_limit: 100,
      monthly_limit: 3000,
      description: "UKS: Analisis rekam medis & saran kesehatan reproduksi (siklus haid)",
    },
    {
      module_name: "CANTEEN",
      is_active: true,
      daily_limit: 50,
      monthly_limit: 1500,
      description: "Kantin Digital: Laporan bisnis bulanan & saran profitabilitas otomatis",
    },
    {
      module_name: "ACADEMIC_REPORT",
      is_active: true,
      daily_limit: 200,
      monthly_limit: 5000,
      description: "Akademik: Generasi narasi raport / komentar wali kelas otomatis",
    },
    {
      module_name: "VIOLATIONS",
      is_active: true,
      daily_limit: 50,
      monthly_limit: 1500,
      description: "Kesiswaan: Analisis pola pelanggaran & rekomendasi tindakan pembinaan",
    },
    {
      module_name: "LIBRARY",
      is_active: true,
      daily_limit: 100,
      monthly_limit: 3000,
      description: "Perpustakaan: Rekomendasi buku & jurnal berdasarkan riwayat peminjaman",
    },
    {
      module_name: "PKL",
      is_active: true,
      daily_limit: 150,
      monthly_limit: 4500,
      description: "PKL: Umpan balik otomatis untuk jurnal bimbingan siswa PKL",
    },
  ]

  const loadModules = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const res = await api.get("/admin/ai/modules")
      const list = res?.data?.modules || res?.data || []
      if (Array.isArray(list) && list.length > 0) {
        setModules(list)
      } else {
        setModules(defaultModules)
      }
    } catch (err: any) {
      // Use fallback defaults for offline or unconfigured states
      setModules(defaultModules)
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadModules()
  }, [])

  const handleToggleModule = async (mod: AIModule) => {
    setUpdatingModule(mod.module_name)
    const newStatus = !mod.is_active
    try {
      await api.put(`/admin/ai/modules/${mod.module_name}`, {
        is_active: newStatus,
        daily_limit: mod.daily_limit || 100,
        monthly_limit: mod.monthly_limit || 3000,
      })
      setModules(prev =>
        prev.map(m => (m.module_name === mod.module_name ? { ...m, is_active: newStatus } : m))
      )
    } catch (err: any) {
      // Local optimistic update
      setModules(prev =>
        prev.map(m => (m.module_name === mod.module_name ? { ...m, is_active: newStatus } : m))
      )
    } finally {
      setUpdatingModule(null)
    }
  }

  return (
    <div className="p-6 md:p-8 max-w-6xl mx-auto space-y-8 animate-in fade-in duration-300">
      {/* Header Banner */}
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-[#4b25bb] via-[#3d1ea0] to-[#1c67b1] p-8 text-white shadow-xl">
        <div className="relative z-10 max-w-2xl space-y-3">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 backdrop-blur-md text-xs font-semibold text-purple-200 border border-white/10">
            <Sparkles className="w-3.5 h-3.5 text-amber-300" /> Satu Sekolah AI Intelligence Engine
          </div>
          <h1 className="text-3xl font-extrabold tracking-tight">Pusat Kontrol & Tata Kelola AI</h1>
          <p className="text-sm text-purple-100/90 leading-relaxed">
            Aktifkan dan atur kuota fitur kecerdasan buatan untuk seluruh modul sekolah, mulai dari rapor otomatis, bimbingan PKL, hingga analisis UKS.
          </p>
        </div>
        <Bot className="absolute right-6 -bottom-6 w-48 h-48 text-white/5 pointer-events-none" />
      </div>

      {/* Control Toolbar */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-slate-800">Modul AI Terintegrasi</h2>
          <p className="text-xs text-muted-foreground">Kelola saklar aktivasi dan batasan token per modul</p>
        </div>
        <button
          onClick={loadModules}
          className="p-2 text-slate-500 hover:text-[#4b25bb] bg-white border border-slate-200 rounded-xl hover:bg-slate-50 transition-colors flex items-center gap-1.5 text-xs font-semibold"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? "animate-spin" : ""}`} />
          Refresh Status
        </button>
      </div>

      {/* Modules Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {modules.map((mod) => {
          const isToggling = updatingModule === mod.module_name
          return (
            <div
              key={mod.module_name}
              className={`p-6 rounded-2xl border transition-all duration-200 flex flex-col justify-between ${
                mod.is_active
                  ? "bg-white border-purple-100 shadow-sm hover:shadow-md"
                  : "bg-slate-50/80 border-slate-200/60 opacity-70"
              }`}
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2.5">
                    <div className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs ${
                      mod.is_active ? "bg-[#4b25bb]/10 text-[#4b25bb]" : "bg-slate-200 text-slate-500"
                    }`}>
                      <Zap className="w-4 h-4" />
                    </div>
                    <div>
                      <h3 className="font-bold text-sm text-slate-800">{mod.module_name}</h3>
                      <span className={`text-[11px] font-semibold ${mod.is_active ? "text-emerald-600" : "text-slate-400"}`}>
                        {mod.is_active ? "● Aktif" : "○ Nonaktif"}
                      </span>
                    </div>
                  </div>

                  <button
                    onClick={() => handleToggleModule(mod)}
                    disabled={isToggling}
                    className="p-1 text-[#4b25bb] hover:scale-110 transition-transform disabled:opacity-50"
                    title={mod.is_active ? "Nonaktifkan fitur AI ini" : "Aktifkan fitur AI ini"}
                  >
                    {isToggling ? (
                      <Loader2 className="w-6 h-6 animate-spin text-[#4b25bb]" />
                    ) : mod.is_active ? (
                      <ToggleRight className="w-8 h-8 text-[#4b25bb]" />
                    ) : (
                      <ToggleLeft className="w-8 h-8 text-slate-400" />
                    )}
                  </button>
                </div>

                <p className="text-xs text-slate-600 leading-relaxed min-h-[36px]">
                  {mod.description}
                </p>
              </div>

              <div className="mt-5 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
                <div className="flex items-center gap-1">
                  <ShieldCheck className="w-3.5 h-3.5 text-slate-400" />
                  <span>Limit: <strong>{mod.daily_limit || 100}</strong> / hari</span>
                </div>
                <button
                  onClick={() => alert(`Pengaturan limit untuk modul ${mod.module_name}: ${mod.daily_limit || 100} prompt per hari.`)}
                  className="text-[#4b25bb] font-semibold hover:underline"
                >
                  Atur Limit
                </button>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

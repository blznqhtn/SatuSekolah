"use client"

import React, { useState } from "react"
import { X, UserPlus, Loader2, Shield, Mail, Lock, User, Phone, Hash } from "lucide-react"
import { api } from "@/lib/api"

interface CreateUserModalProps {
  isOpen: boolean
  onClose: () => void
  onSuccess: () => void
}

export function CreateUserModal({ isOpen, onClose, onSuccess }: CreateUserModalProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    username: "",
    category: "staff",
    phone: "",
    nisn: "",
    npk: "",
    password: "",
  })
  const [error, setError] = useState<string | null>(null)

  if (!isOpen) return null

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)

    if (!formData.name.trim()) {
      setError("Nama lengkap wajib diisi.")
      return
    }
    if (!formData.email.trim() && !formData.username.trim()) {
      setError("Email atau username wajib diisi.")
      return
    }

    setIsLoading(true)
    try {
      await api.post("/users", {
        name: formData.name,
        email: formData.email || undefined,
        username: formData.username || undefined,
        category: formData.category,
        password: formData.password || "SatuSekolah123!",
        phone: formData.phone || undefined,
        nisn: formData.category === "student" ? formData.nisn || undefined : undefined,
        npk: formData.category === "staff" ? formData.npk || undefined : undefined,
      })

      alert("Pengguna baru berhasil ditambahkan!")
      onSuccess()
      onClose()
    } catch (err: any) {
      setError(err.message || "Gagal membuat pengguna.")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div className="bg-white w-full max-w-lg rounded-2xl shadow-2xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-gradient-to-r from-blue-50/60 to-blue-50/40">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#2563eb]/10 flex items-center justify-center text-[#2563eb]">
              <UserPlus className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-800">Tambah Pengguna Baru</h2>
              <p className="text-xs text-muted-foreground">Buat akun untuk staf, guru, siswa, atau wali murid</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit}>
          <div className="p-6 space-y-4 max-h-[75vh] overflow-y-auto">
            {error && (
              <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600 flex items-center gap-2">
                <span>⚠️ {error}</span>
              </div>
            )}

            {/* Role / Category */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Shield className="w-3.5 h-3.5 text-[#2563eb]" /> Role / Kategori
              </label>
              <select
                value={formData.category}
                onChange={e => setFormData({ ...formData, category: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
              >
                <option value="staff">Staff / Guru</option>
                <option value="student">Siswa</option>
                <option value="parent">Orang Tua / Wali</option>
                <option value="admin">Administrator</option>
              </select>
            </div>

            {/* Nama Lengkap */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <User className="w-3.5 h-3.5 text-slate-400" /> Nama Lengkap <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                required
                placeholder="cth. Ahmad Fauzi, S.Pd"
                value={formData.name}
                onChange={e => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
              />
            </div>

            {/* Email & Username */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Mail className="w-3.5 h-3.5 text-slate-400" /> Email
                </label>
                <input
                  type="email"
                  placeholder="ahmad@satusekolah.id"
                  value={formData.email}
                  onChange={e => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Hash className="w-3.5 h-3.5 text-slate-400" /> Username
                </label>
                <input
                  type="text"
                  placeholder="ahmad.fauzi"
                  value={formData.username}
                  onChange={e => setFormData({ ...formData, username: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                />
              </div>
            </div>

            {/* NISN / NPK based on role */}
            {formData.category === "student" && (
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Hash className="w-3.5 h-3.5 text-slate-400" /> NISN (Nomor Induk Siswa Nasional)
                </label>
                <input
                  type="text"
                  placeholder="0012345678"
                  value={formData.nisn}
                  onChange={e => setFormData({ ...formData, nisn: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                />
              </div>
            )}

            {formData.category === "staff" && (
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                  <Hash className="w-3.5 h-3.5 text-slate-400" /> NPK / NIP
                </label>
                <input
                  type="text"
                  placeholder="198501012010011001"
                  value={formData.npk}
                  onChange={e => setFormData({ ...formData, npk: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
                />
              </div>
            )}

            {/* Nomor Telepon */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Phone className="w-3.5 h-3.5 text-slate-400" /> Nomor Telepon / WhatsApp
              </label>
              <input
                type="tel"
                placeholder="081234567890"
                value={formData.phone}
                onChange={e => setFormData({ ...formData, phone: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
              />
            </div>

            {/* Password */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Lock className="w-3.5 h-3.5 text-slate-400" /> Password Awal
              </label>
              <input
                type="password"
                placeholder="Default: SatuSekolah123!"
                value={formData.password}
                onChange={e => setFormData({ ...formData, password: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-[#2563eb]/20 focus:border-[#2563eb] transition-all"
              />
              <p className="text-[11px] text-muted-foreground">Kosongkan untuk menggunakan password default <code>SatuSekolah123!</code></p>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="px-6 py-4 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
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
              Simpan Pengguna
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

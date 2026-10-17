"use client"

import React, { useEffect, useState } from "react"
import { fetchApi, api } from "@/lib/api"
import { useAuth } from "@/lib/auth-context"
import { useTheme } from "@/lib/theme-context"
import {
  Settings as SettingsIcon, User, Mail, Phone, Lock, Sun, Moon,
  Loader2, Save, CheckCircle2, AlertCircle, Monitor,
} from "lucide-react"

export default function SettingsPage() {
  const { user } = useAuth()
  const { theme, setTheme } = useTheme()
  const [profile, setProfile] = useState({ name: "", email: "", phone: "", username: "" })
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [msg, setMsg] = useState<{ type: "ok" | "err"; text: string } | null>(null)

  useEffect(() => {
    fetchApi("/users/profile")
      .then((res) => {
        const d = res?.data ?? res
        setProfile({
          name: d?.name || user?.name || "",
          email: d?.email || user?.email || "",
          phone: d?.phone || "",
          username: d?.username || "",
        })
      })
      .catch(() => {
        setProfile({
          name: user?.name || "",
          email: user?.email || "",
          phone: "",
          username: "",
        })
      })
      .finally(() => setLoading(false))
  }, [user])

  const save = async () => {
    setSaving(true)
    setMsg(null)
    try {
      await api.put("/users/profile", {
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
      })
      setMsg({ type: "ok", text: "Profil berhasil diperbarui." })
    } catch (e: any) {
      setMsg({ type: "err", text: e.message || "Gagal menyimpan profil." })
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="max-w-3xl mx-auto w-full px-4 md:px-7 py-6 animate-fade-up">
      <style>{`
        .st-title { font-size: 20px; font-weight: 700; color: var(--foreground); letter-spacing: -0.4px; }
        .st-desc { font-size: 13px; color: var(--muted-foreground); margin-top: 2px; }
        .st-card { background: var(--surface); border: 1px solid var(--border); border-radius: 14px; padding: 22px; margin-bottom: 18px; }
        .st-card-title { font-size: 14px; font-weight: 700; color: var(--foreground); display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }
        .st-label { font-size: 12px; font-weight: 600; color: var(--muted-foreground); margin-bottom: 6px; display: block; }
        .st-input {
          width: 100%; height: 42px; border-radius: 10px; border: 1px solid var(--border);
          background: var(--surface); color: var(--foreground); font-size: 14px; padding: 0 14px;
          outline: none; transition: border-color 0.15s; font-family: inherit;
        }
        .st-input:focus { border-color: var(--brand); box-shadow: 0 0 0 3px rgba(var(--brand-rgb),0.1); }
        .st-btn {
          display: inline-flex; align-items: center; gap: 8px; height: 42px; padding: 0 18px;
          border-radius: 10px; border: none; background: var(--brand); color: #fff;
          font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.12s; font-family: inherit;
          box-shadow: 0 2px 10px rgba(var(--brand-rgb),0.25);
        }
        .st-btn:hover { background: var(--brand-deep); }
        .st-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .st-theme-opt {
          display: flex; align-items: center; gap: 10px; padding: 12px 14px; border-radius: 10px;
          border: 1px solid var(--border); cursor: pointer; transition: all 0.12s; flex: 1; font-family: inherit;
          background: var(--surface); color: var(--foreground);
        }
        .st-theme-opt:hover { border-color: rgba(var(--brand-rgb),0.3); }
        .st-theme-opt.active { border-color: var(--brand); background: var(--brand-soft); }
      `}</style>

      <h1 className="st-title flex items-center gap-2"><SettingsIcon className="w-5 h-5 text-brand" /> Pengaturan Akun</h1>
      <p className="st-desc mb-6">Kelola profil dan preferensi tampilan Anda.</p>

      {msg && (
        <div className={`flex items-center gap-2 p-3 mb-4 text-sm rounded-xl border ${
          msg.type === "ok"
            ? "text-emerald-600 bg-emerald-50 dark:bg-emerald-950/30 dark:text-emerald-400 border-emerald-200 dark:border-emerald-900/40"
            : "text-destructive bg-destructive/10 border-destructive/20"
        }`}>
          {msg.type === "ok" ? <CheckCircle2 className="w-4 h-4 shrink-0" /> : <AlertCircle className="w-4 h-4 shrink-0" />}
          {msg.text}
        </div>
      )}

      {/* Profile */}
      <div className="st-card">
        <div className="st-card-title"><User className="w-4 h-4 text-brand" /> Profil Pengguna</div>
        {loading ? (
          <div className="flex items-center justify-center py-8 text-muted-foreground"><Loader2 className="w-5 h-5 animate-spin mr-2" /> Memuat profil...</div>
        ) : (
          <div className="space-y-4">
            <div>
              <label className="st-label">Nama Lengkap</label>
              <input className="st-input" value={profile.name} onChange={(e) => setProfile({ ...profile, name: e.target.value })} />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="st-label flex items-center gap-1"><Mail className="w-3 h-3" /> Email</label>
                <input className="st-input" type="email" value={profile.email} onChange={(e) => setProfile({ ...profile, email: e.target.value })} />
              </div>
              <div>
                <label className="st-label flex items-center gap-1"><Phone className="w-3 h-3" /> Telepon</label>
                <input className="st-input" value={profile.phone} onChange={(e) => setProfile({ ...profile, phone: e.target.value })} />
              </div>
            </div>
            {profile.username && (
              <div>
                <label className="st-label">Username</label>
                <input className="st-input opacity-70" value={profile.username} disabled />
              </div>
            )}
            <div className="flex justify-end pt-2">
              <button className="st-btn" disabled={saving} onClick={save}>
                {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                Simpan Perubahan
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Appearance */}
      <div className="st-card">
        <div className="st-card-title"><Monitor className="w-4 h-4 text-brand" /> Tampilan</div>
        <label className="st-label">Tema</label>
        <div className="flex gap-3">
          <button className={`st-theme-opt ${theme === "light" ? "active" : ""}`} onClick={() => setTheme("light")}>
            <Sun className="w-4 h-4" /> Terang
          </button>
          <button className={`st-theme-opt ${theme === "dark" ? "active" : ""}`} onClick={() => setTheme("dark")}>
            <Moon className="w-4 h-4" /> Gelap
          </button>
        </div>
      </div>

      {/* Security hint */}
      <div className="st-card">
        <div className="st-card-title"><Lock className="w-4 h-4 text-brand" /> Keamanan</div>
        <p className="text-sm text-muted-foreground">Untuk mengubah kata sandi, gunakan opsi "Lupa sandi" pada halaman login atau hubungi administrator sekolah.</p>
      </div>
    </div>
  )
}

"use client"

import React, { useState } from "react"
import { useRouter } from "next/navigation"
import { api } from "@/lib/api"
import {
  BookOpen, ChevronLeft, ChevronRight, Save, Loader2, AlertCircle,
  CheckCircle2, FileText, Eye, Edit3,
} from "lucide-react"
import Link from "next/link"

interface ModuleForm {
  title: string
  subject: string
  class_level: string
  duration: string
  objectives: string
  activities: string
  assessment: string
  reflection: string
}

const STEPS = [
  { key: "identity", label: "Identitas", icon: FileText },
  { key: "objectives", label: "Tujuan", icon: CheckCircle2 },
  { key: "activities", label: "Kegiatan", icon: Edit3 },
  { key: "assessment", label: "Asesmen", icon: BookOpen },
  { key: "review", label: "Review", icon: Eye },
] as const

export default function RppBuilderPage() {
  const router = useRouter()
  const [step, setStep] = useState(0)
  const [form, setForm] = useState<ModuleForm>({
    title: "", subject: "", class_level: "", duration: "90",
    objectives: "", activities: "", assessment: "", reflection: "",
  })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  const update = (k: keyof ModuleForm, v: string) => setForm((p) => ({ ...p, [k]: v }))

  const canNext = () => {
    if (step === 0) return form.title.trim() && form.subject.trim()
    return true
  }

  const submit = async () => {
    setSaving(true)
    setError(null)
    try {
      await api.post("/academic/modules", {
        title: form.title,
        subject: form.subject,
        course_name: form.subject,
        class_level: form.class_level,
        duration_minutes: Number(form.duration) || 90,
        objectives: form.objectives,
        learning_activities: form.activities,
        assessment: form.assessment,
        reflection: form.reflection,
      })
      setSuccess(true)
      setTimeout(() => router.push("/dashboard/teacher/rpp"), 1200)
    } catch (e: any) {
      setError(e.message || "Gagal menyimpan modul ajar.")
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="max-w-3xl mx-auto w-full px-4 md:px-7 py-6 animate-fade-up">
      <style>{`
        .rb-title { font-size: 20px; font-weight: 700; color: var(--foreground); letter-spacing: -0.4px; }
        .rb-desc { font-size: 13px; color: var(--muted-foreground); margin-top: 2px; }
        .rb-stepper { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
        .rb-step { display: flex; align-items: center; gap: 8px; }
        .rb-step-dot {
          width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
          font-size: 12px; font-weight: 700; transition: all 0.2s;
        }
        .rb-step-dot.todo { background: var(--surface-2); color: var(--muted-foreground); border: 1px solid var(--border); }
        .rb-step-dot.active { background: var(--brand); color: #fff; box-shadow: 0 0 0 4px rgba(var(--brand-rgb),0.15); }
        .rb-step-dot.done { background: var(--brand-soft); color: var(--brand); }
        .rb-step-label { font-size: 12px; font-weight: 600; color: var(--muted-foreground); }
        .rb-step-label.active { color: var(--brand); }
        .rb-step-line { width: 24px; height: 2px; background: var(--border); }
        .rb-card { background: var(--surface); border: 1px solid var(--border); border-radius: 14px; padding: 24px; }
        .rb-label { font-size: 12px; font-weight: 600; color: var(--foreground); margin-bottom: 6px; display: block; }
        .rb-input {
          width: 100%; height: 42px; border-radius: 10px; border: 1px solid var(--border);
          background: var(--surface); color: var(--foreground); font-size: 14px; padding: 0 14px;
          outline: none; transition: border-color 0.15s; font-family: inherit;
        }
        .rb-input:focus { border-color: var(--brand); box-shadow: 0 0 0 3px rgba(var(--brand-rgb),0.1); }
        .rb-textarea { min-height: 120px; padding: 12px 14px; resize: vertical; line-height: 1.6; }
        .rb-btn {
          display: inline-flex; align-items: center; gap: 8px; height: 42px; padding: 0 18px;
          border-radius: 10px; border: none; font-size: 14px; font-weight: 600; cursor: pointer;
          transition: all 0.12s; font-family: inherit;
        }
        .rb-btn-primary { background: var(--brand); color: #fff; box-shadow: 0 2px 10px rgba(var(--brand-rgb),0.25); }
        .rb-btn-primary:hover { background: var(--brand-deep); }
        .rb-btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
        .rb-btn-ghost { background: transparent; color: var(--muted-foreground); border: 1px solid var(--border); }
        .rb-btn-ghost:hover { background: var(--surface-2); color: var(--foreground); }
        .rb-preview { background: var(--surface-2); border: 1px dashed var(--border); border-radius: 10px; padding: 16px; font-size: 13px; color: var(--foreground); line-height: 1.7; }
        .rb-preview h4 { font-weight: 700; color: var(--brand-deep); margin-bottom: 6px; font-size: 14px; }
        .rb-preview-section { margin-bottom: 14px; }
      `}</style>

      {/* Header */}
      <div className="flex items-center gap-3 mb-1">
        <Link href="/dashboard/teacher/rpp" className="rb-btn rb-btn-ghost" style={{ height: 36, padding: "0 12px" }}>
          <ChevronLeft className="w-4 h-4" /> Kembali
        </Link>
      </div>
      <h1 className="rb-title flex items-center gap-2 mt-2"><BookOpen className="w-5 h-5 text-brand" /> Builder Modul Ajar / RPP</h1>
      <p className="rb-desc mb-6">Susun perangkat pembelajaran terstruktur sesuai kurikulum Merdeka. Tersimpan ke bank modul akademik.</p>

      {/* Stepper */}
      <div className="rb-stepper mb-6">
        {STEPS.map((s, i) => (
          <React.Fragment key={s.key}>
            <div className="rb-step">
              <div className={`rb-step-dot ${i < step ? "done" : i === step ? "active" : "todo"}`}>
                {i < step ? <CheckCircle2 className="w-4 h-4" /> : <s.icon className="w-4 h-4" />}
              </div>
              <span className={`rb-step-label ${i === step ? "active" : ""}`}>{s.label}</span>
            </div>
            {i < STEPS.length - 1 && <div className="rb-step-line" />}
          </React.Fragment>
        ))}
      </div>

      {error && (
        <div className="flex items-center gap-2 p-3 mb-4 text-sm text-destructive bg-destructive/10 rounded-xl border border-destructive/20">
          <AlertCircle className="w-4 h-4 shrink-0" /> {error}
        </div>
      )}
      {success && (
        <div className="flex items-center gap-2 p-3 mb-4 text-sm text-emerald-600 bg-emerald-50 dark:bg-emerald-950/30 dark:text-emerald-400 rounded-xl border border-emerald-200 dark:border-emerald-900/40">
          <CheckCircle2 className="w-4 h-4 shrink-0" /> Modul ajar berhasil disimpan! Mengalihkan ke daftar RPP...
        </div>
      )}

      {/* Step content */}
      <div className="rb-card mb-5">
        {step === 0 && (
          <div className="space-y-4">
            <div>
              <label className="rb-label">Judul Modul Ajar *</label>
              <input className="rb-input" placeholder="cth: Pemrograman Web - Frontend Dasar" value={form.title} onChange={(e) => update("title", e.target.value)} />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="rb-label">Mata Pelajaran *</label>
                <input className="rb-input" placeholder="cth: Pemrograman Web" value={form.subject} onChange={(e) => update("subject", e.target.value)} />
              </div>
              <div>
                <label className="rb-label">Kelas / Fase</label>
                <input className="rb-input" placeholder="cth: XII RPL / Fase F" value={form.class_level} onChange={(e) => update("class_level", e.target.value)} />
              </div>
            </div>
            <div>
              <label className="rb-label">Alokasi Waktu (menit)</label>
              <input type="number" className="rb-input" value={form.duration} onChange={(e) => update("duration", e.target.value)} />
            </div>
          </div>
        )}

        {step === 1 && (
          <div>
            <label className="rb-label">Capaian & Tujuan Pembelajaran</label>
            <textarea className="rb-input rb-textarea" placeholder="Tuliskan tujuan pembelajaran yang ingin dicapai siswa setelah mengikuti pembelajaran ini..." value={form.objectives} onChange={(e) => update("objectives", e.target.value)} />
            <p className="text-[11px] text-muted-foreground mt-2">Pisahkan setiap tujuan dengan baris baru atau penomoran.</p>
          </div>
        )}

        {step === 2 && (
          <div>
            <label className="rb-label">Kegiatan Pembelajaran</label>
            <textarea className="rb-input rb-textarea" placeholder="Deskripsikan kegiatan: pendahuluan, inti, dan penutup. Sertakan metode (diskusi, praktik, demonstrasi, dll)..." value={form.activities} onChange={(e) => update("activities", e.target.value)} />
          </div>
        )}

        {step === 3 && (
          <div>
            <label className="rb-label">Asesmen / Penilaian</label>
            <textarea className="rb-input rb-textarea" placeholder="Bentuk asesmen: formatif/sumatif, rubrik penilaian, kriteria ketuntasan..." value={form.assessment} onChange={(e) => update("assessment", e.target.value)} />
            <div className="mt-4">
              <label className="rb-label">Refleksi Guru (opsional)</label>
              <textarea className="rb-input rb-textarea" placeholder="Catatan refleksi untuk perbaikan pembelajaran berikutnya..." value={form.reflection} onChange={(e) => update("reflection", e.target.value)} />
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="rb-preview">
            <div className="rb-preview-section">
              <h4>{form.title || "Judul Modul"}</h4>
              <div className="text-muted-foreground text-[12px]">{form.subject}{form.class_level ? ` · ${form.class_level}` : ""}{form.duration ? ` · ${form.duration} menit` : ""}</div>
            </div>
            {form.objectives && <div className="rb-preview-section"><strong>Tujuan:</strong> <br />{form.objectives}</div>}
            {form.activities && <div className="rb-preview-section"><strong>Kegiatan:</strong> <br />{form.activities}</div>}
            {form.assessment && <div className="rb-preview-section"><strong>Asesmen:</strong> <br />{form.assessment}</div>}
            {form.reflection && <div className="rb-preview-section"><strong>Refleksi:</strong> <br />{form.reflection}</div>}
          </div>
        )}
      </div>

      {/* Footer nav */}
      <div className="flex items-center justify-between">
        <button className="rb-btn rb-btn-ghost" disabled={step === 0 || saving} onClick={() => setStep((s) => Math.max(0, s - 1))}>
          <ChevronLeft className="w-4 h-4" /> Sebelumnya
        </button>
        {step < STEPS.length - 1 ? (
          <button className="rb-btn rb-btn-primary" disabled={!canNext()} onClick={() => setStep((s) => Math.min(STEPS.length - 1, s + 1))}>
            Selanjutnya <ChevronRight className="w-4 h-4" />
          </button>
        ) : (
          <button className="rb-btn rb-btn-primary" disabled={saving || success} onClick={submit}>
            {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
            Simpan Modul Ajar
          </button>
        )}
      </div>
    </div>
  )
}

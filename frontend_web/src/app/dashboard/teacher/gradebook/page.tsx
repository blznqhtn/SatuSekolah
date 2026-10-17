"use client"

import React, { useEffect, useState, useMemo } from "react"
import { fetchApi, api } from "@/lib/api"
import {
  Table2, Save, Download, Loader2, AlertCircle, CheckCircle2,
  GraduationCap, BookOpen, Search,
} from "lucide-react"

interface Course {
  id: string
  name?: string
  course_name?: string
  subject?: string
  [key: string]: any
}

interface Submission {
  id: string
  student_id?: string
  student_name?: string
  student?: { name?: string; id?: string }
  course_id?: string
  course_name?: string
  title?: string
  assignment_title?: string
  grade?: number | null
  max_grade?: number
  status?: string
  submitted_at?: string
  [key: string]: any
}

export default function GradebookPage() {
  const [courses, setCourses] = useState<Course[]>([])
  const [selectedCourse, setSelectedCourse] = useState<string>("")
  const [submissions, setSubmissions] = useState<Submission[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState<string | null>(null)
  const [search, setSearch] = useState("")
  const [error, setError] = useState<string | null>(null)
  const [drafts, setDrafts] = useState<Record<string, number | "">>({})

  useEffect(() => {
    fetchApi("/academic/courses")
      .then((res) => {
        const raw = res?.data ?? res
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        setCourses(items)
        if (items.length > 0 && !selectedCourse) setSelectedCourse(items[0].id)
      })
      .catch(() => setCourses([]))
  }, [])

  useEffect(() => {
    if (!selectedCourse) {
      setSubmissions([])
      setLoading(false)
      return
    }
    setLoading(true)
    setError(null)
    fetchApi("/academic/submissions")
      .then((res) => {
        const raw = res?.data ?? res
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        const filtered = items.filter(
          (s: Submission) => s.course_id === selectedCourse || s.courseId === selectedCourse
        )
        setSubmissions(filtered.length ? filtered : items)
      })
      .catch((e) => setError(e.message || "Gagal memuat submissions."))
      .finally(() => setLoading(false))
  }, [selectedCourse])

  const studentName = (s: Submission) => s.student_name || s.student?.name || s.title || "Siswa"
  const assignmentTitle = (s: Submission) => s.assignment_title || s.title || s.course_name || "Tugas"

  const filtered = useMemo(() => {
    if (!search) return submissions
    const q = search.toLowerCase()
    return submissions.filter((s) => studentName(s).toLowerCase().includes(q))
  }, [submissions, search])

  const handleGradeChange = (id: string, value: string) => {
    setDrafts((prev) => ({ ...prev, [id]: value === "" ? "" : Number(value) }))
  }

  const saveGrade = async (sub: Submission) => {
    const draft = drafts[sub.id]
    if (draft === undefined || draft === "") return
    setSaving(sub.id)
    try {
      await api.post(`/academic/submissions/${sub.id}/grade`, {
        grade: draft,
        max_grade: sub.max_grade || 100,
      })
      setSubmissions((prev) =>
        prev.map((s) => (s.id === sub.id ? { ...s, grade: draft as number } : s))
      )
      setDrafts((prev) => {
        const next = { ...prev }
        delete next[sub.id]
        return next
      })
    } catch (e: any) {
      setError(e.message || "Gagal menyimpan nilai.")
    } finally {
      setSaving(null)
    }
  }

  const exportCsv = () => {
    const rows = [
      ["Siswa", "Tugas", "Nilai", "Max", "Status"],
      ...filtered.map((s) => [
        studentName(s),
        assignmentTitle(s),
        s.grade ?? "",
        s.max_grade || 100,
        s.status || "",
      ]),
    ]
    const csv = rows.map((r) => r.map((c) => `"${c}"`).join(",")).join("\n")
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `gradebook-${selectedCourse || "all"}.csv`
    a.click()
    URL.revokeObjectURL(url)
  }

  return (
    <div className="max-w-[1280px] mx-auto w-full px-4 md:px-7 py-6 animate-fade-up">
      <style>{`
        .gb-title { font-size: 20px; font-weight: 700; color: var(--foreground); letter-spacing: -0.4px; }
        .gb-desc { font-size: 13px; color: var(--muted-foreground); margin-top: 2px; }
        .gb-card { background: var(--surface); border: 1px solid var(--border); border-radius: 14px; overflow: hidden; }
        .gb-select {
          height: 38px; padding: 0 12px; border-radius: 10px; border: 1px solid var(--border);
          background: var(--surface); color: var(--foreground); font-size: 13px; font-weight: 500;
          outline: none; cursor: pointer; font-family: inherit; transition: border-color 0.15s;
        }
        .gb-select:focus { border-color: var(--brand); }
        .gb-btn {
          display: inline-flex; align-items: center; gap: 7px; height: 38px; padding: 0 14px;
          border-radius: 10px; border: 1px solid var(--border); background: var(--surface);
          color: var(--foreground); font-size: 13px; font-weight: 600; cursor: pointer;
          transition: all 0.12s; font-family: inherit;
        }
        .gb-btn:hover { background: var(--surface-2); border-color: rgba(var(--brand-rgb),0.3); color: var(--brand); }
        .gb-search {
          height: 38px; border-radius: 10px; border: 1px solid var(--border); background: var(--surface);
          padding: 0 12px 0 34px; font-size: 13px; color: var(--foreground); outline: none;
          transition: border-color 0.15s; font-family: inherit;
        }
        .gb-search:focus { border-color: var(--brand); }
        .gb-grade-input {
          width: 70px; height: 34px; border-radius: 8px; border: 1px solid var(--border);
          background: var(--surface); color: var(--foreground); text-align: center; font-size: 13px;
          font-weight: 600; outline: none; transition: border-color 0.15s; font-family: inherit;
        }
        .gb-grade-input:focus { border-color: var(--brand); box-shadow: 0 0 0 3px rgba(var(--brand-rgb),0.1); }
        .gb-save-btn {
          height: 32px; padding: 0 10px; border-radius: 7px; border: none; background: var(--brand);
          color: #fff; font-size: 12px; font-weight: 600; cursor: pointer; transition: background 0.12s; font-family: inherit;
        }
        .gb-save-btn:hover { background: var(--brand-deep); }
        .gb-save-btn:disabled { opacity: 0.5; cursor: not-allowed; }
      `}</style>

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3 mb-5">
        <div>
          <h1 className="gb-title flex items-center gap-2"><Table2 className="w-5 h-5 text-brand" /> Buku Nilai (Gradebook)</h1>
          <p className="gb-desc">Input dan rekap nilai submission siswa per mata pelajaran. Perubahan tersimpan langsung ke server.</p>
        </div>
        <button className="gb-btn" onClick={exportCsv}>
          <Download className="w-4 h-4" /> Ekspor CSV
        </button>
      </div>

      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row gap-3 mb-4">
        <div className="flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-muted-foreground" />
          <select className="gb-select" value={selectedCourse} onChange={(e) => setSelectedCourse(e.target.value)}>
            <option value="">Semua Mata Pelajaran</option>
            {courses.map((c) => (
              <option key={c.id} value={c.id}>{c.name || c.course_name || c.subject || "Mata Pelajaran"}</option>
            ))}
          </select>
        </div>
        <div className="relative flex-1 max-w-xs">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <input className="gb-search w-full" placeholder="Cari siswa..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 p-3 mb-4 text-sm text-destructive bg-destructive/10 rounded-xl border border-destructive/20">
          <AlertCircle className="w-4 h-4 shrink-0" /> {error}
        </div>
      )}

      {/* Table */}
      <div className="gb-card">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-muted/50">
                <th className="text-left px-4 py-3 text-[11px] font-bold text-muted-foreground uppercase tracking-wider">Siswa</th>
                <th className="text-left px-4 py-3 text-[11px] font-bold text-muted-foreground uppercase tracking-wider">Tugas / Asesmen</th>
                <th className="text-center px-4 py-3 text-[11px] font-bold text-muted-foreground uppercase tracking-wider">Nilai Saat Ini</th>
                <th className="text-center px-4 py-3 text-[11px] font-bold text-muted-foreground uppercase tracking-wider">Input Baru</th>
                <th className="text-right px-4 py-3 text-[11px] font-bold text-muted-foreground uppercase tracking-wider">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={5} className="text-center py-12 text-muted-foreground"><Loader2 className="w-5 h-5 animate-spin inline mr-2" /> Memuat data submissions...</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan={5} className="text-center py-12 text-muted-foreground">
                  <GraduationCap className="w-8 h-8 mx-auto mb-2 opacity-40" />
                  Belum ada submission. Pilih mata pelajaran lain atau tunggu siswa mengumpulkan tugas.
                </td></tr>
              ) : (
                filtered.map((s) => {
                  const hasDraft = drafts[s.id] !== undefined && drafts[s.id] !== ""
                  return (
                    <tr key={s.id} className="border-b border-border last:border-0 hover:bg-brand/[0.03] transition-colors">
                      <td className="px-4 py-3">
                        <div className="font-semibold text-foreground">{studentName(s)}</div>
                        {s.student_id && <div className="text-[11px] text-muted-foreground">ID: {s.student_id}</div>}
                      </td>
                      <td className="px-4 py-3 text-muted-foreground">{assignmentTitle(s)}</td>
                      <td className="px-4 py-3 text-center">
                        {s.grade !== null && s.grade !== undefined ? (
                          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-brand/10 text-brand text-xs font-bold">
                            <CheckCircle2 className="w-3 h-3" /> {s.grade}
                          </span>
                        ) : (
                          <span className="text-[11px] font-semibold text-amber-600 bg-amber-50 dark:bg-amber-950/30 dark:text-amber-400 px-2 py-0.5 rounded-full">Belum dinilai</span>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center justify-center gap-1">
                          <input
                            type="number"
                            className="gb-grade-input"
                            placeholder="—"
                            value={drafts[s.id] ?? ""}
                            onChange={(e) => handleGradeChange(s.id, e.target.value)}
                            max={s.max_grade || 100}
                          />
                          <span className="text-[11px] text-muted-foreground">/{s.max_grade || 100}</span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-right">
                        <button className="gb-save-btn" disabled={!hasDraft || saving === s.id} onClick={() => saveGrade(s)}>
                          {saving === s.id ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Save className="w-3.5 h-3.5" />}
                          Simpan
                        </button>
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

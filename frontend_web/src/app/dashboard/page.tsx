"use client"

import React, { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import {
  Users, AlertCircle, Activity, ArrowUpRight, MessageSquare,
  CalendarDays, Clock, BookOpen, ClipboardList, Bell, TrendingUp, Loader2,
} from "lucide-react"
import { useAuth } from "@/lib/auth-context"
import { Button } from "@/components/ui/button"
import { fetchApi } from "@/lib/api"
import Link from "next/link"

interface ActivityLog {
  id: string
  type?: string
  title?: string
  subtitle?: string
  time_label?: string
  emoji?: string
  badge_color?: string
  badge_label?: string
  created_at?: string
}

interface Submission {
  id: string
  student_name?: string
  title?: string
  course_name?: string
  status?: string
  grade?: number | null
  submitted_at?: string
}

interface NotifItem {
  id: string
  title?: string
  message?: string
  read?: boolean
  created_at?: string
}

export default function DashboardPage() {
  const { user } = useAuth()
  const isAdmin = user?.category?.toLowerCase() === "admin"
  const firstName = user?.name?.split(" ")[0]?.split(",")[0] || "Guru"

  const [activities, setActivities] = useState<ActivityLog[]>([])
  const [submissions, setSubmissions] = useState<Submission[]>([])
  const [notifs, setNotifs] = useState<NotifItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let active = true
    setLoading(true)

    const fetchAll = async () => {
      const [actRes, subRes, notifRes] = await Promise.allSettled([
        fetchApi("/dashboard/activities").catch(() => null),
        fetchApi("/academic/submissions").catch(() => null),
        fetchApi("/notifications").catch(() => null),
      ])

      if (!active) return

      if (actRes.status === "fulfilled" && actRes.value) {
        const raw = actRes.value?.data ?? actRes.value
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        setActivities(items.slice(0, 6))
      }
      if (subRes.status === "fulfilled" && subRes.value) {
        const raw = subRes.value?.data ?? subRes.value
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        // Ungraded = no grade yet
        const ungraded = items.filter((s: Submission) => s.grade === null || s.grade === undefined || s.status === "SUBMITTED")
        setSubmissions(ungraded.slice(0, 5))
      }
      if (notifRes.status === "fulfilled" && notifRes.value) {
        const raw = notifRes.value?.data ?? notifRes.value
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        setNotifs(items.slice(0, 4))
      }
      setLoading(false)
    }

    fetchAll()
    return () => { active = false }
  }, [])

  const today = new Date().toLocaleDateString("id-ID", {
    weekday: "long", day: "numeric", month: "long", year: "numeric",
  })

  /* Stat cards differ by role */
  const teacherStats = [
    { title: "Tugas Belum Dinilai", value: submissions.length, description: "Submissions menunggu feedback", icon: ClipboardList, trend: "Perlu tindakan" },
    { title: "Notifikasi Baru", value: notifs.filter((n) => !n.read).length, description: "Pesan & pengumuman", icon: Bell, trend: "Hari ini" },
    { title: "Aktivitas Terbaru", value: activities.length, description: "Log sistem Anda", icon: Activity, trend: "Live" },
  ]
  const adminStats = [
    { title: "Tugas Belum Dinilai", value: submissions.length, description: "Total submissions pending", icon: ClipboardList, trend: "Lintas guru" },
    { title: "Notifikasi", value: notifs.filter((n) => !n.read).length, description: "Belum dibaca", icon: Bell, trend: "Hari ini" },
    { title: "Aktivitas Sistem", value: activities.length, description: "Event terkini", icon: Activity, trend: "Live" },
  ]
  const stats = isAdmin ? adminStats : teacherStats

  return (
    <div className="space-y-6 animate-fade-up">
      <style>{`
        .dash-stat-card {
          position: relative; background: var(--surface); border: 1px solid var(--border);
          border-radius: 16px; padding: 20px; overflow: hidden;
          transition: transform 0.2s, box-shadow 0.2s;
        }
        .dash-stat-card:hover { transform: translateY(-3px); box-shadow: 0 12px 28px rgba(var(--brand-rgb), 0.12); }
        .dash-stat-bar { position: absolute; top: 0; left: 0; right: 0; height: 3px; background: linear-gradient(90deg, var(--brand), var(--brand-accent)); }
        .dash-stat-icon {
          width: 38px; height: 38px; border-radius: 11px;
          background: var(--brand-soft); color: var(--brand);
          display: flex; align-items: center; justify-content: center;
        }
        .dash-stat-value { font-size: 28px; font-weight: 800; color: var(--foreground); letter-spacing: -0.5px; }
        .dash-stat-title { font-size: 11px; font-weight: 700; color: var(--muted-foreground); text-transform: uppercase; letter-spacing: 0.8px; }
        .dash-stat-desc { font-size: 12px; color: var(--muted-foreground); margin-top: 2px; }
        .dash-stat-trend { font-size: 11px; font-weight: 600; color: var(--brand); margin-top: 10px; display: inline-flex; align-items: center; gap: 4px; }

        .dash-panel { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; }
        .dash-act-item { display: flex; gap: 14px; padding: 14px; border-radius: 12px; transition: background 0.12s; border: 1px solid transparent; }
        .dash-act-item:hover { background: var(--surface-2); border-color: var(--border); }
        .dash-act-emoji { width: 40px; height: 40px; border-radius: 11px; background: var(--brand-soft); display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
        .dash-badge { padding: 2px 8px; border-radius: 999px; background: var(--brand-soft); color: var(--brand); font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }

        .dash-side-card {
          background: linear-gradient(160deg, var(--brand) 0%, var(--brand-deep) 100%);
          color: #fff; border-radius: 16px; padding: 22px; position: relative; overflow: hidden;
        }
        .dash-side-glow1 { position: absolute; right: -30px; top: -30px; width: 120px; height: 120px; background: rgba(255,255,255,0.1); border-radius: 50%; filter: blur(40px); }
        .dash-side-glow2 { position: absolute; left: -30px; bottom: -30px; width: 120px; height: 120px; background: rgba(59,130,246,0.3); border-radius: 50%; filter: blur(40px); }
        .dash-side-event { background: rgba(255,255,255,0.1); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.12); border-radius: 12px; padding: 14px; }

        .dash-sub-row { display: flex; align-items: center; justify-content: space-between; padding: 11px 14px; border-radius: 10px; transition: background 0.12s; }
        .dash-sub-row:hover { background: var(--surface-2); }
      `}</style>

      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-foreground">Halo, {firstName} 👋</h1>
        <p className="text-muted-foreground mt-1 text-sm">
          {isAdmin ? "Ringkasan operasional sekolah" : "Berikut ringkasan aktivitas mengajar Anda"} · {today}.
        </p>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {stats.map((stat, i) => (
          <div key={i} className="dash-stat-card" style={{ animation: `ssFadeUp 0.4s ease ${i * 0.06}s both` }}>
            <div className="dash-stat-bar" />
            <div className="flex items-start justify-between mb-3">
              <div>
                <div className="dash-stat-title">{stat.title}</div>
                <div className="dash-stat-desc">{stat.description}</div>
              </div>
              <div className="dash-stat-icon">
                <stat.icon className="w-5 h-5" />
              </div>
            </div>
            <div className="dash-stat-value">{loading ? "—" : stat.value}</div>
            <div className="dash-stat-trend">
              <TrendingUp className="w-3 h-3" />
              {stat.trend}
            </div>
          </div>
        ))}
      </div>

      {/* Main grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Activities / Announcements */}
        <Card className="lg:col-span-2 border-border bg-card">
          <CardHeader className="flex flex-row items-center justify-between space-y-0">
            <div>
              <CardTitle className="text-base">Aktivitas & Pengumuman Terbaru</CardTitle>
              <CardDescription>Informasi terkini dari sistem sekolah</CardDescription>
            </div>
            <Button variant="outline" size="sm" className="text-xs">Lihat Semua</Button>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="flex items-center justify-center py-10 text-muted-foreground">
                <Loader2 className="w-5 h-5 animate-spin mr-2" /> Memuat aktivitas...
              </div>
            ) : activities.length === 0 ? (
              <div className="text-center py-10 text-muted-foreground text-sm">
                <MessageSquare className="w-8 h-8 mx-auto mb-2 opacity-40" />
                Belum ada aktivitas terbaru.
              </div>
            ) : (
              <div className="space-y-2">
                {activities.map((item) => (
                  <div key={item.id} className="dash-act-item">
                    <div className="dash-act-emoji">{item.emoji || "📌"}</div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1 flex-wrap">
                        {item.badge_label && <span className="dash-badge">{item.badge_label}</span>}
                        {item.time_label && (
                          <span className="text-[10px] text-muted-foreground flex items-center gap-1">
                            <Clock className="w-3 h-3" /> {item.time_label}
                          </span>
                        )}
                      </div>
                      <h4 className="text-sm font-semibold text-foreground line-clamp-1">{item.title}</h4>
                      {item.subtitle && <p className="text-xs text-muted-foreground mt-0.5 line-clamp-1">{item.subtitle}</p>}
                    </div>
                    <Button variant="ghost" size="icon" className="shrink-0 text-muted-foreground">
                      <ArrowUpRight className="w-4 h-4" />
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Side: today schedule / quick actions (teacher) or notifications (admin) */}
        <div className="space-y-5">
          <div className="dash-side-card">
            <div className="dash-side-glow1" />
            <div className="dash-side-glow2" />
            <div className="relative z-10">
              <div className="flex items-center gap-2 mb-1">
                <CalendarDays className="w-4 h-4" />
                <h3 className="font-semibold">Agenda Hari Ini</h3>
              </div>
              <p className="text-xs text-white/70 mb-4">Jadwal mengajar & rapat</p>
              <div className="space-y-3">
                <div className="dash-side-event">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-[11px] font-bold uppercase tracking-widest text-white/80">Kelas Berikutnya</span>
                  </div>
                  <h4 className="font-semibold text-sm">Buka modul mengajar</h4>
                  <p className="text-[11px] text-white/70 mt-0.5">Lihat jadwal & RPP aktif</p>
                </div>
                <Link href="/dashboard/teacher/rpp" className="block">
                  <button className="w-full bg-white text-brand-deep hover:bg-white/90 font-semibold text-sm rounded-xl py-2.5 transition-colors flex items-center justify-center gap-2">
                    <BookOpen className="w-4 h-4" />
                    Buka Perangkat Ajar
                  </button>
                </Link>
              </div>
            </div>
          </div>

          {/* Ungraded submissions quick list */}
          <Card className="border-border bg-card">
            <CardHeader className="space-y-0 pb-3">
              <div className="flex items-center justify-between">
                <CardTitle className="text-sm">Tugas Belum Dinilai</CardTitle>
                <Link href="/dashboard/teacher/gradebook" className="text-[11px] font-semibold text-brand hover:underline">Buka Gradebook</Link>
              </div>
            </CardHeader>
            <CardContent className="pt-0">
              {loading ? (
                <div className="text-xs text-muted-foreground py-4 text-center">Memuat...</div>
              ) : submissions.length === 0 ? (
                <div className="text-xs text-muted-foreground py-4 text-center">Tidak ada tugas pending. 🎉</div>
              ) : (
                <div className="space-y-1">
                  {submissions.map((s) => (
                    <div key={s.id} className="dash-sub-row">
                      <div className="min-w-0">
                        <div className="text-sm font-medium text-foreground truncate">{s.student_name || s.title || "Submission"}</div>
                        <div className="text-[11px] text-muted-foreground truncate">{s.course_name || "Mata Pelajaran"}</div>
                      </div>
                      <span className="text-[10px] font-semibold text-amber-600 bg-amber-50 dark:bg-amber-950/30 dark:text-amber-400 px-2 py-0.5 rounded-full whitespace-nowrap">Pending</span>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { 
  Users, 
  CheckCircle2, 
  AlertCircle, 
  ArrowUpRight, 
  MessageSquare, 
  Activity,
  CalendarDays,
  Clock
} from "lucide-react"
import { useAuth } from "@/lib/auth-context"
import { Button } from "@/components/ui/button"

export default function DashboardPage() {
  const { user } = useAuth()
  const stats = [
    {
      title: "Siswa Hadir",
      value: "942",
      description: "Dari total 980 siswa hari ini",
      icon: Users,
      color: "brand-green",
      trend: "+2% dari kemarin"
    },
    {
      title: "Izin/Sakit",
      value: "38",
      description: "24 Izin, 14 Sakit",
      icon: AlertCircle,
      color: "brand-blue",
      trend: "-5% dari kemarin"
    },
    {
      title: "Status Kesehatan",
      value: "Baik",
      description: "Monitoring harian UKS",
      icon: Activity,
      color: "brand-purple",
      trend: "Normal"
    }
  ]

  const announcements = [
    {
      title: "Rapat Persiapan Ujian Akhir",
      time: "2 jam yang lalu",
      category: "Akademik",
      author: "Admin Kurikulum"
    },
    {
      title: "Update Inventaris Lab Komputer",
      time: "Kemarin, 14:00",
      category: "Manajemen",
      author: "Sarpras"
    },
    {
      title: "Pengisian Nilai Rapor Semester Ganjil",
      time: "3 hari yang lalu",
      category: "Wali Kelas",
      author: "Sistem"
    }
  ]

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div>
        <h1 className="text-2xl font-bold text-slate-800">Halo, {user?.name.split(',')[0] || "User"} 👋</h1>
        <p className="text-muted-foreground mt-1">Berikut adalah ringkasan sekolah hari ini, 10 Mei 2026.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {stats.map((stat, i) => (
          <Card key={i} className="border-none shadow-md hover:shadow-lg transition-shadow bg-white overflow-hidden group">
            <div className={`h-1 w-full bg-${stat.color}`}></div>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-bold text-muted-foreground uppercase tracking-wider">
                {stat.title}
              </CardTitle>
              <div className={`p-2 rounded-lg bg-${stat.color}/10 group-hover:bg-${stat.color} transition-colors`}>
                <stat.icon className={`h-4 w-4 text-${stat.color} group-hover:text-white transition-colors`} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-slate-800">{stat.value}</div>
              <p className="text-xs text-muted-foreground mt-1">
                {stat.description}
              </p>
              <div className="mt-4 flex items-center text-[10px] font-bold">
                <span className={stat.trend.includes('+') ? 'text-brand-green' : 'text-brand-blue'}>
                  {stat.trend}
                </span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <Card className="lg:col-span-2 border-none shadow-md bg-white">
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle className="text-lg">Pengumuman Terbaru</CardTitle>
              <CardDescription>Informasi terkini untuk guru dan staf</CardDescription>
            </div>
            <Button variant="outline" size="sm" className="text-xs">Lihat Semua</Button>
          </CardHeader>
          <CardContent>
            <div className="space-y-6">
              {announcements.map((item, i) => (
                <div key={i} className="flex gap-4 p-4 rounded-2xl hover:bg-slate-50 transition-colors border border-transparent hover:border-brand-blue/5">
                  <div className="w-12 h-12 shrink-0 rounded-xl bg-slate-100 flex items-center justify-center">
                    <MessageSquare className="w-5 h-5 text-slate-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="px-2 py-0.5 rounded-full bg-brand-blue/10 text-brand-blue text-[10px] font-bold uppercase tracking-wider">
                        {item.category}
                      </span>
                      <span className="text-[10px] text-muted-foreground flex items-center gap-1">
                        <Clock className="w-3 h-3" /> {item.time}
                      </span>
                    </div>
                    <h4 className="text-sm font-bold text-slate-800 line-clamp-1">{item.title}</h4>
                    <p className="text-xs text-muted-foreground mt-1">Diposting oleh <span className="font-medium text-slate-600">{item.author}</span></p>
                  </div>
                  <Button variant="ghost" size="icon" className="shrink-0 text-slate-400">
                    <ArrowUpRight className="w-4 h-4" />
                  </Button>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card className="border-none shadow-md bg-brand-purple text-white relative overflow-hidden">
          <div className="absolute -right-8 -top-8 w-32 h-32 bg-white/10 rounded-full blur-3xl"></div>
          <div className="absolute -left-8 -bottom-8 w-32 h-32 bg-brand-blue/20 rounded-full blur-3xl"></div>
          
          <CardHeader>
            <CardTitle className="text-lg">Kalender Hari Ini</CardTitle>
            <CardDescription className="text-purple-100">Jadwal mengajar & agenda</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/10">
              <div className="flex items-center justify-between mb-3">
                <span className="text-xs font-bold uppercase tracking-widest text-purple-100">08:00 - 09:30</span>
                <span className="px-2 py-0.5 rounded-md bg-white/20 text-[10px] font-medium">Kelas</span>
              </div>
              <h4 className="font-bold">Pemrograman Web</h4>
              <p className="text-xs text-purple-100 mt-1">XII RPL 1 - Lab Komputer 2</p>
            </div>
            
            <div className="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/10 opacity-70">
              <div className="flex items-center justify-between mb-3">
                <span className="text-xs font-bold uppercase tracking-widest text-purple-100">10:00 - 11:30</span>
                <span className="px-2 py-0.5 rounded-md bg-white/20 text-[10px] font-medium">Rapat</span>
              </div>
              <h4 className="font-bold">Briefing Kurikulum</h4>
              <p className="text-xs text-purple-100 mt-1">Ruang Guru Utama</p>
            </div>

            <Button className="w-full bg-white text-brand-purple hover:bg-slate-50 font-bold mt-2">
              <CalendarDays className="mr-2 h-4 w-4" />
              Buka Kalender
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { 
  Calendar, 
  ChevronLeft, 
  ChevronRight, 
  Plus, 
  MapPin, 
  Clock,
  Search
} from "lucide-react"

export default function KalenderPage() {
  const events = [
    { title: "Ujian Tengah Semester", date: "15 Mei 2026", type: "Akademik", color: "brand-blue" },
    { title: "Rapat Pleno Kelulusan", date: "20 Mei 2026", type: "Manajemen", color: "brand-purple" },
    { title: "Libur Kenaikan Kelas", date: "1 Juni 2026", type: "Libur", color: "brand-green" },
  ]

  const days = Array.from({ length: 31 }, (_, i) => i + 1)

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Kalender Akademik</h1>
          <p className="text-muted-foreground mt-1">Pantau agenda dan jadwal penting sekolah</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <Plus className="w-4 h-4 mr-2" />
          Tambah Agenda
        </Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <Card className="lg:col-span-3 border-none shadow-md overflow-hidden">
          <CardHeader className="flex flex-row items-center justify-between border-b border-slate-50">
            <div className="flex items-center gap-4">
              <h3 className="text-lg font-bold">Mei 2026</h3>
              <div className="flex items-center gap-1">
                <Button variant="outline" size="icon" className="h-8 w-8">
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <Button variant="outline" size="icon" className="h-8 w-8">
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
            <div className="flex items-center bg-slate-50 rounded-lg p-1">
              <Button variant="ghost" size="sm" className="text-xs bg-white shadow-sm">Bulan</Button>
              <Button variant="ghost" size="sm" className="text-xs">Minggu</Button>
              <Button variant="ghost" size="sm" className="text-xs">Hari</Button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="grid grid-cols-7 border-b border-slate-100">
              {["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"].map((day) => (
                <div key={day} className="py-3 text-center text-xs font-bold text-muted-foreground uppercase">
                  {day}
                </div>
              ))}
            </div>
            <div className="grid grid-cols-7 h-[500px]">
              {days.map((day) => (
                <div key={day} className="border-r border-b border-slate-50 p-2 hover:bg-slate-50/50 transition-colors group cursor-pointer relative">
                  <span className={`text-sm font-medium ${day === 10 ? 'bg-brand-blue text-white w-6 h-6 flex items-center justify-center rounded-full' : 'text-slate-600'}`}>
                    {day}
                  </span>
                  {day === 15 && (
                    <div className="mt-1 p-1 bg-brand-blue/10 border-l-2 border-brand-blue rounded text-[9px] font-bold text-brand-blue truncate">
                      UTS Semester
                    </div>
                  )}
                  {day === 20 && (
                    <div className="mt-1 p-1 bg-brand-purple/10 border-l-2 border-brand-purple rounded text-[9px] font-bold text-brand-purple truncate">
                      Rapat Pleno
                    </div>
                  )}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <div className="space-y-6">
          <Card className="border-none shadow-md">
            <CardHeader>
              <CardTitle className="text-sm font-bold uppercase tracking-wider text-muted-foreground">Agenda Mendatang</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {events.map((event, i) => (
                <div key={i} className="flex gap-4 group cursor-pointer">
                  <div className={`w-1 h-12 rounded-full bg-${event.color}`}></div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800 group-hover:text-brand-blue transition-colors">{event.title}</h4>
                    <p className="text-[10px] text-muted-foreground mt-1 flex items-center gap-1">
                      <Clock className="w-3 h-3" /> {event.date}
                    </p>
                  </div>
                </div>
              ))}
              <Button variant="ghost" className="w-full text-xs text-brand-blue font-bold mt-2">
                Lihat Semua Agenda
              </Button>
            </CardContent>
          </Card>

          <Card className="border-none shadow-md bg-brand-blue text-white overflow-hidden relative">
            <div className="absolute -right-4 -bottom-4 w-24 h-24 bg-white/10 rounded-full blur-2xl"></div>
            <CardContent className="p-6 relative">
              <Calendar className="w-8 h-8 mb-4 opacity-50" />
              <h4 className="font-bold mb-1">Cetak Kalender</h4>
              <p className="text-xs text-white/70 mb-4">Unduh kalender akademik format PDF untuk dibagikan.</p>
              <Button className="w-full bg-white text-brand-blue hover:bg-slate-50 font-bold">Unduh PDF</Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

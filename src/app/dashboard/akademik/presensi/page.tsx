"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { 
  ClipboardCheck, 
  Search, 
  Filter, 
  Download, 
  UserCheck, 
  UserX, 
  Clock,
  MoreVertical
} from "lucide-react"

export default function PresensiPage() {
  const students = [
    { id: "1", name: "Achmad Fauzi", status: "Hadir", time: "07:15", class: "XII RPL 1" },
    { id: "2", name: "Bunga Citra", status: "Izin", time: "-", class: "XII RPL 1" },
    { id: "3", name: "Dedi Kurniawan", status: "Hadir", time: "07:20", class: "XII RPL 1" },
    { id: "4", name: "Eka Putri", status: "Sakit", time: "-", class: "XII RPL 1" },
    { id: "5", name: "Fajar Ramadhan", status: "Hadir", time: "07:10", class: "XII RPL 1" },
  ]

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Rekap Presensi Siswa</h1>
          <p className="text-muted-foreground mt-1">Kelola dan pantau kehadiran siswa harian</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" className="bg-white">
            <Download className="w-4 h-4 mr-2" />
            Export
          </Button>
          <Button size="sm" className="bg-brand-blue hover:bg-brand-blue/90">
            <UserCheck className="w-4 h-4 mr-2" />
            Presensi Baru
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {[
          { label: "Total Siswa", value: "36", color: "brand-blue" },
          { label: "Hadir", value: "32", color: "brand-green" },
          { label: "Izin", value: "2", color: "brand-purple" },
          { label: "Sakit", value: "2", color: "brand-blue" },
        ].map((stat, i) => (
          <Card key={i} className="border-none shadow-sm">
            <CardContent className="p-4">
              <p className="text-xs font-medium text-muted-foreground uppercase">{stat.label}</p>
              <p className={`text-2xl font-bold text-${stat.color} mt-1`}>{stat.value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card className="border-none shadow-md overflow-hidden">
        <CardHeader className="bg-white border-b border-slate-50">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <CardTitle className="text-lg font-bold">Daftar Siswa - XII RPL 1</CardTitle>
            <div className="flex items-center gap-2">
              <div className="relative w-64">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input placeholder="Cari siswa..." className="pl-9 h-9" />
              </div>
              <Button variant="outline" size="icon" className="h-9 w-9">
                <Filter className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {/* Mobile View: Card List */}
          <div className="md:hidden divide-y divide-slate-50">
            {students.map((student) => (
              <div key={student.id} className="p-4 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-brand-blue/10 flex items-center justify-center text-brand-blue font-bold">
                      {student.name.charAt(0)}
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-800">{student.name}</p>
                      <p className="text-[10px] text-muted-foreground uppercase">{student.class}</p>
                    </div>
                  </div>
                  <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400">
                    <MoreVertical className="w-4 h-4" />
                  </Button>
                </div>
                <div className="flex items-center justify-between pt-1">
                  <div className="flex items-center gap-1 text-[10px] text-muted-foreground">
                    <Clock className="w-3 h-3" />
                    Masuk: {student.time}
                  </div>
                  <span className={`px-2 py-1 rounded-full text-[10px] font-bold uppercase ${
                    student.status === "Hadir" ? "bg-brand-green/10 text-brand-green" :
                    student.status === "Izin" ? "bg-brand-purple/10 text-brand-purple" :
                    "bg-brand-blue/10 text-brand-blue"
                  }`}>
                    {student.status}
                  </span>
                </div>
              </div>
            ))}
          </div>

          {/* Desktop View: Table */}
          <div className="hidden md:block overflow-x-auto">
            <table className="w-full text-left min-w-[700px]">
              <thead className="bg-slate-50/50 border-b border-slate-50">
                <tr>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Siswa</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Kelas</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Status</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Jam Masuk</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {students.map((student) => (
                  <tr key={student.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-brand-blue/10 flex items-center justify-center text-brand-blue font-bold text-xs">
                          {student.name.charAt(0)}
                        </div>
                        <span className="text-sm font-bold text-slate-700">{student.name}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-600">{student.class}</td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 rounded-full text-[10px] font-bold uppercase ${
                        student.status === "Hadir" ? "bg-brand-green/10 text-brand-green" :
                        student.status === "Izin" ? "bg-brand-purple/10 text-brand-purple" :
                        "bg-brand-blue/10 text-brand-blue"
                      }`}>
                        {student.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-600">
                      <div className="flex items-center gap-1">
                        <Clock className="w-3 h-3 text-muted-foreground" />
                        {student.time}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400">
                        <MoreVertical className="w-4 h-4" />
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

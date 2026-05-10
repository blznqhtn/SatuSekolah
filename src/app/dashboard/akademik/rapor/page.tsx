"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { 
  FileText, 
  Search, 
  Printer, 
  ShieldCheck,
  LayoutGrid,
  List
} from "lucide-react"

export default function RaporPage() {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Rapor Digital</h1>
          <p className="text-muted-foreground mt-1">Kelola nilai dan cetak rapor semester siswa</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" className="bg-white">
            <Printer className="w-4 h-4 mr-2" />
            Cetak Massal
          </Button>
          <Button size="sm" className="bg-brand-blue hover:bg-brand-blue/90">
            <ShieldCheck className="w-4 h-4 mr-2" />
            Finalisasi Nilai
          </Button>
        </div>
      </div>

      <Card className="border-none shadow-md bg-gradient-to-r from-brand-blue to-brand-purple text-white">
        <CardContent className="p-8">
          <div className="flex flex-col md:flex-row items-center gap-8">
            <div className="w-20 h-20 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center">
              <FileText className="w-10 h-10 text-white" />
            </div>
            <div className="flex-1 text-center md:text-left">
              <h2 className="text-xl font-bold mb-2">Input Nilai Semester Ganjil</h2>
              <p className="text-white/80 text-sm max-w-md">
                Batas waktu pengisian nilai rapor tinggal 4 hari lagi. Pastikan semua kompetensi dasar telah terisi lengkap.
              </p>
            </div>
            <Button className="bg-white text-brand-blue hover:bg-slate-50 font-bold px-8">
              Mulai Input
            </Button>
          </div>
        </CardContent>
      </Card>

      <div className="flex items-center justify-between">
        <h3 className="text-lg font-bold text-slate-800">Daftar Wali Kelas</h3>
        <div className="flex bg-white rounded-lg border border-slate-200 p-1">
          <Button variant="ghost" size="icon" className="h-8 w-8 bg-slate-100">
            <LayoutGrid className="w-4 h-4" />
          </Button>
          <Button variant="ghost" size="icon" className="h-8 w-8">
            <List className="w-4 h-4" />
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {[
          { name: "Achmad Fauzi", nis: "21221001", status: "Lengkap", grade: "A" },
          { name: "Bunga Citra", nis: "21221002", status: "Proses", grade: "-" },
          { name: "Dedi Kurniawan", nis: "21221003", status: "Lengkap", grade: "B+" },
          { name: "Eka Putri", nis: "21221004", status: "Lengkap", grade: "A-" },
        ].map((student, i) => (
          <Card key={i} className="border-none shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-5">
              <div className="flex justify-between items-start mb-4">
                <div className="w-12 h-12 rounded-xl bg-slate-50 flex items-center justify-center text-slate-400">
                  <FileText className="w-6 h-6" />
                </div>
                <span className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase ${
                  student.status === "Lengkap" ? "bg-brand-green/10 text-brand-green" : "bg-brand-blue/10 text-brand-blue"
                }`}>
                  {student.status}
                </span>
              </div>
              <h4 className="font-bold text-slate-800">{student.name}</h4>
              <p className="text-xs text-muted-foreground mt-1">NIS: {student.nis}</p>
              <div className="mt-4 pt-4 border-t border-slate-50 flex justify-between items-center">
                <span className="text-xs font-medium text-muted-foreground">Nilai Rata-rata</span>
                <span className="text-lg font-bold text-brand-blue">{student.grade}</span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}

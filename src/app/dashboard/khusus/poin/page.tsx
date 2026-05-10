"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { AlertTriangle, Search, Info } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

export default function PoinPage() {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Poin Pelanggaran</h1>
          <p className="text-muted-foreground mt-1">Sistem poin kedisiplinan dan pembinaan siswa</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <AlertTriangle className="w-4 h-4 mr-2" />
          Input Pelanggaran
        </Button>
      </div>

      <Card className="border-none shadow-md border-l-4 border-l-brand-blue bg-white">
        <CardContent className="p-6 flex items-start gap-4">
          <Info className="w-6 h-6 text-brand-blue shrink-0" />
          <div>
            <h4 className="font-bold text-slate-800">Informasi Pembinaan</h4>
            <p className="text-sm text-muted-foreground mt-1">
              Data poin terintegrasi dengan laporan wali kelas dan guru BK secara otomatis.
            </p>
          </div>
        </CardContent>
      </Card>

      <Card className="border-none shadow-md">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-lg">Daftar Pelanggaran Terbaru</CardTitle>
          <div className="relative w-64">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Cari nama siswa..." className="pl-9 h-9" />
          </div>
        </CardHeader>
        <CardContent className="p-12 text-center text-slate-400">
          <AlertTriangle className="w-12 h-12 mx-auto mb-4 opacity-20" />
          <p>Belum ada data pelanggaran hari ini. Pertahankan kedisiplinan!</p>
        </CardContent>
      </Card>
    </div>
  )
}

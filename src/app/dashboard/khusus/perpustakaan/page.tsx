"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { BookOpen, Search, Bookmark } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

export default function PerpustakaanPage() {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Perpustakaan Digital</h1>
          <p className="text-muted-foreground mt-1">Akses buku, jurnal, dan materi referensi guru</p>
        </div>
        <div className="relative w-64">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input placeholder="Cari buku..." className="pl-9 h-10" />
        </div>
      </div>
      
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <Card key={i} className="border-none shadow-sm hover:shadow-md transition-all cursor-pointer overflow-hidden group">
            <div className="aspect-[3/4] bg-slate-100 flex items-center justify-center relative">
              <BookOpen className="w-8 h-8 text-slate-300 group-hover:scale-110 transition-transform" />
              <div className="absolute top-2 right-2">
                <Bookmark className="w-4 h-4 text-brand-blue opacity-0 group-hover:opacity-100 transition-opacity" />
              </div>
            </div>
            <CardContent className="p-3">
              <h4 className="text-xs font-bold text-slate-800 line-clamp-1">Materi Ajar {i}</h4>
              <p className="text-[10px] text-muted-foreground mt-1">Kategori: Pendidikan</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card className="border-none shadow-md">
        <CardContent className="p-12 text-center">
          <h3 className="text-lg font-bold text-slate-800">Koleksi Digital Lainnya</h3>
          <p className="text-muted-foreground max-w-sm mx-auto mt-2">
            Sedang mensinkronisasi data dengan server perpustakaan pusat.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}

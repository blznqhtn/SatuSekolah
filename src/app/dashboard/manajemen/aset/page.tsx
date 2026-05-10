"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Package, Search, Plus } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

export default function AsetPage() {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Inventaris Aset</h1>
          <p className="text-muted-foreground mt-1">Manajemen sarana dan prasarana sekolah</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <Plus className="w-4 h-4 mr-2" />
          Tambah Aset
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {[
          { title: "Lab Komputer", items: 42, status: "Baik" },
          { title: "Ruang Kelas", items: 24, status: "Baik" },
          { title: "Peralatan Olahraga", items: 115, status: "Perlu Cek" },
        ].map((item, i) => (
          <Card key={i} className="border-none shadow-sm">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{item.title}</CardTitle>
              <Package className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{item.items} Item</div>
              <p className="text-xs text-muted-foreground mt-1">Status: <span className="font-bold text-brand-blue">{item.status}</span></p>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card className="border-none shadow-md">
        <CardContent className="p-12 text-center">
          <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <Package className="w-10 h-10 text-slate-300" />
          </div>
          <h3 className="text-lg font-bold text-slate-800">Daftar Inventaris Sedang Dimuat</h3>
          <p className="text-muted-foreground max-w-sm mx-auto mt-2">
            Halaman manajemen aset dalam pengembangan UI. Nantikan update fitur inventaris lengkap.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}

"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { BarChart3, Search, Download } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function AuditPage() {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Audit Keuangan</h1>
          <p className="text-muted-foreground mt-1">Laporan dan transparansi keuangan sekolah</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <Download className="w-4 h-4 mr-2" />
          Ekspor Laporan
        </Button>
      </div>
      <Card className="border-none shadow-md">
        <CardContent className="p-12 text-center">
          <div className="w-20 h-20 bg-slate-50 rounded-full flex items-center justify-center mx-auto mb-4">
            <BarChart3 className="w-10 h-10 text-slate-300" />
          </div>
          <h3 className="text-lg font-bold text-slate-800">Modul Audit Keuangan</h3>
          <p className="text-muted-foreground max-w-sm mx-auto mt-2">
            Halaman ini sedang dalam tahap perancangan UI untuk mendukung transparansi dana sekolah.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}

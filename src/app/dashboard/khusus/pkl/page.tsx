"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Briefcase, Building2, Users } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function PKLPage() {
  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">PKL & Hubin</h1>
          <p className="text-muted-foreground mt-1">Manajemen Praktik Kerja Lapangan dan Hubungan Industri</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <Building2 className="w-4 h-4 mr-2" />
          Tambah Mitra Industri
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="border-none shadow-md">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Users className="w-5 h-5 text-brand-blue" />
              Status Siswa PKL
            </CardTitle>
          </CardHeader>
          <CardContent className="p-12 text-center">
            <p className="text-muted-foreground">Monitoring tempat PKL siswa XII sedang disiapkan.</p>
          </CardContent>
        </Card>
        <Card className="border-none shadow-md">
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Briefcase className="w-5 h-5 text-brand-purple" />
              Kerjasama Industri
            </CardTitle>
          </CardHeader>
          <CardContent className="p-12 text-center">
            <p className="text-muted-foreground">Daftar MOU dan kemitraan sedang diproses.</p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { 
  CreditCard, 
  Wallet, 
  ArrowUpRight, 
  ArrowDownLeft, 
  Download,
  History,
  Calendar
} from "lucide-react"

export default function PayrollPage() {
  const transactions = [
    { title: "Gaji Pokok Mei 2026", date: "25 Mei 2026", amount: "+Rp 4.500.000", status: "Selesai", type: "income" },
    { title: "Tunjangan Wali Kelas", date: "25 Mei 2026", amount: "+Rp 500.000", status: "Selesai", type: "income" },
    { title: "Potongan Koperasi", date: "25 Mei 2026", amount: "-Rp 200.000", status: "Selesai", type: "expense" },
  ]

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Payroll Guru</h1>
          <p className="text-muted-foreground mt-1">Informasi gaji, tunjangan, dan slip gaji digital</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <Download className="w-4 h-4 mr-2" />
          Unduh Slip Gaji
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="md:col-span-2 border-none shadow-lg bg-gradient-to-br from-brand-blue to-brand-purple text-white relative overflow-hidden">
          <div className="absolute right-0 top-0 w-64 h-64 bg-white/10 rounded-full -mr-20 -mt-20 blur-3xl"></div>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardDescription className="text-white/70">Total Penghasilan Bulan Ini</CardDescription>
              <Wallet className="w-6 h-6 text-white/50" />
            </div>
            <CardTitle className="text-4xl font-bold mt-2">Rp 4.800.000</CardTitle>
          </CardHeader>
          <CardContent className="mt-4">
            <div className="flex flex-wrap gap-4 md:gap-8">
              <div className="min-w-[100px]">
                <p className="text-[10px] uppercase tracking-wider text-white/60 font-bold">Gaji Pokok</p>
                <p className="text-sm font-bold">Rp 4.500.000</p>
              </div>
              <div className="min-w-[100px]">
                <p className="text-[10px] uppercase tracking-wider text-white/60 font-bold">Tunjangan</p>
                <p className="text-sm font-bold">Rp 500.000</p>
              </div>
              <div className="min-w-[100px]">
                <p className="text-[10px] uppercase tracking-wider text-white/60 font-bold">Potongan</p>
                <p className="text-sm font-bold text-red-200">Rp 200.000</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border-none shadow-md">
          <CardHeader>
            <CardTitle className="text-sm font-bold uppercase tracking-wider text-muted-foreground">Status Pembayaran</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col items-center justify-center py-6">
            <div className="w-16 h-16 rounded-full bg-brand-green/10 flex items-center justify-center mb-4">
              <CreditCard className="w-8 h-8 text-brand-green" />
            </div>
            <h4 className="font-bold text-slate-800">Sudah Terbayar</h4>
            <p className="text-xs text-muted-foreground mt-1">Tanggal: 25 Mei 2026</p>
            <Button variant="outline" size="sm" className="mt-6 w-full text-xs font-bold border-brand-blue/20 text-brand-blue">
              Lihat Rincian
            </Button>
          </CardContent>
        </Card>
      </div>

      <Card className="border-none shadow-md">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle className="text-lg">Riwayat Transaksi</CardTitle>
            <CardDescription>Daftar pendapatan dan potongan</CardDescription>
          </div>
          <Button variant="ghost" size="sm" className="text-brand-blue font-bold">
            <History className="w-4 h-4 mr-2" />
            Riwayat Lengkap
          </Button>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {transactions.map((t, i) => (
              <div key={i} className="flex items-center justify-between p-4 rounded-xl hover:bg-slate-50 transition-colors border border-transparent hover:border-slate-100">
                <div className="flex items-center gap-4">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${
                    t.type === 'income' ? 'bg-brand-green/10' : 'bg-red-50'
                  }`}>
                    {t.type === 'income' ? (
                      <ArrowDownLeft className="w-5 h-5 text-brand-green" />
                    ) : (
                      <ArrowUpRight className="w-5 h-5 text-red-400" />
                    )}
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800">{t.title}</h4>
                    <p className="text-[10px] text-muted-foreground">{t.date}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-sm font-bold ${t.type === 'income' ? 'text-brand-green' : 'text-red-500'}`}>
                    {t.amount}
                  </p>
                  <p className="text-[10px] text-brand-blue font-medium">{t.status}</p>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

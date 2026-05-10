"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { 
  Users, 
  UserPlus, 
  Search, 
  Mail, 
  Shield, 
  MoreVertical,
  CheckCircle2
} from "lucide-react"

export default function AkunPage() {
  const accounts = [
    { name: "Budi Santoso, S.Pd", role: "Guru / Wali Kelas", email: "budi@sekolah.id", status: "Aktif" },
    { name: "Siti Aminah, M.Pd", role: "Kepala Sekolah", email: "siti@sekolah.id", status: "Aktif" },
    { name: "Deni Irawan", role: "Admin IT", email: "deni@sekolah.id", status: "Aktif" },
    { name: "Ani Wijaya", role: "Bendahara", email: "ani@sekolah.id", status: "Non-Aktif" },
  ]

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Manajemen Akun</h1>
          <p className="text-muted-foreground mt-1">Kelola hak akses dan akun staf sekolah</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <UserPlus className="w-4 h-4 mr-2" />
          Tambah Akun
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="border-none shadow-sm">
          <CardContent className="p-6 flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-brand-blue/10 flex items-center justify-center">
              <Users className="w-6 h-6 text-brand-blue" />
            </div>
            <div>
              <p className="text-2xl font-bold text-slate-800">42</p>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Total Staf</p>
            </div>
          </CardContent>
        </Card>
        <Card className="border-none shadow-sm">
          <CardContent className="p-6 flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-brand-green/10 flex items-center justify-center">
              <Shield className="w-6 h-6 text-brand-green" />
            </div>
            <div>
              <p className="text-2xl font-bold text-slate-800">5</p>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Administrator</p>
            </div>
          </CardContent>
        </Card>
        <Card className="border-none shadow-sm">
          <CardContent className="p-6 flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-brand-purple/10 flex items-center justify-center">
              <CheckCircle2 className="w-6 h-6 text-brand-purple" />
            </div>
            <div>
              <p className="text-2xl font-bold text-slate-800">38</p>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Akun Aktif</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="border-none shadow-md overflow-hidden">
        <CardHeader className="bg-white border-b border-slate-50">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div className="relative w-full max-w-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input placeholder="Cari nama atau email..." className="pl-9 h-10 border-slate-200" />
            </div>
            <div className="flex items-center gap-2">
              <Button variant="outline" className="text-xs font-bold h-10 px-4">Filter Role</Button>
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {/* Mobile View: Card List */}
          <div className="md:hidden divide-y divide-slate-50">
            {accounts.map((acc, i) => (
              <div key={i} className="p-4 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-brand-blue/10 flex items-center justify-center text-brand-blue font-bold">
                      {acc.name.charAt(0)}
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-800">{acc.name}</p>
                      <p className="text-[10px] text-muted-foreground flex items-center gap-1">
                        <Mail className="w-3 h-3" /> {acc.email}
                      </p>
                    </div>
                  </div>
                  <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400">
                    <MoreVertical className="w-4 h-4" />
                  </Button>
                </div>
                <div className="flex items-center justify-between pt-2">
                  <span className="text-[10px] font-medium text-slate-600 bg-slate-100 px-2 py-1 rounded-md uppercase tracking-wider">
                    {acc.role}
                  </span>
                  <span className={`px-2 py-1 rounded-full text-[10px] font-bold uppercase ${
                    acc.status === "Aktif" ? "bg-brand-green/10 text-brand-green" : "bg-slate-100 text-slate-400"
                  }`}>
                    {acc.status}
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
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Pengguna</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Role</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase">Status</th>
                  <th className="px-6 py-4 text-xs font-bold text-muted-foreground uppercase text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {accounts.map((acc, i) => (
                  <tr key={i} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-500 font-bold">
                          {acc.name.charAt(0)}
                        </div>
                        <div>
                          <p className="text-sm font-bold text-slate-800">{acc.name}</p>
                          <p className="text-[10px] text-muted-foreground flex items-center gap-1">
                            <Mail className="w-3 h-3" /> {acc.email}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="text-xs font-medium text-slate-600 bg-slate-100 px-2 py-1 rounded-md">
                        {acc.role}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 rounded-full text-[10px] font-bold uppercase ${
                        acc.status === "Aktif" ? "bg-brand-green/10 text-brand-green" : "bg-slate-100 text-slate-400"
                      }`}>
                        {acc.status}
                      </span>
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

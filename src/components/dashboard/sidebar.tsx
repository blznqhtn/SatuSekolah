"use client"

import React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { 
  School, 
  LayoutDashboard, 
  GraduationCap, 
  Settings, 
  Wallet, 
  Star,
  ClipboardCheck,
  Monitor,
  FileText,
  Package,
  Calendar,
  Users,
  CreditCard,
  BarChart3,
  BookOpen,
  Briefcase,
  AlertTriangle,
  ChevronRight,
  LogOut
} from "lucide-react"
import { useRouter } from "next/navigation"

const menuGroups = [
  {
    title: "Utama",
    items: [
      { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
    ]
  },
  {
    title: "Akademik",
    items: [
      { name: "Rekap Presensi", href: "/dashboard/akademik/presensi", icon: ClipboardCheck },
      { name: "Monitoring LMS", href: "/dashboard/akademik/lms", icon: Monitor },
      { name: "Rapor Digital", href: "/dashboard/akademik/rapor", icon: FileText },
    ]
  },
  {
    title: "Manajemen",
    items: [
      { name: "Inventaris Aset", href: "/dashboard/manajemen/aset", icon: Package },
      { name: "Kalender Akademik", href: "/dashboard/manajemen/kalender", icon: Calendar },
      { name: "Manajemen Akun", href: "/dashboard/manajemen/akun", icon: Users },
    ]
  },
  {
    title: "Finansial",
    items: [
      { name: "Payroll Guru", href: "/dashboard/finansial/payroll", icon: CreditCard },
      { name: "Audit Keuangan", href: "/dashboard/finansial/audit", icon: BarChart3 },
    ]
  },
  {
    title: "Khusus",
    items: [
      { name: "Perpustakaan Digital", href: "/dashboard/khusus/perpustakaan", icon: BookOpen },
      { name: "PKL & Hubin", href: "/dashboard/khusus/pkl", icon: Briefcase },
      { name: "Poin Pelanggaran", href: "/dashboard/khusus/poin", icon: AlertTriangle },
    ]
  }
]

export function Sidebar({ onClose }: { onClose?: () => void }) {
  const pathname = usePathname()
  const router = useRouter()

  const handleLogout = () => {
    // Di sini bisa ditambahkan logika hapus token/session nanti
    router.push("/login")
    onClose?.()
  }

  const handleLinkClick = () => {
    onClose?.()
  }

  return (
    <div className="flex flex-col h-full bg-white border-r border-brand-blue/10 w-64 shrink-0 shadow-sm overflow-y-auto scrollbar-hide">
      <div className="p-6 flex items-center justify-between">
        <Link href="/dashboard" onClick={handleLinkClick} className="flex items-center gap-3">
          <div className="w-10 h-10 bg-brand-blue rounded-xl flex items-center justify-center shadow-md shadow-brand-blue/20">
            <School className="text-white w-6 h-6" />
          </div>
          <div className="flex flex-col">
            <span className="font-bold text-brand-blue leading-tight">Satu Sekolah</span>
            <span className="text-[10px] text-muted-foreground uppercase tracking-widest font-semibold">Portal Guru</span>
          </div>
        </Link>
      </div>

      <nav className="flex-1 px-4 space-y-6">
        {menuGroups.map((group, i) => (
          <div key={i} className="space-y-2">
            <h3 className="px-3 text-[10px] font-bold text-muted-foreground/60 uppercase tracking-widest">
              {group.title}
            </h3>
            <div className="space-y-1">
              {group.items.map((item) => {
                const isActive = pathname === item.href
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={handleLinkClick}
                    className={cn(
                      "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all group relative",
                      isActive 
                        ? "bg-brand-blue text-white shadow-md shadow-brand-blue/10" 
                        : "text-muted-foreground hover:bg-brand-blue/5 hover:text-brand-blue"
                    )}
                  >
                    <item.icon className={cn(
                      "w-5 h-5",
                      isActive ? "text-white" : "text-muted-foreground/70 group-hover:text-brand-blue"
                    )} />
                    <span>{item.name}</span>
                    {isActive && (
                      <div className="ml-auto">
                        <ChevronRight className="w-4 h-4 text-white/70" />
                      </div>
                    )}
                  </Link>
                )
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="p-4 mt-auto">
        <div className="p-4 rounded-2xl bg-gradient-to-br from-brand-purple/10 to-brand-blue/10 border border-brand-purple/5 mb-4 hidden lg:block">
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 rounded-lg bg-white flex items-center justify-center shadow-sm">
              <Star className="w-4 h-4 text-brand-purple" />
            </div>
            <span className="text-xs font-bold text-brand-purple">Premium Support</span>
          </div>
          <p className="text-[10px] text-muted-foreground leading-relaxed">
            Butuh bantuan sistem? Hubungi IT Support kami 24/7.
          </p>
        </div>

        <button 
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-sm font-bold text-destructive hover:bg-destructive/5 transition-colors"
        >
          <LogOut className="w-5 h-5" />
          <span>Keluar Aplikasi</span>
        </button>
      </div>
    </div>
  )
}

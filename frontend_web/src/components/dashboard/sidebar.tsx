"use client"

import React, { useState } from "react"
import Link from "next/link"
import { usePathname, useRouter } from "next/navigation"
import { useAuth } from "@/lib/auth-context"
import { cn } from "@/lib/utils"
import {
  School,
  LayoutDashboard,
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
  BookOpen,
  Briefcase,
  AlertTriangle,
  ChevronRight,
  LogOut,
  MessageSquare,
  ClipboardList,
  GraduationCap,
  Store,
  UserCheck,
  Activity,
  Award,
  Bot,
  Key,
  ChevronDown,
  Image,
  Eye,
  ScanLine,
  Table2,
} from "lucide-react"

const menuGroups = [
  {
    title: "Utama",
    items: [
      { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
      { name: "Manajemen Pengguna", href: "/dashboard/users", icon: Users, permission: "MANAGE_USERS" },
      { name: "Pesan & Komunikasi", href: "/dashboard/communication", icon: MessageSquare, permission: "MANAGE_COMMUNICATION" },
    ],
  },
  {
    title: "Akademik",
    items: [
      { name: "Jadwal & Kelas", href: "/dashboard/academic", icon: GraduationCap },
      { name: "Kehadiran / Presensi", href: "/dashboard/attendance", icon: ClipboardCheck, permission: "MANAGE_ATTENDANCE" },
      { name: "E-Learning (LMS)", href: "/dashboard/lms", icon: Monitor, permission: "MANAGE_LMS" },
      { name: "Ujian Komputer (CBA)", href: "/dashboard/cba", icon: ClipboardList, permission: "MANAGE_CBA" },
      { name: "Rapor Digital", href: "/dashboard/reports", icon: FileText },
    ],
  },
  {
    title: "Administrasi",
    items: [
      { name: "Penerimaan Siswa (PPDB)", href: "/dashboard/spmb", icon: UserCheck, permission: "MANAGE_SPMB" },
      { name: "Kalender Akademik", href: "/dashboard/calendar", icon: Calendar },
      { name: "Inventaris & Aset", href: "/dashboard/inventory", icon: Package, permission: "MANAGE_INVENTORY" },
      { name: "Surat Izin (Gatepass)", href: "/dashboard/gatepass", icon: Key, permission: "MANAGE_GATEPASS" },
      { name: "Scan QR Gatepass", href: "/dashboard/gatepass/scan", icon: ScanLine, permission: "SCAN_GATEPASS" },
    ],
  },
  {
    title: "Finansial",
    items: [
      { name: "Tagihan & Pembayaran", href: "/dashboard/finance/invoices", icon: Wallet, permission: "MANAGE_FINANCE" },
      { name: "Penggajian (Payroll)", href: "/dashboard/finance/payroll", icon: CreditCard, permission: "MANAGE_FINANCE" },
      { name: "Manajemen Kantin", href: "/dashboard/canteen", icon: Store, permission: "MANAGE_CANTEEN" },
    ],
  },
  {
    title: "Kesiswaan",
    items: [
      { name: "Poin & Pelanggaran", href: "/dashboard/violations", icon: AlertTriangle, permission: "MANAGE_VIOLATIONS" },
      { name: "Kesehatan (UKS)", href: "/dashboard/health", icon: Activity, permission: "MANAGE_HEALTH" },
      { name: "Portofolio Siswa", href: "/dashboard/portfolio", icon: Award },
      { name: "Bursa Kerja (BKK)", href: "/dashboard/career", icon: Briefcase, permission: "MANAGE_BKK" },
      { name: "Prakerin & PKL", href: "/dashboard/performance", icon: Settings, permission: "MANAGE_PKL" },
    ],
  },
  {
    title: "Kepegawaian & Guru",
    items: [
      { name: "Perangkat Pembelajaran", href: "/dashboard/teacher/rpp", icon: BookOpen },
      { name: "Buku Nilai (Gradebook)", href: "/dashboard/teacher/gradebook", icon: Table2, permission: "MANAGE_LMS" },
      { name: "Media & Dokumentasi", href: "/dashboard/teacher/media", icon: Image },
      { name: "Laporan Monitoring PKL", href: "/dashboard/teacher/monitoring-pkl", icon: Activity, permission: "MANAGE_PKL" },
      { name: "Laporan Sarpras", href: "/dashboard/teacher/inventory", icon: Package, permission: "MANAGE_INVENTORY" },
      { name: "Sertifikat Pelatihan", href: "/dashboard/teacher/certificates", icon: Award },
      { name: "Surat Tugas & SK", href: "/dashboard/teacher/assignments", icon: FileText },
      { name: "Observasi Kelas", href: "/dashboard/teacher/observation", icon: Eye, permission: "MANAGE_PKG" },
      { name: "Penilaian Kinerja Pegawai", href: "/dashboard/pkg", icon: Star, permission: "MANAGE_PKG" },
    ],
  },
  {
    title: "Layanan Khusus",
    items: [
      { name: "Perpustakaan Digital", href: "/dashboard/library", icon: BookOpen, permission: "MANAGE_LIBRARY" },
      { name: "Pusat Kontrol AI", href: "/dashboard/ai", icon: Bot, permission: "MANAGE_AI" },
    ],
  },
]

/* Avatar initials helper */
function getInitials(name?: string) {
  if (!name) return "U"
  return name
    .split(" ")
    .slice(0, 2)
    .map((w) => w[0])
    .join("")
    .toUpperCase()
}

export function Sidebar({ onClose }: { onClose?: () => void }) {
  const pathname = usePathname()
  const router = useRouter()
  const { user, logout } = useAuth()
  const [collapsedGroups, setCollapsedGroups] = useState<Record<string, boolean>>({})

  const handleLogout = () => {
    logout()
    onClose?.()
  }

  const handleLinkClick = () => onClose?.()

  const isSuperAdmin = user?.category?.toLowerCase() === "admin"
  const hasPermission = (perm?: string) => {
    if (!perm) return true
    if (isSuperAdmin) return true
    return user?.permissions?.some((p: string) => p.includes(perm) || perm.includes(p))
  }

  const toggleGroup = (title: string) =>
    setCollapsedGroups((prev) => ({ ...prev, [title]: !prev[title] }))

  return (
    <>
      <style>{`
        .sidebar-root {
          display: flex;
          flex-direction: column;
          height: 100%;
          width: 256px;
          flex-shrink: 0;
          background: var(--surface);
          border-right: 1px solid var(--border);
          overflow-y: auto;
          scrollbar-width: none;
        }
        .sidebar-root::-webkit-scrollbar { display: none; }

        .sb-brand {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 20px 18px 16px;
          text-decoration: none;
          border-bottom: 1px solid var(--border);
          margin-bottom: 4px;
          position: sticky;
          top: 0;
          z-index: 10;
          background: var(--surface);
        }
        .sb-brand-icon {
          width: 36px; height: 36px;
          border-radius: 10px;
          background: linear-gradient(135deg, var(--brand), var(--brand-deep));
          display: flex; align-items: center; justify-content: center;
          flex-shrink: 0;
          box-shadow: 0 4px 12px rgba(var(--brand-rgb), 0.32);
        }
        .sb-brand-name {
          font-size: 15px;
          font-weight: 700;
          color: var(--brand-deep);
          letter-spacing: -0.3px;
          line-height: 1.2;
        }
        .sb-brand-sub {
          font-size: 9px;
          color: var(--muted-foreground);
          text-transform: uppercase;
          letter-spacing: 1.2px;
          font-weight: 500;
        }

        .sb-nav {
          flex: 1;
          padding: 6px 10px;
          display: flex;
          flex-direction: column;
          gap: 2px;
        }

        .sb-group { margin-top: 6px; }

        .sb-group-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 5px 8px 3px;
          cursor: pointer;
          border-radius: 6px;
          transition: background 0.12s;
        }
        .sb-group-header:hover { background: rgba(var(--brand-rgb), 0.05); }

        .sb-group-title {
          font-size: 9.5px;
          font-weight: 700;
          color: var(--muted-foreground);
          text-transform: uppercase;
          letter-spacing: 1px;
        }
        .sb-group-chevron {
          color: var(--muted-foreground);
          opacity: 0.6;
          transition: transform 0.2s;
        }
        .sb-group-chevron.open { transform: rotate(180deg); }

        .sb-group-items {
          display: flex;
          flex-direction: column;
          gap: 1px;
          animation: sbFade 0.18s ease both;
        }
        @keyframes sbFade {
          from { opacity: 0; transform: translateY(-4px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .sb-item {
          display: flex;
          align-items: center;
          gap: 9px;
          padding: 8px 10px;
          border-radius: 9px;
          text-decoration: none;
          font-size: 13px;
          font-weight: 400;
          color: var(--muted-foreground);
          transition: background 0.15s, color 0.15s;
          position: relative;
        }
        .sb-item:hover {
          background: rgba(var(--brand-rgb), 0.07);
          color: var(--brand);
        }
        .sb-item.active {
          background: rgba(var(--brand-rgb), 0.11);
          color: var(--brand);
          font-weight: 600;
        }
        .sb-item.active::before {
          content: '';
          position: absolute;
          left: 0; top: 18%; bottom: 18%;
          width: 3px;
          border-radius: 2px;
          background: var(--brand);
        }
        .sb-item-icon {
          flex-shrink: 0;
          color: var(--muted-foreground);
          opacity: 0.85;
          transition: color 0.15s, opacity 0.15s;
        }
        .sb-item:hover .sb-item-icon { color: var(--brand); opacity: 1; }
        .sb-item.active .sb-item-icon { color: var(--brand); opacity: 1; }

        .sb-item-arrow {
          margin-left: auto;
          color: var(--brand);
          opacity: 0.5;
        }

        .sb-divider {
          height: 1px;
          background: var(--border);
          margin: 4px 8px;
        }

        .sb-footer {
          padding: 12px 10px;
          border-top: 1px solid var(--border);
        }

        .sb-support {
          border-radius: 12px;
          background: var(--brand-soft);
          border: 1px solid rgba(var(--brand-rgb), 0.14);
          padding: 12px;
          margin-bottom: 10px;
        }
        .sb-support-head {
          display: flex;
          align-items: center;
          gap: 8px;
          margin-bottom: 4px;
        }
        .sb-support-dot {
          width: 6px; height: 6px;
          border-radius: 50%;
          background: var(--brand);
          box-shadow: 0 0 6px rgba(var(--brand-rgb), 0.6);
          flex-shrink: 0;
        }
        .sb-support-label {
          font-size: 11px;
          font-weight: 700;
          color: var(--brand);
        }
        .sb-support-text {
          font-size: 10px;
          color: var(--muted-foreground);
          line-height: 1.5;
          padding-left: 14px;
        }

        .sb-user {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 8px 4px;
          margin-bottom: 2px;
        }
        .sb-avatar {
          width: 32px; height: 32px;
          border-radius: 9px;
          background: linear-gradient(135deg, var(--brand), var(--brand-deep));
          display: flex; align-items: center; justify-content: center;
          font-size: 11px;
          font-weight: 700;
          color: #fff;
          flex-shrink: 0;
        }
        .sb-user-name {
          font-size: 12px;
          font-weight: 600;
          color: var(--foreground);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .sb-user-role {
          font-size: 10px;
          color: var(--muted-foreground);
          text-transform: capitalize;
        }

        .sb-logout {
          display: flex;
          align-items: center;
          gap: 9px;
          width: 100%;
          padding: 9px 10px;
          border-radius: 9px;
          border: none;
          background: transparent;
          cursor: pointer;
          font-size: 13px;
          font-weight: 500;
          color: var(--destructive);
          transition: background 0.12s, opacity 0.12s;
          opacity: 0.85;
          font-family: inherit;
        }
        .sb-logout:hover {
          background: rgba(220, 38, 38, 0.08);
          opacity: 1;
        }
      `}</style>

      <div className="sidebar-root">

        {/* Brand */}
        <Link href="/dashboard" onClick={handleLinkClick} className="sb-brand">
          <div className="sb-brand-icon">
            <School className="text-white w-4 h-4" />
          </div>
          <div>
            <div className="sb-brand-name">Satu Sekolah</div>
            <div className="sb-brand-sub">Portal Guru</div>
          </div>
        </Link>

        {/* Nav */}
        <nav className="sb-nav">
          {menuGroups.map((group, i) => {
            const filtered = group.items.filter((item) => hasPermission(item.permission))
            if (filtered.length === 0) return null
            const collapsed = collapsedGroups[group.title]

            return (
              <div key={i} className="sb-group">
                <div
                  className="sb-group-header"
                  onClick={() => toggleGroup(group.title)}
                  role="button"
                  aria-expanded={!collapsed}
                >
                  <span className="sb-group-title">{group.title}</span>
                  <ChevronDown
                    className={cn("sb-group-chevron w-3 h-3", !collapsed && "open")}
                  />
                </div>

                {!collapsed && (
                  <div className="sb-group-items">
                    {filtered.map((item) => {
                      const isActive = pathname === item.href
                      return (
                        <Link
                          key={item.href}
                          href={item.href}
                          onClick={handleLinkClick}
                          className={cn("sb-item", isActive && "active")}
                        >
                          <item.icon className="sb-item-icon w-4 h-4" />
                          <span>{item.name}</span>
                          {isActive && (
                            <ChevronRight className="sb-item-arrow w-3.5 h-3.5" />
                          )}
                        </Link>
                      )
                    })}
                  </div>
                )}

                {i < menuGroups.length - 1 && <div className="sb-divider" style={{ marginTop: 6 }} />}
              </div>
            )
          })}
        </nav>

        {/* Footer */}
        <div className="sb-footer">
          {/* Support card — hidden on mobile */}
          <div className="sb-support hidden lg:block">
            <div className="sb-support-head">
              <div className="sb-support-dot" />
              <span className="sb-support-label">Bantuan Cepat</span>
            </div>
            <p className="sb-support-text">
              Butuh bantuan sistem? Tim IT support siap membantu Anda kapan saja.
            </p>
          </div>

          {/* User */}
          <div className="sb-user">
            <div className="sb-avatar">{getInitials(user?.name)}</div>
            <div style={{ overflow: "hidden" }}>
              <div className="sb-user-name">{user?.name ?? "Pengguna"}</div>
              <div className="sb-user-role">{user?.role || user?.category || "—"}</div>
            </div>
          </div>

          {/* Logout */}
          <button className="sb-logout" onClick={handleLogout}>
            <LogOut className="w-4 h-4" />
            <span>Keluar Aplikasi</span>
          </button>
        </div>
      </div>
    </>
  )
}

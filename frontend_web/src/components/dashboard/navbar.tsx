"use client"

import React, { useState, useRef, useEffect } from "react"
import { Search, Bell, Menu, LogOut, Settings, ChevronDown, X, Sun, Moon } from "lucide-react"
import { useRouter } from "next/navigation"
import { useAuth } from "@/lib/auth-context"
import { useTheme } from "@/lib/theme-context"
import { fetchApi } from "@/lib/api"

function getInitials(name?: string) {
  if (!name) return "U"
  return name.split(" ").slice(0, 2).map((w) => w[0]).join("").toUpperCase()
}

interface NotifItem {
  id: string
  title?: string
  message?: string
  type?: string
  read?: boolean
  created_at?: string
  [key: string]: any
}

export function Navbar({ onMenuClick }: { onMenuClick?: () => void }) {
  const router = useRouter()
  const { user, logout } = useAuth()
  const { theme, toggleTheme } = useTheme()
  const [dropdownOpen, setDropdownOpen] = useState(false)
  const [notifOpen, setNotifOpen] = useState(false)
  const [searchOpen, setSearchOpen] = useState(false)
  const [notifs, setNotifs] = useState<NotifItem[]>([])
  const [notifLoading, setNotifLoading] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)
  const notifRef = useRef<HTMLDivElement>(null)

  const handleLogout = () => {
    setDropdownOpen(false)
    logout()
  }

  const unreadCount = notifs.filter((n) => !n.read).length

  /* Load notifications when bell dropdown opens */
  useEffect(() => {
    if (!notifOpen) return
    let active = true
    setNotifLoading(true)
    fetchApi("/notifications")
      .then((res) => {
        if (!active) return
        const raw = res?.data ?? res
        const items: NotifItem[] = Array.isArray(raw)
          ? raw
          : Array.isArray(raw?.items)
          ? raw.items
          : Array.isArray(raw?.notifications)
          ? raw.notifications
          : []
        setNotifs(items.slice(0, 8))
      })
      .catch(() => {
        if (active) setNotifs([])
      })
      .finally(() => active && setNotifLoading(false))
    return () => {
      active = false
    }
  }, [notifOpen])

  /* Close dropdowns on outside click */
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setDropdownOpen(false)
      }
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setNotifOpen(false)
      }
    }
    document.addEventListener("mousedown", handler)
    return () => document.removeEventListener("mousedown", handler)
  }, [])

  const markAllRead = async () => {
    setNotifs((prev) => prev.map((n) => ({ ...n, read: true })))
    notifs.filter((n) => !n.read).forEach((n) =>
      fetchApi(`/notifications/${n.id}/read`, { method: "PUT" }).catch(() => {})
    )
  }

  return (
    <>
      <style>{`
        .nb-root {
          position: sticky;
          top: 0;
          z-index: 30;
          height: 56px;
          background: color-mix(in srgb, var(--surface) 88%, transparent);
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
          border-bottom: 1px solid var(--border);
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 0 1rem;
          gap: 12px;
        }
        @media (min-width: 768px) { .nb-root { padding: 0 1.5rem; } }

        .nb-left { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }

        .nb-menu-btn {
          display: flex; align-items: center; justify-content: center;
          width: 34px; height: 34px; border-radius: 8px; border: none;
          background: transparent; cursor: pointer; color: var(--brand);
          flex-shrink: 0; transition: background 0.12s;
        }
        .nb-menu-btn:hover { background: rgba(var(--brand-rgb), 0.07); }

        .nb-search-wrap {
          position: relative; flex: 1; max-width: 360px; display: none;
        }
        @media (min-width: 768px) { .nb-search-wrap { display: block; } }

        .nb-search-icon {
          position: absolute; left: 11px; top: 50%;
          transform: translateY(-50%); color: var(--muted-foreground);
          pointer-events: none; transition: color 0.12s; width: 15px; height: 15px;
        }
        .nb-search-wrap:focus-within .nb-search-icon { color: var(--brand); }

        .nb-search-input {
          width: 100%; height: 36px; border-radius: 9px;
          border: 1px solid var(--border);
          background: var(--surface-2);
          padding: 0 12px 0 34px; font-size: 13px; color: var(--foreground);
          outline: none; transition: border-color 0.15s, box-shadow 0.15s, background 0.15s;
          font-family: inherit;
        }
        .nb-search-input::placeholder { color: var(--muted-foreground); font-size: 13px; }
        .nb-search-input:focus {
          border-color: rgba(var(--brand-rgb), 0.4);
          box-shadow: 0 0 0 3px rgba(var(--brand-rgb), 0.1);
          background: var(--surface);
        }

        .nb-right { display: flex; align-items: center; gap: 4px; flex-shrink: 0; }

        .nb-icon-btn {
          position: relative; display: flex; align-items: center; justify-content: center;
          width: 36px; height: 36px; border-radius: 9px; border: none;
          background: transparent; cursor: pointer; color: var(--muted-foreground);
          transition: background 0.12s, color 0.12s;
        }
        .nb-icon-btn:hover { background: rgba(var(--brand-rgb), 0.07); color: var(--brand); }

        .nb-badge {
          position: absolute; top: 6px; right: 6px;
          min-width: 16px; height: 16px; padding: 0 4px;
          background: var(--brand); border-radius: 999px;
          border: 2px solid var(--surface);
          color: #fff; font-size: 9px; font-weight: 700;
          display: flex; align-items: center; justify-content: center;
          line-height: 1;
        }

        .nb-search-mobile { display: flex; }
        @media (min-width: 768px) { .nb-search-mobile { display: none; } }

        .nb-divider { width: 1px; height: 22px; background: var(--border); margin: 0 4px; }

        .nb-user-btn {
          display: flex; align-items: center; gap: 8px;
          padding: 4px 8px 4px 4px; border-radius: 10px; border: none;
          background: transparent; cursor: pointer; transition: background 0.12s;
          position: relative;
        }
        .nb-user-btn:hover { background: rgba(var(--brand-rgb), 0.07); }

        .nb-avatar {
          width: 30px; height: 30px; border-radius: 8px;
          background: linear-gradient(135deg, var(--brand), var(--brand-deep));
          display: flex; align-items: center; justify-content: center;
          font-size: 11px; font-weight: 700; color: #fff; flex-shrink: 0; letter-spacing: 0.3px;
        }

        .nb-user-info { text-align: left; display: none; }
        @media (min-width: 640px) { .nb-user-info { display: block; } }
        .nb-user-name { font-size: 12.5px; font-weight: 600; color: var(--foreground); line-height: 1.2; white-space: nowrap; }
        .nb-user-role { font-size: 10px; color: var(--muted-foreground); white-space: nowrap; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 500; }

        .nb-chevron { color: var(--muted-foreground); transition: transform 0.18s; display: none; }
        @media (min-width: 640px) { .nb-chevron { display: block; } }
        .nb-chevron.open { transform: rotate(180deg); }

        .nb-dropdown {
          position: absolute; top: calc(100% + 8px); right: 0;
          background: var(--popover); border: 1px solid var(--border);
          border-radius: 12px;
          box-shadow: 0 8px 24px rgba(0,0,0,0.10), 0 2px 8px rgba(0,0,0,0.06);
          padding: 6px; z-index: 50; animation: nbDrop 0.15s ease;
        }
        .nb-dropdown.wide { width: 340px; }
        @keyframes nbDrop {
          from { opacity: 0; transform: translateY(-6px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .nb-dd-header { padding: 8px 10px 10px; border-bottom: 1px solid var(--border); margin-bottom: 4px; }
        .nb-dd-name { font-size: 13px; font-weight: 600; color: var(--foreground); }
        .nb-dd-email { font-size: 11px; color: var(--muted-foreground); margin-top: 1px; }

        .nb-dd-item {
          display: flex; align-items: center; gap: 9px; padding: 8px 10px;
          border-radius: 8px; border: none; background: transparent; width: 100%;
          text-align: left; cursor: pointer; font-size: 13px; font-weight: 500;
          color: var(--foreground); transition: background 0.1s, color 0.1s; font-family: inherit;
        }
        .nb-dd-item:hover { background: rgba(var(--brand-rgb), 0.07); color: var(--brand); }
        .nb-dd-item.danger { color: var(--destructive); }
        .nb-dd-item.danger:hover { background: rgba(220,38,38,0.08); }

        .nb-dd-divider { height: 1px; background: var(--border); margin: 4px 0; }

        .nb-notif-list { max-height: 340px; overflow-y: auto; }
        .nb-notif-item {
          display: flex; gap: 9px; padding: 9px 10px; border-radius: 8px;
          transition: background 0.1s; cursor: pointer;
        }
        .nb-notif-item:hover { background: var(--surface-2); }
        .nb-notif-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--brand); margin-top: 6px; flex-shrink: 0; }
        .nb-notif-dot.read { background: transparent; border: 1px solid var(--border); }
        .nb-notif-title { font-size: 12.5px; font-weight: 600; color: var(--foreground); line-height: 1.3; }
        .nb-notif-msg { font-size: 11.5px; color: var(--muted-foreground); line-height: 1.4; margin-top: 2px; }
        .nb-notif-time { font-size: 10px; color: var(--muted-foreground); margin-top: 3px; }

        .nb-notif-empty { padding: 28px 16px; text-align: center; color: var(--muted-foreground); font-size: 12.5px; }

        .nb-search-overlay {
          position: fixed; inset: 0; z-index: 50; background: rgba(0,0,0,0.28);
          display: flex; align-items: flex-start; padding: 12px 12px 0;
        }
        .nb-search-overlay-inner {
          width: 100%; background: var(--surface); border-radius: 12px;
          border: 1px solid var(--border); display: flex; align-items: center; gap: 8px;
          padding: 0 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.12);
        }
        .nb-search-overlay-input {
          flex: 1; height: 46px; border: none; background: transparent;
          font-size: 14px; color: var(--foreground); outline: none; font-family: inherit;
        }
        .nb-search-overlay-input::placeholder { color: var(--muted-foreground); }
      `}</style>

      {/* Mobile search overlay */}
      {searchOpen && (
        <div className="nb-search-overlay" onClick={() => setSearchOpen(false)}>
          <div className="nb-search-overlay-inner" onClick={e => e.stopPropagation()}>
            <Search style={{ width: 16, height: 16, color: "var(--brand)", flexShrink: 0 }} />
            <input autoFocus className="nb-search-overlay-input" placeholder="Cari data, siswa, atau fitur..." />
            <button style={{ background: "none", border: "none", cursor: "pointer", color: "var(--muted-foreground)", display: "flex", padding: 4 }} onClick={() => setSearchOpen(false)}>
              <X style={{ width: 16, height: 16 }} />
            </button>
          </div>
        </div>
      )}

      <header className="nb-root">
        {/* Left: hamburger + search */}
        <div className="nb-left">
          <button className="nb-menu-btn lg:hidden" onClick={onMenuClick} aria-label="Buka menu">
            <Menu style={{ width: 20, height: 20 }} />
          </button>
          <div className="nb-search-wrap">
            <Search className="nb-search-icon" />
            <input className="nb-search-input" placeholder="Cari data, siswa, atau fitur..." />
          </div>
        </div>

        {/* Right */}
        <div className="nb-right">
          <button className="nb-icon-btn nb-search-mobile" onClick={() => setSearchOpen(true)} aria-label="Cari">
            <Search style={{ width: 17, height: 17 }} />
          </button>

          {/* Theme toggle */}
          <button className="nb-icon-btn" onClick={toggleTheme} aria-label="Ganti tema">
            {theme === "dark"
              ? <Sun style={{ width: 17, height: 17 }} />
              : <Moon style={{ width: 17, height: 17 }} />}
          </button>

          {/* Notifications */}
          <div style={{ position: "relative" }} ref={notifRef}>
            <button className="nb-icon-btn" onClick={() => setNotifOpen(v => !v)} aria-label="Notifikasi">
              <Bell style={{ width: 17, height: 17 }} />
              {unreadCount > 0 && <span className="nb-badge">{unreadCount > 9 ? "9+" : unreadCount}</span>}
            </button>
            {notifOpen && (
              <div className="nb-dropdown wide">
                <div className="nb-dd-header" style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div>
                    <div className="nb-dd-name">Notifikasi</div>
                    <div className="nb-dd-email">{unreadCount} belum dibaca</div>
                  </div>
                  {unreadCount > 0 && (
                    <button onClick={markAllRead} style={{ background: "none", border: "none", color: "var(--brand)", fontSize: 11, fontWeight: 600, cursor: "pointer", fontFamily: "inherit" }}>
                      Tandai dibaca
                    </button>
                  )}
                </div>
                <div className="nb-notif-list">
                  {notifLoading ? (
                    <div className="nb-notif-empty">Memuat notifikasi...</div>
                  ) : notifs.length === 0 ? (
                    <div className="nb-notif-empty">Tidak ada notifikasi baru.</div>
                  ) : (
                    notifs.map((n) => (
                      <div key={n.id} className="nb-notif-item">
                        <span className={`nb-notif-dot ${n.read ? "read" : ""}`} />
                        <div style={{ minWidth: 0, flex: 1 }}>
                          <div className="nb-notif-title">{n.title || "Notifikasi"}</div>
                          {n.message && <div className="nb-notif-msg">{n.message}</div>}
                          {n.created_at && <div className="nb-notif-time">{new Date(n.created_at).toLocaleString("id-ID")}</div>}
                        </div>
                      </div>
                    ))
                  )}
                </div>
              </div>
            )}
          </div>

          <div className="nb-divider" />

          {/* User dropdown */}
          <div style={{ position: "relative" }} ref={dropdownRef}>
            <button className="nb-user-btn" onClick={() => setDropdownOpen(v => !v)} aria-label="Menu pengguna" aria-expanded={dropdownOpen}>
              <div className="nb-avatar">{getInitials(user?.name)}</div>
              <div className="nb-user-info">
                <div className="nb-user-name">{user?.name || "Pengguna"}</div>
                <div className="nb-user-role">{user?.role || user?.category || "Staf Sekolah"}</div>
              </div>
              <ChevronDown className={`nb-chevron${dropdownOpen ? " open" : ""}`} style={{ width: 14, height: 14 }} />
            </button>

            {dropdownOpen && (
              <div className="nb-dropdown">
                <div className="nb-dd-header">
                  <div className="nb-dd-name">{user?.name || "Pengguna"}</div>
                  <div className="nb-dd-email">{user?.email || user?.role || "Staf Sekolah"}</div>
                </div>
                <button className="nb-dd-item" onClick={() => { setDropdownOpen(false); router.push("/dashboard/settings") }}>
                  <Settings style={{ width: 14, height: 14, flexShrink: 0 }} />
                  Pengaturan akun
                </button>
                <div className="nb-dd-divider" />
                <button className="nb-dd-item danger" onClick={handleLogout}>
                  <LogOut style={{ width: 14, height: 14, flexShrink: 0 }} />
                  Keluar aplikasi
                </button>
              </div>
            )}
          </div>
        </div>
      </header>
    </>
  )
}

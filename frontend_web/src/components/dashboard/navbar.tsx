"use client"

import React, { useState, useRef, useEffect } from "react"
import { Search, Bell, Menu, LogOut, Settings, ChevronDown, X } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useRouter } from "next/navigation"
import { useAuth } from "@/lib/auth-context"

function getInitials(name?: string) {
  if (!name) return "U"
  return name.split(" ").slice(0, 2).map((w) => w[0]).join("").toUpperCase()
}

export function Navbar({ onMenuClick }: { onMenuClick?: () => void }) {
  const router = useRouter()
  const { user, logout } = useAuth()
  const [dropdownOpen, setDropdownOpen] = useState(false)
  const [searchOpen, setSearchOpen] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const handleLogout = () => {
    setDropdownOpen(false)
    logout()
  }

  /* Close dropdown on outside click */
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setDropdownOpen(false)
      }
    }
    document.addEventListener("mousedown", handler)
    return () => document.removeEventListener("mousedown", handler)
  }, [])

  return (
    <>
      <style>{`
        /* ── Navbar tokens (matches sidebar: #4b25bb) ── */
        .nb-root {
          position: sticky;
          top: 0;
          z-index: 30;
          height: 56px;
          background: rgba(255,255,255,0.92);
          backdrop-filter: blur(12px);
          -webkit-backdrop-filter: blur(12px);
          border-bottom: 1px solid rgba(75,37,187,0.08);
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 2.25rem;
          gap: 12px;
        }

        /* Left */
        .nb-left {
          display: flex;
          align-items: center;
          gap: 10px;
          flex: 1;
          min-width: 0;
        }

        .nb-menu-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 34px; height: 34px;
          border-radius: 8px;
          border: none;
          background: transparent;
          cursor: pointer;
          color: #4b25bb;
          flex-shrink: 0;
          transition: background 0.12s;
        }
        .nb-menu-btn:hover { background: rgba(75,37,187,0.06); }

        /* Search */
        .nb-search-wrap {
          position: relative;
          flex: 1;
          max-width: 360px;
          display: none;
        }
        @media (min-width: 768px) { .nb-search-wrap { display: block; } }

        .nb-search-icon {
          position: absolute;
          left: 11px;
          top: 50%;
          transform: translateY(-50%);
          color: #9ca3af;
          pointer-events: none;
          transition: color 0.12s;
          width: 15px; height: 15px;
        }
        .nb-search-wrap:focus-within .nb-search-icon { color: #4b25bb; }

        .nb-search-input {
          width: 100%;
          height: 36px;
          border-radius: 9px;
          border: 1px solid rgba(75,37,187,0.10);
          background: rgba(75,37,187,0.04);
          padding: 0 12px 0 34px;
          font-size: 13px;
          color: #1f2937;
          outline: none;
          transition: border-color 0.15s, box-shadow 0.15s, background 0.15s;
          font-family: inherit;
        }
        .nb-search-input::placeholder { color: #b0b8c8; font-size: 13px; }
        .nb-search-input:focus {
          border-color: rgba(75,37,187,0.3);
          box-shadow: 0 0 0 3px rgba(75,37,187,0.08);
          background: #fff;
        }

        /* Right */
        .nb-right {
          display: flex;
          align-items: center;
          gap: 4px;
          flex-shrink: 0;
        }

        /* Icon buttons */
        .nb-icon-btn {
          position: relative;
          display: flex;
          align-items: center;
          justify-content: center;
          width: 36px; height: 36px;
          border-radius: 9px;
          border: none;
          background: transparent;
          cursor: pointer;
          color: #6b7280;
          transition: background 0.12s, color 0.12s;
        }
        .nb-icon-btn:hover {
          background: rgba(75,37,187,0.06);
          color: #4b25bb;
        }

        /* Notif badge */
        .nb-badge {
          position: absolute;
          top: 7px; right: 7px;
          width: 7px; height: 7px;
          background: #4b25bb;
          border-radius: 50%;
          border: 1.5px solid #fff;
        }

        /* Mobile search btn */
        .nb-search-mobile {
          display: flex;
        }
        @media (min-width: 768px) { .nb-search-mobile { display: none; } }

        /* Divider */
        .nb-divider {
          width: 1px;
          height: 22px;
          background: rgba(75,37,187,0.10);
          margin: 0 4px;
        }

        /* User button */
        .nb-user-btn {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 4px 8px 4px 4px;
          border-radius: 10px;
          border: none;
          background: transparent;
          cursor: pointer;
          transition: background 0.12s;
          position: relative;
        }
        .nb-user-btn:hover { background: rgba(75,37,187,0.06); }

        .nb-avatar {
          width: 30px; height: 30px;
          border-radius: 8px;
          background: linear-gradient(135deg, #4b25bb 0%, #7c3aed 100%);
          display: flex; align-items: center; justify-content: center;
          font-size: 11px;
          font-weight: 700;
          color: #fff;
          flex-shrink: 0;
          letter-spacing: 0.3px;
        }

        .nb-user-info {
          text-align: left;
          display: none;
        }
        @media (min-width: 640px) { .nb-user-info { display: block; } }

        .nb-user-name {
          font-size: 12.5px;
          font-weight: 600;
          color: #1f2937;
          line-height: 1.2;
          white-space: nowrap;
        }
        .nb-user-role {
          font-size: 10px;
          color: #9ca3af;
          white-space: nowrap;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          font-weight: 500;
        }

        .nb-chevron {
          color: #9ca3af;
          transition: transform 0.18s;
          display: none;
        }
        @media (min-width: 640px) { .nb-chevron { display: block; } }
        .nb-chevron.open { transform: rotate(180deg); }

        /* Dropdown */
        .nb-dropdown {
          position: absolute;
          top: calc(100% + 8px);
          right: 0;
          width: 200px;
          background: #fff;
          border: 1px solid rgba(75,37,187,0.10);
          border-radius: 12px;
          box-shadow: 0 8px 24px rgba(75,37,187,0.10), 0 2px 8px rgba(0,0,0,0.06);
          padding: 6px;
          z-index: 50;
          animation: nbDrop 0.15s ease;
        }
        @keyframes nbDrop {
          from { opacity: 0; transform: translateY(-6px); }
          to   { opacity: 1; transform: translateY(0); }
        }

        .nb-dd-header {
          padding: 8px 10px 10px;
          border-bottom: 1px solid rgba(75,37,187,0.07);
          margin-bottom: 4px;
        }
        .nb-dd-name {
          font-size: 13px;
          font-weight: 600;
          color: #1f2937;
        }
        .nb-dd-email {
          font-size: 11px;
          color: #9ca3af;
          margin-top: 1px;
        }

        .nb-dd-item {
          display: flex;
          align-items: center;
          gap: 9px;
          padding: 8px 10px;
          border-radius: 8px;
          border: none;
          background: transparent;
          width: 100%;
          text-align: left;
          cursor: pointer;
          font-size: 13px;
          font-weight: 500;
          color: #374151;
          transition: background 0.1s, color 0.1s;
          font-family: inherit;
        }
        .nb-dd-item:hover {
          background: rgba(75,37,187,0.06);
          color: #4b25bb;
        }
        .nb-dd-item.danger { color: #ef4444; }
        .nb-dd-item.danger:hover { background: #fef2f2; color: #dc2626; }

        .nb-dd-divider {
          height: 1px;
          background: rgba(75,37,187,0.07);
          margin: 4px 0;
        }

        /* Mobile search overlay */
        .nb-search-overlay {
          position: fixed;
          inset: 0;
          z-index: 50;
          background: rgba(0,0,0,0.2);
          display: flex;
          align-items: flex-start;
          padding: 12px 12px 0;
        }
        .nb-search-overlay-inner {
          width: 100%;
          background: #fff;
          border-radius: 12px;
          border: 1px solid rgba(75,37,187,0.12);
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 0 12px;
          box-shadow: 0 8px 24px rgba(0,0,0,0.12);
        }
        .nb-search-overlay-input {
          flex: 1;
          height: 46px;
          border: none;
          background: transparent;
          font-size: 14px;
          color: #1f2937;
          outline: none;
          font-family: inherit;
        }
        .nb-search-overlay-input::placeholder { color: #b0b8c8; }
      `}</style>

      {/* Mobile search overlay */}
      {searchOpen && (
        <div className="nb-search-overlay" onClick={() => setSearchOpen(false)}>
          <div className="nb-search-overlay-inner" onClick={e => e.stopPropagation()}>
            <Search style={{ width: 16, height: 16, color: "#4b25bb", flexShrink: 0 }} />
            <input
              autoFocus
              className="nb-search-overlay-input"
              placeholder="Cari data, siswa, atau fitur..."
            />
            <button
              style={{ background: "none", border: "none", cursor: "pointer", color: "#9ca3af", display: "flex", padding: 4 }}
              onClick={() => setSearchOpen(false)}
            >
              <X style={{ width: 16, height: 16 }} />
            </button>
          </div>
        </div>
      )}

      <header className="nb-root">
        {/* Left: hamburger + search */}
        <div className="nb-left">
          {/* Mobile hamburger */}
          <button className="nb-menu-btn lg:hidden!" onClick={onMenuClick} aria-label="Buka menu">
            <Menu style={{ width: 20, height: 20 }} />
          </button>

          {/* Desktop search */}
          <div className="nb-search-wrap">
            <Search className="nb-search-icon" />
            <input
              className="nb-search-input"
              placeholder="Cari data, siswa, atau fitur..."
            />
          </div>
        </div>

        {/* Right */}
        <div className="nb-right">

          {/* Mobile search toggle */}
          <button
            className="nb-icon-btn nb-search-mobile"
            onClick={() => setSearchOpen(true)}
            aria-label="Cari"
          >
            <Search style={{ width: 17, height: 17 }} />
          </button>

          {/* Notification */}
          <button className="nb-icon-btn" aria-label="Notifikasi">
            <Bell style={{ width: 17, height: 17 }} />
            <span className="nb-badge" />
          </button>

          <div className="nb-divider" />

          {/* User dropdown */}
          <div style={{ position: "relative" }} ref={dropdownRef}>
            <button
              className="nb-user-btn"
              onClick={() => setDropdownOpen(v => !v)}
              aria-label="Menu pengguna"
              aria-expanded={dropdownOpen}
            >
              <div className="nb-avatar">{getInitials(user?.name)}</div>
              <div className="nb-user-info">
                <div className="nb-user-name">{user?.name || "Pengguna"}</div>
                <div className="nb-user-role">{user?.role || user?.category || "Staf Sekolah"}</div>
              </div>
              <ChevronDown
                className={`nb-chevron${dropdownOpen ? " open" : ""}`}
                style={{ width: 14, height: 14 }}
              />
            </button>

            {dropdownOpen && (
              <div className="nb-dropdown">
                {/* Header */}
                <div className="nb-dd-header">
                  <div className="nb-dd-name">{user?.name || "Pengguna"}</div>
                  <div className="nb-dd-email">{user?.email || user?.role || "Staf Sekolah"}</div>
                </div>

                <button
                  className="nb-dd-item"
                  onClick={() => { setDropdownOpen(false); router.push("/dashboard/settings") }}
                >
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
"use client"

import React, { useEffect, useState } from "react"
import { X, Shield, Key, Loader2 } from "lucide-react"
import { fetchApi } from "@/lib/api"

interface User {
  id: string
  name: string
  email: string
  category: string
  [key: string]: any
}

interface EditUserModalProps {
  user: User
  isOpen: boolean
  onClose: () => void
}

interface SystemPermission {
  id: string
  name: string
}

export function EditUserModal({ user, isOpen, onClose }: EditUserModalProps) {
  const [isLoading, setIsLoading] = useState(true)
  const [systemPermissions, setSystemPermissions] = useState<SystemPermission[]>([])
  
  const [role, setRole] = useState("student")
  const [userPermissions, setUserPermissions] = useState<string[]>([])

  useEffect(() => {
    if (isOpen && user) {
      setIsLoading(true)
      
      // Fetch both System Permissions and User's specific access
      Promise.all([
        fetchApi("/permissions").catch(() => ({ data: [] })),
        fetchApi(`/users/${user.id}/access`).catch(() => ({ data: { role: "student", permissions: [] } }))
      ]).then(([permRes, accessRes]) => {
        // Handle System Permissions
        const perms = Array.isArray(permRes) ? permRes : (permRes?.data || [])
        setSystemPermissions(perms)
        
        // Handle User Access
        if (accessRes && accessRes.data) {
          setRole(accessRes.data.role || "student")
          setUserPermissions(accessRes.data.permissions || [])
        }
        
        setIsLoading(false)
      })
    }
  }, [isOpen, user])

  const togglePermission = (permName: string) => {
    setUserPermissions(prev => 
      prev.includes(permName) 
        ? prev.filter(p => p !== permName) 
        : [...prev, permName]
    )
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="bg-white w-full max-w-lg rounded-2xl shadow-xl border border-slate-100 overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50/50">
          <div>
            <h2 className="text-lg font-bold text-slate-800">Edit Akses Pengguna</h2>
            <p className="text-sm text-muted-foreground">Kelola peran dan izin untuk {user?.name}</p>
          </div>
          <button 
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 space-y-6">
          {isLoading ? (
            <div className="flex flex-col items-center justify-center py-12 text-slate-500">
              <Loader2 className="w-8 h-8 animate-spin mb-3 text-brand-blue" />
              <p className="text-sm">Memuat konfigurasi akses...</p>
            </div>
          ) : (
            <>
              {/* Role Section */}
              <div className="space-y-3">
                <div className="flex items-center gap-2 text-slate-800 font-semibold">
                  <Shield className="w-4 h-4 text-brand-blue" />
                  <h3>Role Utama</h3>
                </div>
                <select 
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-brand-blue/30 focus:border-brand-blue transition-all"
                >
                  <option value="Admin">Administrator</option>
                  <option value="Staff">Staff / Guru</option>
                  <option value="Student">Siswa</option>
                  <option value="Parent">Orang Tua</option>
                </select>
                <p className="text-xs text-muted-foreground">
                  Role menentukan hak akses dasar pengguna di seluruh sistem.
                </p>
              </div>

              {/* Permissions Section */}
              <div className="space-y-3">
                <div className="flex items-center gap-2 text-slate-800 font-semibold">
                  <Key className="w-4 h-4 text-brand-purple" />
                  <h3>Izin Khusus (Permissions)</h3>
                </div>
                <div className="space-y-2 border border-slate-100 rounded-xl p-4 bg-slate-50/50 max-h-48 overflow-y-auto">
                  {systemPermissions.length > 0 ? systemPermissions.map(p => (
                    <label key={p.id} className="flex items-center gap-3 cursor-pointer p-1 hover:bg-slate-100/50 rounded">
                      <input 
                        type="checkbox" 
                        checked={userPermissions.includes(p.name)}
                        onChange={() => togglePermission(p.name)}
                        className="w-4 h-4 text-brand-blue rounded border-slate-300 focus:ring-brand-blue" 
                      />
                      <span className="text-sm font-medium text-slate-700">{p.name}</span>
                    </label>
                  )) : (
                    <p className="text-xs text-slate-500">Tidak ada permissions yang ditemukan di sistem.</p>
                  )}
                </div>
                <p className="text-xs text-muted-foreground">
                  Centang izin tambahan yang spesifik melampaui batasan Role utamanya.
                </p>
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-slate-50 border-t border-slate-100 flex items-center justify-end gap-3">
          <button 
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 hover:text-slate-800 transition-colors"
          >
            Batal
          </button>
          <button 
            onClick={async () => {
              setIsLoading(true)
              try {
                await fetchApi(`/users/${user.id}/access`, {
                  method: 'PUT',
                  body: JSON.stringify({
                    role: role,
                    permissions: userPermissions
                  })
                })
                alert("Akses berhasil diperbarui!")
                onClose()
              } catch (err: any) {
                alert("Gagal menyimpan: " + err.message)
                setIsLoading(false)
              }
            }}
            disabled={isLoading}
            className="px-5 py-2 text-sm font-semibold text-white bg-brand-blue rounded-xl hover:bg-brand-blue/90 shadow-md shadow-brand-blue/20 transition-all disabled:opacity-50 flex items-center gap-2"
          >
            {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
            Simpan Perubahan
          </button>
        </div>

      </div>
    </div>
  )
}

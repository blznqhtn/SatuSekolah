"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef, TabDef } from "@/components/dashboard/data-table-template"
import { EditUserModal } from "./components/edit-user-modal"
import { CreateUserModal } from "./components/create-user-modal"
import { fetchApi, api } from "@/lib/api"
import { Trash2, KeyRound, ShieldAlert } from "lucide-react"

export default function Page() {
  const [editingUser, setEditingUser] = useState<any | null>(null)
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [refreshKey, setRefreshKey] = useState(0)

  const tabs: TabDef[] = [
    { label: "Semua", value: "all" },
    { label: "Staff & Guru", value: "staff" },
    { label: "Siswa", value: "student" },
    { label: "Orang Tua", value: "parent" },
    { label: "Admin", value: "admin" },
  ]

  const triggerRefresh = () => setRefreshKey(prev => prev + 1)

  const handleResetPassword = async (item: any) => {
    if (!confirm(`Kirim instruksi reset password untuk pengguna ${item.name || item.email}?`)) return

    try {
      const res = await api.post(`/users/${item.id}/reset-password`)
      alert(res.message || "Password berhasil direset.")
    } catch (err: any) {
      alert("Gagal mereset password: " + err.message)
    }
  }

  const handleDeleteUser = async (item: any) => {
    if (!confirm(`Apakah Anda yakin ingin menonaktifkan pengguna "${item.name}"?`)) return

    try {
      await api.delete(`/users/${item.id}`)
      alert("Pengguna berhasil dinonaktifkan.")
      triggerRefresh()
    } catch (err: any) {
      alert("Gagal menghapus pengguna: " + err.message)
    }
  }

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-400 text-xs">{index + 1}</span>,
    },
    {
      key: "name",
      label: "Nama & Identitas",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800">{item.name}</span>
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            {item.username && <span>@{item.username}</span>}
            {item.nisn && <span className="bg-slate-100 px-1 rounded text-[11px]">NISN: {item.nisn}</span>}
            {item.npk && <span className="bg-slate-100 px-1 rounded text-[11px]">NPK: {item.npk}</span>}
          </div>
        </div>
      ),
    },
    {
      key: "account_number",
      label: "Nomor Akun",
      sortable: true,
      render: (item) => (
        <span className="font-mono text-xs text-slate-600 bg-slate-50 border border-slate-200/60 px-2 py-1 rounded-md">
          {item.account_number || "—"}
        </span>
      ),
    },
    {
      key: "email",
      label: "Email / Kontak",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col text-xs">
          <span className="text-slate-700">{item.email || "—"}</span>
          {item.phone && <span className="text-slate-400">{item.phone}</span>}
        </div>
      ),
    },
    {
      key: "category",
      label: "Role / Kategori",
      sortable: true,
      render: (item) => {
        const cat = (item.category || "").toLowerCase()
        const badgeStyles =
          cat === "admin"
            ? "bg-rose-50 text-rose-600 border-rose-200"
            : cat === "staff"
            ? "bg-blue-50 text-blue-600 border-blue-200"
            : cat === "student"
            ? "bg-emerald-50 text-emerald-600 border-emerald-200"
            : cat === "parent"
            ? "bg-purple-50 text-purple-600 border-purple-200"
            : "bg-slate-50 text-slate-600 border-slate-200"

        return (
          <span className={`px-2.5 py-0.5 text-[11px] font-semibold rounded-full border ${badgeStyles}`}>
            {(item.category || "UMUM").toUpperCase()}
          </span>
        )
      },
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => {
        const isRestricted = item.category === "student" || item.category === "parent"
        return (
          <div className="flex items-center justify-end gap-1.5">
            {!isRestricted && (
              <button
                onClick={() => setEditingUser(item)}
                className="px-2.5 py-1 text-xs font-semibold text-[#4b25bb] hover:bg-[#4b25bb]/10 border border-[#4b25bb]/20 rounded-lg transition-colors"
                title="Kelola hak akses role & izin"
              >
                Hak Akses
              </button>
            )}
            <button
              onClick={() => handleResetPassword(item)}
              className="p-1.5 text-amber-600 hover:bg-amber-50 border border-amber-200 rounded-lg transition-colors"
              title="Reset Password"
            >
              <KeyRound className="w-3.5 h-3.5" />
            </button>
            <button
              onClick={() => handleDeleteUser(item)}
              className="p-1.5 text-red-500 hover:bg-red-50 border border-red-200 rounded-lg transition-colors"
              title="Nonaktifkan Pengguna"
            >
              <Trash2 className="w-3.5 h-3.5" />
            </button>
          </div>
        )
      },
    },
  ]

  return (
    <>
      <DataTableTemplate
        moduleName="Manajemen Pengguna"
        description="Kelola seluruh entitas akun pengguna: administrator, tenaga pendidik / staf, siswa, dan orang tua."
        endpoint="/users"
        columns={columns}
        tabs={tabs}
        categoryKey="category"
        addLabel="Tambah Pengguna"
        onAddClick={() => setIsAddOpen(true)}
        refreshTrigger={refreshKey}
      />

      {/* Modal Tambah Pengguna */}
      <CreateUserModal
        isOpen={isAddOpen}
        onClose={() => setIsAddOpen(false)}
        onSuccess={triggerRefresh}
      />

      {/* Modal Edit Akses */}
      <EditUserModal
        user={editingUser}
        isOpen={!!editingUser}
        onClose={() => {
          setEditingUser(null)
          triggerRefresh()
        }}
      />
    </>
  )
}


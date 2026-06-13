"use client"

import React, { useState } from "react"
import { DataTableTemplate, ColumnDef, TabDef } from "@/components/dashboard/data-table-template"
import { EditUserModal } from "./components/edit-user-modal"

export default function Page() {
  const [editingUser, setEditingUser] = useState<any | null>(null)

  const tabs: TabDef[] = [
    { label: "Semua", value: "all" },
    { label: "Staff & Guru", value: "staff" },
    { label: "Siswa", value: "student" },
    { label: "Orang Tua", value: "parent" }
  ]

  const handleResetPassword = async (item: any) => {
    if (!confirm(`Kirim link reset password ke email ${item.email || "pengguna ini"}?`)) return;

    try {
      await fetchApi(`/users/${item.id}/reset-password`, { method: "POST" });
      alert("Email reset password berhasil dikirim!");
    } catch (err: any) {
      alert("Gagal mengirim email reset password: " + err.message);
    }
  };

  const columns: ColumnDef[] = [
    {
      key: "no",
      label: "No",
      render: (_, index) => <span className="font-medium text-slate-500">{index + 1}</span>
    },
    {
      key: "name",
      label: "Nama & Username",
      sortable: true,
      render: (item) => (
        <div className="flex flex-col">
          <span className="font-semibold text-slate-800">{item.name}</span>
          {item.username && (
            <span className="text-xs text-muted-foreground">@{item.username}</span>
          )}
        </div>
      )
    },
    {
      key: "account_number",
      label: "Nomor Akun",
      sortable: true,
      render: (item) => (
        <span className="font-mono text-xs text-slate-500 bg-slate-50 px-2 py-1 rounded">
          {item.account_number || "—"}
        </span>
      )
    },
    {
      key: "email",
      label: "Email",
      sortable: true,
      render: (item) => item.email || "—"
    },
    {
      key: "category",
      label: "Role / Kategori",
      sortable: true,
      render: (item) => (
        <span className={`px-2.5 py-1 text-xs font-semibold rounded-full border ${
          item.category === "staff" ? "bg-blue-50 text-blue-600 border-blue-100" :
          item.category === "student" ? "bg-emerald-50 text-emerald-600 border-emerald-100" :
          item.category === "parent" ? "bg-purple-50 text-purple-600 border-purple-100" :
          "bg-slate-50 text-slate-600 border-slate-100"
        }`}>
          {item.category ? item.category.toUpperCase() : "UMUM"}
        </span>
      )
    },
    {
      key: "actions",
      label: "Aksi",
      render: (item) => {
        const isRestricted = item.category === "student" || item.category === "parent";
        return (
          <div className="flex items-center justify-end gap-2">
            {!isRestricted && (
              <button 
                onClick={() => setEditingUser(item)}
                className="px-3 py-1.5 bg-brand-blue/5 hover:bg-brand-blue/10 text-brand-blue rounded-lg text-sm font-medium transition-colors border border-brand-blue/10"
              >
                Edit Akses
              </button>
            )}
            <button 
              onClick={() => handleResetPassword(item)}
              className="px-3 py-1.5 bg-orange-50 hover:bg-orange-100 text-orange-600 rounded-lg text-sm font-medium transition-colors border border-orange-100"
            >
              Reset Password
            </button>
          </div>
        );
      }
    }
  ]

  return (
    <>
      <DataTableTemplate 
        moduleName="Manajemen Pengguna"
        description="Kelola seluruh entitas pengguna, baik itu staf, guru, siswa, maupun orang tua."
        endpoint="/users"
        columns={columns}
        tabs={tabs}
        categoryKey="category"
      />
      
      {/* Modal Edit Akses */}
      <EditUserModal 
        user={editingUser} 
        isOpen={!!editingUser} 
        onClose={() => setEditingUser(null)} 
      />
    </>
  )
}

"use client"

import React, { createContext, useContext, useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { fetchApi } from "./api"

export interface User {
  id: string
  name: string
  email: string
  role?: string
  category?: string
  permissions?: string[]
  tenant_id?: string
}

interface AuthContextType {
  user: User | null
  login: (email: string, pass: string) => Promise<{ success: boolean; error?: string }>
  logout: () => void
  isLoading: boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {
    // Simulasi cek session dari localStorage
    const savedUser = localStorage.getItem("satu_sekolah_user")
    if (savedUser) {
      setUser(JSON.parse(savedUser))
    }
    setIsLoading(false)
  }, [])

  const login = async (identifier: string, pass: string) => {
    try {
      const data = await fetchApi("/users/login", {
        method: "POST",
        body: JSON.stringify({ identifier: identifier, password: pass }),
      });

      if (data.token && data.user) {
        // Blokir akses untuk kategori selain admin atau staff
        const category = data.user.category?.toLowerCase() || "";
        if (category !== "admin" && category !== "staff") {
          return { 
            success: false, 
            error: "Akses Ditolak: Aplikasi web ini khusus untuk Admin dan Staff/Guru. Siswa dan Orang Tua silakan menggunakan aplikasi Satu Sekolah Mobile." 
          };
        }

        setUser(data.user);
        localStorage.setItem("satu_sekolah_user", JSON.stringify(data.user));
        localStorage.setItem("satu_sekolah_token", data.token);
        return { success: true };
      }
      return { success: false, error: "Format respons tidak valid." };
    } catch (error: any) {
      return { success: false, error: error.message || "Terjadi kesalahan saat login." };
    }
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem("satu_sekolah_user")
    localStorage.removeItem("satu_sekolah_token")
    router.push("/login")
  }

  return (
    <AuthContext.Provider value={{ user, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}

"use client"

import React, { createContext, useContext, useState, useEffect } from "react"
import { useRouter } from "next/navigation"

interface User {
  name: string
  role: string
  email: string
  avatar?: string
}

interface AuthContextType {
  user: User | null
  login: (email: string, pass: string) => Promise<boolean>
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
    // Simulasi API delay
    await new Promise(resolve => setTimeout(resolve, 800))

    if ((identifier === "admin@sekolah.id" || identifier === "123456") && pass === "admin123") {
      const mockUser = {
        name: "Budi Santoso, S.Pd",
        role: "Wali Kelas - XII RPL 1",
        email: "budi@sekolah.id"
      }
      setUser(mockUser)
      localStorage.setItem("satu_sekolah_user", JSON.stringify(mockUser))
      return true
    }
    return false
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem("satu_sekolah_user")
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

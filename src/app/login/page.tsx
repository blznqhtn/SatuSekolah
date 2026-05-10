"use client"

import React, { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card"
import { School, User, Lock, ArrowRight, AlertCircle } from "lucide-react"

import { useAuth } from "@/lib/auth-context"

export default function LoginPage() {
  const router = useRouter()
  const { login, user } = useAuth()
  const [identifier, setIdentifier] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")
  const [isLoading, setIsLoading] = useState(false)

  // Redirect jika sudah login
  React.useEffect(() => {
    if (user) {
      router.push("/dashboard")
    }
  }, [user, router])

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    const success = await login(identifier, password)
    
    if (success) {
      router.push("/dashboard")
    } else {
      setError("NIP/Email atau kata sandi salah. Silakan coba lagi.")
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-brand-green/10 via-brand-blue/10 to-brand-purple/10 p-4">
      <div className="w-full max-w-md">
        <div className="flex flex-col items-center mb-8 animate-in fade-in slide-in-from-top-4 duration-700">
          <div className="w-16 h-16 bg-brand-blue rounded-2xl flex items-center justify-center shadow-lg shadow-brand-blue/20 mb-4">
            <School className="text-white w-10 h-10" />
          </div>
          <h1 className="text-3xl font-bold text-brand-blue">Satu Sekolah</h1>
          <p className="text-muted-foreground mt-2">Portal Khusus Sekolah & Guru</p>
        </div>

        <Card className="border-none shadow-xl bg-white/80 backdrop-blur-md animate-in fade-in zoom-in-95 duration-500">
          <CardHeader className="space-y-1">
            <CardTitle className="text-2xl text-center">Selamat Datang</CardTitle>
            <CardDescription className="text-center">
              Masukkan kredensial Anda untuk mengakses dashboard
            </CardDescription>
          </CardHeader>
          <form onSubmit={handleLogin}>
            <CardContent className="space-y-4">
              {error && (
                <div className="flex items-center gap-2 p-3 text-xs font-medium text-destructive bg-destructive/10 rounded-lg border border-destructive/20 animate-in fade-in zoom-in-95">
                  <AlertCircle className="h-4 w-4" />
                  {error}
                </div>
              )}
              <div className="space-y-2">
                <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                  NIP atau Email
                </label>
                <div className="relative">
                  <User className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                  <Input 
                    required
                    value={identifier}
                    onChange={(e) => setIdentifier(e.target.value)}
                    placeholder="Masukkan NIP atau Email" 
                    className="pl-10 border-brand-blue/20 focus:border-brand-blue"
                  />
                </div>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                  Kata Sandi
                </label>
                <div className="relative">
                  <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                  <Input 
                    required
                    type="password" 
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••" 
                    className="pl-10 border-brand-blue/20 focus:border-brand-blue"
                  />
                </div>
              </div>
              <div className="flex items-center justify-between">
                <label className="flex items-center space-x-2 cursor-pointer">
                  <input type="checkbox" className="rounded border-brand-blue/20 text-brand-blue focus:ring-brand-blue" />
                  <span className="text-xs text-muted-foreground">Ingat saya</span>
                </label>
                <a href="#" className="text-xs text-brand-blue hover:underline">Lupa kata sandi?</a>
              </div>
            </CardContent>
            <CardFooter className="flex flex-col gap-4">
              <Button 
                type="submit"
                disabled={isLoading}
                className="w-full h-11 text-base font-semibold transition-all hover:scale-[1.01]" 
                variant="brand-blue"
              >
                {isLoading ? (
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                    Memproses...
                  </div>
                ) : (
                  <>
                    Masuk ke Dashboard
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </>
                )}
              </Button>
              <div className="p-3 bg-slate-50 rounded-lg border border-slate-100 text-[10px] text-slate-500">
                <p className="font-bold mb-1 uppercase tracking-wider text-[9px]">Akses Demo:</p>
                <div className="flex justify-between">
                  <span>NIP: <span className="text-slate-800 font-mono">123456</span></span>
                  <span>Sandi: <span className="text-slate-800 font-mono">admin123</span></span>
                </div>
              </div>
              <p className="text-xs text-center text-muted-foreground">
                Masalah login? Hubungi <span className="text-brand-purple font-medium">Administrator IT</span>
              </p>
            </CardFooter>
          </form>
        </Card>
        
        <div className="mt-8 text-center text-xs text-muted-foreground">
          &copy; 2026 Satu Sekolah. Seluruh hak cipta dilindungi.
        </div>
      </div>
    </div>
  )
}

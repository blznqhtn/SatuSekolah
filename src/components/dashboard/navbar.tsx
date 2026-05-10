"use client"

import React from "react"
import { Search, Bell, Menu, User, Settings, LogOut } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useRouter } from "next/navigation"

import { useAuth } from "@/lib/auth-context"

export function Navbar({ onMenuClick }: { onMenuClick?: () => void }) {
  const router = useRouter()
  const { user, logout } = useAuth()

  const handleLogout = () => {
    logout()
  }

  return (
    <header className="h-16 border-b border-brand-blue/10 bg-white/80 backdrop-blur-md sticky top-0 z-30 flex items-center justify-between px-4 md:px-6">
      <div className="flex items-center gap-4 flex-1 max-w-md">
        <Button 
          variant="ghost" 
          size="icon" 
          className="lg:hidden text-brand-blue"
          onClick={onMenuClick}
        >
          <Menu className="h-6 w-6" />
        </Button>
        <div className="relative w-full group hidden md:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground group-focus-within:text-brand-blue transition-colors" />
          <Input 
            placeholder="Cari data, siswa, atau fitur..." 
            className="pl-10 h-10 bg-brand-blue/5 border-none focus-visible:ring-1 focus-visible:ring-brand-blue/30"
          />
        </div>
      </div>

      <div className="flex items-center gap-2">
        <Button variant="ghost" size="icon" className="relative text-muted-foreground hover:text-brand-blue">
          <Bell className="h-5 w-5" />
          <span className="absolute top-2.5 right-2.5 w-2 h-2 bg-brand-purple rounded-full border-2 border-white"></span>
        </Button>
        
        <div className="w-[1px] h-6 bg-brand-blue/10 mx-1 md:mx-2"></div>
        
        <div className="flex items-center gap-2 md:gap-3 pl-1 md:pl-2 group cursor-pointer" onClick={handleLogout}>
          <div className="text-right hidden sm:block">
            <p className="text-sm font-bold text-slate-700 leading-none">{user?.name || "User"}</p>
            <p className="text-[10px] text-muted-foreground font-medium mt-1 uppercase tracking-tighter">
              {user?.role || "Staf Sekolah"} • Keluar
            </p>
          </div>
          <div className="w-9 h-9 md:w-10 md:h-10 rounded-xl bg-gradient-to-tr from-brand-blue to-brand-purple p-[2px] cursor-pointer hover:scale-105 transition-transform shadow-md shadow-brand-blue/10">
            <div className="w-full h-full rounded-[10px] bg-white flex items-center justify-center overflow-hidden">
               <LogOut className="w-5 h-5 text-brand-blue" />
            </div>
          </div>
        </div>
      </div>
    </header>
  )
}

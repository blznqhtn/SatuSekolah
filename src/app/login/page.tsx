"use client"

import React, { useState, useEffect, useRef } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { School, User, Lock, ArrowRight, AlertCircle, ShieldCheck, Eye, EyeOff } from "lucide-react"
import { useAuth } from "@/lib/auth-context"

/* ─── 3D Particle Canvas ─────────────────────────────────── */
function ParticleCanvas() {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext("2d")
    if (!ctx) return

    let animId: number

    const resize = () => {
      canvas.width = canvas.offsetWidth
      canvas.height = canvas.offsetHeight
    }
    resize()
    window.addEventListener("resize", resize)

    /* Particles */
    type Particle = {
      x: number; y: number; z: number
      vx: number; vy: number
      r: number; warm: boolean
    }

    const particles: Particle[] = Array.from({ length: 55 }, () => {
      const z = Math.random() * 0.8 + 0.2
      return {
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        z,
        vx: (Math.random() - 0.5) * 0.35 * z,
        vy: (Math.random() - 0.5) * 0.35 * z,
        r: Math.random() * 1.4 + 0.5,
        warm: Math.random() > 0.5,
      }
    })

    const reset = (p: Particle) => {
      p.z = Math.random() * 0.8 + 0.2
      p.x = Math.random() * canvas.width
      p.y = Math.random() * canvas.height
      p.vx = (Math.random() - 0.5) * 0.35 * p.z
      p.vy = (Math.random() - 0.5) * 0.35 * p.z
    }

    /* Rotating wireframe cube */
    let angle = 0

    const project = (x: number, y: number, z: number, cx: number, cy: number) => {
      const fov = 180
      const s = fov / (fov + z)
      return { x: cx + x * s, y: cy + y * s, s }
    }

    const drawCube = (cx: number, cy: number, size: number, a: number) => {
      const cos = Math.cos(a), sin = Math.sin(a)
      const cos2 = Math.cos(a * 0.65), sin2 = Math.sin(a * 0.65)
      const verts = [
        [-1,-1,-1],[1,-1,-1],[1,1,-1],[-1,1,-1],
        [-1,-1, 1],[1,-1, 1],[1,1, 1],[-1,1, 1],
      ].map(([x, y, z]) => {
        const x1 = x * cos - z * sin
        const z1 = x * sin + z * cos
        const y1 = y * cos2 - z1 * sin2
        const z2 = y * sin2 + z1 * cos2
        return project(x1 * size, y1 * size, z2 * size, cx, cy)
      })
      const edges = [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]]
      ctx.strokeStyle = "rgba(124,58,237,0.22)"
      ctx.lineWidth = 0.8
      edges.forEach(([a, b]) => {
        ctx.beginPath()
        ctx.moveTo(verts[a].x, verts[a].y)
        ctx.lineTo(verts[b].x, verts[b].y)
        ctx.stroke()
      })
      verts.forEach(p => {
        ctx.beginPath()
        ctx.arc(p.x, p.y, 1.5 * p.s, 0, Math.PI * 2)
        ctx.fillStyle = "rgba(167,139,250,0.65)"
        ctx.fill()
      })
    }

    const drawBook = (cx: number, cy: number, a: number) => {
      const cos = Math.cos(a * 0.5), sin = Math.sin(a * 0.5)
      const [w, h, d] = [26, 34, 7]
      const verts = [
        [-w,-h,-d],[w,-h,-d],[w,h,-d],[-w,h,-d],
        [-w,-h, d],[w,-h, d],[w,h, d],[-w,h, d],
      ].map(([x, y, z]) => {
        const x1 = x * cos - z * sin
        const z1 = x * sin + z * cos
        return project(x1, y, z1, cx, cy)
      })
      ctx.strokeStyle = "rgba(129,200,255,0.28)"
      ctx.lineWidth = 0.8
      ;[[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]].forEach(([a, b]) => {
        ctx.beginPath(); ctx.moveTo(verts[a].x, verts[a].y); ctx.lineTo(verts[b].x, verts[b].y); ctx.stroke()
      })
    }

    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      angle += 0.005

      particles.forEach(p => {
        p.x += p.vx; p.y += p.vy
        if (p.x < 0 || p.x > canvas.width || p.y < 0 || p.y > canvas.height) reset(p)
        ctx.beginPath()
        ctx.arc(p.x, p.y, p.r * p.z, 0, Math.PI * 2)
        ctx.fillStyle = p.warm
          ? `rgba(167,139,250,${0.4 * p.z})`
          : `rgba(129,200,255,${0.3 * p.z})`
        ctx.fill()
      })

      /* connections */
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const dx = particles[i].x - particles[j].x
          const dy = particles[i].y - particles[j].y
          const d = Math.sqrt(dx * dx + dy * dy)
          if (d < 80) {
            ctx.beginPath()
            ctx.moveTo(particles[i].x, particles[i].y)
            ctx.lineTo(particles[j].x, particles[j].y)
            ctx.strokeStyle = `rgba(167,139,250,${0.12 * (1 - d / 80)})`
            ctx.lineWidth = 0.5
            ctx.stroke()
          }
        }
      }

      drawCube(canvas.width * 0.75, canvas.height * 0.32, 30, angle)
      drawBook(canvas.width * 0.22, canvas.height * 0.7, angle * 0.8)
      animId = requestAnimationFrame(animate)
    }

    animate()
    return () => {
      cancelAnimationFrame(animId)
      window.removeEventListener("resize", resize)
    }
  }, [])

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full"
      style={{ zIndex: 0 }}
    />
  )
}

/* ─── Floating SVG Shapes ─────────────────────────────────── */
function FloatingShapes() {
  return (
    <>
      {/* Triangle */}
      <svg
        className="absolute pointer-events-none"
        style={{
          width: 80, height: 80,
          top: "18%", right: "8%",
          zIndex: 1,
          animation: "float1 6s ease-in-out infinite",
        }}
        viewBox="0 0 80 80"
      >
        <polygon points="40,8 72,58 8,58" fill="none" stroke="rgba(167,139,250,0.55)" strokeWidth="1.5" />
        <polygon points="40,20 62,52 18,52" fill="rgba(109,40,217,0.15)" stroke="rgba(167,139,250,0.25)" strokeWidth="0.5" />
      </svg>

      {/* Square */}
      <svg
        className="absolute pointer-events-none"
        style={{
          width: 58, height: 58,
          bottom: "26%", left: "6%",
          zIndex: 1,
          animation: "float2 8s ease-in-out infinite",
        }}
        viewBox="0 0 60 60"
      >
        <rect x="10" y="10" width="40" height="40" rx="6" fill="none" stroke="rgba(129,200,255,0.45)" strokeWidth="1.5" transform="rotate(15 30 30)" />
        <rect x="16" y="16" width="28" height="28" rx="4" fill="rgba(59,130,246,0.1)" stroke="rgba(129,200,255,0.2)" strokeWidth="0.5" transform="rotate(15 30 30)" />
      </svg>

      {/* Circle */}
      <svg
        className="absolute pointer-events-none"
        style={{
          width: 48, height: 48,
          top: "54%", right: "12%",
          zIndex: 1,
          animation: "float3 7s ease-in-out infinite",
        }}
        viewBox="0 0 50 50"
      >
        <circle cx="25" cy="25" r="18" fill="none" stroke="rgba(196,181,253,0.45)" strokeWidth="1.5" />
        <circle cx="25" cy="25" r="10" fill="rgba(167,139,250,0.12)" stroke="rgba(196,181,253,0.25)" strokeWidth="0.5" />
      </svg>
    </>
  )
}

/* ─── Main Page ───────────────────────────────────────────── */
export default function LoginPage() {
  const router = useRouter()
  const { login, user } = useAuth()
  const [identifier, setIdentifier] = useState("")
  const [password, setPassword] = useState("")
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState("")
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    if (user) router.push("/dashboard")
  }, [user, router])

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    const result = await login(identifier, password)

    if (result.success) {
      router.push("/dashboard")
    } else {
      setError(result.error || "NIP/Email atau kata sandi salah. Silakan coba lagi.")
      setIsLoading(false)
    }
  }

  return (
    <>
      {/* Keyframe animations */}
      <style>{`
        @keyframes float1 {
          0%, 100% { transform: translateY(0) rotate(0deg); }
          50% { transform: translateY(-12px) rotate(5deg); }
        }
        @keyframes float2 {
          0%, 100% { transform: translateY(0) rotate(0deg); }
          50% { transform: translateY(10px) rotate(-8deg); }
        }
        @keyframes float3 {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-8px); }
        }
        @keyframes btnShine {
          0% { left: -100%; }
          50% { left: 150%; }
          100% { left: 150%; }
        }
      `}</style>

      <div className="min-h-screen w-full flex flex-col lg:flex-row font-sans bg-slate-50">

        {/* ── LEFT PANEL ── */}
        <div
          className="hidden lg:flex lg:w-[46%] relative overflow-hidden flex-col justify-between p-12"
          style={{ background: "#1c67b1ff" }}
        >
          <ParticleCanvas />
          <FloatingShapes />

          {/* Top: brand + tagline */}
          <div className="relative z-10 max-w-lg">
            <div className="flex items-center gap-2 mb-10">
              <div
                className="w-12 h-12 rounded-2xl flex items-center justify-center"
              >
                <img src="/src/satusekolah.png" alt="Satu Sekolah" className="w-12 h-12 object-contain" />
              </div>
              <span className="text-2xl font-semibold text-white tracking-tight">
                Satu Sekolah
              </span>
            </div>

            <h1
              className="text-4xl font-semibold leading-snug mb-4 text-white tracking-tight"
              style={{ letterSpacing: "-0.5px" }}
            >
              Transformasi{" "}
              <span style={{ color: "#FFC439" }}>Digital</span>
              <br />
              Pendidikan Indonesia
            </h1>
            <p className="text-sm leading-relaxed" style={{ color: "rgba(255,255,255,0.68)" }}>
              Satu portal terintegrasi untuk guru, siswa, dan orang tua.
              Sistem yang cerdas, aman, dan mutakhir.
            </p>

            {/* Stats */}
            <div className="flex gap-8 mt-8">
              {[
                { num: "1.0", label: "Versi" },
                { num: "100+", label: "Pengguna" },
                { num: "99.9%", label: "Uptime" },
              ].map(({ num, label }) => (
                <div key={label}>
                  <div className="text-xl font-semibold text-white">{num}</div>
                  <div className="text-xs mt-0.5" style={{ color: "rgba(255,255,255,0.78)" }}>
                    {label}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Bottom: security badge */}
          <div
            className="relative z-10 flex items-center gap-3 text-xs"
            style={{ color: "rgba(255,255,255,0.72)" }}
          >
            <div
              className="w-8 h-8 rounded-full flex items-center justify-center"
              style={{ background: "#0f0533" }}
            >
              <ShieldCheck className="w-4 h-4" style={{ color: "#a78bfa" }} />
            </div>
            Sistem dilindungi enkripsi end-to-end &amp; kriptografi blockchain
          </div>
        </div>

        {/* ── RIGHT PANEL ── */}
        <div className="flex-1 min-h-screen lg:min-h-0 flex flex-col items-center justify-center p-6 sm:p-12 relative bg-white">

          {/* Mobile logo */}
          <div className="absolute top-8 left-8 lg:hidden flex items-center gap-1.5">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center">
              <img src="/src/satusekolah.png" alt="Satu Sekolah" className="w-10 h-10 object-contain" />
            </div>
            <span className="text-lg font-semibold text-slate-800 tracking-tight">Satu Sekolah</span>
          </div>

          <div className="w-full max-w-[400px] mt-16 lg:mt-0">

            {/* Heading */}
            <div className="mb-8 text-center lg:text-left">
              <h2 className="text-3xl font-semibold text-slate-900 tracking-tight mb-1.5">
                Selamat datang 👋
              </h2>
              <p className="text-sm text-slate-500">
                Masukkan kredensial Anda untuk melanjutkan ke dashboard.
              </p>
            </div>

            {/* Error */}
            {error && (
              <div className="flex items-start gap-3 p-3.5 mb-6 text-sm text-red-600 bg-red-50 rounded-xl border border-red-100">
                <AlertCircle className="h-4 w-4 shrink-0 mt-0.5 text-red-500" />
                <p>{error}</p>
              </div>
            )}

            {/* Form */}
            <form onSubmit={handleLogin} className="space-y-5">

              {/* Identifier */}
              <div className="space-y-1.5">
                <label className="block text-[11px] font-semibold text-slate-500 uppercase tracking-widest">
                  Email / Username / NPK
                </label>
                <div className="relative group">
                  <User
                    className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 transition-colors duration-200 group-focus-within:text-violet-600"
                  />
                  <Input
                    required
                    value={identifier}
                    onChange={e => setIdentifier(e.target.value)}
                    placeholder="Masukkan identitas Anda"
                    className="pl-10 h-12 bg-slate-50 border-slate-200 hover:border-slate-300 focus:bg-white focus:border-violet-500 focus:ring-2 focus:ring-violet-500/10 rounded-xl text-sm text-slate-800 placeholder:text-slate-400 transition-all"
                  />
                </div>
              </div>

              {/* Password */}
              <div className="space-y-1.5">
                <div className="flex items-center justify-between">
                  <label className="block text-[11px] font-semibold text-slate-500 uppercase tracking-widest">
                    Kata Sandi
                  </label>
                  <a
                    href="#"
                    className="text-xs font-semibold text-violet-600 hover:text-violet-800 hover:underline transition-colors"
                  >
                    Lupa sandi?
                  </a>
                </div>
                <div className="relative group">
                  <Lock
                    className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 transition-colors duration-200 group-focus-within:text-violet-600"
                  />
                  <Input
                    required
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="pl-10 pr-10 h-12 bg-slate-50 border-slate-200 hover:border-slate-300 focus:bg-white focus:border-violet-500 focus:ring-2 focus:ring-violet-500/10 rounded-xl text-sm text-slate-800 placeholder:text-slate-400 transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(v => !v)}
                    className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
                    tabIndex={-1}
                    aria-label={showPassword ? "Sembunyikan sandi" : "Tampilkan sandi"}
                  >
                    {showPassword
                      ? <EyeOff className="h-4 w-4" />
                      : <Eye className="h-4 w-4" />
                    }
                  </button>
                </div>
              </div>

              {/* Remember me */}
              <label className="flex items-center gap-2.5 cursor-pointer group">
                <input
                  type="checkbox"
                  className="w-4 h-4 rounded border-slate-300 text-violet-600 focus:ring-violet-500/20 focus:ring-offset-0 accent-violet-600"
                />
                <span className="text-sm text-slate-600 group-hover:text-slate-900 transition-colors">
                  Ingat saya di perangkat ini
                </span>
              </label>

              {/* Submit */}
              <Button
                type="submit"
                disabled={isLoading}
                className="relative w-full h-12 text-sm font-semibold text-white cursor-pointer rounded-xl overflow-hidden transition-all hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-70 disabled:hover:translate-y-0"
                style={{
                  background: "linear-gradient(135deg, #4b25bbff 0%, #1a0760ff 100%)",
                  boxShadow: "0 4px 20px rgba(109,40,217,0.3)",
                }}
              >
                {/* Shine animation */}
                {!isLoading && (
                  <span
                    className="absolute top-0 h-full w-[55%] pointer-events-none"
                    style={{
                      background: "linear-gradient(90deg,transparent,rgba(255,255,255,0.14),transparent)",
                      animation: "btnShine 2.8s ease-in-out infinite",
                    }}
                  />
                )}

                {isLoading ? (
                  <span className="flex items-center justify-center gap-2.5">
                    <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Memverifikasi...
                  </span>
                ) : (
                  <span className="flex items-center justify-center gap-2">
                    Masuk ke Dashboard
                    <ArrowRight className="w-4 h-4" />
                  </span>
                )}
              </Button>
            </form>
          </div>

          {/* Footer */}
          <div className="absolute bottom-6 w-full text-center px-6">
            <p className="text-xs text-slate-400">
              Sistem Satu Sekolah &copy; {new Date().getFullYear()} Neura Cakrawira Solusi
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
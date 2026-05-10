"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { 
  Monitor, 
  BookOpen, 
  FileCheck, 
  Users, 
  PlayCircle,
  ArrowRight
} from "lucide-react"

export default function LMSPage() {
  const courses = [
    { title: "Pemrograman Web Dasar", students: 36, tasks: 12, progress: 85, color: "brand-blue" },
    { title: "Basis Data XII", students: 34, tasks: 8, progress: 60, color: "brand-green" },
    { title: "Project Kreatif & Kewirausahaan", students: 36, tasks: 15, progress: 45, color: "brand-purple" },
  ]

  return (
    <div className="space-y-6 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Monitoring LMS</h1>
          <p className="text-muted-foreground mt-1">Pantau aktivitas pembelajaran dan tugas siswa</p>
        </div>
        <Button className="bg-brand-blue hover:bg-brand-blue/90">
          <BookOpen className="w-4 h-4 mr-2" />
          Kelola Materi
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {courses.map((course, i) => (
          <Card key={i} className="border-none shadow-md hover:shadow-lg transition-all group overflow-hidden bg-white">
            <div className={`h-1.5 w-full bg-${course.color}`}></div>
            <CardHeader>
              <div className={`w-10 h-10 rounded-lg bg-${course.color}/10 flex items-center justify-center mb-4`}>
                <PlayCircle className={`w-6 h-6 text-${course.color}`} />
              </div>
              <CardTitle className="text-lg font-bold group-hover:text-brand-blue transition-colors">
                {course.title}
              </CardTitle>
              <CardDescription>Aktif Semester Ganjil 2026</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex justify-between text-xs font-medium">
                  <span className="text-muted-foreground">Progres Materi</span>
                  <span className={`text-${course.color}`}>{course.progress}%</span>
                </div>
                <div className="w-full bg-slate-100 rounded-full h-1.5">
                  <div 
                    className={`bg-${course.color} h-1.5 rounded-full transition-all duration-1000`} 
                    style={{ width: `${course.progress}%` }}
                  ></div>
                </div>
                <div className="grid grid-cols-2 gap-4 pt-2">
                  <div className="flex items-center gap-2">
                    <Users className="w-4 h-4 text-slate-400" />
                    <span className="text-xs font-bold text-slate-700">{course.students} Siswa</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <FileCheck className="w-4 h-4 text-slate-400" />
                    <span className="text-xs font-bold text-slate-700">{course.tasks} Tugas</span>
                  </div>
                </div>
                <Button variant="ghost" className="w-full mt-2 justify-between hover:bg-slate-50 text-brand-blue font-bold">
                  Lihat Detail
                  <ArrowRight className="w-4 h-4" />
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
      
      <Card className="border-none shadow-md">
        <CardHeader>
          <CardTitle className="text-lg">Tugas Perlu Dinilai</CardTitle>
          <CardDescription>5 tugas baru dikumpulkan hari ini</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[1, 2, 3].map((_, i) => (
              <div key={i} className="flex items-center justify-between p-4 rounded-xl border border-slate-100 hover:border-brand-blue/20 transition-colors">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center">
                    <FileCheck className="w-5 h-5 text-slate-400" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800">Tugas Praktikum 3 - Form Validation</h4>
                    <p className="text-xs text-muted-foreground">Oleh: <span className="font-medium text-slate-600">Siswa {i+1}</span> • 2 jam yang lalu</p>
                  </div>
                </div>
                <Button size="sm" variant="outline" className="text-xs font-bold border-brand-blue/20 text-brand-blue">
                  Beri Nilai
                </Button>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

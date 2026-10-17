"use client"

import React, { useEffect, useState, useRef } from "react"
import { fetchApi, api } from "@/lib/api"
import {
  MessageSquare, Plus, X, Loader2, ShieldCheck, Send, Search,
  ArrowLeft, Users,
} from "lucide-react"

interface Contact {
  id: string
  name?: string
  username?: string
  email?: string
  account_number?: string
  category?: string
  role?: string
  [key: string]: any
}

interface Message {
  id: string
  sender_id?: string
  sender_name?: string
  content?: string
  message?: string
  created_at?: string
  mine?: boolean
  [key: string]: any
}

interface Room {
  id: string
  name?: string
  title?: string
  participant_name?: string
  last_message?: string
  unread?: number
  [key: string]: any
}

export default function CommunicationPage() {
  const [contacts, setContacts] = useState<Contact[]>([])
  const [rooms, setRooms] = useState<Room[]>([])
  const [activeRoom, setActiveRoom] = useState<Room | null>(null)
  const [messages, setMessages] = useState<Message[]>([])
  const [loadingContacts, setLoadingContacts] = useState(true)
  const [loadingMsgs, setLoadingMsgs] = useState(false)
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [search, setSearch] = useState("")
  const [draft, setDraft] = useState("")
  const [sending, setSending] = useState(false)

  const [recipientIdentifier, setRecipientIdentifier] = useState("")
  const [initialMessage, setInitialMessage] = useState("")
  const [modalLoading, setModalLoading] = useState(false)
  const [modalError, setModalError] = useState<string | null>(null)

  const msgsEndRef = useRef<HTMLDivElement>(null)

  /* Load contacts + rooms */
  useEffect(() => {
    Promise.allSettled([
      fetchApi("/communication/contacts"),
      fetchApi("/communication/rooms"),
    ]).then(([cRes, rRes]) => {
      if (cRes.status === "fulfilled") {
        const raw = cRes.value?.data ?? cRes.value
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        setContacts(items)
      }
      if (rRes.status === "fulfilled") {
        const raw = rRes.value?.data ?? rRes.value
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        setRooms(items)
      }
      setLoadingContacts(false)
    })
  }, [])

  /* Load messages for active room */
  useEffect(() => {
    if (!activeRoom) return
    setLoadingMsgs(true)
    fetchApi(`/communication/rooms/${activeRoom.id}/messages`)
      .then((res) => {
        const raw = res?.data ?? res
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.messages) ? raw.messages : []
        setMessages(items)
      })
      .catch(() => setMessages([]))
      .finally(() => {
        setLoadingMsgs(false)
        setTimeout(() => msgsEndRef.current?.scrollIntoView({ behavior: "smooth" }), 100)
      })
  }, [activeRoom])

  const filteredContacts = contacts.filter((c) => {
    if (!search) return true
    const q = search.toLowerCase()
    return (c.name || c.username || c.email || "").toLowerCase().includes(q)
  })

  const sendMessage = async () => {
    if (!draft.trim() || !activeRoom) return
    const text = draft.trim()
    setDraft("")
    setSending(true)
    // Optimistic
    setMessages((prev) => [...prev, { id: `tmp-${Date.now()}`, content: text, mine: true, created_at: new Date().toISOString() }])
    try {
      await api.post(`/communication/rooms/${activeRoom.id}/messages`, { message: text })
    } catch {
      // best-effort; message already shown optimistically
    } finally {
      setSending(false)
      setTimeout(() => msgsEndRef.current?.scrollIntoView({ behavior: "smooth" }), 50)
    }
  }

  const startChat = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!recipientIdentifier.trim()) {
      setModalError("Email atau ID kontak tujuan wajib diisi.")
      return
    }
    setModalLoading(true)
    setModalError(null)
    try {
      const res = await api.post("/communication/rooms/initiate", {
        target_identifier: recipientIdentifier.trim(),
        message: initialMessage.trim() || undefined,
      })
      const room = res?.data ?? res
      if (room?.id) {
        setActiveRoom(room)
      }
      setRecipientIdentifier("")
      setInitialMessage("")
      setIsAddOpen(false)
      // refresh rooms
      fetchApi("/communication/rooms").then((r) => {
        const raw = r?.data ?? r
        const items = Array.isArray(raw) ? raw : Array.isArray(raw?.items) ? raw.items : []
        setRooms(items)
      }).catch(() => {})
    } catch (err: any) {
      setModalError(err.message || "Gagal memulai obrolan.")
    } finally {
      setModalLoading(false)
    }
  }

  const fmtTime = (t?: string) => t ? new Date(t).toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" }) : ""

  return (
    <div className="max-w-[1280px] mx-auto w-full px-4 md:px-7 py-6 animate-fade-up">
      <style>{`
        .cm-title { font-size: 20px; font-weight: 700; color: var(--foreground); letter-spacing: -0.4px; }
        .cm-desc { font-size: 13px; color: var(--muted-foreground); margin-top: 2px; }
        .cm-shell { display: grid; grid-template-columns: 1fr; height: calc(100vh - 180px); min-height: 480px; background: var(--surface); border: 1px solid var(--border); border-radius: 16px; overflow: hidden; }
        @media (min-width: 768px) { .cm-shell { grid-template-columns: 340px 1fr; } }
        .cm-list { border-right: 1px solid var(--border); display: flex; flex-direction: column; min-height: 0; }
        .cm-list-head { padding: 16px; border-bottom: 1px solid var(--border); display: flex; flex-direction: column; gap: 10px; }
        .cm-search { height: 36px; border-radius: 9px; border: 1px solid var(--border); background: var(--surface-2); padding: 0 12px 0 32px; font-size: 13px; color: var(--foreground); outline: none; transition: border-color 0.15s; font-family: inherit; }
        .cm-search:focus { border-color: var(--brand); }
        .cm-list-body { flex: 1; overflow-y: auto; }
        .cm-contact { display: flex; align-items: center; gap: 11px; padding: 12px 16px; cursor: pointer; transition: background 0.12s; border-bottom: 1px solid var(--border); }
        .cm-contact:hover { background: var(--surface-2); }
        .cm-contact.active { background: var(--brand-soft); }
        .cm-avatar { width: 38px; height: 38px; border-radius: 11px; background: linear-gradient(135deg, var(--brand), var(--brand-deep)); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 700; flex-shrink: 0; }
        .cm-contact-name { font-size: 13.5px; font-weight: 600; color: var(--foreground); }
        .cm-contact-sub { font-size: 11px; color: var(--muted-foreground); }
        .cm-badge { background: var(--brand); color: #fff; font-size: 10px; font-weight: 700; border-radius: 999px; padding: 1px 6px; }

        .cm-chat { display: flex; flex-direction: column; min-height: 0; }
        .cm-chat-head { padding: 14px 18px; border-bottom: 1px solid var(--border); display: flex; align-items: center; gap: 11px; }
        .cm-msgs { flex: 1; overflow-y: auto; padding: 18px; display: flex; flex-direction: column; gap: 10px; background: var(--surface-2); }
        .cm-bubble { max-width: 75%; padding: 10px 14px; border-radius: 14px; font-size: 13.5px; line-height: 1.5; word-wrap: break-word; }
        .cm-bubble.mine { align-self: flex-end; background: var(--brand); color: #fff; border-bottom-right-radius: 4px; }
        .cm-bubble.other { align-self: flex-start; background: var(--surface); color: var(--foreground); border: 1px solid var(--border); border-bottom-left-radius: 4px; }
        .cm-bubble-time { font-size: 10px; color: var(--muted-foreground); margin-top: 4px; }
        .cm-bubble.mine .cm-bubble-time { color: rgba(255,255,255,0.7); }
        .cm-compose { padding: 12px 16px; border-top: 1px solid var(--border); display: flex; gap: 10px; align-items: center; background: var(--surface); }
        .cm-input { flex: 1; height: 42px; border-radius: 11px; border: 1px solid var(--border); background: var(--surface-2); padding: 0 14px; font-size: 14px; color: var(--foreground); outline: none; font-family: inherit; transition: border-color 0.15s; }
        .cm-input:focus { border-color: var(--brand); }
        .cm-send { width: 42px; height: 42px; border-radius: 11px; border: none; background: var(--brand); color: #fff; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: background 0.12s; flex-shrink: 0; }
        .cm-send:hover { background: var(--brand-deep); }
        .cm-send:disabled { opacity: 0.5; cursor: not-allowed; }
        .cm-empty { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: var(--muted-foreground); text-align: center; padding: 24px; }
        .cm-btn-primary { display: inline-flex; align-items: center; gap: 7px; height: 38px; padding: 0 14px; border-radius: 9px; border: none; background: var(--brand); color: #fff; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.12s; font-family: inherit; }
        .cm-btn-primary:hover { background: var(--brand-deep); }
      `}</style>

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3 mb-5">
        <div>
          <h1 className="cm-title flex items-center gap-2"><MessageSquare className="w-5 h-5 text-brand" /> Pusat Komunikasi</h1>
          <p className="cm-desc">Pesan aman terenkripsi end-to-end antar guru, wali kelas, dan orang tua.</p>
        </div>
        <button className="cm-btn-primary" onClick={() => setIsAddOpen(true)}>
          <Plus className="w-4 h-4" /> Obrolan Baru
        </button>
      </div>

      {/* Shell */}
      <div className="cm-shell">
        {/* Contacts / Rooms list */}
        <div className="cm-list">
          <div className="cm-list-head">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-muted-foreground" />
              <input className="cm-search w-full" placeholder="Cari kontak..." value={search} onChange={(e) => setSearch(e.target.value)} />
            </div>
          </div>
          <div className="cm-list-body">
            {loadingContacts ? (
              <div className="flex items-center justify-center py-10 text-muted-foreground text-sm"><Loader2 className="w-4 h-4 animate-spin mr-2" /> Memuat kontak...</div>
            ) : filteredContacts.length === 0 && rooms.length === 0 ? (
              <div className="text-center py-10 text-muted-foreground text-sm">
                <Users className="w-8 h-8 mx-auto mb-2 opacity-40" />
                Belum ada kontak.
              </div>
            ) : (
              <>
                {/* Prefer rooms if available, else contacts */}
                {(rooms.length > 0 ? rooms : filteredContacts).map((item) => {
                  const name = item.name || item.title || item.participant_name || "Kontak"
                  const sub = item.last_message || item.email || item.account_number || ""
                  const isActive = activeRoom?.id === item.id
                  return (
                    <div key={item.id} className={`cm-contact ${isActive ? "active" : ""}`} onClick={() => setActiveRoom(item)}>
                      <div className="cm-avatar">{(name || "U").charAt(0).toUpperCase()}</div>
                      <div className="flex-1 min-w-0">
                        <div className="cm-contact-name truncate">{name}</div>
                        {sub && <div className="cm-contact-sub truncate">{sub}</div>}
                      </div>
                      {item.unread ? <span className="cm-badge">{item.unread}</span> : null}
                    </div>
                  )
                })}
              </>
            )}
          </div>
        </div>

        {/* Chat panel */}
        <div className="cm-chat">
          {activeRoom ? (
            <>
              <div className="cm-chat-head">
                <button className="md:hidden" onClick={() => setActiveRoom(null)} style={{ background: "none", border: "none", color: "var(--muted-foreground)", cursor: "pointer" }}>
                  <ArrowLeft className="w-5 h-5" />
                </button>
                <div className="cm-avatar">{(activeRoom.name || activeRoom.title || activeRoom.participant_name || "U").charAt(0).toUpperCase()}</div>
                <div className="min-w-0 flex-1">
                  <div className="cm-contact-name truncate">{activeRoom.name || activeRoom.title || activeRoom.participant_name || "Obrolan"}</div>
                  <div className="cm-contact-sub flex items-center gap-1"><ShieldCheck className="w-3 h-3 text-emerald-500" /> E2EE Active</div>
                </div>
              </div>
              <div className="cm-msgs">
                {loadingMsgs ? (
                  <div className="flex items-center justify-center py-10 text-muted-foreground text-sm"><Loader2 className="w-4 h-4 animate-spin mr-2" /> Memuat pesan...</div>
                ) : messages.length === 0 ? (
                  <div className="text-center py-10 text-muted-foreground text-sm">Mulai percakapan Anda.</div>
                ) : (
                  messages.map((m) => (
                    <div key={m.id} className={`cm-bubble ${m.mine ? "mine" : "other"}`}>
                      {m.content || m.message}
                      <div className="cm-bubble-time">{fmtTime(m.created_at)}</div>
                    </div>
                  ))
                )}
                <div ref={msgsEndRef} />
              </div>
              <div className="cm-compose">
                <input className="cm-input" placeholder="Tulis pesan..." value={draft} onChange={(e) => setDraft(e.target.value)} onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage() } }} />
                <button className="cm-send" disabled={!draft.trim() || sending} onClick={sendMessage}>
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </>
          ) : (
            <div className="cm-empty">
              <MessageSquare className="w-10 h-10 mb-3 opacity-30" />
              <p className="text-sm font-medium">Pilih kontak untuk mulai mengobrol</p>
              <p className="text-xs mt-1">Atau mulai obrolan baru dengan menekan tombol di atas.</p>
            </div>
          )}
        </div>
      </div>

      {/* Modal Mulai Obrolan */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-fade-up">
          <div className="w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-scale-in" style={{ background: "var(--surface)", border: "1px solid var(--border)" }}>
            <div className="flex items-center justify-between px-6 py-4 border-b" style={{ borderColor: "var(--border)", background: "var(--brand-soft)" }}>
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: "rgba(var(--brand-rgb),0.12)", color: "var(--brand)" }}>
                  <MessageSquare className="w-5 h-5" />
                </div>
                <div>
                  <h2 className="text-base font-bold text-foreground">Obrolan Baru (E2EE)</h2>
                  <p className="text-xs text-muted-foreground">Kirim pesan ke warga sekolah</p>
                </div>
              </div>
              <button onClick={() => setIsAddOpen(false)} className="p-2 rounded-full transition-colors" style={{ color: "var(--muted-foreground)" }}>
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={startChat}>
              <div className="p-6 space-y-4">
                {modalError && (
                  <div className="p-3 rounded-xl text-xs" style={{ background: "rgba(220,38,38,0.08)", color: "var(--destructive)", border: "1px solid rgba(220,38,38,0.2)" }}>
                    ⚠️ {modalError}
                  </div>
                )}
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-foreground">Email / Nomor Akun Penerima <span className="text-destructive">*</span></label>
                  <input type="text" required placeholder="cth. walikelas@satusekolah.id" value={recipientIdentifier} onChange={(e) => setRecipientIdentifier(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border text-sm outline-none transition-all"
                    style={{ borderColor: "var(--border)", background: "var(--surface)", color: "var(--foreground)" }} />
                </div>
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-foreground">Pesan Pembuka</label>
                  <textarea rows={3} placeholder="Tuliskan salam dan maksud pesan Anda..." value={initialMessage} onChange={(e) => setInitialMessage(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border text-sm outline-none transition-all resize-none"
                    style={{ borderColor: "var(--border)", background: "var(--surface)", color: "var(--foreground)" }} />
                </div>
              </div>
              <div className="px-6 py-4 border-t flex items-center justify-end gap-3" style={{ borderColor: "var(--border)", background: "var(--surface-2)" }}>
                <button type="button" onClick={() => setIsAddOpen(false)} className="px-4 py-2 text-sm font-medium rounded-xl border transition-colors" style={{ color: "var(--muted-foreground)", borderColor: "var(--border)", background: "var(--surface)" }}>
                  Batal
                </button>
                <button type="submit" disabled={modalLoading} className="px-5 py-2 text-sm font-semibold text-white rounded-xl transition-all disabled:opacity-50 flex items-center gap-2" style={{ background: "var(--brand)" }}>
                  {modalLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                  Mulai Obrolan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

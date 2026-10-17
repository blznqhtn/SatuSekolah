"use client"

import React, { useEffect, useState, useMemo } from "react"
import { fetchApi } from "@/lib/api"
import {
  Search, Plus, Filter, AlertCircle, RefreshCw,
  ChevronUp, ChevronDown, X, SlidersHorizontal, ChevronLeft, ChevronRight,
} from "lucide-react"

export interface ColumnDef<T = any> {
  key: string
  label: string
  sortable?: boolean
  render?: (item: T, index: number) => React.ReactNode
}

export interface TabDef {
  label: string
  value: string
}

export interface DataTableTemplateProps {
  moduleName: string
  endpoint?: string
  description?: string
  columns?: ColumnDef[]
  tabs?: TabDef[]
  categoryKey?: string
  onAddClick?: () => void
  addLabel?: string
  hideAddButton?: boolean
  headerActions?: React.ReactNode
  refreshTrigger?: number
  customData?: any[]
  onRefresh?: () => void
  pageSize?: number
}

export function DataTableTemplate({
  moduleName,
  endpoint,
  description,
  columns = [],
  tabs = [],
  categoryKey = "category",
  onAddClick,
  addLabel = "Tambah Data",
  hideAddButton = false,
  headerActions,
  refreshTrigger,
  customData,
  onRefresh,
  pageSize,
}: DataTableTemplateProps) {
  const [data, setData] = useState<any[]>(customData || [])
  const [isLoading, setIsLoading] = useState(!customData && !!endpoint)
  const [error, setError] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState("")
  const [isFilterOpen, setIsFilterOpen] = useState(false)
  const [activeTab, setActiveTab] = useState(tabs.length > 0 ? tabs[0].value : "")
  const [sortConfig, setSortConfig] = useState<{ key: string; direction: "asc" | "desc" } | null>(null)
  const [page, setPage] = useState(1)

  const loadData = async () => {
    if (onRefresh) {
      onRefresh()
    }
    if (customData) {
      setData(customData)
      setIsLoading(false)
      return
    }
    if (!endpoint) {
      setIsLoading(false)
      return
    }
    setIsLoading(true)
    setError(null)
    try {
      const res = await fetchApi(endpoint)
      const raw = res?.data ?? res
      let items: any[] = []
      if (Array.isArray(raw)) {
        items = raw
      } else if (raw && Array.isArray(raw.items)) {
        items = raw.items
      } else if (raw && Array.isArray(raw.records)) {
        items = raw.records
      } else if (raw && Array.isArray(raw.data)) {
        items = raw.data
      }
      setData(items)
    } catch (err: any) {
      setError(err.message || "Gagal memuat data dari server.")
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    if (customData) {
      setData(customData)
      setIsLoading(false)
    } else {
      loadData()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [endpoint, refreshTrigger, customData])

  const handleSort = (key: string) => {
    let direction: "asc" | "desc" = "asc"
    if (sortConfig?.key === key && sortConfig.direction === "asc") direction = "desc"
    setSortConfig({ key, direction })
  }

  const processedData = useMemo(() => {
    let filtered = [...data]
    if (activeTab && activeTab !== "all") {
      filtered = filtered.filter(item =>
        String(item[categoryKey] || "").toLowerCase() === activeTab.toLowerCase()
      )
    }
    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      filtered = filtered.filter(item =>
        Object.values(item).some(v => String(v).toLowerCase().includes(q))
      )
    }
    if (sortConfig) {
      filtered.sort((a, b) => {
        const av = a[sortConfig.key], bv = b[sortConfig.key]
        if (av < bv) return sortConfig.direction === "asc" ? -1 : 1
        if (av > bv) return sortConfig.direction === "asc" ? 1 : -1
        return 0
      })
    }
    return filtered
  }, [data, activeTab, searchQuery, sortConfig, categoryKey])

  /* Pagination */
  const usePagination = !!pageSize && processedData.length > pageSize
  const totalPages = usePagination ? Math.ceil(processedData.length / pageSize!) : 1
  const currentPage = Math.min(page, totalPages)
  const pagedData = usePagination
    ? processedData.slice((currentPage - 1) * pageSize!, currentPage * pageSize!)
    : processedData

  useEffect(() => { setPage(1) }, [searchQuery, activeTab, sortConfig])

  const colCount = columns.length || 3

  return (
    <>
      <style>{`
        .dt-root {
          padding: 24px 28px;
          max-width: 1280px;
          margin: 0 auto;
          width: 100%;
          animation: ssFadeUp 0.35s ease both;
        }
        @media (max-width: 768px) { .dt-root { padding: 16px 12px; } }

        .dt-header {
          display: flex; flex-direction: column; gap: 16px; margin-bottom: 22px;
        }
        @media (min-width: 640px) {
          .dt-header { flex-direction: row; align-items: flex-end; justify-content: space-between; }
        }

        .dt-title { font-size: 20px; font-weight: 700; color: var(--foreground); letter-spacing: -0.4px; margin-bottom: 3px; }
        .dt-desc { font-size: 13px; color: var(--muted-foreground); line-height: 1.5; }

        .dt-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }

        .dt-btn-icon {
          width: 36px; height: 36px; border-radius: 9px;
          border: 1px solid var(--border); background: var(--surface); color: var(--muted-foreground);
          display: flex; align-items: center; justify-content: center; cursor: pointer;
          transition: background 0.12s, color 0.12s, border-color 0.12s; flex-shrink: 0;
        }
        .dt-btn-icon:hover { background: rgba(var(--brand-rgb), 0.06); color: var(--brand); border-color: rgba(var(--brand-rgb), 0.3); }

        .dt-btn-primary {
          display: flex; align-items: center; gap: 7px;
          padding: 0 16px; height: 36px; border-radius: 9px; border: none;
          background: var(--brand); color: #fff; font-size: 13px; font-weight: 600;
          cursor: pointer; transition: background 0.12s, box-shadow 0.12s, transform 0.12s;
          box-shadow: 0 2px 10px rgba(var(--brand-rgb), 0.28);
          white-space: nowrap; font-family: inherit;
        }
        .dt-btn-primary:hover { background: var(--brand-deep); box-shadow: 0 4px 16px rgba(var(--brand-rgb), 0.36); transform: translateY(-1px); }

        .dt-tabs {
          display: flex; align-items: center; gap: 2px;
          border-bottom: 1px solid var(--border); margin-bottom: 18px;
          overflow-x: auto; scrollbar-width: none;
        }
        .dt-tabs::-webkit-scrollbar { display: none; }

        .dt-tab {
          padding: 9px 14px; font-size: 13px; font-weight: 500; color: var(--muted-foreground);
          border: none; background: transparent; border-bottom: 2px solid transparent;
          cursor: pointer; white-space: nowrap; transition: color 0.12s, border-color 0.12s;
          margin-bottom: -1px; font-family: inherit;
        }
        .dt-tab:hover { color: var(--brand); }
        .dt-tab.active { color: var(--brand); border-bottom-color: var(--brand); font-weight: 600; }

        .dt-toolbar { display: flex; flex-direction: column; gap: 10px; margin-bottom: 16px; }
        @media (min-width: 640px) { .dt-toolbar { flex-direction: row; align-items: center; } }

        .dt-search-wrap { position: relative; flex: 1; max-width: 380px; }
        .dt-search-icon {
          position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
          color: var(--muted-foreground); pointer-events: none; width: 14px; height: 14px; transition: color 0.12s;
        }
        .dt-search-wrap:focus-within .dt-search-icon { color: var(--brand); }

        .dt-search-input {
          width: 100%; height: 36px; border: 1px solid var(--border); border-radius: 9px;
          background: var(--surface); padding: 0 32px 0 33px; font-size: 13px; color: var(--foreground);
          outline: none; transition: border-color 0.15s, box-shadow 0.15s; font-family: inherit;
          box-shadow: 0 1px 3px rgba(0,0,0,0.03);
        }
        .dt-search-input::placeholder { color: var(--muted-foreground); }
        .dt-search-input:focus { border-color: rgba(var(--brand-rgb), 0.4); box-shadow: 0 0 0 3px rgba(var(--brand-rgb), 0.1); }
        .dt-search-input:disabled { opacity: 0.5; cursor: not-allowed; }

        .dt-search-clear {
          position: absolute; right: 9px; top: 50%; transform: translateY(-50%);
          background: none; border: none; cursor: pointer; color: var(--muted-foreground);
          display: flex; padding: 2px; border-radius: 4px; transition: color 0.12s;
        }
        .dt-search-clear:hover { color: var(--brand); }

        .dt-filter-btn {
          display: flex; align-items: center; gap: 6px; padding: 0 14px; height: 36px;
          border-radius: 9px; border: 1px solid var(--border); font-size: 13px; font-weight: 500;
          cursor: pointer; transition: all 0.12s; font-family: inherit;
          background: var(--surface); color: var(--muted-foreground);
          box-shadow: 0 1px 3px rgba(0,0,0,0.03); white-space: nowrap;
        }
        .dt-filter-btn:hover, .dt-filter-btn.active {
          background: rgba(var(--brand-rgb), 0.07); color: var(--brand); border-color: rgba(var(--brand-rgb), 0.3);
        }

        .dt-filter-panel {
          margin-bottom: 16px; padding: 16px;
          background: var(--brand-soft); border: 1px solid rgba(var(--brand-rgb), 0.14);
          border-radius: 12px; animation: ssFadeUp 0.18s ease both;
        }
        .dt-filter-title { font-size: 11.5px; font-weight: 700; color: var(--brand); text-transform: uppercase; letter-spacing: 0.8px; margin-bottom: 12px; }
        .dt-filter-grid { display: grid; grid-template-columns: 1fr; gap: 10px; }
        @media (min-width: 768px) { .dt-filter-grid { grid-template-columns: 1fr 1fr 1fr; } }
        .dt-filter-select {
          width: 100%; height: 36px; padding: 0 10px; border-radius: 8px;
          border: 1px solid var(--border); background: var(--surface); font-size: 13px;
          color: var(--foreground); outline: none; cursor: pointer; font-family: inherit;
        }
        .dt-filter-apply {
          height: 36px; padding: 0 16px; border-radius: 8px; border: none;
          background: var(--brand); color: #fff; font-size: 13px; font-weight: 600;
          cursor: pointer; font-family: inherit; transition: background 0.12s;
        }
        .dt-filter-apply:hover { background: var(--brand-deep); }

        .dt-card {
          background: var(--surface); border: 1px solid var(--border);
          border-radius: 14px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }

        .dt-count {
          padding: 10px 18px; border-bottom: 1px solid var(--border);
          font-size: 12px; color: var(--muted-foreground);
          display: flex; align-items: center; gap: 6px;
        }
        .dt-count strong { color: var(--brand); font-weight: 700; }

        .dt-table-wrap { overflow-x: auto; }

        table.dt-table { width: 100%; border-collapse: collapse; font-size: 13px; text-align: left; }

        table.dt-table thead tr {
          background: var(--surface-2); border-bottom: 1px solid var(--border);
        }
        table.dt-table th {
          padding: 11px 18px; font-size: 10.5px; font-weight: 700; color: var(--muted-foreground);
          text-transform: uppercase; letter-spacing: 0.7px; white-space: nowrap; user-select: none;
        }
        table.dt-table th.sortable { cursor: pointer; }
        table.dt-table th.sortable:hover { color: var(--brand); background: rgba(var(--brand-rgb), 0.05); }
        table.dt-table th.sorted { color: var(--brand); }

        .dt-th-inner { display: flex; align-items: center; gap: 4px; }
        .dt-th-inner.right { justify-content: flex-end; }

        table.dt-table td {
          padding: 13px 18px; color: var(--foreground); border-bottom: 1px solid var(--border); vertical-align: middle;
        }
        table.dt-table tbody tr:last-child td { border-bottom: none; }
        table.dt-table tbody tr { transition: background 0.1s; }
        table.dt-table tbody tr:hover { background: rgba(var(--brand-rgb), 0.03); }

        .dt-state-cell { padding: 48px 24px; text-align: center; }
        .dt-state-icon {
          width: 48px; height: 48px; border-radius: 14px;
          display: flex; align-items: center; justify-content: center; margin: 0 auto 14px;
        }
        .dt-state-icon.error { background: rgba(220,38,38,0.1); color: var(--destructive); }
        .dt-state-icon.empty { background: rgba(var(--brand-rgb), 0.08); color: var(--brand); }

        .dt-state-title { font-size: 14px; font-weight: 600; color: var(--foreground); margin-bottom: 4px; }
        .dt-state-sub { font-size: 12.5px; color: var(--muted-foreground); max-width: 320px; margin: 0 auto; line-height: 1.5; }

        .dt-retry-btn {
          margin-top: 14px; display: inline-flex; align-items: center; gap: 6px;
          padding: 7px 16px; border-radius: 8px; border: 1px solid rgba(var(--brand-rgb), 0.25);
          background: transparent; color: var(--brand); font-size: 13px; font-weight: 500;
          cursor: pointer; font-family: inherit; transition: background 0.12s;
        }
        .dt-retry-btn:hover { background: rgba(var(--brand-rgb), 0.06); }

        .dt-skel {
          border-radius: 6px;
          background: linear-gradient(90deg, var(--surface-2) 25%, var(--border) 50%, var(--surface-2) 75%);
          background-size: 200% 100%; animation: ssShimmer 1.4s ease infinite; height: 14px;
        }

        .dt-pagination {
          display: flex; align-items: center; justify-content: space-between;
          padding: 12px 18px; border-top: 1px solid var(--border);
          font-size: 12.5px; color: var(--muted-foreground);
        }
        .dt-page-btns { display: flex; align-items: center; gap: 4px; }
        .dt-page-btn {
          width: 30px; height: 30px; border-radius: 7px; border: 1px solid var(--border);
          background: var(--surface); color: var(--muted-foreground); cursor: pointer;
          display: flex; align-items: center; justify-content: center; transition: all 0.12s; font-family: inherit;
        }
        .dt-page-btn:hover:not(:disabled) { background: rgba(var(--brand-rgb), 0.07); color: var(--brand); }
        .dt-page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
        .dt-page-btn.active { background: var(--brand); color: #fff; border-color: var(--brand); }
      `}</style>

      <div className="dt-root">

        {/* ── Header ── */}
        <div className="dt-header">
          <div>
            <h1 className="dt-title">{moduleName}</h1>
            <p className="dt-desc">
              {description || `Kelola data ${moduleName.toLowerCase()} dengan mudah.`}
            </p>
          </div>
          <div className="dt-actions">
            {headerActions}
            <button className="dt-btn-icon" onClick={loadData} title="Refresh data" aria-label="Refresh">
              <RefreshCw className={`w-4 h-4 ${isLoading ? "animate-spin" : ""}`} />
            </button>
            {!hideAddButton && onAddClick && (
              <button className="dt-btn-primary" onClick={onAddClick}>
                <Plus className="w-3.5 h-3.5" />
                {addLabel}
              </button>
            )}
          </div>
        </div>

        {/* ── Tabs ── */}
        {tabs.length > 0 && (
          <div className="dt-tabs">
            {tabs.map(tab => (
              <button key={tab.value} className={`dt-tab ${activeTab === tab.value ? "active" : ""}`} onClick={() => setActiveTab(tab.value)}>
                {tab.label}
              </button>
            ))}
          </div>
        )}

        {/* ── Toolbar ── */}
        <div className="dt-toolbar">
          <div className="dt-search-wrap">
            <Search className="dt-search-icon" />
            <input type="text" className="dt-search-input" placeholder="Cari data..." value={searchQuery} onChange={e => setSearchQuery(e.target.value)} disabled={isLoading} />
            {searchQuery && (
              <button className="dt-search-clear" onClick={() => setSearchQuery("")} aria-label="Hapus pencarian">
                <X style={{ width: 12, height: 12 }} />
              </button>
            )}
          </div>
          <button className={`dt-filter-btn ${isFilterOpen ? "active" : ""}`} onClick={() => setIsFilterOpen(v => !v)}>
            <SlidersHorizontal style={{ width: 14, height: 14 }} />
            Filter
            {isFilterOpen && <X style={{ width: 12, height: 12, marginLeft: 2 }} />}
          </button>
        </div>

        {/* ── Filter Panel ── */}
        {isFilterOpen && (
          <div className="dt-filter-panel">
            <div className="dt-filter-title">Filter Lanjutan</div>
            <div className="dt-filter-grid">
              <select className="dt-filter-select">
                <option value="">Semua Status</option>
                <option value="active">Aktif</option>
                <option value="inactive">Nonaktif</option>
              </select>
              <select className="dt-filter-select">
                <option value="">Urutkan Berdasarkan</option>
                <option value="newest">Terbaru</option>
                <option value="oldest">Terlama</option>
              </select>
              <button className="dt-filter-apply">Terapkan Filter</button>
            </div>
          </div>
        )}

        {/* ── Table Card ── */}
        <div className="dt-card">
          {!isLoading && !error && (
            <div className="dt-count">
              Menampilkan <strong>{pagedData.length}</strong> dari {processedData.length} data
              {searchQuery && <span> · pencarian: <strong style={{ color: "var(--brand)" }}>"{searchQuery}"</strong></span>}
            </div>
          )}

          <div className="dt-table-wrap">
            <table className="dt-table">
              <thead>
                <tr>
                  {columns.length > 0 ? columns.map((col, idx) => {
                    const isSorted = sortConfig?.key === col.key
                    const isLast = idx === columns.length - 1
                    return (
                      <th key={col.key} className={`${col.sortable ? "sortable" : ""} ${isSorted ? "sorted" : ""}`} onClick={() => col.sortable && handleSort(col.key)}>
                        <div className={`dt-th-inner ${isLast ? "right" : ""}`}>
                          {col.label}
                          {col.sortable && (
                            isSorted
                              ? (sortConfig?.direction === "asc"
                                ? <ChevronUp style={{ width: 12, height: 12 }} />
                                : <ChevronDown style={{ width: 12, height: 12 }} />)
                              : <ChevronDown style={{ width: 12, height: 12, opacity: 0.3 }} />
                          )}
                        </div>
                      </th>
                    )
                  }) : (
                    <>
                      <th>No</th>
                      <th>Data</th>
                      <th><div className="dt-th-inner right">Aksi</div></th>
                    </>
                  )}
                </tr>
              </thead>

              <tbody>
                {isLoading ? (
                  Array.from({ length: 6 }).map((_, i) => (
                    <tr key={i}>
                      {(columns.length > 0 ? columns : [1, 2, 3]).map((col, idx, arr) => (
                        <td key={idx}>
                          <div className="dt-skel" style={{ width: idx === 0 ? 28 : idx === arr.length - 1 ? 56 : `${60 + Math.random() * 30}%`, marginLeft: idx === arr.length - 1 ? "auto" : 0, opacity: 1 - i * 0.12 }} />
                        </td>
                      ))}
                    </tr>
                  ))
                ) : error ? (
                  <tr>
                    <td colSpan={colCount}>
                      <div className="dt-state-cell">
                        <div className="dt-state-icon error">
                          <AlertCircle style={{ width: 22, height: 22 }} />
                        </div>
                        <div className="dt-state-title">Gagal Memuat Data</div>
                        <div className="dt-state-sub">{error}</div>
                        <button className="dt-retry-btn" onClick={loadData}>
                          <RefreshCw style={{ width: 13, height: 13 }} />
                          Coba Lagi
                        </button>
                      </div>
                    </td>
                  </tr>
                ) : pagedData.length === 0 ? (
                  <tr>
                    <td colSpan={colCount}>
                      <div className="dt-state-cell">
                        <div className="dt-state-icon empty">
                          <Search style={{ width: 22, height: 22 }} />
                        </div>
                        <div className="dt-state-title">Data Tidak Ditemukan</div>
                        <div className="dt-state-sub">
                          {searchQuery ? `Tidak ada hasil untuk "${searchQuery}". Coba kata kunci lain.` : "Belum ada data untuk kategori atau filter ini."}
                        </div>
                        {searchQuery && (
                          <button className="dt-retry-btn" onClick={() => setSearchQuery("")}>
                            <X style={{ width: 13, height: 13 }} />
                            Hapus Pencarian
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ) : (
                  pagedData.map((item, idx) => (
                    <tr key={item.id || idx}>
                      {columns.length > 0 ? columns.map((col, colIdx) => (
                        <td key={col.key} style={colIdx === columns.length - 1 ? { textAlign: "right" } : {}}>
                          {col.render ? col.render(item, usePagination ? (currentPage - 1) * pageSize! + idx : idx) : (item[col.key] ?? "—")}
                        </td>
                      )) : (
                        <>
                          <td style={{ color: "var(--muted-foreground)", fontWeight: 500 }}>{idx + 1}</td>
                          <td>{item.name || "—"}</td>
                          <td style={{ textAlign: "right" }}>
                            <button style={{ color: "var(--brand)", background: "none", border: "none", fontSize: 13, fontWeight: 600, cursor: "pointer", padding: "4px 8px", borderRadius: 6, transition: "background 0.1s", fontFamily: "inherit" }}
                              onMouseEnter={e => (e.currentTarget.style.background = "rgba(var(--brand-rgb), 0.08)")}
                              onMouseLeave={e => (e.currentTarget.style.background = "none")}>
                              Detail
                            </button>
                          </td>
                        </>
                      )}
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {usePagination && !isLoading && !error && (
            <div className="dt-pagination">
              <span>Halaman {currentPage} dari {totalPages}</span>
              <div className="dt-page-btns">
                <button className="dt-page-btn" onClick={() => setPage(p => Math.max(1, p - 1))} disabled={currentPage === 1} aria-label="Sebelumnya">
                  <ChevronLeft style={{ width: 15, height: 15 }} />
                </button>
                {Array.from({ length: totalPages }).slice(0, 5).map((_, i) => {
                  const p = i + 1
                  return (
                    <button key={p} className={`dt-page-btn ${p === currentPage ? "active" : ""}`} onClick={() => setPage(p)}>
                      {p}
                    </button>
                  )
                })}
                {totalPages > 5 && <span style={{ padding: "0 4px", color: "var(--muted-foreground)" }}>…</span>}
                <button className="dt-page-btn" onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={currentPage === totalPages} aria-label="Berikutnya">
                  <ChevronRight style={{ width: 15, height: 15 }} />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  )
}

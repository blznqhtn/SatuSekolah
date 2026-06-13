"use client"

import React from "react"
import { DataTableTemplate } from "@/components/dashboard/data-table-template"

export default function Page() {
  return (
    <DataTableTemplate 
      moduleName="Tagihan & Pembayaran"
      endpoint="/finance/invoices"
    />
  )
}

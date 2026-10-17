package usecase

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jung-kurt/gofpdf"
	"github.com/xuri/excelize/v2"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/reports/domain"
)

type reportUsecase struct {
	repo domain.ReportRepository
}

func NewReportUsecase(repo domain.ReportRepository) domain.ReportUsecase {
	return &reportUsecase{repo: repo}
}

// ==========================================
// ATTENDANCE REPORT
// ==========================================
func (u *reportUsecase) GenerateAttendanceReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time, format domain.ReportFormat) (interface{}, string, error) {
	data, err := u.repo.GetAttendanceReport(ctx, tenantID, startDate, endDate)
	if err != nil {
		return nil, "", err
	}

	switch format {
	case domain.FormatJSON:
		return data, "application/json", nil

	case domain.FormatExcel:
		f := excelize.NewFile()
		defer f.Close()
		sheet := "Attendance"
		f.SetSheetName("Sheet1", sheet)
		
		// Headers
		headers := []string{"User ID", "Name", "Role", "Total Days", "Present", "Absent", "Late", "Percentage (%)"}
		for i, h := range headers {
			col, _ := excelize.ColumnNumberToName(i + 1)
			f.SetCellValue(sheet, fmt.Sprintf("%s1", col), h)
		}

		for rIdx, row := range data {
			rowNum := rIdx + 2
			f.SetCellValue(sheet, fmt.Sprintf("A%d", rowNum), row.UserID.String())
			f.SetCellValue(sheet, fmt.Sprintf("B%d", rowNum), row.UserName)
			f.SetCellValue(sheet, fmt.Sprintf("C%d", rowNum), row.Role)
			f.SetCellValue(sheet, fmt.Sprintf("D%d", rowNum), row.TotalDays)
			f.SetCellValue(sheet, fmt.Sprintf("E%d", rowNum), row.PresentDays)
			f.SetCellValue(sheet, fmt.Sprintf("F%d", rowNum), row.AbsentDays)
			f.SetCellValue(sheet, fmt.Sprintf("G%d", rowNum), row.LateDays)
			f.SetCellValue(sheet, fmt.Sprintf("H%d", rowNum), row.Percentage)
		}

		var buf bytes.Buffer
		if err := f.Write(&buf); err != nil {
			return nil, "", err
		}
		return buf.Bytes(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", nil

	case domain.FormatPDF:
		pdf := gofpdf.New("P", "mm", "A4", "")
		pdf.AddPage()
		pdf.SetFont("Arial", "B", 16)
		pdf.Cell(40, 10, "Attendance Report")
		pdf.Ln(10)
		pdf.SetFont("Arial", "", 12)
		pdf.Cell(40, 10, fmt.Sprintf("Period: %s to %s", startDate.Format("2006-01-02"), endDate.Format("2006-01-02")))
		pdf.Ln(10)

		// Table Header
		pdf.SetFont("Arial", "B", 10)
		pdf.CellFormat(50, 8, "Name", "1", 0, "L", false, 0, "")
		pdf.CellFormat(30, 8, "Role", "1", 0, "L", false, 0, "")
		pdf.CellFormat(20, 8, "Total", "1", 0, "C", false, 0, "")
		pdf.CellFormat(20, 8, "Present", "1", 0, "C", false, 0, "")
		pdf.CellFormat(20, 8, "Absent", "1", 0, "C", false, 0, "")
		pdf.CellFormat(20, 8, "Late", "1", 0, "C", false, 0, "")
		pdf.CellFormat(30, 8, "Percentage", "1", 1, "C", false, 0, "")

		// Table Body
		pdf.SetFont("Arial", "", 10)
		for _, row := range data {
			pdf.CellFormat(50, 8, row.UserName, "1", 0, "L", false, 0, "")
			pdf.CellFormat(30, 8, row.Role, "1", 0, "L", false, 0, "")
			pdf.CellFormat(20, 8, fmt.Sprintf("%d", row.TotalDays), "1", 0, "C", false, 0, "")
			pdf.CellFormat(20, 8, fmt.Sprintf("%d", row.PresentDays), "1", 0, "C", false, 0, "")
			pdf.CellFormat(20, 8, fmt.Sprintf("%d", row.AbsentDays), "1", 0, "C", false, 0, "")
			pdf.CellFormat(20, 8, fmt.Sprintf("%d", row.LateDays), "1", 0, "C", false, 0, "")
			pdf.CellFormat(30, 8, fmt.Sprintf("%.2f%%", row.Percentage), "1", 1, "C", false, 0, "")
		}

		var buf bytes.Buffer
		if err := pdf.Output(&buf); err != nil {
			return nil, "", err
		}
		return buf.Bytes(), "application/pdf", nil
	}

	return nil, "", fmt.Errorf("unsupported format")
}

// ==========================================
// FINANCIAL REPORT
// ==========================================
func (u *reportUsecase) GenerateFinancialReport(ctx context.Context, tenantID uuid.UUID, startDate, endDate time.Time, format domain.ReportFormat) (interface{}, string, error) {
	data, err := u.repo.GetFinancialReport(ctx, tenantID, startDate, endDate)
	if err != nil {
		return nil, "", err
	}

	switch format {
	case domain.FormatJSON:
		return data, "application/json", nil

	case domain.FormatExcel:
		f := excelize.NewFile()
		defer f.Close()
		sheet := "Financials"
		f.SetSheetName("Sheet1", sheet)
		
		headers := []string{"Date", "Total Credit", "Total Debit", "Net Balance", "Transactions"}
		for i, h := range headers {
			col, _ := excelize.ColumnNumberToName(i + 1)
			f.SetCellValue(sheet, fmt.Sprintf("%s1", col), h)
		}

		for rIdx, row := range data {
			rowNum := rIdx + 2
			f.SetCellValue(sheet, fmt.Sprintf("A%d", rowNum), row.Date.Format("2006-01-02"))
			f.SetCellValue(sheet, fmt.Sprintf("B%d", rowNum), row.TotalCredit)
			f.SetCellValue(sheet, fmt.Sprintf("C%d", rowNum), row.TotalDebit)
			f.SetCellValue(sheet, fmt.Sprintf("D%d", rowNum), row.NetBalance)
			f.SetCellValue(sheet, fmt.Sprintf("E%d", rowNum), row.Transactions)
		}

		var buf bytes.Buffer
		if err := f.Write(&buf); err != nil {
			return nil, "", err
		}
		return buf.Bytes(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", nil

	case domain.FormatPDF:
		pdf := gofpdf.New("P", "mm", "A4", "")
		pdf.AddPage()
		pdf.SetFont("Arial", "B", 16)
		pdf.Cell(40, 10, "Financial Ledger Report")
		pdf.Ln(15)

		pdf.SetFont("Arial", "B", 10)
		pdf.CellFormat(40, 8, "Date", "1", 0, "C", false, 0, "")
		pdf.CellFormat(40, 8, "Credit", "1", 0, "R", false, 0, "")
		pdf.CellFormat(40, 8, "Debit", "1", 0, "R", false, 0, "")
		pdf.CellFormat(40, 8, "Net Balance", "1", 0, "R", false, 0, "")
		pdf.CellFormat(30, 8, "Transactions", "1", 1, "C", false, 0, "")

		pdf.SetFont("Arial", "", 10)
		for _, row := range data {
			pdf.CellFormat(40, 8, row.Date.Format("2006-01-02"), "1", 0, "C", false, 0, "")
			pdf.CellFormat(40, 8, fmt.Sprintf("%.2f", row.TotalCredit), "1", 0, "R", false, 0, "")
			pdf.CellFormat(40, 8, fmt.Sprintf("%.2f", row.TotalDebit), "1", 0, "R", false, 0, "")
			pdf.CellFormat(40, 8, fmt.Sprintf("%.2f", row.NetBalance), "1", 0, "R", false, 0, "")
			pdf.CellFormat(30, 8, fmt.Sprintf("%d", row.Transactions), "1", 1, "C", false, 0, "")
		}

		var buf bytes.Buffer
		if err := pdf.Output(&buf); err != nil {
			return nil, "", err
		}
		return buf.Bytes(), "application/pdf", nil
	}

	return nil, "", fmt.Errorf("unsupported format")
}

// ==========================================
// ACADEMIC REPORT
// ==========================================
func (u *reportUsecase) GenerateAcademicReport(ctx context.Context, tenantID uuid.UUID, format domain.ReportFormat) (interface{}, string, error) {
	data, err := u.repo.GetAcademicReport(ctx, tenantID)
	if err != nil {
		return nil, "", err
	}

	if format == domain.FormatJSON {
		return data, "application/json", nil
	}

	// Stub for PDF/Excel for Academic, returning JSON for simplicity in this artifact
	js, _ := json.Marshal(data)
	return js, "application/json", nil
}

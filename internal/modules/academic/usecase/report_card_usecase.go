package usecase

import (
	"bytes"
	"context"
	"errors"
	"mime/multipart"
	"strconv"
	"strings"

	"github.com/google/uuid"
	"github.com/xuri/excelize/v2"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/entities"
)

type reportCardUsecase struct {
	repo domain.ReportCardRepository
}

func NewReportCardUsecase(repo domain.ReportCardRepository) domain.ReportCardUsecase {
	return &reportCardUsecase{repo: repo}
}

func (u *reportCardUsecase) GenerateExcelTemplate(ctx context.Context, tenantID, classID uuid.UUID) ([]byte, error) {
	// Fetch students
	students, err := u.repo.GetStudentsByClass(ctx, tenantID, classID)
	if err != nil {
		return nil, err
	}

	f := excelize.NewFile()
	sheet := "Template_Nilai"
	index, _ := f.NewSheet(sheet)
	f.SetActiveSheet(index)

	// We only provide standard columns because courses can be added dynamically by users
	// However, if the tenant has predefined courses, we could theoretically fetch them
	// For simplicity, we just provide NISN and Nama. The teacher can add subject columns.
	headers := []string{"NISN", "Nama Lengkap"}
	
	// Write Headers
	for i, h := range headers {
		cell, _ := excelize.CoordinatesToCellName(i+1, 1)
		f.SetCellValue(sheet, cell, h)
	}

	// Make Header bold
	style, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Bold: true},
	})
	f.SetRowStyle(sheet, 1, 1, style)

	// Write Students
	for r, s := range students {
		rowIdx := r + 2
		cellNISN, _ := excelize.CoordinatesToCellName(1, rowIdx)
		cellName, _ := excelize.CoordinatesToCellName(2, rowIdx)
		f.SetCellValue(sheet, cellNISN, s.NISN)
		f.SetCellValue(sheet, cellName, s.Name)
	}

	var buf bytes.Buffer
	if err := f.Write(&buf); err != nil {
		return nil, err
	}

	return buf.Bytes(), nil
}

func (u *reportCardUsecase) UploadExcelGrades(ctx context.Context, tenantID, termID, uploadedBy uuid.UUID, file *multipart.FileHeader) error {
	f, err := file.Open()
	if err != nil {
		return err
	}
	defer f.Close()

	xlsx, err := excelize.OpenReader(f)
	if err != nil {
		return err
	}
	defer xlsx.Close()

	sheetName := xlsx.GetSheetName(xlsx.GetActiveSheetIndex())
	rows, err := xlsx.GetRows(sheetName)
	if err != nil {
		return err
	}

	if len(rows) < 2 {
		return errors.New("excel file is empty or missing data rows")
	}

	headers := rows[0]
	// Map course index to courseID
	courseIdxMap := make(map[int]uuid.UUID)
	
	for i := 2; i < len(headers); i++ {
		courseName := strings.TrimSpace(headers[i])
		if courseName == "" {
			continue
		}
		
		course, err := u.repo.GetCourseByName(ctx, tenantID, courseName)
		if err != nil || course == nil {
			// If course not found, skip it or we could create it, but for now we skip 
			// (Assuming it must exist in the system)
			continue
		}
		courseIdxMap[i] = course.ID
	}

	err = u.repo.ExecTx(ctx, func(txRepo domain.ReportCardRepository) error {
		for rIdx := 1; rIdx < len(rows); rIdx++ {
			row := rows[rIdx]
			if len(row) < 1 {
				continue
			}
			nisn := strings.TrimSpace(row[0])
			if nisn == "" {
				continue
			}

			studentID, err := txRepo.GetStudentByNISN(ctx, tenantID, nisn)
			if err != nil || studentID == uuid.Nil {
				continue // skip invalid student
			}

			// Get or create ReportCard
			rc, err := txRepo.GetReportCardByStudentAndTerm(ctx, tenantID, studentID, termID)
			if err != nil {
				return err
			}
			if rc == nil {
				rc = &entities.ReportCard{
					TenantID:  tenantID,
					TermID:    termID,
					StudentID: studentID,
					UpdatedBy: uploadedBy,
				}
			} else {
				rc.UpdatedBy = uploadedBy
			}

			if err := txRepo.SaveReportCard(ctx, rc); err != nil {
				return err
			}

			// Process grades
			var grades []*entities.ReportCardGrade
			for colIdx, courseID := range courseIdxMap {
				if colIdx < len(row) {
					scoreStr := strings.TrimSpace(row[colIdx])
					if scoreStr == "" {
						continue
					}
					score, err := strconv.Atoi(scoreStr)
					if err == nil {
						predicate := "C"
						if score >= 90 {
							predicate = "A"
						} else if score >= 80 {
							predicate = "B"
						}
						
						grades = append(grades, &entities.ReportCardGrade{
							ReportCardID: rc.ID,
							CourseID:     courseID,
							Score:        score,
							Predicate:    predicate,
						})
					}
				}
			}

			if len(grades) > 0 {
				if err := txRepo.SaveReportCardGrades(ctx, grades); err != nil {
					return err
				}
			}
		}
		return nil
	})

	return err
}

func (u *reportCardUsecase) GetLeaderboard(ctx context.Context, tenantID uuid.UUID, termID uuid.UUID, filter domain.LeaderboardFilter, filterID string) ([]*domain.LeaderboardRow, error) {
	var parsedFilterID *uuid.UUID
	if filterID != "" {
		id, err := uuid.Parse(filterID)
		if err == nil {
			parsedFilterID = &id
		}
	}
	
	return u.repo.GetLeaderboard(ctx, tenantID, termID, filter, parsedFilterID)
}

func (u *reportCardUsecase) GetStudentReportCard(ctx context.Context, tenantID, studentID, termID uuid.UUID) (*domain.ReportCardResponseDTO, error) {
	// If termID is empty, we could fetch the active term, but we'll assume it's handled by the handler
	return u.repo.GetStudentReportCardSummary(ctx, tenantID, studentID, termID)
}

func (u *reportCardUsecase) GetStudentDetailedGrades(ctx context.Context, tenantID, studentID, termID, courseID uuid.UUID) (*domain.DetailedSubjectGradeResponseDTO, error) {
	return u.repo.GetStudentDetailedGrades(ctx, tenantID, studentID, termID, courseID)
}

func (u *reportCardUsecase) GetStudentSemesters(ctx context.Context, tenantID, studentID uuid.UUID) ([]domain.SemesterHistoryDTO, error) {
	return u.repo.GetStudentSemesters(ctx, tenantID, studentID)
}

func (u *reportCardUsecase) UpdateReportCardNotes(ctx context.Context, tenantID, reportCardID, updatedBy uuid.UUID, notes []domain.ReportCardNoteDTO) error {
	return u.repo.UpdateReportCardNotes(ctx, tenantID, reportCardID, updatedBy, notes)
}

func (u *reportCardUsecase) GenerateReportCardPDF(ctx context.Context, tenantID, studentID, termID uuid.UUID) ([]byte, error) {
	// Fetch report card data
	data, err := u.repo.GetStudentReportCardSummary(ctx, tenantID, studentID, termID)
	if err != nil {
		return nil, err
	}

	// For simplicity, we just generate a dummy PDF-like byte array or plain text representing the PDF.
	// In a real scenario, use github.com/jung-kurt/gofpdf to generate actual PDF layout.
	var buf bytes.Buffer
	buf.WriteString("%PDF-1.4\n")
	buf.WriteString("1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n")
	buf.WriteString("2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n")
	
	// Just writing the data as plain text inside a mock pdf stream
	content := "Rapor Akademik: " + data.Summary.ActiveSemester + "\n"
	content += "Rata-rata: " + strconv.FormatFloat(data.Summary.AverageScore, 'f', 2, 64) + "\n"
	buf.WriteString(content)
	
	return buf.Bytes(), nil
}

package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	appCrypto "neuracakrawira.asia/satu-sekolah-backend/pkg/crypto"

	coreDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	libraryDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/domain"
	pkgDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/domain"
)

type pklUsecase struct {
	repo      domain.PklRepository
	coreRepo  coreDomain.CoreRepository
	libraryUc libraryDomain.LibraryUsecase
	pkgUc     pkgDomain.PkgUsecase
	encKey    []byte // AES-256-GCM key (32 bytes)
}

// NewPklUsecase constructs the PKL usecase.
// encryptionKey is the raw PKL_ENCRYPTION_KEY string from config (padded/truncated to 32 bytes internally).
func NewPklUsecase(
	repo domain.PklRepository,
	coreRepo coreDomain.CoreRepository,
	libraryUc libraryDomain.LibraryUsecase,
	pkgUc pkgDomain.PkgUsecase,
	encryptionKey string,
) domain.PklUsecase {
	return &pklUsecase{
		repo:      repo,
		coreRepo:  coreRepo,
		libraryUc: libraryUc,
		pkgUc:     pkgUc,
		encKey:    appCrypto.DeriveKey(encryptionKey),
	}
}

// encryptURL encrypts an S3 URL using AES-256-GCM.
func (u *pklUsecase) encryptURL(raw string) (string, error) {
	return appCrypto.EncryptAESGCM(raw, u.encKey)
}

// decryptURL decrypts an AES-256-GCM encrypted S3 URL.
func (u *pklUsecase) decryptURL(enc string) (string, error) {
	return appCrypto.DecryptAESGCM(enc, u.encKey)
}

// ------------------------------------------
// Existing PKL Monitoring
// ------------------------------------------

func (u *pklUsecase) ConfigureSetting(ctx context.Context, setting *domain.PerformanceSetting, adminID uuid.UUID) error {
	user, err := u.coreRepo.GetUserByID(ctx, adminID)
	if err != nil || user.Category != "admin" {
		return errors.New("unauthorized: only admin can configure performance settings")
	}
	setting.TenantID = user.TenantID
	setting.CreatedAt = time.Now()
	return u.repo.UpsertSetting(ctx, setting)
}

func (u *pklUsecase) ReportMonitoring(ctx context.Context, pkl *domain.PklMonitoring) error {
	pkl.Status = domain.PklPending
	return u.repo.CreateMonitoring(ctx, pkl)
}

func (u *pklUsecase) EvaluateMonitoring(ctx context.Context, pklID uuid.UUID, principalID uuid.UUID, score float64, notes string, status domain.PklStatus) error {
	pkl, err := u.repo.GetMonitoring(ctx, pklID)
	if err != nil || pkl == nil {
		return errors.New("monitoring record not found")
	}
	setting, _ := u.repo.GetSetting(ctx, pkl.TenantID)
	if setting == nil || setting.PrincipalStaffID != principalID {
		return errors.New("unauthorized: only the designated principal can evaluate PKL monitorings")
	}
	return u.repo.UpdateMonitoringEvaluation(ctx, pklID, score, notes, status)
}

// ------------------------------------------
// Hubungan Industri Monitoring → E-Kinerja (PKG)
// ------------------------------------------

func (u *pklUsecase) ReportHubinMonitoring(ctx context.Context, tenantID uuid.UUID, staffID uuid.UUID, fileURL string, title string) error {
	// Encrypt the S3 URL before persisting
	encURL, err := u.encryptURL(fileURL)
	if err != nil {
		return err
	}

	// Resolve the active PKG period for this tenant
	activePeriod, err := u.pkgUc.GetActivePeriod(ctx, tenantID)
	if err != nil || activePeriod == nil {
		return errors.New("no active PKG period found; please ask the admin to create one")
	}

	// Resolve the indicator ID for Hubin monitoring.
	// We look for an indicator named "Monitoring PKL" (case-insensitive).
	indicators, err := u.pkgUc.GetIndicators(ctx, tenantID)
	if err != nil {
		return err
	}
	var indicatorID uuid.UUID
	for _, ind := range indicators {
		if normalizeStr(ind.Name) == normalizeStr("Monitoring PKL") {
			indicatorID = ind.ID
			break
		}
	}
	if indicatorID == uuid.Nil {
		return errors.New("PKG indicator 'Monitoring PKL' not found; please ask the admin to create it first")
	}

	// Auto-submit a PKG submission on behalf of this Hubin staff member
	submission := &pkgDomain.PkgSubmission{
		ID:          uuid.New(),
		PeriodID:    activePeriod.ID,
		IndicatorID: indicatorID,
		StaffID:     staffID,
		DocumentURL: encURL,
		Description: title,
		SubmittedAt: time.Now(),
	}
	return u.pkgUc.SubmitDocument(ctx, submission)
}

// ------------------------------------------
// Mentorship Assignment
// ------------------------------------------

func (u *pklUsecase) AssignMentors(ctx context.Context, tenantID uuid.UUID, academicYearID uuid.UUID, studentIDs []uuid.UUID, mentorID uuid.UUID) error {
	var ms []*domain.PklMentorship
	for _, sID := range studentIDs {
		ms = append(ms, &domain.PklMentorship{
			TenantID:       tenantID,
			AcademicYearID: academicYearID,
			StudentID:      sID,
			MentorID:       mentorID,
		})
	}
	return u.repo.AssignMentor(ctx, ms)
}

// ------------------------------------------
// Mentoring Schedule
// ------------------------------------------

func (u *pklUsecase) CreateSchedule(ctx context.Context, mentorID uuid.UUID, schedule *domain.PklMentoringSchedule) error {
	// Verify that the mentorID is indeed assigned to this mentorship (fetch all for mentor, cross-check)
	ms, err := u.repo.GetMentorshipsByMentor(ctx, mentorID, uuid.Nil)
	if err != nil {
		return err
	}
	authorized := false
	for _, m := range ms {
		if m.ID == schedule.MentorshipID {
			authorized = true
			break
		}
	}
	if !authorized {
		return errors.New("unauthorized: you are not the assigned mentor for this mentorship")
	}
	// Encrypt the Zoom link if provided
	if schedule.ZoomLink != nil && *schedule.ZoomLink != "" {
		enc, err := u.encryptURL(*schedule.ZoomLink)
		if err != nil {
			return err
		}
		schedule.ZoomLink = &enc
	}
	return u.repo.CreateSchedule(ctx, schedule)
}

// ------------------------------------------
// Journal Submission (Student)
// ------------------------------------------

func (u *pklUsecase) SubmitJournal(ctx context.Context, studentID uuid.UUID, scheduleID uuid.UUID, description string, documentURLs string) error {
	schedule, err := u.repo.GetScheduleByID(ctx, scheduleID)
	if err != nil || schedule == nil {
		return errors.New("schedule not found")
	}

	// Verify mentorship belongs to this student
	ms, err := u.repo.GetMentorshipByStudent(ctx, studentID)
	if err != nil || ms == nil {
		return errors.New("no mentorship found for this student")
	}
	if ms.ID != schedule.MentorshipID {
		return errors.New("unauthorized: this schedule does not belong to your mentorship")
	}

	// ---- Time Lock Logic ----
	now := time.Now()
	loc := schedule.ScheduleDate.Location()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
	schDate := time.Date(schedule.ScheduleDate.Year(), schedule.ScheduleDate.Month(), schedule.ScheduleDate.Day(), 0, 0, 0, 0, loc)

	if today.Before(schDate) {
		return errors.New("schedule is locked: this session has not started yet")
	}

	existing, _ := u.repo.GetJournalBySchedule(ctx, scheduleID)

	// Past the schedule date — only allowed if the existing journal was REJECTED
	if today.After(schDate) {
		if existing == nil || existing.Status != domain.PklRejected {
			return errors.New("schedule is locked: the deadline has passed")
		}
	}

	// Already approved — fully locked
	if existing != nil && existing.Status == domain.PklApproved {
		return errors.New("journal is locked: it has already been approved")
	}

	// Encrypt document URL payload (a JSON array encrypted as a single blob)
	encURLs, err := appCrypto.EncryptAESGCM(documentURLs, u.encKey)
	if err != nil {
		return err
	}

	journal := &domain.PklJournal{
		ScheduleID:   scheduleID,
		Description:  description, // E2EE: already ciphertext from FE
		DocumentURLs: encURLs,
		Status:       domain.PklPending,
	}
	if existing != nil {
		journal.ID = existing.ID
		journal.CreatedAt = existing.CreatedAt
	}
	return u.repo.SaveJournal(ctx, journal)
}

// ------------------------------------------
// Journal Review (Mentor)
// ------------------------------------------

func (u *pklUsecase) ReviewJournal(ctx context.Context, mentorID uuid.UUID, journalID uuid.UUID, status domain.PklStatus, feedback string) error {
	journal, err := u.repo.GetJournalByID(ctx, journalID)
	if err != nil || journal == nil {
		return errors.New("journal not found")
	}
	if journal.Status == domain.PklApproved {
		return errors.New("journal is already approved and cannot be changed")
	}

	schedule, err := u.repo.GetScheduleByID(ctx, journal.ScheduleID)
	if err != nil || schedule == nil {
		return errors.New("schedule not found")
	}

	// Verify this mentor owns the mentorship for this schedule
	// We fetch all mentorships for this mentor for the schedule's mentorship ID match
	mentorships, err := u.repo.GetMentorshipsByMentor(ctx, mentorID, uuid.Nil)
	if err != nil {
		return err
	}
	authorized := false
	for _, m := range mentorships {
		if m.ID == schedule.MentorshipID {
			authorized = true
			break
		}
	}
	if !authorized {
		return errors.New("unauthorized: you are not the assigned mentor for this journal")
	}

	// feedback is E2EE ciphertext from FE — store as-is
	journal.Status = status
	journal.Feedback = &feedback
	return u.repo.SaveJournal(ctx, journal)
}

// ------------------------------------------
// Final Report Settings
// ------------------------------------------

func (u *pklUsecase) ConfigureFinalReport(ctx context.Context, tenantID uuid.UUID, setting *domain.PklFinalReportSetting) error {
	setting.TenantID = tenantID
	return u.repo.UpsertFinalReportSetting(ctx, setting)
}

// ------------------------------------------
// Final Report Submission (Student)
// ------------------------------------------

func (u *pklUsecase) SubmitFinalReport(ctx context.Context, tenantID uuid.UUID, studentID uuid.UUID, documentURL string) error {
	// Check if a Final Report setting exists at the ALL level first
	// ClassID / MajorID not tracked in core User; pass uuid.Nil to fall back to "ALL" setting.
	setting, err := u.repo.GetFinalReportSetting(ctx, tenantID, uuid.Nil, uuid.Nil)
	if err != nil {
		return err
	}
	if setting != nil {
		now := time.Now()
		if setting.StartDate != nil && now.Before(*setting.StartDate) {
			return errors.New("final report submission is not yet open")
		}
		if setting.EndDate != nil && now.After(*setting.EndDate) {
			return errors.New("final report submission deadline has passed")
		}
	}

	// Encrypt the document URL
	encURL, err := u.encryptURL(documentURL)
	if err != nil {
		return err
	}

	report := &domain.PklFinalReport{
		StudentID:   studentID,
		DocumentURL: encURL,
		Status:      domain.PklPending,
	}
	return u.repo.SaveFinalReport(ctx, report)
}

// ------------------------------------------
// Final Report Verification (Hubungan Industri → Library)
// ------------------------------------------

func (u *pklUsecase) VerifyFinalReport(ctx context.Context, tenantID uuid.UUID, hubinID uuid.UUID, reportID uuid.UUID, status domain.PklStatus, notes string) error {
	report, err := u.repo.GetFinalReportByID(ctx, reportID)
	if err != nil || report == nil {
		return errors.New("final report not found")
	}

	report.Status = status
	if notes != "" {
		report.Notes = &notes
	}
	report.ApprovedBy = &hubinID

	if err := u.repo.SaveFinalReport(ctx, report); err != nil {
		return err
	}

	// ---- On Approve: forward to Library as E-Journal ----
	if status == domain.PklApproved {
		// Decrypt the URL so the library can store its own reference
		rawURL, err := u.decryptURL(report.DocumentURL)
		if err != nil {
			return err
		}

		// Fetch student info for metadata
		student, err := u.coreRepo.GetUserByID(ctx, report.StudentID)
		if err != nil || student == nil {
			return errors.New("student not found when forwarding to library")
		}

		journal := &libraryDomain.JournalArchive{
			ID:          uuid.New(),
			TenantID:    tenantID,
			UploaderID:  report.StudentID,
			Title:       student.Name + " — PKL Journal",
			Abstract:    "Jurnal PKL yang telah disetujui oleh Hubungan Industri.",
			SoftcopyURL: rawURL,
			ScannerURL:  rawURL,
			Status:      libraryDomain.JournalPending,
			CreatedAt:   time.Now(),
		}
		if err := u.libraryUc.UploadJournal(ctx, journal); err != nil {
			return err
		}
	}

	return nil
}

// ------------------------------------------
// Helpers
// ------------------------------------------

func normalizeStr(s string) string {
	result := []byte{}
	for _, c := range s {
		if c >= 'A' && c <= 'Z' {
			result = append(result, byte(c+32))
		} else if c == ' ' || c == '\t' {
			// skip leading/trailing spaces — simple trim approach
			continue
		} else {
			result = append(result, byte(c))
		}
	}
	return string(result)
}

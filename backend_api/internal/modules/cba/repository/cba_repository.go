package repository

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/domain"
)

type cbaRepository struct {
	db *sql.DB
	tx *sql.Tx
}

func NewCBARepository(db *sql.DB) domain.CBARepository {
	return &cbaRepository{db: db}
}

func (r *cbaRepository) ExecTx(ctx context.Context, fn func(repo domain.CBARepository) error) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	txRepo := &cbaRepository{db: r.db, tx: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (r *cbaRepository) queryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	if r.tx != nil {
		return r.tx.QueryRowContext(ctx, query, args...)
	}
	return r.db.QueryRowContext(ctx, query, args...)
}

func (r *cbaRepository) query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
	if r.tx != nil {
		return r.tx.QueryContext(ctx, query, args...)
	}
	return r.db.QueryContext(ctx, query, args...)
}

func (r *cbaRepository) exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	if r.tx != nil {
		return r.tx.ExecContext(ctx, query, args...)
	}
	return r.db.ExecContext(ctx, query, args...)
}

// ==========================================
// LMS Quiz (Lightweight)
// ==========================================

func (r *cbaRepository) CreateQuiz(ctx context.Context, quiz *domain.Quiz) error {
	quiz.ID = uuid.New()
	_, err := r.exec(ctx, `INSERT INTO quizzes (id, module_id, title) VALUES ($1, $2, $3)`, quiz.ID, quiz.ModuleID, quiz.Title)
	return err
}

func (r *cbaRepository) GetQuizzesByModule(ctx context.Context, moduleID uuid.UUID) ([]*domain.Quiz, error) {
	rows, err := r.query(ctx, `SELECT id, module_id, title FROM quizzes WHERE module_id = $1 AND deleted_at IS NULL`, moduleID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var quizzes []*domain.Quiz
	for rows.Next() {
		var q domain.Quiz
		if err := rows.Scan(&q.ID, &q.ModuleID, &q.Title); err != nil {
			return nil, err
		}
		quizzes = append(quizzes, &q)
	}
	return quizzes, nil
}

func (r *cbaRepository) GetQuizByID(ctx context.Context, quizID uuid.UUID) (*domain.Quiz, error) {
	var q domain.Quiz
	err := r.queryRow(ctx, `SELECT id, module_id, title FROM quizzes WHERE id = $1 AND deleted_at IS NULL`, quizID).
		Scan(&q.ID, &q.ModuleID, &q.Title)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &q, err
}

func (r *cbaRepository) CreateQuestion(ctx context.Context, q *domain.Question) error {
	q.ID = uuid.New()
	_, err := r.exec(ctx, `INSERT INTO questions (id, quiz_id, type, question_text, media_url, media_type, ai_reference_answer) VALUES ($1,$2,$3,$4,$5,$6,$7)`,
		q.ID, q.QuizID, q.Type, q.QuestionText, q.MediaURL, q.MediaType, q.AIReferenceAnswer)
	return err
}

func (r *cbaRepository) GetQuestionsByQuiz(ctx context.Context, quizID uuid.UUID) ([]*domain.Question, error) {
	rows, err := r.query(ctx, `SELECT id, quiz_id, type, question_text, media_url, media_type FROM questions WHERE quiz_id = $1 AND deleted_at IS NULL`, quizID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var questions []*domain.Question
	for rows.Next() {
		var q domain.Question
		if err := rows.Scan(&q.ID, &q.QuizID, &q.Type, &q.QuestionText, &q.MediaURL, &q.MediaType); err != nil {
			return nil, err
		}
		questions = append(questions, &q)
	}
	return questions, nil
}

func (r *cbaRepository) CreateOption(ctx context.Context, opt *domain.QuestionOption) error {
	opt.ID = uuid.New()
	_, err := r.exec(ctx, `INSERT INTO question_options (id, question_id, option_text, media_url, media_type, is_correct, match_left, match_right) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
		opt.ID, opt.QuestionID, opt.OptionText, opt.MediaURL, opt.MediaType, opt.IsCorrect, opt.MatchLeft, opt.MatchRight)
	return err
}

func (r *cbaRepository) GetOptionsByQuestion(ctx context.Context, questionID uuid.UUID) ([]*domain.QuestionOption, error) {
	rows, err := r.query(ctx, `SELECT id, question_id, option_text, is_correct FROM question_options WHERE question_id = $1`, questionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var opts []*domain.QuestionOption
	for rows.Next() {
		var o domain.QuestionOption
		if err := rows.Scan(&o.ID, &o.QuestionID, &o.OptionText, &o.IsCorrect); err != nil {
			return nil, err
		}
		opts = append(opts, &o)
	}
	return opts, nil
}

func (r *cbaRepository) CreateAnswer(ctx context.Context, answer *domain.StudentAnswer) error {
	answer.ID = uuid.New()
	_, err := r.exec(ctx, `INSERT INTO student_answers (id, question_id, student_id, answer_text, is_correct, ai_score, ai_feedback) VALUES ($1,$2,$3,$4,$5,$6,$7)`,
		answer.ID, answer.QuestionID, answer.StudentID, answer.AnswerText, answer.IsCorrect, answer.AIScore, answer.AIFeedback)
	return err
}

func (r *cbaRepository) GetAnswersByQuizAndStudent(ctx context.Context, quizID, studentID uuid.UUID) ([]*domain.StudentAnswer, error) {
	rows, err := r.query(ctx, `
		SELECT sa.id, sa.question_id, sa.student_id, sa.answer_text, sa.is_correct, sa.ai_score, sa.ai_feedback, sa.created_at
		FROM student_answers sa
		JOIN questions q ON sa.question_id = q.id
		WHERE q.quiz_id = $1 AND sa.student_id = $2`, quizID, studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var answers []*domain.StudentAnswer
	for rows.Next() {
		var a domain.StudentAnswer
		if err := rows.Scan(&a.ID, &a.QuestionID, &a.StudentID, &a.AnswerText, &a.IsCorrect, &a.AIScore, &a.AIFeedback, &a.CreatedAt); err != nil {
			return nil, err
		}
		answers = append(answers, &a)
	}
	return answers, nil
}

// ==========================================
// CBA EXAM MODE
// ==========================================

func (r *cbaRepository) CreateFolder(ctx context.Context, folder *domain.CBAFolder) error {
	folder.ID = uuid.New()
	_, err := r.exec(ctx,
		`INSERT INTO cba_folders (id, tenant_id, name, description, current_token, token_expires_at, created_by) VALUES ($1,$2,$3,$4,$5,$6,$7)`,
		folder.ID, folder.TenantID, folder.Name, folder.Description, folder.CurrentToken, folder.TokenExpiresAt, folder.CreatedBy)
	return err
}

func (r *cbaRepository) GetFoldersByTenant(ctx context.Context, tenantID uuid.UUID) ([]*domain.CBAFolder, error) {
	rows, err := r.query(ctx,
		`SELECT id, tenant_id, name, description, current_token, token_expires_at, created_by, created_at, updated_at FROM cba_folders WHERE tenant_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC`,
		tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var folders []*domain.CBAFolder
	for rows.Next() {
		var f domain.CBAFolder
		if err := rows.Scan(&f.ID, &f.TenantID, &f.Name, &f.Description, &f.CurrentToken, &f.TokenExpiresAt, &f.CreatedBy, &f.CreatedAt, &f.UpdatedAt); err != nil {
			return nil, err
		}
		folders = append(folders, &f)
	}
	return folders, nil
}

func (r *cbaRepository) GetFolderByID(ctx context.Context, folderID uuid.UUID) (*domain.CBAFolder, error) {
	var f domain.CBAFolder
	err := r.queryRow(ctx,
		`SELECT id, tenant_id, name, description, current_token, token_expires_at, created_by, created_at, updated_at FROM cba_folders WHERE id = $1 AND deleted_at IS NULL`,
		folderID).Scan(&f.ID, &f.TenantID, &f.Name, &f.Description, &f.CurrentToken, &f.TokenExpiresAt, &f.CreatedBy, &f.CreatedAt, &f.UpdatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &f, err
}

func (r *cbaRepository) UpdateFolderToken(ctx context.Context, folderID uuid.UUID, token string, expiresAt time.Time) error {
	_, err := r.exec(ctx,
		`UPDATE cba_folders SET current_token = $1, token_expires_at = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3`,
		token, expiresAt, folderID)
	return err
}

func (r *cbaRepository) CreateExam(ctx context.Context, exam *domain.CBAExam) error {
	exam.ID = uuid.New()
	_, err := r.exec(ctx,
		`INSERT INTO cba_exams (id, folder_id, tenant_id, title, terms_and_conditions, start_time, end_time, waiting_room_open_minutes, show_results, created_by) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
		exam.ID, exam.FolderID, exam.TenantID, exam.Title, exam.TermsAndConditions, exam.StartTime, exam.EndTime, exam.WaitingRoomOpenMinutes, exam.ShowResults, exam.CreatedBy)
	return err
}

func (r *cbaRepository) GetExamsByFolderToday(ctx context.Context, folderID uuid.UUID) ([]*domain.CBAExam, error) {
	rows, err := r.query(ctx,
		`SELECT id, folder_id, tenant_id, title, terms_and_conditions, start_time, end_time, waiting_room_open_minutes, show_results, created_by, created_at 
		 FROM cba_exams 
		 WHERE folder_id = $1 AND deleted_at IS NULL
		 AND DATE(start_time) = CURRENT_DATE
		 ORDER BY start_time ASC`,
		folderID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var exams []*domain.CBAExam
	for rows.Next() {
		var e domain.CBAExam
		if err := rows.Scan(&e.ID, &e.FolderID, &e.TenantID, &e.Title, &e.TermsAndConditions, &e.StartTime, &e.EndTime, &e.WaitingRoomOpenMinutes, &e.ShowResults, &e.CreatedBy, &e.CreatedAt); err != nil {
			return nil, err
		}
		exams = append(exams, &e)
	}
	return exams, nil
}

func (r *cbaRepository) GetExamByID(ctx context.Context, examID uuid.UUID) (*domain.CBAExam, error) {
	var e domain.CBAExam
	err := r.queryRow(ctx,
		`SELECT id, folder_id, tenant_id, title, terms_and_conditions, start_time, end_time, waiting_room_open_minutes, show_results, created_by, created_at FROM cba_exams WHERE id = $1 AND deleted_at IS NULL`,
		examID).Scan(&e.ID, &e.FolderID, &e.TenantID, &e.Title, &e.TermsAndConditions, &e.StartTime, &e.EndTime, &e.WaitingRoomOpenMinutes, &e.ShowResults, &e.CreatedBy, &e.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &e, err
}

func (r *cbaRepository) CountQuestions(ctx context.Context, examID uuid.UUID) (int, error) {
	var count int
	err := r.queryRow(ctx, `SELECT COUNT(*) FROM cba_questions WHERE exam_id = $1`, examID).Scan(&count)
	return count, err
}

func (r *cbaRepository) CreateCBAQuestion(ctx context.Context, q *domain.CBAQuestion) error {
	q.ID = uuid.New()
	_, err := r.exec(ctx,
		`INSERT INTO cba_questions (id, exam_id, order_index, question_type, question_text, media_url, media_type, score_weight, ai_reference_answer) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
		q.ID, q.ExamID, q.OrderIndex, q.QuestionType, q.QuestionText, q.MediaURL, q.MediaType, q.ScoreWeight, q.AIReferenceAnswer)
	return err
}

func (r *cbaRepository) GetCBAQuestionsByExam(ctx context.Context, examID uuid.UUID) ([]*domain.CBAQuestion, error) {
	rows, err := r.query(ctx,
		`SELECT id, exam_id, order_index, question_type, question_text, media_url, media_type, score_weight FROM cba_questions WHERE exam_id = $1 ORDER BY order_index ASC`,
		examID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var questions []*domain.CBAQuestion
	for rows.Next() {
		var q domain.CBAQuestion
		if err := rows.Scan(&q.ID, &q.ExamID, &q.OrderIndex, &q.QuestionType, &q.QuestionText, &q.MediaURL, &q.MediaType, &q.ScoreWeight); err != nil {
			return nil, err
		}
		questions = append(questions, &q)
	}
	return questions, nil
}

func (r *cbaRepository) CreateCBAOption(ctx context.Context, opt *domain.CBAOption) error {
	opt.ID = uuid.New()
	_, err := r.exec(ctx,
		`INSERT INTO cba_options (id, question_id, option_text, media_url, media_type, is_correct) VALUES ($1,$2,$3,$4,$5,$6)`,
		opt.ID, opt.QuestionID, opt.OptionText, opt.MediaURL, opt.MediaType, opt.IsCorrect)
	return err
}

func (r *cbaRepository) GetCBAOptionsByQuestion(ctx context.Context, questionID uuid.UUID) ([]*domain.CBAOption, error) {
	rows, err := r.query(ctx,
		`SELECT id, question_id, option_text, media_url, media_type FROM cba_options WHERE question_id = $1`,
		questionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var opts []*domain.CBAOption
	for rows.Next() {
		var o domain.CBAOption
		if err := rows.Scan(&o.ID, &o.QuestionID, &o.OptionText, &o.MediaURL, &o.MediaType); err != nil {
			return nil, err
		}
		opts = append(opts, &o)
	}
	return opts, nil
}

func (r *cbaRepository) CreateOrGetSession(ctx context.Context, examID, studentID uuid.UUID) (*domain.CBASession, error) {
	// Try to get existing first
	var s domain.CBASession
	err := r.queryRow(ctx,
		`SELECT id, exam_id, student_id, waiting_room_joined_at, started_at, submitted_at, is_auto_submitted, final_score, status, created_at FROM cba_sessions WHERE exam_id = $1 AND student_id = $2`,
		examID, studentID).
		Scan(&s.ID, &s.ExamID, &s.StudentID, &s.WaitingRoomJoinedAt, &s.StartedAt, &s.SubmittedAt, &s.IsAutoSubmitted, &s.FinalScore, &s.Status, &s.CreatedAt)
	if err == nil {
		return &s, nil
	}
	if err != sql.ErrNoRows {
		return nil, err
	}
	// Create new session
	s.ID = uuid.New()
	s.ExamID = examID
	s.StudentID = studentID
	s.Status = domain.SessionWaiting
	now := time.Now()
	s.WaitingRoomJoinedAt = &now
	s.CreatedAt = now
	_, err = r.exec(ctx,
		`INSERT INTO cba_sessions (id, exam_id, student_id, waiting_room_joined_at, status) VALUES ($1,$2,$3,$4,$5)`,
		s.ID, s.ExamID, s.StudentID, s.WaitingRoomJoinedAt, s.Status)
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (r *cbaRepository) UpdateSessionStatus(ctx context.Context, sessionID uuid.UUID, status domain.SessionStatus, startedAt *time.Time) error {
	_, err := r.exec(ctx,
		`UPDATE cba_sessions SET status = $1, started_at = $2 WHERE id = $3`,
		status, startedAt, sessionID)
	return err
}

func (r *cbaRepository) SubmitSession(ctx context.Context, sessionID uuid.UUID, score float64, isAuto bool) error {
	now := time.Now()
	_, err := r.exec(ctx,
		`UPDATE cba_sessions SET status = $1, submitted_at = $2, final_score = $3, is_auto_submitted = $4 WHERE id = $5`,
		domain.SessionSubmitted, now, score, isAuto, sessionID)
	return err
}

func (r *cbaRepository) GetSession(ctx context.Context, examID, studentID uuid.UUID) (*domain.CBASession, error) {
	var s domain.CBASession
	err := r.queryRow(ctx,
		`SELECT id, exam_id, student_id, waiting_room_joined_at, started_at, submitted_at, is_auto_submitted, final_score, status, created_at FROM cba_sessions WHERE exam_id = $1 AND student_id = $2`,
		examID, studentID).
		Scan(&s.ID, &s.ExamID, &s.StudentID, &s.WaitingRoomJoinedAt, &s.StartedAt, &s.SubmittedAt, &s.IsAutoSubmitted, &s.FinalScore, &s.Status, &s.CreatedAt)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &s, err
}

func (r *cbaRepository) GetExpiredOngoingSessions(ctx context.Context) ([]*domain.CBASession, error) {
	rows, err := r.query(ctx,
		`SELECT cs.id, cs.exam_id, cs.student_id, cs.status
		 FROM cba_sessions cs
		 JOIN cba_exams ce ON cs.exam_id = ce.id
		 WHERE cs.status = 'ONGOING' AND ce.end_time <= CURRENT_TIMESTAMP`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var sessions []*domain.CBASession
	for rows.Next() {
		var s domain.CBASession
		if err := rows.Scan(&s.ID, &s.ExamID, &s.StudentID, &s.Status); err != nil {
			return nil, err
		}
		sessions = append(sessions, &s)
	}
	return sessions, nil
}

func (r *cbaRepository) UpsertAnswer(ctx context.Context, answer *domain.CBAAnswer) error {
	answer.ID = uuid.New()
	_, err := r.exec(ctx,
		`INSERT INTO cba_answers (id, session_id, question_id, option_id, essay_text, is_doubt, answered_at)
		 VALUES ($1,$2,$3,$4,$5,$6,CURRENT_TIMESTAMP)
		 ON CONFLICT (session_id, question_id) DO UPDATE SET
		   option_id = EXCLUDED.option_id,
		   essay_text = EXCLUDED.essay_text,
		   is_doubt = EXCLUDED.is_doubt,
		   answered_at = CURRENT_TIMESTAMP`,
		answer.ID, answer.SessionID, answer.QuestionID, answer.OptionID, answer.EssayText, answer.IsDoubt)
	return err
}

func (r *cbaRepository) GetAnswersBySession(ctx context.Context, sessionID uuid.UUID) ([]*domain.CBAAnswer, error) {
	rows, err := r.query(ctx,
		`SELECT id, session_id, question_id, option_id, essay_text, is_doubt, answered_at FROM cba_answers WHERE session_id = $1`,
		sessionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var answers []*domain.CBAAnswer
	for rows.Next() {
		var a domain.CBAAnswer
		if err := rows.Scan(&a.ID, &a.SessionID, &a.QuestionID, &a.OptionID, &a.EssayText, &a.IsDoubt, &a.AnsweredAt); err != nil {
			return nil, err
		}
		answers = append(answers, &a)
	}
	return answers, nil
}

func (r *cbaRepository) CheckOptionCorrect(ctx context.Context, optionID uuid.UUID) (bool, error) {
	var isCorrect bool
	err := r.queryRow(ctx, `SELECT is_correct FROM cba_options WHERE id = $1`, optionID).Scan(&isCorrect)
	if err != nil {
		return false, err
	}
	return isCorrect, nil
}

func (r *cbaRepository) GetStudentProfile(ctx context.Context, studentID uuid.UUID) (*domain.StudentExamProfile, error) {
	var p domain.StudentExamProfile
	err := r.queryRow(ctx,
		`SELECT u.id, u.name, u.identifier, COALESCE(u.face_encoding, '') as photo_url,
		        COALESCE(m.name, '') as major_name, COALESCE(cl.name, '') as class_name
		 FROM users u
		 LEFT JOIN classes cl ON u.class_id = cl.id
		 LEFT JOIN majors m ON cl.major_id = m.id
		 WHERE u.id = $1`,
		studentID).Scan(&p.StudentID, &p.Name, &p.NISN, &p.PhotoURL, &p.MajorName, &p.ClassName)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	return &p, err
}

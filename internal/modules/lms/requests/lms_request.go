package requests

type CreateCourseRequest struct {
	TenantID  string `json:"tenant_id" validate:"required,uuid"`
	Name      string `json:"name" validate:"required"`
	StaffID string `json:"staff_id" validate:"required,uuid"`
}

type CreateModuleRequest struct {
	CourseID string `json:"course_id" validate:"required,uuid"`
	Title    string `json:"title" validate:"required"`
	Content  string `json:"content" validate:"required"`
}

type CreateQuizRequest struct {
	ModuleID string `json:"module_id" validate:"required,uuid"`
	Title    string `json:"title" validate:"required"`
}

type CreateQuestionRequest struct {
	QuizID            string `json:"quiz_id" validate:"required,uuid"`
	Type              string `json:"type" validate:"required"`
	QuestionText      string `json:"question_text" validate:"required"`
	AIReferenceAnswer string `json:"ai_reference_answer"`
}

type SubmitAnswerRequest struct {
	QuestionID string `json:"question_id" validate:"required,uuid"`
	StudentID  string `json:"student_id" validate:"required,uuid"`
	AnswerText string `json:"answer_text" validate:"required"`
}

type CreateBookRequest struct {
	TenantID  string `json:"tenant_id" validate:"required,uuid"`
	Title     string `json:"title" validate:"required"`
	Author    string `json:"author"`
	ISBN      string `json:"isbn"`
	CoverURL  string `json:"cover_url" validate:"url"`
	FileURL   string `json:"file_url" validate:"url"`
	Stock     int    `json:"stock" validate:"gte=0"`
	IsDigital bool   `json:"is_digital"`
}

type BorrowBookRequest struct {
	BookID string `json:"book_id" validate:"required,uuid"`
	UserID string `json:"user_id" validate:"required,uuid"`
}

type ReturnBookRequest struct {
	BorrowingID string `json:"borrowing_id" validate:"required,uuid"`
}

type CreateEJournalRequest struct {
	TenantID       string `json:"tenant_id" validate:"required,uuid"`
	StudentID      string `json:"student_id" validate:"required,uuid"`
	AcademicYearID string `json:"academic_year_id" validate:"required,uuid"`
	ClassID        string `json:"class_id" validate:"required,uuid"`
	Title          string `json:"title" validate:"required"`
	Description    string `json:"description"`
	FileURL        string `json:"file_url" validate:"required,url"`
}

package routes

import (
	"e-presence-backend/controllers"
	"e-presence-backend/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutesApi(app *fiber.App) {
	api := app.Group("/api")

	// =====================================================
	// PUBLIC ROUTES (NO AUTH REQUIRED)
	// =====================================================
	authPublic := api.Group("/auth")
	authPublic.Post("/login", controllers.Login)
	authPublic.Post("/password/email", controllers.ForgotPassword)
	authPublic.Post("/password/reset", controllers.ResetPassword)
	authPublic.Post("/refresh", controllers.RefreshToken)
	authPublic.Get("/totalUsers", controllers.TotalUsers)
	authPublic.Post("/daftar-akun", controllers.DaftarAkun)
	authPublic.Post("/register-account", controllers.RegisterAccount)
	authPublic.Post("/forgot-password", controllers.ForgotPassword)

	code := api.Group("/code")
	code.Post("/send-verification", controllers.SendVerificationCode)
	code.Post("/verify", controllers.VerifyCode)

	faceAuth := api.Group("/face-recognition")
	faceAuth.Post("/authenticate", controllers.AuthenticateFace)
	faceAuth.Post("/attendance", controllers.FaceAttendance)

	api.Post("/presensi", controllers.Presensi)

	late := api.Group("/late")
	late.Get("/arrival", controllers.ShowArrivalForm)
	late.Post("/arrival", controllers.StoreArrival)
	late.Get("/departure", controllers.ShowDepartureForm)
	late.Post("/departure", controllers.StoreDeparture)

	reason := api.Group("/reason")
	reason.Get("/coming", controllers.ShowReasonForm)
	reason.Post("/coming", controllers.StoreReason)

	early := api.Group("/early")
	early.Get("/departure", controllers.ShowEarlyDepartureForm)
	early.Post("/departure", controllers.StoreEarlyDeparture)
	// =====================================================
	// PROTECTED ROUTES (AUTH REQUIRED)
	// =====================================================
	protected := api.Group("", middleware.RequireAuth)

	authProtected := protected.Group("/auth")
	authProtected.Get("/validate-token", controllers.ValidateToken)
	authProtected.Get("/me", controllers.GetMe)
	authProtected.Post("/logout", controllers.Logout)

	presence := protected.Group("/presensi")
	presence.Get("/charts", controllers.GetAttendanceData)

	leavedocument := protected.Group("/leave-documents")
	leavedocument.Post("/send", controllers.SendLeaveDocument)
	leavedocument.Get("/", controllers.GetLeaveDocuments)
	leavedocument.Get("/:id", controllers.GetLeaveDocument)
	leavedocument.Delete("/:id", controllers.DeleteLeaveDocument)

	members := protected.Group("/school-members")
	members.Get("/", controllers.GetSchoolMembers)
	members.Delete("/bulk-delete", controllers.BulkDeleteMembers)
	members.Get("/template", controllers.DownloadUserTemplate)
	members.Post("/import", controllers.ImportUserExcel)
	members.Get("/no-rfid", controllers.GetSchoolMembersNoRfid)
	members.Delete("/multiple", controllers.DeleteMultipleMembers);
	members.Post("/", controllers.CreateSchoolMember)
	members.Post("/rfid-connect", controllers.RfidConnect)
	members.Delete("/rfid/remove/:id", controllers.RemoveRfid)
	members.Get("/:id", controllers.GetMemberById)
	members.Post("/:id", controllers.UpdateSchoolMember)
	members.Delete("/:id", controllers.DeleteSchoolMember)

	kelas := protected.Group("/kelas")
	kelas.Post("/", controllers.UpsertKelas)

	users := protected.Group("/users")
	users.Get("/", controllers.GetUsers)
	users.Post("/", controllers.CreateUser)
	users.Delete("/bulk-delete", controllers.BulkDeleteUsers)
	users.Delete("/multiple", controllers.DeleteMultipleUsers)
	users.Post("/check-rfid-status", controllers.CheckRfidStatus)
	users.Patch("/linkedCard/:id", controllers.LinkedCard)
	users.Get("/linkedCard/:id", controllers.LinkedCard)
	users.Get("/checkStatusCard/:id", controllers.CheckStatusCard)
	users.Get("/getMyAccount/:id", controllers.GetMyAccount)
	users.Post("/:id/remove-rfid", controllers.RemoveRfid)
	users.Patch("/:id/ban", controllers.ToggleBanUser)
	users.Put("/:id", controllers.UpdateUser)
	users.Get("/:id", controllers.GetUserById)
	users.Delete("/:id", controllers.DeleteUser)

	admin := protected.Group("/admin-accounts")
	admin.Get("/", controllers.GetAdminAccounts)
	admin.Post("/", controllers.CreateAdmin)
	admin.Put("/:id", controllers.UpdateAdmin)
	admin.Delete("/:id", controllers.DeleteAdmin)

	settings := protected.Group("/settings")
	settings.Get("/:user_id", controllers.GetSettings)
	settings.Post("/:user_id", controllers.UpsertSetting)
	settings.Delete("/:id", controllers.DeleteSetting)

	days := protected.Group("/hari")
	days.Get("/", controllers.GetHari)
	days.Post("/", controllers.SaveHari)

	school := protected.Group("/sekolah")
	school.Get("/", controllers.GetSekolah)
	school.Put("/", controllers.UpdateSekolah)

	faceRegistration := protected.Group("/face-registration")
	faceRegistration.Post("/register", controllers.RegisterFace)
	faceRegistration.Get("/status/:user_id", controllers.CheckFaceRegistration)
	faceRegistration.Post("/reset/:nomor_induk", controllers.ResetFace)

	akun := protected.Group("/akun-user")
	akun.Patch("/ban-akun/:id", controllers.BanAccount)
	akun.Patch("/unban-akun/:id", controllers.UnbanAccount)

	dashboard := protected.Group("/dashboard")
	dashboard.Get("/stats", controllers.GetDashboardStats)
	dashboard.Get("/getChart", controllers.GetChart)

	photos := protected.Group("/photos")
	photos.Get("/", controllers.ListPhotos)
	photos.Post("/upload", controllers.UploadPhotos)
	photos.Delete("/delete", controllers.DeletePhoto)

	export := protected.Group("/export")
	export.Get("/presence", controllers.ExportPresence)

	connections := protected.Group("/connections")
	connections.Post("/connect", controllers.ConnectService)
	connections.Post("/disconnect", controllers.DisconnectService)
}

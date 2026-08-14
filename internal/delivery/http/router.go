package http

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/helmet"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/websocket/v2"

	// Core Module
	coreHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/delivery/http"
	coreRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/repository"
	coreUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/usecase"

	// Finance Module
	financeHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/delivery/http"
	financeRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/repository"
	financeUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/finance/usecase"

	// Scaffolded Modules
	attendanceHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/attendance/delivery/http"
	attendanceRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/attendance/repository"
	attendanceUc "neuracakrawira.asia/satu-sekolah-backend/internal/modules/attendance/usecase"

	careerHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/career/delivery/http"
	careerRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/career/repository"
	careerUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/career/usecase"

	// Communication Module
	// Communication Module
	commHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/delivery/http"
	commWs "neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/delivery/ws"
	commRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/repository"
	commUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/communication/usecase"
	evaluationHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/evaluation/delivery/http"
	evaluationRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/evaluation/repository"
	evaluationUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/evaluation/usecase"
	violationHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/violations/delivery/http"
	violationRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/violations/repository"
	violationUc "neuracakrawira.asia/satu-sekolah-backend/internal/modules/violations/usecase"

	calendarHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/calendar/delivery/http"

	calendarRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/calendar/repository"
	calendarUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/calendar/usecase"

	presenceHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/delivery/http"
	presenceRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/repository"
	presenceUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/presence/usecase"

	paymentHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/payment/delivery/http"
	paymentRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/payment/repository"
	paymentUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/payment/usecase"

	dashboardHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/dashboard/delivery/http"
	dashboardRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/dashboard/repository"
	dashboardUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/dashboard/usecase"

	notificationHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/notifications/delivery/http"
	notificationRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/notifications/repository"
	notificationUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/notifications/usecase"

	// Health (UKS & Cycles) Module
	healthHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/health/delivery/http"
	healthRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/health/repository"
	healthUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/health/usecase"
	inventoryHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/inventory/delivery/http"
	inventoryRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/inventory/repository"
	inventoryUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/inventory/usecase"

	// Library
	libraryHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/delivery/http"
	libraryRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/repository"
	libraryUc "neuracakrawira.asia/satu-sekolah-backend/internal/modules/library/usecase"

	// Performance (PKL)
	performanceHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/delivery/http"
	performanceDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/domain"
	performanceRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/repository"
	performanceUc "neuracakrawira.asia/satu-sekolah-backend/internal/modules/performance/usecase"
	portfolioHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/delivery/http"
	portfolioRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/repository"
	portfolioUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/portfolio/usecase"
	spmbHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/delivery/http"
	spmbRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/repository"
	spmbUc "neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/usecase"
	usersHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/users/delivery/http"

	// Academic & LMS Module
	academicHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/delivery/http"
	academicRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/repository"
	academicUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/academic/usecase"

	// CBA (Computer Based Assessment) Module
	cbaHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/delivery/http"
	cbaRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/repository"
	cbaUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/cba/usecase"

	// Reports Module
	reportHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/reports/delivery/http"
	reportRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/reports/repository"
	reportUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/reports/usecase"

	// PKG (Penilaian Kinerja Guru) Module
	pkgHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/delivery/http"
	pkgRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/repository"
	pkgUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/pkg/usecase"

	// AI Module
	aiHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/delivery/http"
	aiRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/repository"
	aiUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/usecase"

	// Canteen Module
	canteenHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/canteen/delivery/http"
	canteenRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/canteen/repository"
	canteenUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/canteen/usecase"

	// Gate Pass Module
	gatepassHttp "neuracakrawira.asia/satu-sekolah-backend/internal/modules/gatepass/delivery/http"
	gatepassRepo "neuracakrawira.asia/satu-sekolah-backend/internal/modules/gatepass/repository"
	gatepassUsecase "neuracakrawira.asia/satu-sekolah-backend/internal/modules/gatepass/usecase"

	// Middleware
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"

	// Infrastructure Cloud
	"neuracakrawira.asia/satu-sekolah-backend/internal/infrastructure/cloud/aws"

	// Config
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/pkg/cache"

	"github.com/redis/go-redis/v9"
)

// SetupRouter initializes the Fiber app, injects dependencies, and defines routes.
func SetupRouter(db *sql.DB, cfg *config.Config) *fiber.App {
	app := fiber.New(fiber.Config{
		AppName:   "Satu Sekolah Backend API v1.0",
		BodyLimit: 500 * 1024 * 1024, // 500 MB (Maksimal untuk Video)
		// Prevent internal stack traces leaking in production error responses.
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(fiber.Map{"error": err.Error()})
		},
	})

	// ==========================================
	// GLOBAL MIDDLEWARE: Security Hardening
	// ==========================================
	app.Use(logger.New())
	app.Use(recover.New())

	// Helmet: sets secure HTTP response headers to mitigate XSS, clickjacking, etc.
	app.Use(helmet.New())

	// CORS: only allow trusted origins. Adjust allowed origins via config if needed.
	allowedOrigins := "https://satusekolah.id, https://www.satusekolah.id"
	if cfg.App.Env == "development" || cfg.App.Env == "local" {
		allowedOrigins = "http://localhost:3000, http://127.0.0.1:3000, http://localhost:5173, http://127.0.0.1:5173, https://satusekolah.id, https://www.satusekolah.id"
	}

	app.Use(cors.New(cors.Config{
		AllowOrigins:     allowedOrigins, // Dynamic based on environment
		AllowMethods:     "GET,POST,PUT,PATCH,DELETE,OPTIONS",
		AllowHeaders:     "Origin, Content-Type, Accept, Authorization, X-Tenant-ID",
		AllowCredentials: true,  // Diperlukan jika menggunakan cookies/session lintas subdomain
		MaxAge:           86400, // 24 hours preflight cache
	}))

	// Smart Rate Limiter: Limit berdasarkan Token/Device ID. Melindungi NAT sekolah.
	app.Use(limiter.New(limiter.Config{
		Max:        100, // 100 request per menit per User/Device
		Expiration: 1 * time.Minute,
		KeyGenerator: func(c *fiber.Ctx) string {
			// 1. Cek IoT Device ID
			deviceID := c.Get("X-Device-ID")
			if deviceID != "" {
				return "device:" + deviceID
			}

			// 2. Cek JWT Token (User yang sudah login)
			authHeader := c.Get("Authorization")
			if authHeader != "" {
				return "token:" + authHeader
			}

			// 3. Fallback: Gunakan IP (untuk request anonim seperti login/register)
			return "ip:" + c.IP()
		},
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "too many requests, please slow down",
			})
		},
	}))

	// Communication Module (WebSocket & REST)
	commRepository := commRepo.NewCommunicationRepository(db)
	commUc := commUsecase.NewCommunicationUsecase(commRepository)
	wsHub := commWs.NewHub(cfg.JWT.Secret, commUc)
	go wsHub.Run()
	commWsHandler := commWs.NewCommunicationWsHandler(commUc, wsHub)
	commHandler := commHttp.NewCommunicationHandler(commUc)

	// ==========================================
	// CACHE WIRING
	// ==========================================
	var redisClient *redis.Client
	if cfg.App.CacheDriver == "redis" {
		redisClient = redis.NewClient(&redis.Options{
			Addr:     fmt.Sprintf("%s:%s", cfg.Redis.Host, cfg.Redis.Port),
			Password: cfg.Redis.Password,
			DB:       cfg.Redis.DB,
		})
	}
	appCache := cache.NewCache(cfg, db, redisClient, cfg.Database.Driver)

	// Background cleanup: purge expired DB cache entries every hour (no-op for Redis).
	go func() {
		ticker := time.NewTicker(1 * time.Hour)
		defer ticker.Stop()
		for range ticker.C {
			if err := appCache.CleanupExpired(context.Background()); err != nil {
				log.Printf("[cache] cleanup error: %v", err)
			}
		}
	}()

	// ==========================================
	// DEPENDENCY INJECTION WIRING
	// ==========================================

	// Core (Tenants & RBAC)
	coreRepository := coreRepo.NewCoreRepository(db, appCache)
	coreUc := coreUsecase.NewCoreUsecase(coreRepository)
	coreHandler := coreHttp.NewTenantHandler(coreUc)

	// Canteen Repository (Needed by Finance for VA checks)
	canteenRepository := canteenRepo.NewCanteenRepository(db)

	// Finance (Web3 Ledger & Billing)
	financeRepository := financeRepo.NewLedgerRepository(db)
	billingRepository := financeRepo.NewBillingRepository(db)

	financeUc := financeUsecase.NewLedgerUsecase(financeRepository, coreRepository, canteenRepository, billingRepository, cfg.Ledger.HMACSecret)
	financeHandler := financeHttp.NewLedgerHandler(financeUc, cfg)

	billingUc := financeUsecase.NewBillingUsecase(billingRepository, financeUc, coreRepository, cfg.Ledger.HMACSecret, cfg.Midtrans.ServerKey)
	billingHandler := financeHttp.NewBillingHandler(billingUc, cfg)

	// Attendance (IoT & Face Rekognition)
	rekognitionClient, err := aws.NewRekognitionClient(context.Background(), cfg)
	if err != nil {
		log.Printf("Warning: Failed to initialize AWS Rekognition: %v", err)
	}
	attendanceRepository := attendanceRepo.NewAttendanceRepository(db)
	attendanceUsecase := attendanceUc.NewAttendanceUsecase(attendanceRepository, rekognitionClient)
	attendanceHandler := attendanceHttp.NewAttendanceHandler(attendanceUsecase)

	// Presence Module (Mobile App read operations)
	presenceRepository := presenceRepo.NewPresenceRepository(db)
	presenceUc := presenceUsecase.NewPresenceUsecase(presenceRepository)
	presenceHandler := presenceHttp.NewPresenceHandler(presenceUc)

	// Violations (Student & Staff violation point tracking)
	violationRepository := violationRepo.NewViolationRepository(db)
	violationUsecase := violationUc.NewViolationUsecase(violationRepository)
	violationHandler := violationHttp.NewViolationHandler(violationUsecase)

	// Calendar Module
	calendarRepository := calendarRepo.NewCalendarRepository(db)
	calendarUc := calendarUsecase.NewCalendarUsecase(calendarRepository)
	calendarHandler := calendarHttp.NewCalendarHandler(calendarUc)

	// Payment Module
	paymentRepository := paymentRepo.NewPaymentRepository(db)
	paymentUc := paymentUsecase.NewPaymentUsecase(paymentRepository)
	paymentHandler := paymentHttp.NewPaymentHandler(paymentUc)

	// Dashboard Module
	dashboardRepository := dashboardRepo.NewDashboardRepository(db)
	dashboardUc := dashboardUsecase.NewDashboardUsecase(dashboardRepository)
	dashboardHandler := dashboardHttp.NewDashboardHandler(dashboardUc)

	// Notifications Module
	notificationRepository := notificationRepo.NewNotificationRepository(db)
	notificationUc := notificationUsecase.NewNotificationUsecase(notificationRepository)
	notificationHandler := notificationHttp.NewNotificationHandler(notificationUc)

	libraryRepository := libraryRepo.NewLibraryRepository(db)
	libraryUsecase := libraryUc.NewLibraryUsecase(libraryRepository, coreRepository, financeUc)
	libraryHandler := libraryHttp.NewLibraryHandler(libraryUsecase)

	pklRepository := performanceRepo.NewPklRepository(db)
	// pklUsecase depends on libraryUc and pkgUc (wired below after those are created)
	// Temporarily define vars here; assigned after dependencies are ready.
	var pklUsecase performanceDomain.PklUsecase

	// inventoryHandler wired below after pkgUc is ready
	var inventoryHandler *inventoryHttp.InventoryHandler

	// Academic & LMS
	academicRepository := academicRepo.NewAcademicRepository(db)
	academicUc := academicUsecase.NewAcademicUsecase(academicRepository)
	academicHandler := academicHttp.NewAcademicHandler(academicUc)

	reportCardRepository := academicRepo.NewReportCardRepository(db)
	reportCardUc := academicUsecase.NewReportCardUsecase(reportCardRepository)
	reportCardHandler := academicHttp.NewReportCardHandler(reportCardUc)

	// CBA
	cbaRepository := cbaRepo.NewCBARepository(db)
	cbaUc := cbaUsecase.NewCBAUsecase(cbaRepository)
	cbaHandler := cbaHttp.NewCBAHandler(cbaUc)

	// PKG
	pkgRepository := pkgRepo.NewPkgRepository(db)
	pkgUc := pkgUsecase.NewPkgUsecase(pkgRepository)
	pkgHandler := pkgHttp.NewPkgHandler(pkgUc)

	// Wire PKL usecase now that libraryUsecase and pkgUc are ready
	pklUsecase = performanceUc.NewPklUsecase(pklRepository, coreRepository, libraryUsecase, pkgUc, cfg.App.EncryptionKey)
	performanceHandler := performanceHttp.NewPerformanceHandler(pklUsecase)

	// Wire Inventory usecase now that pkgUc is ready
	inventoryRepository := inventoryRepo.NewInventoryRepository(db)
	inventoryUc := inventoryUsecase.NewInventoryUsecase(inventoryRepository, appCache, pkgUc)
	inventoryHandler = inventoryHttp.NewInventoryHandler(inventoryUc)

	// Reports
	reportRepository := reportRepo.NewReportRepository(db)
	reportUc := reportUsecase.NewReportUsecase(reportRepository)
	reportHandler := reportHttp.NewReportHandler(reportUc)

	// Users & Auth — shares coreRepository so no extra DB layer needed
	usersHandler := usersHttp.NewUserHandler(coreRepository, cfg)

	// AI (Gemini Token Quota + Feature Control)
	aiRepository := aiRepo.NewAIRepository(db)
	aiHandler := aiHttp.NewAIHandler(aiRepository, cfg)
	aiModuleUc := aiUsecase.NewAIModuleUsecase(aiRepository)
	aiModuleHandler := aiHttp.NewAIModuleHandler(aiModuleUc)

	// Health (UKS & Cycles)
	healthRepository := healthRepo.NewHealthRepository(db)
	healthUc := healthUsecase.NewHealthUsecase(healthRepository, coreRepository, aiRepository)
	healthHandler := healthHttp.NewHealthHandler(healthUc)

	// Canteen (Digital Canteen + POS)
	canteenUc := canteenUsecase.NewCanteenUsecase(canteenRepository, coreRepository, financeUc, aiRepository, cfg.Ledger.HMACSecret)
	canteenHandler := canteenHttp.NewCanteenHandler(canteenUc)

	// Gate Pass (Surat Izin Keluar)
	gatepassRepository := gatepassRepo.NewGatePassRepository(db)
	gatepassUc := gatepassUsecase.NewGatePassUsecase(gatepassRepository, coreRepository)
	gatepassHandler := gatepassHttp.NewGatePassHandler(gatepassUc)

	// Career (BKK)
	careerRepoImpl := careerRepo.NewCareerRepository(db)

	// Portfolio (LinkedIn Style)
	portfolioRepoImpl := portfolioRepo.NewPortfolioRepository(db)
	portfolioUc := portfolioUsecase.NewPortfolioUsecase(portfolioRepoImpl, aiModuleUc)
	portfolioHandler := portfolioHttp.NewPortfolioHandler(portfolioUc)

	// Inject portfolio repo to career so it can load applicant portfolios
	careerUc := careerUsecase.NewCareerUsecase(careerRepoImpl, portfolioRepoImpl)
	careerHandler := careerHttp.NewCareerHandler(careerUc)
	// Evaluation Module
	evaluationRepository := evaluationRepo.NewEvaluationRepository(db)
	evaluationUc := evaluationUsecase.NewEvaluationUsecase(evaluationRepository)
	evaluationHandler := evaluationHttp.NewEvaluationHandler(evaluationUc)

	// SPMB Module
	spmbRepository := spmbRepo.NewSpmbRepository(db)
	spmbUsecase := spmbUc.NewSpmbUsecase(spmbRepository)
	spmbHandler := spmbHttp.NewSpmbHandler(spmbUsecase)

	// WebTorrent Handler (shared media upload + magnet link resolver)
	torrentHandler := coreHttp.NewTorrentHandler(db)

	// ==========================================
	// ROUTE MIDDLEWARE SHORTCUTS
	// ==========================================
	jwtAuth := middleware.JWTAuth(cfg.JWT.Secret)
	adminOnly := middleware.RequireRole("Admin")
	manageAI := middleware.RequirePermission(db, "MANAGE_AI")
	manageCBA := middleware.RequirePermission(db, "MANAGE_CBA")

	// ==========================================
	// ROUTES CONFIGURATION
	// ==========================================
	apiV1 := app.Group("/api/v1")

	// ---- Public Routes (no auth required) ----

	// Users & Auth
	// Strict rate limiter for login: max 5 attempts/minute/IP (anti-brute-force)
	loginLimiter := limiter.New(limiter.Config{
		Max:        5,
		Expiration: 1 * time.Minute,
		KeyGenerator: func(c *fiber.Ctx) string {
			return c.IP()
		},
		LimitReached: func(c *fiber.Ctx) error {
			return c.Status(fiber.StatusTooManyRequests).JSON(fiber.Map{
				"error": "too many login attempts, please try again in 1 minute",
			})
		},
	})
	apiV1.Post("/users/register", usersHandler.RegisterParent)
	apiV1.Post("/users/login", loginLimiter, usersHandler.Login)
	apiV1.Post("/users/auth/google", usersHandler.GoogleLogin)
	apiV1.Get("/users/profile", jwtAuth, usersHandler.GetProfile)
	apiV1.Put("/users/profile", jwtAuth, usersHandler.UpdateProfile)
	userGroup := apiV1.Group("/users", jwtAuth)
	userGroup.Put("/public-key", usersHandler.UploadPublicKey)
	userGroup.Get("/children", usersHandler.GetChildren)
	apiV1.Get("/users/notification-settings", jwtAuth, usersHandler.GetNotificationSettings)
	apiV1.Put("/users/notification-settings", jwtAuth, usersHandler.UpdateNotificationSettings)
	apiV1.Put("/users/password", jwtAuth, usersHandler.ChangePassword)

	apiV1.Get("/faqs", coreHandler.GetFaqs)

	// Tenant Registration (called by web main — internal, ideally protected by API key)
	apiV1.Post("/tenants/register", coreHandler.RegisterTenant)

	// SPMB Public (Orphan Parents viewing schools)
	apiV1.Get("/public/schools", spmbHandler.GetPublicSchools)

	// Webhooks (no JWT — verified by Midtrans HMAC signature inside handler)
	apiV1.Post("/webhooks/midtrans/ai-tokens", aiHandler.WebhookTokenPurchase)
	apiV1.Post("/webhooks/midtrans/invoices", billingHandler.MidtransWebhook)

	// ---- Authenticated Routes (JWT required) ----

	// Users
	apiV1.Get("/users/profile", jwtAuth, usersHandler.GetProfile)

	// Tenant profile
	apiV1.Get("/tenants/:id", jwtAuth, coreHandler.GetTenantProfile)

	// Roles & Permissions
	apiV1.Get("/permissions", jwtAuth, coreHandler.GetPermissions)

	// Finance (any authenticated user)
	financeGroup := apiV1.Group("/finance", jwtAuth)
	financeGroup.Post("/transfer", financeHandler.TransferP2P)
	financeGroup.Post("/ledger/transaction", financeHandler.RecordTransaction)
	financeGroup.Get("/ledger/history", financeHandler.GetTransactionHistory)
	financeGroup.Get("/midtrans/client-key", financeHandler.GetMidtransClientKey)
	// Finance - Tagihan & Pembayaran
	financeGroup.Post("/fees/generate", billingHandler.GenerateMassInvoices)          // Keuangan: buat tagihan massal
	financeGroup.Get("/invoices", billingHandler.GetMyInvoices)                       // Semua: lihat tagihan (siswa/ortu)
	financeGroup.Get("/invoices/va/:va", billingHandler.GetInvoiceByVA)               // Siswa/Ortu: auto-fetch tagihan via VA 15 digit
	financeGroup.Post("/invoices/pay-va", billingHandler.PayInvoiceVA)                // Siswa/Ortu: bayar tagihan via VA 15 digit
	financeGroup.Post("/invoices/pay-dynamic-qr", billingHandler.PayInvoiceDynamicQR) // Siswa/Ortu: bayar via QR
	financeGroup.Post("/invoices/:id/pay-cash", billingHandler.InitiateCashPayment)   // Keuangan: bayar tunai Midtrans
	financeGroup.Get("/reports/invoices", billingHandler.GetFinanceReport)            // Keuangan: laporan rekap tagihan

	// Presence / Attendance (Mobile App views)
	attendanceGroup := apiV1.Group("/attendance", jwtAuth)
	attendanceGroup.Get("/summary", presenceHandler.GetSummary)
	attendanceGroup.Get("/weekly", presenceHandler.GetWeekly)
	attendanceGroup.Get("/history", presenceHandler.GetHistory)

	// Violations (Mobile App views & Staff management)
	violationsGroup := apiV1.Group("/violations", jwtAuth)
	violationsGroup.Get("/history", violationHandler.GetUserViolationHistory) // Use the updated handler for mobile
	violationsGroup.Get("/types", violationHandler.GetViolationTypes)
	violationsGroup.Post("/types", adminOnly, violationHandler.CreateViolationType)
	violationsGroup.Patch("/types/:id/toggle", violationHandler.ToggleViolationType)
	violationsGroup.Delete("/types/:id", violationHandler.DeleteViolationType)
	violationsGroup.Post("/record", violationHandler.RecordViolation)
	violationsGroup.Get("/users/:user_id", violationHandler.GetUserViolationHistory)

	// Calendar (Admin for modifying, others for reading)
	calendarGroup := apiV1.Group("/calendar", jwtAuth)
	calendarGroup.Get("/month/:year/:month", calendarHandler.GetEventsByMonth)
	calendarGroup.Post("/events", adminOnly, calendarHandler.CreateEvent)
	calendarGroup.Put("/events/:id", adminOnly, calendarHandler.UpdateEvent)
	calendarGroup.Delete("/events/:id", adminOnly, calendarHandler.DeleteEvent)

	// Dashboard
	dashboardGroup := apiV1.Group("/dashboard", jwtAuth)
	dashboardGroup.Get("/summary", dashboardHandler.GetSummary)
	dashboardGroup.Get("/activities", dashboardHandler.GetActivities)

	// Notifications
	notifGroup := apiV1.Group("/notifications", jwtAuth)
	notifGroup.Get("/", notificationHandler.GetNotifications)
	notifGroup.Put("/:id/read", notificationHandler.MarkAsRead)
	notifGroup.Delete("/:id", notificationHandler.DeleteNotification)

	// Payment Module
	paymentGroup := apiV1.Group("/payments", jwtAuth)
	paymentGroup.Get("/active", paymentHandler.GetActiveBills)
	paymentGroup.Get("/history", paymentHandler.GetTransactions)
	paymentGroup.Post("/pay", paymentHandler.PayBill)

	// SPMB (Authenticated, some for parents, some for staff)
	spmbGroup := apiV1.Group("/spmb", jwtAuth)
	spmbGroup.Post("/register", spmbHandler.RegisterSpmb)
	spmbGroup.Get("/my-applications", spmbHandler.GetMyApplications)
	spmbGroup.Patch("/registrations/:id/approve", spmbHandler.ApproveRegistration)
	spmbGroup.Post("/registrations/:id/reregister", spmbHandler.ReRegister)
	spmbGroup.Post("/registrations/:id/pay", spmbHandler.SimulatePayment)

	// Academic & LMS
	academicGroup := apiV1.Group("/academic", jwtAuth)
	academicGroup.Get("/courses", academicHandler.GetCourses)
	academicGroup.Post("/courses", academicHandler.CreateCourse)
	academicGroup.Post("/modules", academicHandler.CreateModule)
	academicGroup.Get("/modules", academicHandler.GetModules)
	academicGroup.Post("/submissions", academicHandler.SubmitWork)
	academicGroup.Get("/submissions", academicHandler.GetSubmissions)
	academicGroup.Post("/submissions/:id/grade", academicHandler.GradeSubmission)
	academicGroup.Post("/assign-target", academicHandler.AssignTarget)

	// Schedules
	academicGroup.Get("/schedules/student/day/:dayOfWeek", academicHandler.GetStudentSchedules)

	academicGroup.Get("/report-cards/template", reportCardHandler.GetTemplate)
	academicGroup.Post("/report-cards/upload", reportCardHandler.UploadGrades)
	academicGroup.Get("/report-cards/leaderboard", reportCardHandler.GetLeaderboard)

	// New Student Rapor Endpoints
	academicGroup.Get("/report-cards/student/:studentId", reportCardHandler.GetStudentReportCard)
	academicGroup.Get("/report-cards/student/:studentId/semesters", reportCardHandler.GetStudentSemesters)
	academicGroup.Get("/grades/student/:studentId/subject/:courseId", reportCardHandler.GetStudentDetailedGrades)
	academicGroup.Put("/report-cards/:id/notes", reportCardHandler.UpdateReportCardNotes)
	academicGroup.Get("/report-cards/student/:studentId/pdf", reportCardHandler.GenerateReportCardPDF)

	// CBA (Computer Based Assessment — UTBK-Style)
	cbaGroup := apiV1.Group("/cba", jwtAuth)

	// Server time (public within auth, prevents device clock manipulation)
	cbaGroup.Get("/time", cbaHandler.GetServerTime)

	// Folder management (MANAGE_CBA required)
	cbaGroup.Post("/folders", manageCBA, cbaHandler.CreateFolder)
	cbaGroup.Get("/folders", cbaHandler.GetFolders)                                // All authenticated users
	cbaGroup.Put("/folders/:id/refresh-token", manageCBA, cbaHandler.RefreshToken) // Teacher/Admin refreshes token
	cbaGroup.Post("/folders/:id/verify-token", cbaHandler.VerifyToken)             // Student submits token
	cbaGroup.Get("/folders/:id/exams", cbaHandler.GetTodayExams)                   // Today's exams in folder

	// Exam management (MANAGE_CBA required)
	cbaGroup.Post("/exams", manageCBA, cbaHandler.CreateExam)
	cbaGroup.Post("/exam-questions", manageCBA, cbaHandler.AddCBAQuestion)
	cbaGroup.Post("/exam-options", manageCBA, cbaHandler.AddCBAOption)

	// Student exam flow
	cbaGroup.Post("/exams/:id/join", cbaHandler.JoinWaitingRoom)      // Enter waiting room + read T&C
	cbaGroup.Post("/exams/:id/start", cbaHandler.StartExam)           // Start exam (server-time gated)
	cbaGroup.Get("/exams/:id/questions", cbaHandler.GetExamQuestions) // Get questions + navigation state
	cbaGroup.Post("/exams/:id/answers", cbaHandler.SaveAnswer)        // Save/update one answer
	cbaGroup.Post("/exams/:id/submit", cbaHandler.SubmitExam)         // Manual submit

	// Legacy LMS Quizzes (lightweight)
	cbaGroup.Post("/quizzes", manageCBA, cbaHandler.CreateQuiz)
	cbaGroup.Get("/quizzes", cbaHandler.GetQuizzes)
	cbaGroup.Get("/quizzes/:id", cbaHandler.GetQuizByID)
	cbaGroup.Post("/questions", manageCBA, cbaHandler.AddQuestion)
	cbaGroup.Post("/options", manageCBA, cbaHandler.AddOption)
	cbaGroup.Post("/answers", cbaHandler.SubmitAnswer)
	cbaGroup.Get("/answers", cbaHandler.GetStudentAnswers)

	// PKG (Staff Performance)
	pkgGroup := apiV1.Group("/pkg", jwtAuth)
	pkgGroup.Post("/submissions", pkgHandler.SubmitDocument)
	pkgGroup.Get("/submissions", pkgHandler.GetMySubmissions)

	// Teacher Evaluations
	evaluationGroup := apiV1.Group("/evaluations", jwtAuth)
	evaluationGroup.Get("/categories", evaluationHandler.GetCategories)
	evaluationGroup.Get("/active-period", evaluationHandler.GetActivePeriod)
	evaluationGroup.Get("/teachers/eligible", evaluationHandler.GetEligibleTeachers)
	evaluationGroup.Post("/submit", evaluationHandler.SubmitEvaluation)
	evaluationGroup.Get("/results/:teacherId", evaluationHandler.GetTeacherResults)

	// Reports
	reportsGroup := apiV1.Group("/reports", jwtAuth)
	reportsGroup.Get("/attendance", reportHandler.GetAttendanceReport)
	reportsGroup.Get("/financial", reportHandler.GetFinancialReport)
	reportsGroup.Get("/academic", reportHandler.GetAcademicReport)

	// Attendance
	attendanceGroup.Post("/face/register", attendanceHandler.RegisterFace)

	// IoT Universal Endpoint (Could be protected by API Key middleware in the future instead of JWT)
	iotGroup := apiV1.Group("/iot")
	iotGroup.Post("/presence", attendanceHandler.RouteIotPresence)
	// Kantin IoT
	iotGroup.Get("/canteen/order/:rfidPaymentCode", canteenHandler.GetOrderForIoT)
	iotGroup.Post("/canteen/pay-rfid", canteenHandler.PayViaRFID)
	// Tagihan Sekolah IoT (RFID)
	iotGroup.Get("/finance/invoice/:rfidPaymentCode", billingHandler.GetInvoiceForIoT)
	iotGroup.Post("/finance/pay-rfid", billingHandler.PayInvoiceRFID)

	// Health & UKS
	healthGroup := apiV1.Group("/health", jwtAuth)
	healthGroup.Get("/records", healthHandler.GetRecords)
	healthGroup.Post("/records", healthHandler.AddHealthRecord)
	healthGroup.Post("/cycles/start", healthHandler.StartCycle)
	healthGroup.Post("/cycles/stop", healthHandler.StopCycle)
	healthGroup.Post("/ribbons/borrow", healthHandler.BorrowRibbon)
	healthGroup.Get("/watchlist", healthHandler.GetOverdueWatchlist)
	healthGroup.Post("/force-stop", healthHandler.ForceStopCycle)

	// UKS Health Endpoints
	healthGroup.Get("/student/:studentId/summary", healthHandler.GetStudentHealthSummary)
	healthGroup.Get("/student/:studentId/checkups", healthHandler.GetStudentCheckups)
	healthGroup.Post("/checkups", healthHandler.AddHealthCheckup)
	healthGroup.Get("/student/:studentId/history", healthHandler.GetStudentMedicalHistory)
	healthGroup.Put("/student/:studentId/history", healthHandler.UpdateMedicalHistory)

	// Library (Books, Borrowing, Digital, Journals)
	libraryGroup := apiV1.Group("/library", jwtAuth)
	libraryGroup.Post("/books", libraryHandler.AddBook)
	libraryGroup.Post("/borrowings/request", libraryHandler.RequestBorrow)
	libraryGroup.Post("/borrowings/approve", libraryHandler.ApproveBorrow)
	libraryGroup.Post("/borrowings/scan-borrow", libraryHandler.ScanBorrowQR)
	libraryGroup.Post("/borrowings/scan-return/check", libraryHandler.ReturnScanCheck)
	libraryGroup.Post("/borrowings/scan-return/confirm", libraryHandler.ReturnScanConfirm)
	libraryGroup.Post("/digital-books/purchase", libraryHandler.PurchaseDigitalBook)
	libraryGroup.Post("/journals", libraryHandler.UploadJournal)
	libraryGroup.Post("/journals/approve", libraryHandler.ApproveJournal)

	// Career (BKK - Bursa Kerja Khusus)
	careerGroup := apiV1.Group("/career", jwtAuth)
	careerGroup.Get("/vacancies/public", careerHandler.GetPublicJobs)                 // Semua (lintas sekolah)
	careerGroup.Get("/vacancies/local", careerHandler.GetLocalJobs)                   // Hanya tenant ini
	careerGroup.Post("/vacancies", careerHandler.CreateJobVacancy)                    // Admin/BKK buat lowongan
	careerGroup.Post("/vacancies/:id/apply", careerHandler.ApplyJob)                  // User melamar
	careerGroup.Get("/applications/my", careerHandler.GetMyApplications)              // User lihat lamaran sendiri
	careerGroup.Get("/vacancies/:id/applications", careerHandler.GetJobApplications)  // BKK lihat pelamar
	careerGroup.Patch("/applications/:appId/review", careerHandler.ReviewApplication) // BKK review lamaran

	// Performance & PKL
	performanceGroup := apiV1.Group("/performance", jwtAuth)
	performanceGroup.Get("/records", performanceHandler.GetPerformances)
	performanceGroup.Post("/pkl", performanceHandler.ReportPKL)
	performanceGroup.Post("/pkl/evaluate", performanceHandler.EvaluatePKL)

	// PKL Mentoring & Journals
	performanceGroup.Post("/pkl/mentors/assign", performanceHandler.AssignMentors)
	performanceGroup.Post("/pkl/mentors/schedules", performanceHandler.CreateSchedule)
	performanceGroup.Post("/pkl/schedules/:id/submit", performanceHandler.SubmitJournal)
	performanceGroup.Post("/pkl/journals/:id/review", performanceHandler.ReviewJournal)

	// PKL Final Reports
	performanceGroup.Post("/pkl/final-reports/settings", performanceHandler.ConfigureFinalReportSetting)
	performanceGroup.Post("/pkl/final-reports", performanceHandler.SubmitFinalReport)
	performanceGroup.Post("/pkl/final-reports/:id/verify", performanceHandler.VerifyFinalReport)

	// Hubin Monitoring (E-Kinerja)
	performanceGroup.Post("/pkl/monitoring", performanceHandler.ReportHubinMonitoring)

	// Communication Module
	commGroup := apiV1.Group("/communication", jwtAuth)
	commGroup.Get("/contacts", commHandler.GetContacts)
	commGroup.Get("/rooms", commHandler.GetRoomSummaries)
	commGroup.Post("/rooms/initiate", commHandler.InitiateRoom)
	commGroup.Get("/rooms/:roomId/messages", commHandler.GetMessages)

	// Portfolio (LinkedIn Style)
	portfolioGroup := apiV1.Group("/portfolio", jwtAuth)
	portfolioGroup.Get("/", portfolioHandler.GetMyPortfolio)                    // Semua User
	portfolioGroup.Put("/", portfolioHandler.UpdateSummary)                     // Update summary/CV
	portfolioGroup.Post("/experiences", portfolioHandler.AddExperience)         // Tambah pengalaman
	portfolioGroup.Post("/import/linkedin", portfolioHandler.ImportLinkedInPDF) // Import dari PDF LinkedIn

	// SPMB (old batch route merged here)
	spmbGroup.Get("/batches", spmbHandler.GetBatches)

	// Inventory
	invGroup := apiV1.Group("/inventory", jwtAuth)
	invGroup.Get("/items", inventoryHandler.GetInventories)
	invGroup.Post("/items", middleware.RequirePermission(db, "MANAGE_INVENTORY"), inventoryHandler.CreateItem)
	invGroup.Post("/items/:id/reports", middleware.RequirePermission(db, "MANAGE_INVENTORY"), inventoryHandler.ReportCondition)

	// ==========================================
	// CANTEEN ROUTES (JWT required)
	// ==========================================
	canteenGroup := apiV1.Group("/canteen", jwtAuth)
	canteenGroup.Post("/shop", canteenHandler.CreateShop)                                    // Owner: create shop
	canteenGroup.Post("/items", canteenHandler.AddItem)                                      // Owner: add menu item
	canteenGroup.Post("/discounts", canteenHandler.AddDiscount)                              // Owner: add discount
	canteenGroup.Post("/cart", canteenHandler.AddToCart)                                     // Buyer: add to cart
	canteenGroup.Post("/checkout", canteenHandler.Checkout)                                  // Buyer: checkout cart (PIN)
	canteenGroup.Post("/pos/order", canteenHandler.CreatePOSOrder)                           // Owner: POS create order
	canteenGroup.Patch("/pos/orders/:id/payment-method", canteenHandler.SwitchPaymentMethod) // Owner: ganti metode bayar
	canteenGroup.Post("/pay-dynamic-qr", canteenHandler.PayViaDynamicQR)                     // Buyer: POS scan QR (PIN)
	canteenGroup.Get("/order/va/:va", canteenHandler.GetOrderForVA)                          // Buyer: auto-fetch order via VA 15 digit
	canteenGroup.Post("/pay-va", canteenHandler.PayViaVA)                                    // Buyer: pay via VA 15 digit (PIN)
	canteenGroup.Patch("/orders/:id/status", canteenHandler.UpdateOrderStatus)               // Owner: update status
	canteenGroup.Get("/reports/financial", canteenHandler.GetFinancialReport)                // Owner: financial report
	canteenGroup.Get("/reports/insight", canteenHandler.GetAIInsight)                        // Owner: AI business insight

	// ==========================================
	// GATE PASS ROUTES (JWT required)
	// ==========================================
	gatepassGroup := apiV1.Group("/gatepass", jwtAuth)
	gatepassGroup.Post("/request", gatepassHandler.SubmitRequest)       // Student: request exit
	gatepassGroup.Post("/:id/approve", gatepassHandler.ProcessApproval) // Approver: approve/reject
	gatepassGroup.Post("/scan-exit", gatepassHandler.ScanExitQR)        // Guard: scan exit QR
	gatepassGroup.Post("/scan-return", gatepassHandler.ScanReturnQR)    // Guard: scan return QR

	// Admin Gate Pass Config
	gatepassGroup.Post("/settings", adminOnly, gatepassHandler.ConfigureSetting)
	gatepassGroup.Get("/settings", adminOnly, gatepassHandler.GetSetting)

	// ==========================================
	// COMMUNICATION (WEBSOCKET CHAT) ROUTES
	// ==========================================
	// WebSocket route for real-time chat
	// Auth is done inside the WS connection via the FIRST message payload:
	// { "type": "auth", "token": "<JWT>" }
	// No token in URL — prevents token exposure in server logs.
	wsGroup := app.Group("/ws")
	wsGroup.Use(commWs.WebsocketUpgradeMiddleware()) // Only allows WS upgrade, no auth check here
	wsGroup.Get("/chat/:room_id", websocket.New(commWsHandler.HandleChatRoom))

	// ==========================================
	// ADMIN-ONLY ROUTES (JWT + Role=Admin)
	// ==========================================
	adminGroup := apiV1.Group("/admin", jwtAuth, adminOnly)

	// Admin-Only PKG routes
	adminGroup.Post("/pkg/periods", pkgHandler.CreatePeriod)
	adminGroup.Post("/pkg/indicators", pkgHandler.CreateIndicator)
	adminGroup.Post("/pkg/evaluations", pkgHandler.EvaluateSubmission)
	adminGroup.Get("/pkg/average", pkgHandler.GetFairAverage)

	// Admin-Only Health settings
	adminGroup.Post("/health/settings", healthHandler.ConfigureSetting)

	// Admin-Only Library Settings
	adminGroup.Post("/library/settings", libraryHandler.ConfigureSetting)

	// Admin-Only PKL/Performance Settings
	adminGroup.Post("/performance/settings", performanceHandler.ConfigureSetting)

	// Admin > AI Token Management (Admin only)
	adminGroup.Get("/ai/quota/:tenant_id", aiHandler.GetQuota)
	adminGroup.Post("/ai/buy-tokens", aiHandler.BuyTokens)

	// ==========================================
	// AI MODULE MANAGEMENT ROUTES
	// Accessible by: Admin OR any role with MANAGE_AI permission
	// ==========================================
	aiModuleGroup := apiV1.Group("/admin/ai", jwtAuth, manageAI)
	aiModuleGroup.Get("/modules", aiModuleHandler.ListModules)                      // List all modules & stats
	aiModuleGroup.Put("/modules/:module", aiModuleHandler.UpdateModule)             // Toggle + set limits
	aiModuleGroup.Get("/modules/:module/status", aiModuleHandler.CheckModuleStatus) // Check current status

	// ==========================================
	// STATIC FILE SERVING (with byte-range/WebSeed support)
	// Fiber's Static middleware enables Accept-Ranges: bytes by default,
	// which is the WebSeed requirement for WebTorrent.
	// ==========================================
	app.Static("/files/media", "./uploads/media")

	// ==========================================
	// MEDIA / WEBTORRENT ROUTES
	// ==========================================
	mediaGroup := apiV1.Group("/media", jwtAuth)
	// POST /api/v1/media/upload   — upload any file; if > 10MB, generates magnet link async
	mediaGroup.Post("/upload", torrentHandler.UploadMedia)
	// GET  /api/v1/media/torrent?path=... — return info_hash + magnet_link for a given file
	mediaGroup.Get("/torrent", torrentHandler.GetTorrentMeta)

	// Health Check & Root Routes
	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "message": "Satu Sekolah API is ready 🚀"})
	})
	apiV1.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "message": "Satu Sekolah API v1 is ready 🚀"})
	})

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "message": "Satu Sekolah API is running healthy 🚀"})
	})
	apiV1.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "message": "Satu Sekolah API v1 is running healthy 🚀"})
	})

	// ==========================================
	// BACKGROUND: CBA Auto-Submit Expired Sessions
	// Polls every 30 seconds to force-submit sessions past end_time
	// ==========================================
	go func() {
		for {
			time.Sleep(30 * time.Second)
			_ = cbaUc.AutoSubmitExpiredSessions(context.Background())
		}
	}()

	return app
}

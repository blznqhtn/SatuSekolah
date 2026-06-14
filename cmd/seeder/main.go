package main

import (
	"context"
	"log"

	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/internal/infrastructure/database"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/repository"
)

func main() {
	log.Println("Starting Satu Sekolah Seeder...")

	// 1. Load Config
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 2. Connect to Database (MySQL assumed based on previous context)
	db, err := database.NewMySQLConnection(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}
	defer db.Close()

	// 3. Init Repository
	repo := repository.NewCoreRepository(db, nil)
	ctx := context.Background()

	// 4. Seed Tenant
	domainStr := "sekolah.id"
	tenant, err := repo.GetTenantByDomain(ctx, domainStr)
	if err != nil {
		log.Fatalf("Error checking tenant: %v", err)
	}

	if tenant == nil {
		tenantName := "Satu Sekolah Demo"
		npsn := "12345678"
		tenant = &domain.Tenant{
			Name:   tenantName,
			Domain: &domainStr,
			NPSN:   &npsn,
		}
		if err := repo.CreateTenant(ctx, tenant); err != nil {
			log.Fatalf("Failed to create tenant: %v", err)
		}
		log.Printf("Created Tenant: %s (ID: %s)\n", tenant.Name, tenant.ID)
	} else {
		log.Printf("Tenant already exists: %s (ID: %s)\n", tenant.Name, tenant.ID)
	}

	// 5. Seed Roles
	roles := []string{"Admin", "Staff"}
	roleMap := make(map[string]*domain.Role)

	for _, roleName := range roles {
		role, err := repo.GetRoleByNameAndTenant(ctx, roleName, tenant.ID)
		if err != nil {
			log.Fatalf("Error checking role %s: %v", roleName, err)
		}

		if role == nil {
			role = &domain.Role{
				TenantID: &tenant.ID,
				Name:     roleName,
				IsCustom: false,
			}
			if err := repo.CreateRole(ctx, role); err != nil {
				log.Fatalf("Failed to create role %s: %v", roleName, err)
			}
			log.Printf("Created Role: %s\n", roleName)
		} else {
			log.Printf("Role already exists: %s\n", roleName)
		}
		roleMap[roleName] = role
	}

	// 6. Seed Permissions for Admin
	permissions, err := repo.GetSystemPermissions(ctx)
	if err != nil {
		log.Fatalf("Failed to get system permissions: %v", err)
	}

	if len(permissions) > 0 {
		adminRole := roleMap["Admin"]
		for _, perm := range permissions {
			// In a real seeder, we might want to check if it's already assigned.
			// The repository method might throw unique constraint error if we don't catch it,
			// or it might use ON CONFLICT DO NOTHING (if postgres) or IGNORE (if mysql).
			// Since we use raw SQL in AssignPermissionToRole, we'll try assigning and ignore err
			// for simplicity in the seeder, or ideally check.
			_ = repo.AssignPermissionToRole(ctx, adminRole.ID, perm.ID)
		}
		log.Printf("Assigned %d permissions to Admin role\n", len(permissions))
	} else {
		log.Println("No system permissions found to assign. Ensure migrations ran successfully.")
	}

	// 7. Seed Users
	// Admin User
	adminEmail := "admin@sekolah.id"
	adminUsername := "admin"
	admin, err := repo.GetUserByLoginIdentifier(ctx, adminUsername)
	if err != nil {
		log.Fatalf("Error checking admin user: %v", err)
	}

	if admin == nil {
		admin = &domain.User{
			TenantID: tenant.ID,
			Category: "admin",
			Name:     "Super Admin",
			Email:    adminEmail,
			Username: &adminUsername,
			Password: "admin123", // Will be hashed in CreateUser
		}
		if err := repo.CreateUser(ctx, admin); err != nil {
			log.Fatalf("Failed to create admin user: %v", err)
		}
		log.Println("Created Admin user: admin@sekolah.id")
		
		if err := repo.AssignRoleToUser(ctx, admin.ID, roleMap["Admin"].ID); err != nil {
			log.Fatalf("Failed to assign role to admin: %v", err)
		}
	} else {
		log.Println("Admin user already exists.")
	}

	// Staff User
	staffEmail := "guru@sekolah.id"
	staffNpk := "19902030"
	staff, err := repo.GetUserByLoginIdentifier(ctx, staffNpk)
	if err != nil {
		log.Fatalf("Error checking staff user: %v", err)
	}

	if staff == nil {
		staff = &domain.User{
			TenantID: tenant.ID,
			Category: "staff",
			Name:     "Guru Teladan",
			Email:    staffEmail,
			Npk:      &staffNpk,
			Password: "staff123", // Will be hashed in CreateUser
		}
		if err := repo.CreateUser(ctx, staff); err != nil {
			log.Fatalf("Failed to create staff user: %v", err)
		}
		log.Println("Created Staff user: 19902030")

		if err := repo.AssignRoleToUser(ctx, staff.ID, roleMap["Staff"].ID); err != nil {
			log.Fatalf("Failed to assign role to staff: %v", err)
		}
	} else {
		log.Println("Staff user already exists.")
	}

	log.Println("Seeding completed successfully!")
}

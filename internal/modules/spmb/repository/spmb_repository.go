package repository

import (
	"context"
	"database/sql"

	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/spmb/domain"
)

type spmbRepository struct {
	db *sql.DB
}

func NewSpmbRepository(db *sql.DB) domain.SpmbRepository {
	return &spmbRepository{db: db}
}

func (r *spmbRepository) GetPublicSchools(ctx context.Context) ([]*domain.PublicSchoolInfo, error) {
	query := `SELECT id, name, address, logo_url FROM tenants`
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schools []*domain.PublicSchoolInfo
	for rows.Next() {
		var s domain.PublicSchoolInfo
		var address, logoURL sql.NullString
		if err := rows.Scan(&s.ID, &s.Name, &address, &logoURL); err != nil {
			return nil, err
		}
		s.Address = address.String
		s.LogoURL = logoURL.String
		schools = append(schools, &s)
	}
	return schools, nil
}

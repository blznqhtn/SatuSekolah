package repository

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/calendar/domain"
)

type calendarRepository struct {
	db *sql.DB
}

func NewCalendarRepository(db *sql.DB) domain.CalendarRepository {
	return &calendarRepository{db: db}
}

func (r *calendarRepository) GetEventsByMonth(ctx context.Context, tenantID uuid.UUID, year, month int, targetUserID *uuid.UUID) ([]*domain.CalendarEvent, error) {
	query := `
		SELECT id, tenant_id, title, description, event_date, start_time, end_time, location, category, status, attachment_url, created_by, target_user_id, created_at, updated_at
		FROM calendar_events
		WHERE tenant_id = ? 
		  AND YEAR(event_date) = ? 
		  AND MONTH(event_date) = ?
		  AND deleted_at IS NULL
	`
	var args []interface{}
	args = append(args, tenantID, year, month)

	if targetUserID != nil {
		query += ` AND (target_user_id IS NULL OR target_user_id = ?)`
		args = append(args, *targetUserID)
	} else {
		query += ` AND target_user_id IS NULL`
	}

	query += ` ORDER BY event_date ASC, start_time ASC`

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var events []*domain.CalendarEvent
	for rows.Next() {
		var e domain.CalendarEvent
		var desc, loc, att sql.NullString
		var st, et sql.NullString
		var tu sql.NullString

		if err := rows.Scan(
			&e.ID, &e.TenantID, &e.Title, &desc, &e.EventDate, &st, &et, &loc, &e.Category, &e.Status, &att, &e.CreatedBy, &tu, &e.CreatedAt, &e.UpdatedAt,
		); err != nil {
			return nil, err
		}

		if desc.Valid {
			e.Description = desc.String
		}
		if loc.Valid {
			e.Location = loc.String
		}
		if att.Valid {
			e.Attachment = att.String
		}
		if st.Valid {
			e.StartTime = &st.String
		}
		if et.Valid {
			e.EndTime = &et.String
		}
		if tu.Valid {
			uid, _ := uuid.Parse(tu.String)
			e.TargetUserID = &uid
		}
		events = append(events, &e)
	}

	return events, nil
}

func (r *calendarRepository) GetEventByID(ctx context.Context, tenantID, eventID uuid.UUID) (*domain.CalendarEvent, error) {
	query := `
		SELECT id, tenant_id, title, description, event_date, start_time, end_time, location, category, status, attachment_url, created_by, target_user_id, created_at, updated_at
		FROM calendar_events
		WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL
	`
	row := r.db.QueryRowContext(ctx, query, tenantID, eventID)

	var e domain.CalendarEvent
	var desc, loc, att sql.NullString
	var st, et sql.NullString
	var tu sql.NullString

	if err := row.Scan(
		&e.ID, &e.TenantID, &e.Title, &desc, &e.EventDate, &st, &et, &loc, &e.Category, &e.Status, &att, &e.CreatedBy, &tu, &e.CreatedAt, &e.UpdatedAt,
	); err != nil {
		return nil, err
	}

	if desc.Valid {
		e.Description = desc.String
	}
	if loc.Valid {
		e.Location = loc.String
	}
	if att.Valid {
		e.Attachment = att.String
	}
	if st.Valid {
		e.StartTime = &st.String
	}
	if et.Valid {
		e.EndTime = &et.String
	}
	if tu.Valid {
		uid, _ := uuid.Parse(tu.String)
		e.TargetUserID = &uid
	}

	return &e, nil
}

func (r *calendarRepository) CreateEvent(ctx context.Context, e *domain.CalendarEvent) error {
	query := `
		INSERT INTO calendar_events (id, tenant_id, title, description, event_date, start_time, end_time, location, category, status, attachment_url, created_by, target_user_id)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`
	var tu interface{}
	if e.TargetUserID != nil {
		tu = *e.TargetUserID
	}

	_, err := r.db.ExecContext(ctx, query,
		e.ID, e.TenantID, e.Title, e.Description, e.EventDate, e.StartTime, e.EndTime, e.Location, e.Category, e.Status, e.Attachment, e.CreatedBy, tu,
	)
	return err
}

func (r *calendarRepository) UpdateEvent(ctx context.Context, e *domain.CalendarEvent) error {
	query := `
		UPDATE calendar_events
		SET title = ?, description = ?, event_date = ?, start_time = ?, end_time = ?, location = ?, category = ?, status = ?, attachment_url = ?, target_user_id = ?
		WHERE id = ? AND tenant_id = ? AND deleted_at IS NULL
	`
	var tu interface{}
	if e.TargetUserID != nil {
		tu = *e.TargetUserID
	}

	res, err := r.db.ExecContext(ctx, query,
		e.Title, e.Description, e.EventDate, e.StartTime, e.EndTime, e.Location, e.Category, e.Status, e.Attachment, tu, e.ID, e.TenantID,
	)
	if err != nil {
		return err
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("event not found or not modified")
	}
	return nil
}

func (r *calendarRepository) DeleteEvent(ctx context.Context, tenantID, eventID uuid.UUID) error {
	query := `UPDATE calendar_events SET deleted_at = NOW() WHERE id = ? AND tenant_id = ?`
	res, err := r.db.ExecContext(ctx, query, eventID, tenantID)
	if err != nil {
		return err
	}
	rows, _ := res.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("event not found")
	}
	return nil
}

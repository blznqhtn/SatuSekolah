package database

import (
	"context"
	"database/sql"
	"database/sql/driver"
	"fmt"
	"regexp"
	"strings"

	"github.com/lib/pq"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
)

var insertIgnoreRegex = regexp.MustCompile(`(?i)INSERT\s+IGNORE\s+INTO`)

// rebindQuery converts MySQL-style '?' placeholders into PostgreSQL-style '$1, $2, ...'
// and adapts MySQL-specific syntax like 'INSERT IGNORE' to PostgreSQL 'ON CONFLICT DO NOTHING'
func rebindQuery(query string) string {
	if insertIgnoreRegex.MatchString(query) {
		query = insertIgnoreRegex.ReplaceAllString(query, "INSERT INTO")
		if !strings.Contains(strings.ToUpper(query), "ON CONFLICT") {
			query = strings.TrimRight(strings.TrimSpace(query), ";") + " ON CONFLICT DO NOTHING"
		}
	}

	var sb strings.Builder
	sb.Grow(len(query) + 16)
	paramIndex := 1
	inString := false
	for i := 0; i < len(query); i++ {
		c := query[i]
		if c == '\'' {
			inString = !inString
			sb.WriteByte(c)
		} else if c == '?' && !inString {
			sb.WriteString(fmt.Sprintf("$%d", paramIndex))
			paramIndex++
		} else {
			sb.WriteByte(c)
		}
	}
	return sb.String()
}

type rebindConnector struct {
	underlying driver.Connector
}

func (c *rebindConnector) Connect(ctx context.Context) (driver.Conn, error) {
	conn, err := c.underlying.Connect(ctx)
	if err != nil {
		return nil, err
	}
	return &rebindConn{conn: conn}, nil
}

func (c *rebindConnector) Driver() driver.Driver {
	return c.underlying.Driver()
}

type rebindConn struct {
	conn driver.Conn
}

func (c *rebindConn) Prepare(query string) (driver.Stmt, error) {
	return c.conn.Prepare(rebindQuery(query))
}

func (c *rebindConn) PrepareContext(ctx context.Context, query string) (driver.Stmt, error) {
	if pc, ok := c.conn.(driver.ConnPrepareContext); ok {
		return pc.PrepareContext(ctx, rebindQuery(query))
	}
	return c.conn.Prepare(rebindQuery(query))
}

func (c *rebindConn) Close() error {
	return c.conn.Close()
}

func (c *rebindConn) Begin() (driver.Tx, error) {
	return c.conn.Begin()
}

func (c *rebindConn) BeginTx(ctx context.Context, opts driver.TxOptions) (driver.Tx, error) {
	if bt, ok := c.conn.(driver.ConnBeginTx); ok {
		return bt.BeginTx(ctx, opts)
	}
	return c.conn.Begin()
}

func (c *rebindConn) ExecContext(ctx context.Context, query string, args []driver.NamedValue) (driver.Result, error) {
	if ec, ok := c.conn.(driver.ExecerContext); ok {
		return ec.ExecContext(ctx, rebindQuery(query), args)
	}
	stmt, err := c.PrepareContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer stmt.Close()
	dargs := make([]driver.Value, len(args))
	for i, a := range args {
		dargs[i] = a.Value
	}
	return stmt.Exec(dargs)
}

func (c *rebindConn) QueryContext(ctx context.Context, query string, args []driver.NamedValue) (driver.Rows, error) {
	if qc, ok := c.conn.(driver.QueryerContext); ok {
		return qc.QueryContext(ctx, rebindQuery(query), args)
	}
	stmt, err := c.PrepareContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer stmt.Close()
	dargs := make([]driver.Value, len(args))
	for i, a := range args {
		dargs[i] = a.Value
	}
	return stmt.Query(dargs)
}

func (c *rebindConn) Ping(ctx context.Context) error {
	if p, ok := c.conn.(driver.Pinger); ok {
		return p.Ping(ctx)
	}
	return nil
}

func (c *rebindConn) ResetSession(ctx context.Context) error {
	if rs, ok := c.conn.(driver.SessionResetter); ok {
		return rs.ResetSession(ctx)
	}
	return nil
}

func NewPostgresConnection(cfg *config.Config) (*sql.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		cfg.Database.Host,
		cfg.Database.Port,
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.DBName,
		cfg.Database.SSLMode,
	)

	connector, err := pq.NewConnector(dsn)
	if err != nil {
		return nil, err
	}

	db := sql.OpenDB(&rebindConnector{underlying: connector})

	if err := db.Ping(); err != nil {
		db.Close()
		return nil, err
	}

	return db, nil
}

package database

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"concursosapp/api/internal/config"
	"github.com/go-sql-driver/mysql"
)

func OpenMySQL(ctx context.Context, cfg config.Config) (*sql.DB, error) {
	driverConfig := mysql.Config{
		User:                 cfg.DatabaseUser,
		Passwd:               cfg.DatabasePass,
		Net:                  "tcp",
		Addr:                 fmt.Sprintf("%s:%d", cfg.DatabaseHost, cfg.DatabasePort),
		DBName:               cfg.DatabaseName,
		Collation:            "utf8mb4_unicode_ci",
		ParseTime:            true,
		AllowNativePasswords: true,
	}

	db, err := sql.Open("mysql", driverConfig.FormatDSN())
	if err != nil {
		return nil, fmt.Errorf("open mysql: %w", err)
	}
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(3 * time.Minute)
	db.SetConnMaxIdleTime(time.Minute)

	pingCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	if err := db.PingContext(pingCtx); err != nil {
		db.Close()
		return nil, fmt.Errorf("ping mysql: %w", err)
	}
	return db, nil
}

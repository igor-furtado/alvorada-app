package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	concursosApplication "concursosapp/api/internal/application/concursos"
	application "concursosapp/api/internal/application/studies"
	"concursosapp/api/internal/config"
	mysqlrepo "concursosapp/api/internal/infrastructure/mysql"
	"concursosapp/api/internal/platform/database"
	"concursosapp/api/internal/presentation/httpapi"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	cfg, err := config.FromEnvironment()
	if err != nil {
		logger.Error("invalid configuration", "error", err)
		os.Exit(1)
	}

	rootCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	db, err := database.OpenMySQL(rootCtx, cfg)
	if err != nil {
		logger.Error("database unavailable", "error", err)
		os.Exit(1)
	}
	defer db.Close()
	if err := mysqlrepo.EnsurePortugueseSchema(rootCtx, db); err != nil {
		logger.Error("database schema migration failed", "error", err)
		os.Exit(1)
	}
	if err := mysqlrepo.EnsureDisciplineInvariants(rootCtx, db); err != nil {
		logger.Error("discipline data migration failed", "error", err)
		os.Exit(1)
	}
	if err := mysqlrepo.EnsureConcursoSchema(rootCtx, db); err != nil {
		logger.Error("concurso schema migration failed", "error", err)
		os.Exit(1)
	}

	repository := mysqlrepo.NewStudyRepository(db)
	service := application.NewService(repository)
	concursosRepository := mysqlrepo.NewConcursoRepository(db)
	concursosService := concursosApplication.NewService(concursosRepository)
	handler := httpapi.NewHandler(service, concursosService, logger)
	server := &http.Server{
		Addr:              cfg.Address(),
		Handler:           handler.Router(),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	go func() {
		logger.Info("api started", "address", cfg.Address())
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("server failed", "error", err)
			stop()
		}
	}()

	<-rootCtx.Done()
	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()
	if err := server.Shutdown(shutdownCtx); err != nil {
		logger.Error("graceful shutdown failed", "error", err)
		return
	}
	logger.Info("api stopped")
}

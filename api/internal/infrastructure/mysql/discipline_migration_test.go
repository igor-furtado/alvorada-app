package mysqlrepo

import (
	"context"
	"testing"

	domain "concursosapp/api/internal/domain/studies"
	"github.com/DATA-DOG/go-sqlmock"
)

func TestEnsureDisciplineInvariantsRepairsLegacyDataAndProtectsUniqueness(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectQuery("SELECT GET_LOCK").
		WithArgs(disciplineInvariantLock).
		WillReturnRows(sqlmock.NewRows([]string{"acquired"}).AddRow(true))
	mock.ExpectBegin()
	mock.ExpectExec("DELETE duplicate").
		WithArgs(domain.MandatoryReviewTopicName, domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 2))
	mock.ExpectExec("INSERT INTO topicos").
		WithArgs(domain.MandatoryReviewTopicName, domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("topicos", "obrigatorio").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("ALTER TABLE topicos").
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("topicos", mandatoryTopicIndex).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("CREATE UNIQUE INDEX").
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT RELEASE_LOCK").
		WithArgs(disciplineInvariantLock).
		WillReturnRows(sqlmock.NewRows([]string{"released"}).AddRow(true))

	if err := EnsureDisciplineInvariants(context.Background(), db); err != nil {
		t.Fatalf("EnsureDisciplineInvariants() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestEnsureDisciplineInvariantsIsIdempotentOnCurrentSchema(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectQuery("SELECT GET_LOCK").
		WithArgs(disciplineInvariantLock).
		WillReturnRows(sqlmock.NewRows([]string{"acquired"}).AddRow(true))
	mock.ExpectBegin()
	mock.ExpectExec("DELETE duplicate").
		WithArgs(domain.MandatoryReviewTopicName, domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectExec("INSERT INTO topicos").
		WithArgs(domain.MandatoryReviewTopicName, domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectCommit()
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("topicos", "obrigatorio").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("topicos", mandatoryTopicIndex).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectQuery("SELECT RELEASE_LOCK").
		WithArgs(disciplineInvariantLock).
		WillReturnRows(sqlmock.NewRows([]string{"released"}).AddRow(true))

	if err := EnsureDisciplineInvariants(context.Background(), db); err != nil {
		t.Fatalf("EnsureDisciplineInvariants() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

package mysqlrepo

import (
	"context"
	"regexp"
	"testing"
	"time"

	domain "concursosapp/api/internal/domain/concursos"
	"github.com/DATA-DOG/go-sqlmock"
)

func TestFindActiveConcursosPreservesDatabaseOrder(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	date := time.Date(2027, time.February, 21, 0, 0, 0, 0, time.UTC)
	mock.ExpectQuery("SELECT id, instituicao, cargo, banca, data_prova, prioritario, progresso_edital").
		WillReturnRows(
			sqlmock.NewRows([]string{"id", "instituicao", "cargo", "banca", "data_prova", "prioritario", "progresso_edital"}).
				AddRow("concurso-1", "Câmara dos Deputados", "Analista Legislativo", "Cebraspe", date, true, 48).
				AddRow("concurso-2", "TCE-PE", "Auditor", nil, nil, false, 0),
		)

	items, err := NewConcursoRepository(db).FindActive(context.Background())

	if err != nil {
		t.Fatalf("FindActive() error = %v", err)
	}
	if len(items) != 2 || items[0].ID != "concurso-1" || items[1].ID != "concurso-2" {
		t.Fatalf("FindActive() = %#v", items)
	}
	if items[0].DataProva == nil || items[0].Banca == nil || items[1].DataProva != nil {
		t.Fatalf("nullable fields were not preserved: %#v", items)
	}
}

func TestSetPrioritarioReplacesPreviousChoiceInOneTransaction(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectBegin()
	mock.ExpectExec(regexp.QuoteMeta("UPDATE concursos SET prioritario = 0 WHERE prioritario = 1")).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(regexp.QuoteMeta("UPDATE concursos SET prioritario = 1 WHERE id = ? AND arquivado_em IS NULL")).
		WithArgs("concurso-2").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	err = NewConcursoRepository(db).SetPrioritario(context.Background(), "concurso-2")

	if err != nil {
		t.Fatalf("SetPrioritario() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestCreatePrioritarioClearsPreviousChoice(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectBegin()
	mock.ExpectExec("UPDATE concursos SET prioritario = 0").WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec("INSERT INTO concursos").
		WithArgs(sqlmock.AnyArg(), "Câmara dos Deputados", "Analista Legislativo", sqlmock.AnyArg(), sqlmock.AnyArg(), true).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()
	banca := "Cebraspe"
	date := time.Date(2027, time.February, 21, 0, 0, 0, 0, time.UTC)

	id, err := NewConcursoRepository(db).Create(context.Background(), domain.CreateConcursoInput{
		Instituicao: "Câmara dos Deputados",
		Cargo:       "Analista Legislativo",
		Banca:       &banca,
		DataProva:   &date,
		Prioritario: true,
	})

	if err != nil || id == "" {
		t.Fatalf("Create() id = %q, error = %v", id, err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestEnsureConcursoSchemaIsIdempotent(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectExec("CREATE TABLE IF NOT EXISTS concursos").WillReturnResult(sqlmock.NewResult(0, 0))

	if err := EnsureConcursoSchema(context.Background(), db); err != nil {
		t.Fatalf("EnsureConcursoSchema() error = %v", err)
	}
}

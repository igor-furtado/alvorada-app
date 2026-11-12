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
			sqlmock.NewRows([]string{
				"id", "instituicao", "cargo", "banca", "data_prova", "prioritario", "progresso_edital",
				"sigla", "quantidade_vagas", "vencimento_centavos", "carga_horaria_semanal",
				"local_prova", "horario_inicio_prova", "horario_fim_prova", "requisitos", "criterios_pontuacao",
			}).
				AddRow("concurso-1", "Câmara dos Deputados", "Analista Legislativo", "Cebraspe", date, true, 48,
					"CD", 100, int64(2200000), 40, "Brasília", "13:00", "18:00", "Nível superior", "Provas ponderadas").
				AddRow("concurso-2", "TCE-PE", "Auditor", nil, nil, false, 0,
					nil, nil, nil, nil, nil, nil, nil, nil, nil),
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
	if items[0].Sigla == nil || *items[0].Sigla != "CD" || items[0].VencimentoCentavos == nil || *items[0].VencimentoCentavos != 2200000 {
		t.Fatalf("new Concurso fields were not preserved: %#v", items[0])
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
		WithArgs(sqlmock.AnyArg(), "Câmara dos Deputados", "Analista Legislativo", sqlmock.AnyArg(), sqlmock.AnyArg(), true,
			nil, nil, nil, nil, nil, nil, nil, nil, nil).
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

func TestUpdatePrioritarioPreservesProgressAndReplacesPreviousChoice(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectBegin()
	mock.ExpectExec("UPDATE concursos SET prioritario = 0").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec("UPDATE concursos").
		WithArgs("TRF da 5ª Região", "Analista Judiciário", nil, nil, true,
			nil, nil, nil, nil, nil, nil, nil, nil, nil, "concurso-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	err = NewConcursoRepository(db).Update(context.Background(), "concurso-1", domain.UpdateConcursoInput{
		Instituicao: "TRF da 5ª Região",
		Cargo:       "Analista Judiciário",
		Prioritario: true,
	})

	if err != nil {
		t.Fatalf("Update() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestUpdateAcceptsUnchangedValuesForExistingConcurso(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectBegin()
	mock.ExpectExec("UPDATE concursos").
		WithArgs("TRF da 5ª Região", "Analista Judiciário", nil, nil, false,
			nil, nil, nil, nil, nil, nil, nil, nil, nil, "concurso-1").
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("concurso-1").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectCommit()

	err = NewConcursoRepository(db).Update(context.Background(), "concurso-1", domain.UpdateConcursoInput{
		Instituicao: "TRF da 5ª Região",
		Cargo:       "Analista Judiciário",
	})

	if err != nil {
		t.Fatalf("Update() error = %v", err)
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
	for _, column := range []string{
		"sigla", "quantidade_vagas", "vencimento_centavos", "carga_horaria_semanal", "local_prova",
		"horario_inicio_prova", "horario_fim_prova", "requisitos", "criterios_pontuacao",
	} {
		mock.ExpectQuery("SELECT EXISTS").
			WithArgs("concursos", column).
			WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	}
	for _, constraint := range []string{
		"chk_concurso_carga_horaria", "chk_concurso_horarios_prova",
		"chk_concurso_quantidade_vagas", "chk_concurso_textos_longos",
	} {
		mock.ExpectQuery("SELECT EXISTS").
			WithArgs("concursos", constraint).
			WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	}

	if err := EnsureConcursoSchema(context.Background(), db); err != nil {
		t.Fatalf("EnsureConcursoSchema() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestEnsureConcursoSchemaAddsComplementaryFieldsToLegacyTable(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectExec("CREATE TABLE IF NOT EXISTS concursos").WillReturnResult(sqlmock.NewResult(0, 0))
	for _, column := range []string{
		"sigla", "quantidade_vagas", "vencimento_centavos", "carga_horaria_semanal", "local_prova",
		"horario_inicio_prova", "horario_fim_prova", "requisitos", "criterios_pontuacao",
	} {
		mock.ExpectQuery("SELECT EXISTS").
			WithArgs("concursos", column).
			WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
		mock.ExpectExec("ALTER TABLE concursos ADD COLUMN").WillReturnResult(sqlmock.NewResult(0, 0))
	}
	for _, constraint := range []string{
		"chk_concurso_carga_horaria", "chk_concurso_horarios_prova",
		"chk_concurso_quantidade_vagas", "chk_concurso_textos_longos",
	} {
		mock.ExpectQuery("SELECT EXISTS").
			WithArgs("concursos", constraint).
			WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
		mock.ExpectExec("ALTER TABLE concursos ADD CONSTRAINT").WillReturnResult(sqlmock.NewResult(0, 0))
	}

	if err := EnsureConcursoSchema(context.Background(), db); err != nil {
		t.Fatalf("EnsureConcursoSchema() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

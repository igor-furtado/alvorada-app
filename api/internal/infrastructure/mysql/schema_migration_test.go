package mysqlrepo

import (
	"context"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestEnsurePortugueseSchemaMigratesConstraintBeforeItsColumn(t *testing.T) {
	originalTables := portugueseTables
	originalColumns := portugueseColumns
	originalConstraints := portugueseConstraints
	originalIndexes := portugueseIndexes
	portugueseTables = nil
	portugueseColumns = []columnRename{
		{table: "disciplinas", from: "difficulty", to: "dificuldade"},
	}
	portugueseConstraints = []constraintMigration{
		{
			table:      "disciplinas",
			from:       "chk_subject_difficulty",
			to:         "chk_disciplina_dificuldade",
			dropClause: "DROP CHECK",
			definition: "CHECK (`dificuldade` BETWEEN 1 AND 5)",
		},
	}
	portugueseIndexes = nil
	t.Cleanup(func() {
		portugueseTables = originalTables
		portugueseColumns = originalColumns
		portugueseConstraints = originalConstraints
		portugueseIndexes = originalIndexes
	})

	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "chk_subject_difficulty").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "chk_disciplina_dificuldade").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("ALTER TABLE `disciplinas` DROP CHECK `chk_subject_difficulty`").
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "difficulty").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "dificuldade").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("ALTER TABLE `disciplinas` RENAME COLUMN `difficulty` TO `dificuldade`").
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "chk_disciplina_dificuldade").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("ALTER TABLE `disciplinas` ADD CONSTRAINT `chk_disciplina_dificuldade` CHECK \\(`dificuldade` BETWEEN 1 AND 5\\)").
		WillReturnResult(sqlmock.NewResult(0, 0))

	if err := EnsurePortugueseSchema(context.Background(), db); err != nil {
		t.Fatalf("EnsurePortugueseSchema() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestRenameTableIfNeededPreservesExistingData(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectQuery("SELECT EXISTS").WithArgs("subjects").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("RENAME TABLE `subjects` TO `disciplinas`").
		WillReturnResult(sqlmock.NewResult(0, 0))

	err = renameTableIfNeeded(context.Background(), db, tableRename{from: "subjects", to: "disciplinas"})

	if err != nil {
		t.Fatalf("renameTableIfNeeded() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestRenameColumnIfNeededPreservesExistingData(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "name").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))
	mock.ExpectQuery("SELECT EXISTS").WithArgs("disciplinas", "nome").
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))
	mock.ExpectExec("ALTER TABLE `disciplinas` RENAME COLUMN `name` TO `nome`").
		WillReturnResult(sqlmock.NewResult(0, 0))

	err = renameColumnIfNeeded(
		context.Background(),
		db,
		columnRename{table: "disciplinas", from: "name", to: "nome"},
	)

	if err != nil {
		t.Fatalf("renameColumnIfNeeded() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

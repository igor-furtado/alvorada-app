package mysqlrepo

import (
	"context"
	"errors"
	"regexp"
	"testing"

	domain "concursosapp/api/internal/domain/studies"
	"github.com/DATA-DOG/go-sqlmock"
)

func TestCreateSubjectPersistsMandatoryReviewTopicInSameTransaction(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectExec(regexp.QuoteMeta("INSERT INTO disciplinas (id, nome, dificuldade, cor)\n\t\tVALUES (?, ?, ?, ?)")).
		WithArgs(sqlmock.AnyArg(), "Português", domain.DifficultyMedium, "#E8742A").
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectExec(regexp.QuoteMeta("INSERT INTO topicos (id, disciplina_id, nome)\n\t\tVALUES (?, ?, ?)")).
		WithArgs(sqlmock.AnyArg(), sqlmock.AnyArg(), domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	repository := NewStudyRepository(db)
	id, err := repository.CreateSubject(context.Background(), domain.CreateSubjectInput{
		Name:       "Português",
		Difficulty: domain.DifficultyMedium,
		Color:      "#E8742A",
	})

	if err != nil {
		t.Fatalf("CreateSubject() error = %v", err)
	}
	if id == "" {
		t.Fatal("CreateSubject() returned an empty id")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestFindCatalogReturnsMandatoryReviewTopicLast(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectQuery("SELECT id, nome, dificuldade, cor").WillReturnRows(
		sqlmock.NewRows([]string{"id", "nome", "dificuldade", "cor"}).
			AddRow("discipline-1", "Português", 3, "#E8742A"),
	)
	mock.ExpectQuery("SELECT id, disciplina_id, nome, BINARY nome = BINARY \\? AS obrigatorio").
		WithArgs(domain.MandatoryReviewTopicName).
		WillReturnRows(
			sqlmock.NewRows([]string{"id", "disciplina_id", "nome", "obrigatorio"}).
				AddRow("topic-1", "discipline-1", "Pontuação", false).
				AddRow("topic-2", "discipline-1", domain.MandatoryReviewTopicName, true),
		)
	mock.ExpectQuery("SELECT id, topico_id, nome").WillReturnRows(
		sqlmock.NewRows([]string{"id", "topico_id", "nome"}).
			AddRow("subtopic-1", "topic-1", "Uso da vírgula"),
	)
	mock.ExpectCommit()

	repository := NewStudyRepository(db)
	catalog, err := repository.FindCatalog(context.Background())

	if err != nil {
		t.Fatalf("FindCatalog() error = %v", err)
	}
	if len(catalog) != 1 || len(catalog[0].Topics) != 2 {
		t.Fatalf("FindCatalog() = %#v", catalog)
	}
	if !catalog[0].Topics[1].Mandatory {
		t.Fatal("mandatory review topic was not returned last")
	}
	if len(catalog[0].Topics[0].Subtopics) != 1 || catalog[0].Topics[0].Subtopics[0].Name != "Uso da vírgula" {
		t.Fatalf("subtopics were not attached to the correct topic: %#v", catalog[0].Topics)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestDeleteTopicRejectsMandatoryReviewTopic(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectExec("DELETE FROM topicos").
		WithArgs("topic-1", domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("topic-1", domain.MandatoryReviewTopicName).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	repository := NewStudyRepository(db)
	err = repository.DeleteTopic(context.Background(), "topic-1")

	if !errors.Is(err, domain.ErrMandatoryTopic) {
		t.Fatalf("DeleteTopic() error = %v, want %v", err, domain.ErrMandatoryTopic)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestCreateSubtopicRejectsMandatoryReviewTopic(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectExec("INSERT INTO subtopicos").
		WithArgs(sqlmock.AnyArg(), "Conteúdo externo", "topic-1", domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 0))
	mock.ExpectQuery("SELECT EXISTS").
		WithArgs("topic-1", domain.MandatoryReviewTopicName).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	repository := NewStudyRepository(db)
	err = repository.CreateSubtopic(context.Background(), "topic-1", "Conteúdo externo")

	if !errors.Is(err, domain.ErrMandatoryTopic) {
		t.Fatalf("CreateSubtopic() error = %v, want %v", err, domain.ErrMandatoryTopic)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

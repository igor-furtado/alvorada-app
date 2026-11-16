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
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestCreateTopicsPersistsBatchInOrderInSameTransaction(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectQuery(regexp.QuoteMeta("SELECT id FROM disciplinas WHERE id = ? FOR UPDATE")).
		WithArgs("discipline-1").
		WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow("discipline-1"))
	mock.ExpectQuery(regexp.QuoteMeta("SELECT COALESCE(MAX(posicao), 0) FROM topicos WHERE disciplina_id = ?")).
		WithArgs("discipline-1").
		WillReturnRows(sqlmock.NewRows([]string{"posicao"}).AddRow(4))
	mock.ExpectExec(regexp.QuoteMeta("INSERT INTO topicos (id, disciplina_id, nome, posicao) VALUES (?, ?, ?, ?)")).
		WithArgs(sqlmock.AnyArg(), "discipline-1", "Pontuação", 5).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectExec(regexp.QuoteMeta("INSERT INTO topicos (id, disciplina_id, nome, posicao) VALUES (?, ?, ?, ?)")).
		WithArgs(sqlmock.AnyArg(), "discipline-1", "Concordância", 6).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectCommit()

	err = NewStudyRepository(db).CreateTopics(
		context.Background(),
		"discipline-1",
		[]string{"Pontuação", "Concordância"},
	)

	if err != nil {
		t.Fatalf("CreateTopics() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestCreateTopicsRollsBackWholeBatchWhenOneInsertFails(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectQuery("SELECT id FROM disciplinas").
		WithArgs("discipline-1").
		WillReturnRows(sqlmock.NewRows([]string{"id"}).AddRow("discipline-1"))
	mock.ExpectQuery("SELECT COALESCE").
		WithArgs("discipline-1").
		WillReturnRows(sqlmock.NewRows([]string{"posicao"}).AddRow(0))
	mock.ExpectExec("INSERT INTO topicos").
		WithArgs(sqlmock.AnyArg(), "discipline-1", "Pontuação", 1).
		WillReturnResult(sqlmock.NewResult(1, 1))
	mock.ExpectExec("INSERT INTO topicos").
		WithArgs(sqlmock.AnyArg(), "discipline-1", "Concordância", 2).
		WillReturnError(errors.New("insert failed"))
	mock.ExpectRollback()

	err = NewStudyRepository(db).CreateTopics(
		context.Background(),
		"discipline-1",
		[]string{"Pontuação", "Concordância"},
	)

	if err == nil {
		t.Fatal("CreateTopics() error = nil, want insert failure")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestReorderTopicsPersistsEveryPositionInSameTransaction(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectQuery("SELECT id\\s+FROM topicos").
		WithArgs("discipline-1", domain.MandatoryReviewTopicName).
		WillReturnRows(
			sqlmock.NewRows([]string{"id"}).
				AddRow("topic-1").
				AddRow("topic-2"),
		)
	mock.ExpectExec(regexp.QuoteMeta("UPDATE topicos SET posicao = ? WHERE id = ? AND disciplina_id = ?")).
		WithArgs(1, "topic-2", "discipline-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec(regexp.QuoteMeta("UPDATE topicos SET posicao = ? WHERE id = ? AND disciplina_id = ?")).
		WithArgs(2, "topic-1", "discipline-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	err = NewStudyRepository(db).ReorderTopics(
		context.Background(),
		"discipline-1",
		[]string{"topic-2", "topic-1"},
	)

	if err != nil {
		t.Fatalf("ReorderTopics() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestReorderTopicsRejectsIncompleteOrder(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectQuery("SELECT id\\s+FROM topicos").
		WithArgs("discipline-1", domain.MandatoryReviewTopicName).
		WillReturnRows(
			sqlmock.NewRows([]string{"id"}).
				AddRow("topic-1").
				AddRow("topic-2"),
		)
	mock.ExpectRollback()

	err = NewStudyRepository(db).ReorderTopics(
		context.Background(),
		"discipline-1",
		[]string{"topic-1"},
	)

	if !errors.Is(err, domain.ErrInvalidTopicOrder) {
		t.Fatalf("ReorderTopics() error = %v, want %v", err, domain.ErrInvalidTopicOrder)
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

	mock.ExpectBegin()
	mock.ExpectQuery("SELECT nome, disciplina_id FROM topicos").
		WithArgs("topic-1").
		WillReturnRows(sqlmock.NewRows([]string{"nome", "disciplina_id"}).AddRow(domain.MandatoryReviewTopicName, "discipline-1"))
	mock.ExpectRollback()

	repository := NewStudyRepository(db)
	err = repository.DeleteTopic(context.Background(), "topic-1")

	if !errors.Is(err, domain.ErrMandatoryTopic) {
		t.Fatalf("DeleteTopic() error = %v, want %v", err, domain.ErrMandatoryTopic)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestDeleteTopicUnlinksTopicFromEditaisBeforeDeletingIt(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectBegin()
	mock.ExpectQuery("SELECT nome, disciplina_id FROM topicos").
		WithArgs("topic-1").
		WillReturnRows(sqlmock.NewRows([]string{"nome", "disciplina_id"}).AddRow("Pontuação", "discipline-1"))
	mock.ExpectExec("DELETE FROM concursos_topicos").
		WithArgs("topic-1").
		WillReturnResult(sqlmock.NewResult(0, 2))
	mock.ExpectExec("DELETE FROM topicos").
		WithArgs("topic-1", domain.MandatoryReviewTopicName).
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec("DELETE relacao").
		WithArgs("discipline-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectCommit()

	err = NewStudyRepository(db).DeleteTopic(context.Background(), "topic-1")

	if err != nil {
		t.Fatalf("DeleteTopic() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestDeleteTopicRollsBackUnlinkWhenTopicDeletionFails(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()

	mock.ExpectBegin()
	mock.ExpectQuery("SELECT nome, disciplina_id FROM topicos").
		WithArgs("topic-1").
		WillReturnRows(sqlmock.NewRows([]string{"nome", "disciplina_id"}).AddRow("Pontuação", "discipline-1"))
	mock.ExpectExec("DELETE FROM concursos_topicos").
		WithArgs("topic-1").
		WillReturnResult(sqlmock.NewResult(0, 1))
	mock.ExpectExec("DELETE FROM topicos").
		WithArgs("topic-1", domain.MandatoryReviewTopicName).
		WillReturnError(errors.New("delete failed"))
	mock.ExpectRollback()

	err = NewStudyRepository(db).DeleteTopic(context.Background(), "topic-1")

	if err == nil {
		t.Fatal("DeleteTopic() error = nil, want delete failure")
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

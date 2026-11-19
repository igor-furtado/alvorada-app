package mysqlrepo

import (
	"context"
	"testing"
	"time"

	domain "concursosapp/api/internal/domain/semana"
	"github.com/DATA-DOG/go-sqlmock"
)

func TestFindPlanejamentoCombinesInitialStudiesReviewsAndAvailableTopics(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	date := time.Date(2026, time.November, 17, 0, 0, 0, 0, time.UTC)
	mock.ExpectQuery("SELECT CONCAT\\('estudo:'").
		WithArgs(sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{
			"id", "concurso_id", "concurso_nome", "concurso_sigla", "topico_id", "topico_nome",
			"disciplina_nome", "data_planejada", "posicao_dia", "teoria", "memoria", "conferencia",
			"acertos", "erros", "versao", "concluido",
		}).AddRow(
			"estudo:c1:t1", "c1", "Tribunal", "TCE", "t1", "Atos", "Administrativo",
			date, 0, true, false, false, 4, 1, 1, false,
		))
	mock.ExpectQuery("SELECT revisao.id").
		WithArgs(sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{
			"id", "concurso_id", "concurso_nome", "concurso_sigla", "topico_id", "topico_nome",
			"disciplina_nome", "data_planejada", "posicao_dia", "teoria", "memoria", "conferencia",
			"acertos", "erros", "versao", "concluido", "intervalo",
		}).AddRow(
			"r1", "c1", "Tribunal", "TCE", "t2", "Poderes", "Administrativo",
			date, 1, true, true, true, 8, 2, 1, false, 7,
		))
	mock.ExpectQuery("SELECT vinculo.concurso_id").
		WillReturnRows(sqlmock.NewRows([]string{
			"concurso_id", "concurso_nome", "concurso_sigla", "topico_id", "topico_nome", "disciplina_nome",
		}).AddRow("c1", "Tribunal", "TCE", "t3", "Agentes", "Administrativo"))

	plano, err := NewSemanaRepository(db).FindPlanejamento(
		context.Background(),
		date.AddDate(0, 0, -1),
		date.AddDate(0, 0, 5),
	)

	if err != nil {
		t.Fatalf("FindPlanejamento() error = %v", err)
	}
	if len(plano.Itens) != 2 || plano.Itens[0].Tipo != domain.TipoEstudoInicial || plano.Itens[1].Tipo != domain.TipoRevisao {
		t.Fatalf("items = %#v", plano.Itens)
	}
	if plano.Itens[0].Acertos != 4 || plano.Itens[1].IntervaloRevisaoDias == nil || *plano.Itens[1].IntervaloRevisaoDias != 7 {
		t.Fatalf("study data was not preserved: %#v", plano.Itens)
	}
	if len(plano.Disponiveis) != 1 || plano.Disponiveis[0].TopicoID != "t3" {
		t.Fatalf("available topics = %#v", plano.Disponiveis)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

func TestRegistrarQuestaoIncrementsOnlyRequestedCounter(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("sqlmock.New() error = %v", err)
	}
	defer db.Close()
	mock.ExpectExec("SET erros = erros \\+ 1").
		WithArgs(uint16(1), "concurso-1", "topico-1").
		WillReturnResult(sqlmock.NewResult(0, 1))

	err = NewSemanaRepository(db).RegistrarQuestao(
		context.Background(),
		"concurso-1",
		"topico-1",
		domain.QuestaoErrada,
		1,
	)

	if err != nil {
		t.Fatalf("RegistrarQuestao() error = %v", err)
	}
	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("database expectations: %v", err)
	}
}

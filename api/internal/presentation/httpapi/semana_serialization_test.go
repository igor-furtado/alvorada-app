package httpapi

import (
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	semanaApplication "concursosapp/api/internal/application/semana"
	domain "concursosapp/api/internal/domain/semana"
)

func TestWeekContractUsesPortugueseStudyFields(t *testing.T) {
	repository := &semanaSerializationRepository{}
	handler := NewHandler(
		nil,
		nil,
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
		semanaApplication.NewService(repository),
	).Router()
	request := httptest.NewRequest(http.MethodGet, "/api/v1/semana?inicio=2026-11-16&fim=2026-11-22", nil)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d: %s", response.Code, http.StatusOK, response.Body.String())
	}
	for _, field := range []string{
		"tipo", "concurso_id", "topico_id", "data_planejada", "teoria_concluida",
		"memoria_concluida", "conferencia_concluida", "acertos", "erros", "disponiveis",
	} {
		if !strings.Contains(response.Body.String(), `"`+field+`"`) {
			t.Fatalf("response does not contain %q: %s", field, response.Body.String())
		}
	}
}

func TestReviewIntervalsAreOptional(t *testing.T) {
	repository := &semanaSerializationRepository{}
	handler := NewHandler(
		nil,
		nil,
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
		semanaApplication.NewService(repository),
	).Router()
	request := httptest.NewRequest(
		http.MethodPut,
		"/api/v1/concursos/concurso-1/topicos/topico-1/revisoes",
		strings.NewReader(`{"intervalos_dias":[]}`),
	)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusNoContent {
		t.Fatalf("status = %d, want %d: %s", response.Code, http.StatusNoContent, response.Body.String())
	}
	if repository.intervals == nil || len(repository.intervals) != 0 {
		t.Fatalf("intervals = %#v, want empty non-nil selection", repository.intervals)
	}
}

type semanaSerializationRepository struct {
	intervals []uint8
}

func (r *semanaSerializationRepository) FindPlanejamento(
	_ context.Context,
	inicio, fim time.Time,
) (domain.Planejamento, error) {
	interval := uint8(7)
	return domain.Planejamento{
		Inicio: inicio,
		Fim:    fim,
		Itens: []domain.Item{{
			ID: "revisao-1", Tipo: domain.TipoRevisao,
			ConcursoID: "concurso-1", ConcursoNome: "TCE", TopicoID: "topico-1",
			TopicoNome: "Atos administrativos", DisciplinaNome: "Direito Administrativo",
			DataPlanejada: inicio, IntervaloRevisaoDias: &interval,
		}},
		Disponiveis: []domain.TopicoDisponivel{},
	}, nil
}

func (r *semanaSerializationRepository) PlanejarTopico(context.Context, string, string, time.Time, uint) error {
	return nil
}

func (r *semanaSerializationRepository) AtualizarProgresso(
	context.Context,
	string,
	string,
	domain.ProgressoInput,
	uint16,
) error {
	return nil
}

func (r *semanaSerializationRepository) RegistrarQuestao(
	context.Context,
	string,
	string,
	domain.ResultadoQuestao,
	uint16,
) error {
	return nil
}

func (r *semanaSerializationRepository) SubstituirRevisoes(_ context.Context, _, _ string, intervals []uint8) error {
	r.intervals = append([]uint8{}, intervals...)
	return nil
}

func (r *semanaSerializationRepository) MoverRevisao(context.Context, string, time.Time, uint) error {
	return nil
}

func (r *semanaSerializationRepository) ConcluirRevisao(context.Context, string) error { return nil }

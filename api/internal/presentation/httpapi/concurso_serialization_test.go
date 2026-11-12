package httpapi

import (
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	application "concursosapp/api/internal/application/concursos"
	domain "concursosapp/api/internal/domain/concursos"
)

func TestConcursoContractUsesPortugueseFieldsAndDateOnly(t *testing.T) {
	date := time.Date(2027, time.February, 21, 0, 0, 0, 0, time.UTC)
	banca := "Cebraspe"
	sigla := "CD"
	inicio := "13:00"
	fim := "18:00"
	vagas := 100
	vencimento := int64(2200000)
	repository := &concursoSerializationRepository{items: []domain.Concurso{{
		ID: "concurso-1", Instituicao: "Câmara dos Deputados", Cargo: "Analista Legislativo",
		Banca: &banca, DataProva: &date, Prioritario: true, ProgressoEdital: 48,
		Sigla: &sigla, QuantidadeVagas: &vagas, VencimentoCentavos: &vencimento,
		HorarioInicioProva: &inicio, HorarioFimProva: &fim,
	}}}
	handler := NewHandler(
		nil,
		application.NewService(repository),
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(http.MethodGet, "/api/v1/concursos", nil)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	body := response.Body.String()
	for _, value := range []string{`"instituicao"`, `"cargo"`, `"data_prova":"2027-02-21"`, `"prioritario":true`, `"progresso_edital":48`, `"sigla":"CD"`, `"quantidade_vagas":100`, `"vencimento_centavos":2200000`, `"horario_inicio_prova":"13:00"`} {
		if !strings.Contains(body, value) {
			t.Fatalf("response does not contain %q: %s", value, body)
		}
	}
}

func TestCreateConcursoAcceptsPortugueseFields(t *testing.T) {
	repository := &concursoSerializationRepository{}
	handler := NewHandler(
		nil,
		application.NewService(repository),
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(
		http.MethodPost,
		"/api/v1/concursos",
		strings.NewReader(`{"instituicao":"TRF da 5ª Região","cargo":"Técnico Judiciário","banca":"FCC","data_prova":"2026-12-13","prioritario":true,"sigla":"TRF5","quantidade_vagas":20,"vencimento_centavos":1234567,"carga_horaria_semanal":40,"local_prova":"Recife/PE","horario_inicio_prova":"13:00","horario_fim_prova":"18:00","requisitos":"Nível superior","criterios_pontuacao":"Pesos por bloco"}`),
	)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusCreated {
		t.Fatalf("status = %d, want %d: %s", response.Code, http.StatusCreated, response.Body.String())
	}
	if repository.created.DataProva == nil || !repository.created.Prioritario ||
		repository.created.VencimentoCentavos == nil || *repository.created.VencimentoCentavos != 1234567 {
		t.Fatalf("created Concurso = %#v", repository.created)
	}
}

func TestUpdateConcursoAcceptsPortugueseFields(t *testing.T) {
	repository := &concursoSerializationRepository{}
	handler := NewHandler(
		nil,
		application.NewService(repository),
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(
		http.MethodPut,
		"/api/v1/concursos/concurso-1",
		strings.NewReader(`{"instituicao":"TRF da 5ª Região","cargo":"Analista Judiciário","banca":null,"data_prova":null,"prioritario":false}`),
	)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusNoContent {
		t.Fatalf("status = %d, want %d: %s", response.Code, http.StatusNoContent, response.Body.String())
	}
	if repository.updated.Cargo != "Analista Judiciário" || repository.updated.Prioritario {
		t.Fatalf("updated Concurso = %#v", repository.updated)
	}
}

type concursoSerializationRepository struct {
	items   []domain.Concurso
	created domain.CreateConcursoInput
	updated domain.UpdateConcursoInput
}

func (r *concursoSerializationRepository) FindActive(context.Context) ([]domain.Concurso, error) {
	return r.items, nil
}
func (r *concursoSerializationRepository) Create(_ context.Context, input domain.CreateConcursoInput) (string, error) {
	r.created = input
	return "concurso-1", nil
}
func (r *concursoSerializationRepository) Update(_ context.Context, _ string, input domain.UpdateConcursoInput) error {
	r.updated = input
	return nil
}
func (r *concursoSerializationRepository) SetPrioritario(context.Context, string) error { return nil }
func (r *concursoSerializationRepository) Archive(context.Context, string) error        { return nil }
func (r *concursoSerializationRepository) Restore(context.Context, string) error        { return nil }
func (r *concursoSerializationRepository) Delete(context.Context, string) error         { return nil }
func (r *concursoSerializationRepository) AddDisciplinaToEdital(context.Context, string, string) error {
	return nil
}
func (r *concursoSerializationRepository) AddTopicoToEdital(context.Context, string, string) error {
	return nil
}
func (r *concursoSerializationRepository) RemoveTopicoFromEdital(context.Context, string, string) error {
	return nil
}

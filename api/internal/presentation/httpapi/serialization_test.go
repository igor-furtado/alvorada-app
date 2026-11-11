package httpapi

import (
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	application "concursosapp/api/internal/application/studies"
	domain "concursosapp/api/internal/domain/studies"
)

func TestDisciplineContractUsesPortugueseJSONFields(t *testing.T) {
	repository := &serializationRepository{
		catalog: []domain.Subject{
			{
				ID:         "disciplina-1",
				Name:       "Português",
				Difficulty: domain.DifficultyMedium,
				Color:      "#E8742A",
				Topics: []domain.Topic{
					{
						ID:        "topico-1",
						Name:      domain.MandatoryReviewTopicName,
						Mandatory: true,
						Subtopics: []domain.Subtopic{},
					},
				},
			},
		},
	}
	handler := NewHandler(
		application.NewService(repository),
		nil,
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(http.MethodGet, "/api/v1/subjects", nil)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	body := response.Body.String()
	for _, field := range []string{"nome", "dificuldade", "cor", "topicos", "obrigatorio", "subtopicos"} {
		if !strings.Contains(body, `"`+field+`"`) {
			t.Fatalf("response does not contain %q: %s", field, body)
		}
	}
}

func TestCreateDisciplineAcceptsPortugueseJSONFields(t *testing.T) {
	repository := &serializationRepository{}
	handler := NewHandler(
		application.NewService(repository),
		nil,
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(
		http.MethodPost,
		"/api/v1/subjects",
		strings.NewReader(`{"nome":"Português","dificuldade":3,"cor":"#E8742A"}`),
	)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusCreated {
		t.Fatalf("status = %d, want %d: %s", response.Code, http.StatusCreated, response.Body.String())
	}
	if repository.createdSubject.Name != "Português" {
		t.Fatalf("created subject = %#v", repository.createdSubject)
	}
}

func TestErrorResponseUsesPortugueseField(t *testing.T) {
	handler := NewHandler(
		application.NewService(&serializationRepository{}),
		nil,
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(http.MethodPost, "/api/v1/subjects", strings.NewReader(`{"name":"Português"}`))
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusBadRequest)
	}
	if body := response.Body.String(); !strings.Contains(body, `"erro"`) || strings.Contains(body, `"error"`) {
		t.Fatalf("unexpected error response: %s", body)
	}
}

func TestDeleteMandatoryTopicReturnsValidationError(t *testing.T) {
	repository := &serializationRepository{deleteTopicError: domain.ErrMandatoryTopic}
	handler := NewHandler(
		application.NewService(repository),
		nil,
		slog.New(slog.NewTextHandler(&strings.Builder{}, nil)),
	).Router()
	request := httptest.NewRequest(http.MethodDelete, "/api/v1/topics/topico-1", nil)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want %d: %s", response.Code, http.StatusBadRequest, response.Body.String())
	}
	if body := response.Body.String(); !strings.Contains(body, domain.ErrMandatoryTopic.Error()) {
		t.Fatalf("response does not explain the protected topic: %s", body)
	}
}

type serializationRepository struct {
	catalog          []domain.Subject
	createdSubject   domain.CreateSubjectInput
	deleteTopicError error
}

func (r *serializationRepository) FindCatalog(context.Context) ([]domain.Subject, error) {
	return r.catalog, nil
}

func (r *serializationRepository) CreateSubject(_ context.Context, input domain.CreateSubjectInput) (string, error) {
	r.createdSubject = input
	return "disciplina-1", nil
}

func (r *serializationRepository) UpdateSubject(context.Context, string, domain.UpdateSubjectInput) error {
	return nil
}

func (r *serializationRepository) DeleteSubject(context.Context, string) error { return nil }

func (r *serializationRepository) CreateTopic(context.Context, string, string) error { return nil }

func (r *serializationRepository) UpdateTopic(context.Context, string, string) error { return nil }

func (r *serializationRepository) DeleteTopic(context.Context, string) error {
	return r.deleteTopicError
}

func (r *serializationRepository) CreateSubtopic(context.Context, string, string) error { return nil }

func (r *serializationRepository) UpdateSubtopic(context.Context, string, string) error { return nil }

func (r *serializationRepository) DeleteSubtopic(context.Context, string) error { return nil }

package semana

import (
	"context"
	"errors"
	"testing"
	"time"

	domain "concursosapp/api/internal/domain/semana"
)

func TestAtualizarProgressoRequiresAtLeastOneActivity(t *testing.T) {
	service := NewService(&repositoryStub{})

	err := service.AtualizarProgresso(context.Background(), "concurso", "topico", domain.ProgressoInput{})

	if !errors.Is(err, ErrProgressoVazio) {
		t.Fatalf("AtualizarProgresso() error = %v, want %v", err, ErrProgressoVazio)
	}
}

func TestSubstituirRevisoesAcceptsAnyUniqueOptionalCombination(t *testing.T) {
	repository := &repositoryStub{}
	service := NewService(repository)

	if err := service.SubstituirRevisoes(context.Background(), "concurso", "topico", []uint8{1, 30}); err != nil {
		t.Fatalf("SubstituirRevisoes() error = %v", err)
	}
	if len(repository.reviewIntervals) != 2 || repository.reviewIntervals[0] != 1 || repository.reviewIntervals[1] != 30 {
		t.Fatalf("review intervals = %#v", repository.reviewIntervals)
	}
	if err := service.SubstituirRevisoes(context.Background(), "concurso", "topico", nil); err != nil {
		t.Fatalf("SubstituirRevisoes(empty) error = %v", err)
	}
}

func TestSubstituirRevisoesRejectsUnsupportedOrDuplicateIntervals(t *testing.T) {
	service := NewService(&repositoryStub{})
	for _, intervals := range [][]uint8{{2}, {7, 7}} {
		if err := service.SubstituirRevisoes(context.Background(), "concurso", "topico", intervals); !errors.Is(err, ErrIntervaloRevisao) {
			t.Fatalf("SubstituirRevisoes(%v) error = %v, want %v", intervals, err, ErrIntervaloRevisao)
		}
	}
}

type repositoryStub struct {
	reviewIntervals []uint8
}

func (r *repositoryStub) FindPlanejamento(context.Context, time.Time, time.Time) (domain.Planejamento, error) {
	return domain.Planejamento{}, nil
}

func (r *repositoryStub) PlanejarTopico(context.Context, string, string, time.Time, uint) error {
	return nil
}

func (r *repositoryStub) AtualizarProgresso(
	context.Context,
	string,
	string,
	domain.ProgressoInput,
	uint16,
) error {
	return nil
}

func (r *repositoryStub) RegistrarQuestao(
	context.Context,
	string,
	string,
	domain.ResultadoQuestao,
	uint16,
) error {
	return nil
}

func (r *repositoryStub) SubstituirRevisoes(_ context.Context, _, _ string, intervals []uint8) error {
	r.reviewIntervals = append([]uint8(nil), intervals...)
	return nil
}

func (r *repositoryStub) MoverRevisao(context.Context, string, time.Time, uint) error { return nil }

func (r *repositoryStub) ConcluirRevisao(context.Context, string) error { return nil }

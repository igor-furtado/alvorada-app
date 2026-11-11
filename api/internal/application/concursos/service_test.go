package concursos

import (
	"context"
	"errors"
	"testing"

	domain "concursosapp/api/internal/domain/concursos"
)

func TestCreateNormalizesConcursoFields(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)
	banca := "  FCC  "

	_, err := service.Create(context.Background(), domain.CreateConcursoInput{
		Instituicao: "  Tribunal Regional Federal  ",
		Cargo:       "  Técnico Judiciário  ",
		Banca:       &banca,
	})

	if err != nil {
		t.Fatalf("Create() error = %v", err)
	}
	if repository.created.Instituicao != "Tribunal Regional Federal" || repository.created.Cargo != "Técnico Judiciário" {
		t.Fatalf("normalized input = %#v", repository.created)
	}
	if repository.created.Banca == nil || *repository.created.Banca != "FCC" {
		t.Fatalf("normalized banca = %#v", repository.created.Banca)
	}
}

func TestCreateRejectsBlankCargo(t *testing.T) {
	service := NewService(&fakeRepository{})

	_, err := service.Create(context.Background(), domain.CreateConcursoInput{
		Instituicao: "TRF da 5ª Região",
		Cargo:       "   ",
	})

	if !errors.Is(err, ErrCargoRequired) {
		t.Fatalf("Create() error = %v, want %v", err, ErrCargoRequired)
	}
}

type fakeRepository struct {
	created domain.CreateConcursoInput
}

func (f *fakeRepository) FindActive(context.Context) ([]domain.Concurso, error) { return nil, nil }
func (f *fakeRepository) Create(_ context.Context, input domain.CreateConcursoInput) (string, error) {
	f.created = input
	return "concurso-1", nil
}
func (f *fakeRepository) SetPrioritario(context.Context, string) error { return nil }
func (f *fakeRepository) Archive(context.Context, string) error        { return nil }
func (f *fakeRepository) Restore(context.Context, string) error        { return nil }
func (f *fakeRepository) Delete(context.Context, string) error         { return nil }

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

func TestUpdateNormalizesConcursoFields(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)
	banca := "  FGV  "
	sigla := "  TRF  "
	inicio := " 13:00 "
	fim := " 18:00 "

	err := service.Update(context.Background(), "concurso-1", domain.UpdateConcursoInput{
		Instituicao: "  Tribunal Regional Federal  ",
		Cargo:       "  Analista Judiciário  ",
		Banca:       &banca,
		Prioritario: true,
		Sigla:       &sigla, HorarioInicioProva: &inicio, HorarioFimProva: &fim,
	})

	if err != nil {
		t.Fatalf("Update() error = %v", err)
	}
	if repository.updated.Instituicao != "Tribunal Regional Federal" || repository.updated.Cargo != "Analista Judiciário" {
		t.Fatalf("normalized input = %#v", repository.updated)
	}
	if repository.updated.Banca == nil || *repository.updated.Banca != "FGV" || !repository.updated.Prioritario {
		t.Fatalf("updated Concurso = %#v", repository.updated)
	}
	if repository.updated.Sigla == nil || *repository.updated.Sigla != "TRF" ||
		repository.updated.HorarioInicioProva == nil || *repository.updated.HorarioInicioProva != "13:00" {
		t.Fatalf("normalized complementary fields = %#v", repository.updated)
	}
}

func TestCreateRejectsIncompleteExamTime(t *testing.T) {
	service := NewService(&fakeRepository{})
	inicio := "13:00"

	_, err := service.Create(context.Background(), domain.CreateConcursoInput{
		Instituicao:        "TRF da 5ª Região",
		Cargo:              "Técnico Judiciário",
		HorarioInicioProva: &inicio,
	})

	if !errors.Is(err, ErrHorariosProva) {
		t.Fatalf("Create() error = %v, want %v", err, ErrHorariosProva)
	}
}

type fakeRepository struct {
	created domain.CreateConcursoInput
	updated domain.UpdateConcursoInput
}

func (f *fakeRepository) FindActive(context.Context) ([]domain.Concurso, error) { return nil, nil }
func (f *fakeRepository) Create(_ context.Context, input domain.CreateConcursoInput) (string, error) {
	f.created = input
	return "concurso-1", nil
}
func (f *fakeRepository) Update(_ context.Context, _ string, input domain.UpdateConcursoInput) error {
	f.updated = input
	return nil
}
func (f *fakeRepository) SetPrioritario(context.Context, string) error { return nil }
func (f *fakeRepository) Archive(context.Context, string) error        { return nil }
func (f *fakeRepository) Restore(context.Context, string) error        { return nil }
func (f *fakeRepository) Delete(context.Context, string) error         { return nil }

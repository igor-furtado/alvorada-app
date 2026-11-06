package studies

import (
	"context"
	"errors"
	"testing"

	domain "concursosapp/api/internal/domain/studies"
)

func TestCreateSubjectNormalizesName(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)

	_, err := service.CreateSubject(context.Background(), domain.CreateSubjectInput{
		Name:       "  Direito Constitucional  ",
		Difficulty: domain.DifficultyHard,
		Color:      "#6657D9",
	})

	if err != nil {
		t.Fatalf("CreateSubject() error = %v", err)
	}
	if repository.createdSubject.Name != "Direito Constitucional" {
		t.Fatalf("normalized name = %q", repository.createdSubject.Name)
	}
}

func TestCreateTopicRejectsBlankName(t *testing.T) {
	service := NewService(&fakeRepository{})
	err := service.CreateTopic(context.Background(), "subject-id", "   ")
	if !errors.Is(err, ErrNameRequired) {
		t.Fatalf("CreateTopic() error = %v, want %v", err, ErrNameRequired)
	}
}

func TestCreateSubjectRejectsInvalidDifficulty(t *testing.T) {
	service := NewService(&fakeRepository{})
	_, err := service.CreateSubject(context.Background(), domain.CreateSubjectInput{
		Name:       "Português",
		Difficulty: 6,
		Color:      "#6657D9",
	})
	if !errors.Is(err, ErrInvalidDifficulty) {
		t.Fatalf("CreateSubject() error = %v, want %v", err, ErrInvalidDifficulty)
	}
}

type fakeRepository struct {
	createdSubject domain.CreateSubjectInput
}

func (f *fakeRepository) FindCatalog(context.Context) ([]domain.Subject, error) {
	return []domain.Subject{}, nil
}

func (f *fakeRepository) CreateSubject(_ context.Context, input domain.CreateSubjectInput) (string, error) {
	f.createdSubject = input
	return "subject-id", nil
}

func (f *fakeRepository) UpdateSubject(context.Context, string, domain.UpdateSubjectInput) error {
	return nil
}
func (f *fakeRepository) DeleteSubject(context.Context, string) error          { return nil }
func (f *fakeRepository) CreateTopic(context.Context, string, string) error    { return nil }
func (f *fakeRepository) UpdateTopic(context.Context, string, string) error    { return nil }
func (f *fakeRepository) DeleteTopic(context.Context, string) error            { return nil }
func (f *fakeRepository) CreateSubtopic(context.Context, string, string) error { return nil }
func (f *fakeRepository) UpdateSubtopic(context.Context, string, string) error { return nil }
func (f *fakeRepository) DeleteSubtopic(context.Context, string) error         { return nil }

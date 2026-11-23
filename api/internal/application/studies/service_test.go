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
		Color:      "#E8742A",
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

func TestCreateTopicRejectsReservedMandatoryTopicName(t *testing.T) {
	service := NewService(&fakeRepository{})
	err := service.CreateTopic(context.Background(), "subject-id", domain.MandatoryReviewTopicName)
	if !errors.Is(err, domain.ErrMandatoryTopic) {
		t.Fatalf("CreateTopic() error = %v, want %v", err, domain.ErrMandatoryTopic)
	}
}

func TestCreateTopicsNormalizesWholeBatchBeforePersisting(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)
	err := service.CreateTopics(context.Background(), "subject-id", []string{"  Pontuação  ", "Concordância"})
	if err != nil {
		t.Fatalf("CreateTopics() error = %v", err)
	}
	if len(repository.createdTopics) != 2 || repository.createdTopics[0] != "Pontuação" || repository.createdTopics[1] != "Concordância" {
		t.Fatalf("CreateTopics() persisted %#v", repository.createdTopics)
	}
}

func TestCreateTopicsRejectsEmptyBatch(t *testing.T) {
	service := NewService(&fakeRepository{})
	err := service.CreateTopics(context.Background(), "subject-id", nil)
	if !errors.Is(err, ErrTopicsRequired) {
		t.Fatalf("CreateTopics() error = %v, want %v", err, ErrTopicsRequired)
	}
}

func TestReplaceTopicsNormalizesNamesAndPreservesIDs(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)
	err := service.ReplaceTopics(context.Background(), "subject-id", []domain.ReplaceTopicInput{
		{ID: "topic-1", Name: "  Pontuação  "},
		{Name: "Concordância"},
	})
	if err != nil {
		t.Fatalf("ReplaceTopics() error = %v", err)
	}
	if len(repository.replacedTopics) != 2 || repository.replacedTopics[0].ID != "topic-1" || repository.replacedTopics[0].Name != "Pontuação" {
		t.Fatalf("ReplaceTopics() persisted %#v", repository.replacedTopics)
	}
}

func TestReplaceTopicsRejectsDuplicateIDs(t *testing.T) {
	service := NewService(&fakeRepository{})
	err := service.ReplaceTopics(context.Background(), "subject-id", []domain.ReplaceTopicInput{
		{ID: "topic-1", Name: "Pontuação"},
		{ID: "topic-1", Name: "Concordância"},
	})
	if !errors.Is(err, domain.ErrInvalidTopicOrder) {
		t.Fatalf("ReplaceTopics() error = %v, want %v", err, domain.ErrInvalidTopicOrder)
	}
}

func TestReorderTopicsRejectsDuplicateIDs(t *testing.T) {
	service := NewService(&fakeRepository{})
	err := service.ReorderTopics(context.Background(), "subject-id", []string{"topic-1", "topic-1"})
	if !errors.Is(err, domain.ErrInvalidTopicOrder) {
		t.Fatalf("ReorderTopics() error = %v, want %v", err, domain.ErrInvalidTopicOrder)
	}
}

func TestReorderSubjectsRejectsDuplicateIDs(t *testing.T) {
	service := NewService(&fakeRepository{})
	err := service.ReorderSubjects(context.Background(), []string{"subject-1", "subject-1"})
	if !errors.Is(err, domain.ErrInvalidSubjectOrder) {
		t.Fatalf("ReorderSubjects() error = %v, want %v", err, domain.ErrInvalidSubjectOrder)
	}
}

func TestReorderSubjectsPreservesRequestedOrder(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)
	err := service.ReorderSubjects(context.Background(), []string{"subject-2", "subject-1"})
	if err != nil {
		t.Fatalf("ReorderSubjects() error = %v", err)
	}
	if len(repository.reorderedSubjects) != 2 || repository.reorderedSubjects[0] != "subject-2" {
		t.Fatalf("ReorderSubjects() persisted %#v", repository.reorderedSubjects)
	}
}

func TestReorderTopicsPreservesRequestedOrder(t *testing.T) {
	repository := &fakeRepository{}
	service := NewService(repository)
	err := service.ReorderTopics(context.Background(), "subject-id", []string{"topic-2", "topic-1"})
	if err != nil {
		t.Fatalf("ReorderTopics() error = %v", err)
	}
	if len(repository.reorderedTopics) != 2 || repository.reorderedTopics[0] != "topic-2" {
		t.Fatalf("ReorderTopics() persisted %#v", repository.reorderedTopics)
	}
}

func TestCreateSubjectRejectsInvalidDifficulty(t *testing.T) {
	service := NewService(&fakeRepository{})
	_, err := service.CreateSubject(context.Background(), domain.CreateSubjectInput{
		Name:       "Português",
		Difficulty: 6,
		Color:      "#E8742A",
	})
	if !errors.Is(err, ErrInvalidDifficulty) {
		t.Fatalf("CreateSubject() error = %v, want %v", err, ErrInvalidDifficulty)
	}
}

type fakeRepository struct {
	createdSubject    domain.CreateSubjectInput
	createdTopics     []string
	replacedTopics    []domain.ReplaceTopicInput
	reorderedSubjects []string
	reorderedTopics   []string
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
func (f *fakeRepository) DeleteSubject(context.Context, string) error { return nil }
func (f *fakeRepository) ReorderSubjects(_ context.Context, subjectIDs []string) error {
	f.reorderedSubjects = subjectIDs
	return nil
}
func (f *fakeRepository) CreateTopics(_ context.Context, _ string, names []string) error {
	f.createdTopics = names
	return nil
}
func (f *fakeRepository) ReplaceTopics(_ context.Context, _ string, topics []domain.ReplaceTopicInput) error {
	f.replacedTopics = topics
	return nil
}
func (f *fakeRepository) ReorderTopics(_ context.Context, _ string, topicIDs []string) error {
	f.reorderedTopics = topicIDs
	return nil
}
func (f *fakeRepository) UpdateTopic(context.Context, string, string) error { return nil }
func (f *fakeRepository) DeleteTopic(context.Context, string) error         { return nil }

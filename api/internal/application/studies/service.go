package studies

import (
	"context"
	"errors"
	"regexp"
	"strings"

	domain "concursosapp/api/internal/domain/studies"
)

var (
	ErrNameRequired      = errors.New("informe um nome")
	ErrTopicsRequired    = errors.New("informe ao menos um Tópico")
	ErrNameTooLong       = errors.New("o nome deve ter no máximo 120 caracteres")
	ErrInvalidDifficulty = errors.New("a dificuldade deve estar entre 1 e 5")
	ErrInvalidColor      = errors.New("a cor deve estar no formato hexadecimal #RRGGBB")
	colorPattern         = regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
)

type Service struct {
	repository domain.Repository
}

func NewService(repository domain.Repository) *Service {
	return &Service{repository: repository}
}

func (s *Service) Catalog(ctx context.Context) ([]domain.Subject, error) {
	return s.repository.FindCatalog(ctx)
}

func (s *Service) CreateSubject(ctx context.Context, input domain.CreateSubjectInput) (string, error) {
	name, err := validateName(input.Name)
	if err != nil {
		return "", err
	}
	if !input.Difficulty.Valid() {
		return "", ErrInvalidDifficulty
	}
	if !colorPattern.MatchString(input.Color) {
		return "", ErrInvalidColor
	}
	input.Name = name
	return s.repository.CreateSubject(ctx, input)
}

func (s *Service) UpdateSubject(ctx context.Context, id string, input domain.UpdateSubjectInput) error {
	if input.Name != nil {
		name, err := validateName(*input.Name)
		if err != nil {
			return err
		}
		input.Name = &name
	}
	if input.Difficulty != nil && !input.Difficulty.Valid() {
		return ErrInvalidDifficulty
	}
	if input.Color != nil && !colorPattern.MatchString(*input.Color) {
		return ErrInvalidColor
	}
	return s.repository.UpdateSubject(ctx, id, input)
}

func (s *Service) DeleteSubject(ctx context.Context, id string) error {
	return s.repository.DeleteSubject(ctx, id)
}

func (s *Service) ReorderSubjects(ctx context.Context, subjectIDs []string) error {
	values, err := validateOrder(subjectIDs, domain.ErrInvalidSubjectOrder)
	if err != nil {
		return err
	}
	return s.repository.ReorderSubjects(ctx, values)
}

func (s *Service) CreateTopic(ctx context.Context, subjectID, name string) error {
	return s.CreateTopics(ctx, subjectID, []string{name})
}

func (s *Service) CreateTopics(ctx context.Context, subjectID string, names []string) error {
	if len(names) == 0 {
		return ErrTopicsRequired
	}
	values := make([]string, 0, len(names))
	for _, name := range names {
		value, err := validateName(name)
		if err != nil {
			return err
		}
		if value == domain.MandatoryReviewTopicName {
			return domain.ErrMandatoryTopic
		}
		values = append(values, value)
	}
	return s.repository.CreateTopics(ctx, subjectID, values)
}

func (s *Service) ReplaceTopics(ctx context.Context, subjectID string, topics []domain.ReplaceTopicInput) error {
	values := make([]domain.ReplaceTopicInput, 0, len(topics))
	seenIDs := make(map[string]struct{}, len(topics))
	for _, topic := range topics {
		name, err := validateName(topic.Name)
		if err != nil {
			return err
		}
		if name == domain.MandatoryReviewTopicName {
			return domain.ErrMandatoryTopic
		}
		id := strings.TrimSpace(topic.ID)
		if id != "" {
			if _, exists := seenIDs[id]; exists {
				return domain.ErrInvalidTopicOrder
			}
			seenIDs[id] = struct{}{}
		}
		values = append(values, domain.ReplaceTopicInput{ID: id, Name: name})
	}
	return s.repository.ReplaceTopics(ctx, subjectID, values)
}

func (s *Service) UpdateTopic(ctx context.Context, id, name string) error {
	value, err := validateName(name)
	if err != nil {
		return err
	}
	if value == domain.MandatoryReviewTopicName {
		return domain.ErrMandatoryTopic
	}
	return s.repository.UpdateTopic(ctx, id, value)
}

func (s *Service) ReorderTopics(ctx context.Context, subjectID string, topicIDs []string) error {
	values, err := validateOrder(topicIDs, domain.ErrInvalidTopicOrder)
	if err != nil {
		return err
	}
	return s.repository.ReorderTopics(ctx, subjectID, values)
}

func (s *Service) DeleteTopic(ctx context.Context, id string) error {
	return s.repository.DeleteTopic(ctx, id)
}

func validateName(name string) (string, error) {
	value := strings.TrimSpace(name)
	if value == "" {
		return "", ErrNameRequired
	}
	if len([]rune(value)) > 120 {
		return "", ErrNameTooLong
	}
	return value, nil
}

func validateOrder(ids []string, invalidOrder error) ([]string, error) {
	if len(ids) == 0 {
		return nil, invalidOrder
	}
	seen := make(map[string]struct{}, len(ids))
	values := make([]string, 0, len(ids))
	for _, id := range ids {
		value := strings.TrimSpace(id)
		if value == "" {
			return nil, invalidOrder
		}
		if _, exists := seen[value]; exists {
			return nil, invalidOrder
		}
		seen[value] = struct{}{}
		values = append(values, value)
	}
	return values, nil
}

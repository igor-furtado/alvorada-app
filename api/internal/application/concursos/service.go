package concursos

import (
	"context"
	"errors"
	"strings"

	domain "concursosapp/api/internal/domain/concursos"
)

var (
	ErrInstituicaoRequired = errors.New("informe o órgão ou instituição")
	ErrCargoRequired       = errors.New("informe o cargo")
	ErrInstituicaoTooLong  = errors.New("o órgão ou instituição deve ter no máximo 160 caracteres")
	ErrCargoTooLong        = errors.New("o cargo deve ter no máximo 160 caracteres")
	ErrBancaTooLong        = errors.New("a banca deve ter no máximo 120 caracteres")
)

type Service struct {
	repository domain.Repository
}

func NewService(repository domain.Repository) *Service {
	return &Service{repository: repository}
}

func (s *Service) ListActive(ctx context.Context) ([]domain.Concurso, error) {
	return s.repository.FindActive(ctx)
}

func (s *Service) Create(ctx context.Context, input domain.CreateConcursoInput) (string, error) {
	instituicao, err := requiredText(input.Instituicao, 160, ErrInstituicaoRequired, ErrInstituicaoTooLong)
	if err != nil {
		return "", err
	}
	cargo, err := requiredText(input.Cargo, 160, ErrCargoRequired, ErrCargoTooLong)
	if err != nil {
		return "", err
	}
	banca, err := optionalText(input.Banca, 120, ErrBancaTooLong)
	if err != nil {
		return "", err
	}
	input.Instituicao = instituicao
	input.Cargo = cargo
	input.Banca = banca
	return s.repository.Create(ctx, input)
}

func (s *Service) SetPrioritario(ctx context.Context, id string) error {
	return s.repository.SetPrioritario(ctx, id)
}

func (s *Service) Archive(ctx context.Context, id string) error {
	return s.repository.Archive(ctx, id)
}

func (s *Service) Restore(ctx context.Context, id string) error {
	return s.repository.Restore(ctx, id)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	return s.repository.Delete(ctx, id)
}

func requiredText(value string, limit int, requiredError, lengthError error) (string, error) {
	normalized := strings.TrimSpace(value)
	if normalized == "" {
		return "", requiredError
	}
	if len([]rune(normalized)) > limit {
		return "", lengthError
	}
	return normalized, nil
}

func optionalText(value *string, limit int, lengthError error) (*string, error) {
	if value == nil {
		return nil, nil
	}
	normalized := strings.TrimSpace(*value)
	if normalized == "" {
		return nil, nil
	}
	if len([]rune(normalized)) > limit {
		return nil, lengthError
	}
	return &normalized, nil
}

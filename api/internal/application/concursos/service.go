package concursos

import (
	"context"
	"errors"
	"strings"
	"time"

	domain "concursosapp/api/internal/domain/concursos"
)

var (
	ErrInstituicaoRequired = errors.New("informe o órgão ou instituição")
	ErrCargoRequired       = errors.New("informe o cargo")
	ErrInstituicaoTooLong  = errors.New("o órgão ou instituição deve ter no máximo 160 caracteres")
	ErrCargoTooLong        = errors.New("o cargo deve ter no máximo 160 caracteres")
	ErrBancaTooLong        = errors.New("a banca deve ter no máximo 120 caracteres")
	ErrSiglaTooLong        = errors.New("a sigla do órgão deve ter no máximo 24 caracteres")
	ErrQuantidadeVagas     = errors.New("a quantidade de vagas deve estar entre 0 e 1.000.000")
	ErrVencimento          = errors.New("o vencimento não pode ser negativo")
	ErrCargaHoraria        = errors.New("a carga horária semanal deve estar entre 1 e 168 horas")
	ErrLocalProvaTooLong   = errors.New("o local da prova deve ter no máximo 240 caracteres")
	ErrHorariosProva       = errors.New("informe início e término válidos, com o término posterior ao início")
	ErrRequisitosTooLong   = errors.New("os requisitos devem ter no máximo 10.000 caracteres")
	ErrPontuacaoTooLong    = errors.New("as informações de pontuação devem ter no máximo 10.000 caracteres")
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
	fields, err := normalizeFields(rawFields{
		instituicao: input.Instituicao, cargo: input.Cargo, banca: input.Banca, sigla: input.Sigla,
		quantidadeVagas: input.QuantidadeVagas, vencimentoCentavos: input.VencimentoCentavos,
		cargaHorariaSemanal: input.CargaHorariaSemanal, localProva: input.LocalProva,
		horarioInicioProva: input.HorarioInicioProva, horarioFimProva: input.HorarioFimProva,
		requisitos: input.Requisitos, criteriosPontuacao: input.CriteriosPontuacao,
	})
	if err != nil {
		return "", err
	}
	applyCreateFields(&input, fields)
	return s.repository.Create(ctx, input)
}

func (s *Service) Update(ctx context.Context, id string, input domain.UpdateConcursoInput) error {
	fields, err := normalizeFields(rawFields{
		instituicao: input.Instituicao, cargo: input.Cargo, banca: input.Banca, sigla: input.Sigla,
		quantidadeVagas: input.QuantidadeVagas, vencimentoCentavos: input.VencimentoCentavos,
		cargaHorariaSemanal: input.CargaHorariaSemanal, localProva: input.LocalProva,
		horarioInicioProva: input.HorarioInicioProva, horarioFimProva: input.HorarioFimProva,
		requisitos: input.Requisitos, criteriosPontuacao: input.CriteriosPontuacao,
	})
	if err != nil {
		return err
	}
	applyUpdateFields(&input, fields)
	return s.repository.Update(ctx, id, input)
}

type rawFields struct {
	instituicao         string
	cargo               string
	banca               *string
	sigla               *string
	quantidadeVagas     *int
	vencimentoCentavos  *int64
	cargaHorariaSemanal *int
	localProva          *string
	horarioInicioProva  *string
	horarioFimProva     *string
	requisitos          *string
	criteriosPontuacao  *string
}

type normalizedFields struct {
	instituicao         string
	cargo               string
	banca               *string
	sigla               *string
	quantidadeVagas     *int
	vencimentoCentavos  *int64
	cargaHorariaSemanal *int
	localProva          *string
	horarioInicioProva  *string
	horarioFimProva     *string
	requisitos          *string
	criteriosPontuacao  *string
}

func normalizeFields(input rawFields) (normalizedFields, error) {
	instituicao, err := requiredText(input.instituicao, 160, ErrInstituicaoRequired, ErrInstituicaoTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	cargo, err := requiredText(input.cargo, 160, ErrCargoRequired, ErrCargoTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	banca, err := optionalText(input.banca, 120, ErrBancaTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	sigla, err := optionalText(input.sigla, 24, ErrSiglaTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	localProva, err := optionalText(input.localProva, 240, ErrLocalProvaTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	requisitos, err := optionalText(input.requisitos, 10000, ErrRequisitosTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	criterios, err := optionalText(input.criteriosPontuacao, 10000, ErrPontuacaoTooLong)
	if err != nil {
		return normalizedFields{}, err
	}
	if value := input.quantidadeVagas; value != nil && (*value < 0 || *value > 1000000) {
		return normalizedFields{}, ErrQuantidadeVagas
	}
	if value := input.vencimentoCentavos; value != nil && *value < 0 {
		return normalizedFields{}, ErrVencimento
	}
	if value := input.cargaHorariaSemanal; value != nil && (*value < 1 || *value > 168) {
		return normalizedFields{}, ErrCargaHoraria
	}
	horarioInicio := normalizeOptionalTime(input.horarioInicioProva)
	horarioFim := normalizeOptionalTime(input.horarioFimProva)
	if (horarioInicio == nil) != (horarioFim == nil) ||
		(horarioInicio != nil && (!validTime(*horarioInicio) || !validTime(*horarioFim) || *horarioInicio >= *horarioFim)) {
		return normalizedFields{}, ErrHorariosProva
	}
	return normalizedFields{
		instituicao: instituicao, cargo: cargo, banca: banca, sigla: sigla,
		quantidadeVagas: input.quantidadeVagas, vencimentoCentavos: input.vencimentoCentavos,
		cargaHorariaSemanal: input.cargaHorariaSemanal, localProva: localProva,
		horarioInicioProva: horarioInicio, horarioFimProva: horarioFim,
		requisitos: requisitos, criteriosPontuacao: criterios,
	}, nil
}

func applyCreateFields(input *domain.CreateConcursoInput, fields normalizedFields) {
	input.Instituicao, input.Cargo, input.Banca, input.Sigla = fields.instituicao, fields.cargo, fields.banca, fields.sigla
	input.QuantidadeVagas, input.VencimentoCentavos = fields.quantidadeVagas, fields.vencimentoCentavos
	input.CargaHorariaSemanal, input.LocalProva = fields.cargaHorariaSemanal, fields.localProva
	input.HorarioInicioProva, input.HorarioFimProva = fields.horarioInicioProva, fields.horarioFimProva
	input.Requisitos, input.CriteriosPontuacao = fields.requisitos, fields.criteriosPontuacao
}

func applyUpdateFields(input *domain.UpdateConcursoInput, fields normalizedFields) {
	input.Instituicao, input.Cargo, input.Banca, input.Sigla = fields.instituicao, fields.cargo, fields.banca, fields.sigla
	input.QuantidadeVagas, input.VencimentoCentavos = fields.quantidadeVagas, fields.vencimentoCentavos
	input.CargaHorariaSemanal, input.LocalProva = fields.cargaHorariaSemanal, fields.localProva
	input.HorarioInicioProva, input.HorarioFimProva = fields.horarioInicioProva, fields.horarioFimProva
	input.Requisitos, input.CriteriosPontuacao = fields.requisitos, fields.criteriosPontuacao
}

func normalizeOptionalTime(value *string) *string {
	if value == nil {
		return nil
	}
	normalized := strings.TrimSpace(*value)
	if normalized == "" {
		return nil
	}
	return &normalized
}

func validTime(value string) bool {
	_, err := time.Parse("15:04", value)
	return err == nil
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

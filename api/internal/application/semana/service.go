package semana

import (
	"context"
	"errors"
	"time"

	domain "concursosapp/api/internal/domain/semana"
)

var (
	ErrPeriodoInvalido      = errors.New("informe um período semanal válido")
	ErrDataInvalida         = errors.New("informe uma data de planejamento válida")
	ErrProgressoVazio       = errors.New("informe ao menos uma atividade para atualizar")
	ErrResultadoQuestao     = errors.New("o resultado deve ser certa ou errada")
	ErrIntervaloRevisao     = errors.New("as revisões devem usar D+1, D+7 ou D+30, sem repetições")
	ErrTopicoNaoEncontrado  = domain.ErrTopicoNaoEncontrado
	ErrTopicoNaoConcluido   = domain.ErrTopicoNaoConcluido
	ErrRevisaoNaoEncontrada = domain.ErrRevisaoNaoEncontrada
)

type Service struct {
	repository domain.Repository
}

func NewService(repository domain.Repository) *Service {
	return &Service{repository: repository}
}

func (s *Service) Planejamento(ctx context.Context, inicio, fim time.Time) (domain.Planejamento, error) {
	inicio = somenteData(inicio)
	fim = somenteData(fim)
	if fim.Before(inicio) || fim.Sub(inicio) > 31*24*time.Hour {
		return domain.Planejamento{}, ErrPeriodoInvalido
	}
	return s.repository.FindPlanejamento(ctx, inicio, fim)
}

func (s *Service) PlanejarTopico(
	ctx context.Context,
	concursoID, topicoID string,
	data time.Time,
	posicao uint,
) error {
	if data.IsZero() {
		return ErrDataInvalida
	}
	return s.repository.PlanejarTopico(ctx, concursoID, topicoID, somenteData(data), posicao)
}

func (s *Service) AtualizarProgresso(
	ctx context.Context,
	concursoID, topicoID string,
	input domain.ProgressoInput,
) error {
	if input.TeoriaConcluida == nil && input.MemoriaConcluida == nil && input.ConferenciaConcluida == nil {
		return ErrProgressoVazio
	}
	return s.repository.AtualizarProgresso(
		ctx,
		concursoID,
		topicoID,
		input,
		domain.VersaoMetodologiaAtual,
	)
}

func (s *Service) RegistrarQuestao(
	ctx context.Context,
	concursoID, topicoID string,
	resultado domain.ResultadoQuestao,
) error {
	if resultado != domain.QuestaoCerta && resultado != domain.QuestaoErrada {
		return ErrResultadoQuestao
	}
	return s.repository.RegistrarQuestao(
		ctx,
		concursoID,
		topicoID,
		resultado,
		domain.VersaoMetodologiaAtual,
	)
}

func (s *Service) SubstituirRevisoes(
	ctx context.Context,
	concursoID, topicoID string,
	intervalos []uint8,
) error {
	seen := make(map[uint8]struct{}, len(intervalos))
	for _, intervalo := range intervalos {
		if intervalo != 1 && intervalo != 7 && intervalo != 30 {
			return ErrIntervaloRevisao
		}
		if _, exists := seen[intervalo]; exists {
			return ErrIntervaloRevisao
		}
		seen[intervalo] = struct{}{}
	}
	return s.repository.SubstituirRevisoes(ctx, concursoID, topicoID, intervalos)
}

func (s *Service) MoverRevisao(ctx context.Context, revisaoID string, data time.Time, posicao uint) error {
	if data.IsZero() {
		return ErrDataInvalida
	}
	return s.repository.MoverRevisao(ctx, revisaoID, somenteData(data), posicao)
}

func (s *Service) ConcluirRevisao(ctx context.Context, revisaoID string) error {
	return s.repository.ConcluirRevisao(ctx, revisaoID)
}

func somenteData(value time.Time) time.Time {
	return time.Date(value.Year(), value.Month(), value.Day(), 0, 0, 0, 0, time.UTC)
}

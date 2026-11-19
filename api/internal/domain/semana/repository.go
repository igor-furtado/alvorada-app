package semana

import (
	"context"
	"time"
)

type Repository interface {
	FindPlanejamento(ctx context.Context, inicio, fim time.Time) (Planejamento, error)
	PlanejarTopico(ctx context.Context, concursoID, topicoID string, data time.Time, posicao uint) error
	AtualizarProgresso(ctx context.Context, concursoID, topicoID string, input ProgressoInput, versao uint16) error
	RegistrarQuestao(ctx context.Context, concursoID, topicoID string, resultado ResultadoQuestao, versao uint16) error
	SubstituirRevisoes(ctx context.Context, concursoID, topicoID string, intervalos []uint8) error
	MoverRevisao(ctx context.Context, revisaoID string, data time.Time, posicao uint) error
	ConcluirRevisao(ctx context.Context, revisaoID string) error
}

package semana

import (
	"errors"
	"time"
)

var (
	ErrTopicoNaoEncontrado  = errors.New("o Tópico não pertence ao Edital informado")
	ErrTopicoNaoConcluido   = errors.New("conclua teoria, memória e conferência antes de agendar revisões")
	ErrRevisaoNaoEncontrada = errors.New("a Revisão programada não foi encontrada")
)

const VersaoMetodologiaAtual uint16 = 1

type TipoItem string

const (
	TipoEstudoInicial TipoItem = "estudo_inicial"
	TipoRevisao       TipoItem = "revisao"
)

type Item struct {
	ID                   string
	Tipo                 TipoItem
	ConcursoID           string
	ConcursoNome         string
	ConcursoSigla        *string
	TopicoID             string
	TopicoNome           string
	DisciplinaNome       string
	DataPlanejada        time.Time
	PosicaoDia           uint
	TeoriaConcluida      bool
	MemoriaConcluida     bool
	ConferenciaConcluida bool
	Acertos              uint
	Erros                uint
	VersaoMetodologia    *uint16
	Concluido            bool
	IntervaloRevisaoDias *uint8
}

type TopicoDisponivel struct {
	ConcursoID     string
	ConcursoNome   string
	ConcursoSigla  *string
	TopicoID       string
	TopicoNome     string
	DisciplinaNome string
}

type Planejamento struct {
	Inicio      time.Time
	Fim         time.Time
	Itens       []Item
	Disponiveis []TopicoDisponivel
}

type ProgressoInput struct {
	TeoriaConcluida      *bool
	MemoriaConcluida     *bool
	ConferenciaConcluida *bool
}

type ResultadoQuestao string

const (
	QuestaoCerta  ResultadoQuestao = "certa"
	QuestaoErrada ResultadoQuestao = "errada"
)

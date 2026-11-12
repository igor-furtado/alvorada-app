package concursos

import (
	"errors"
	"time"
)

var ErrConcursoNotFound = errors.New("Concurso não encontrado")

type Concurso struct {
	ID                  string
	Instituicao         string
	Cargo               string
	Banca               *string
	DataProva           *time.Time
	Prioritario         bool
	ProgressoEdital     int
	Sigla               *string
	QuantidadeVagas     *int
	VencimentoCentavos  *int64
	CargaHorariaSemanal *int
	LocalProva          *string
	HorarioInicioProva  *string
	HorarioFimProva     *string
	Requisitos          *string
	CriteriosPontuacao  *string
	Disciplinas         []EditalDisciplina
}

type EditalDisciplina struct {
	ID      string         `json:"id"`
	Nome    string         `json:"nome"`
	Topicos []EditalTopico `json:"topicos"`
}

type EditalTopico struct {
	ID          string `json:"id"`
	Nome        string `json:"nome"`
	Obrigatorio bool   `json:"obrigatorio"`
}

type CreateConcursoInput struct {
	Instituicao         string
	Cargo               string
	Banca               *string
	DataProva           *time.Time
	Prioritario         bool
	Sigla               *string
	QuantidadeVagas     *int
	VencimentoCentavos  *int64
	CargaHorariaSemanal *int
	LocalProva          *string
	HorarioInicioProva  *string
	HorarioFimProva     *string
	Requisitos          *string
	CriteriosPontuacao  *string
}

type UpdateConcursoInput struct {
	Instituicao         string
	Cargo               string
	Banca               *string
	DataProva           *time.Time
	Prioritario         bool
	Sigla               *string
	QuantidadeVagas     *int
	VencimentoCentavos  *int64
	CargaHorariaSemanal *int
	LocalProva          *string
	HorarioInicioProva  *string
	HorarioFimProva     *string
	Requisitos          *string
	CriteriosPontuacao  *string
}

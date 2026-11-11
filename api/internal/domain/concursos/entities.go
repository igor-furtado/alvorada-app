package concursos

import (
	"errors"
	"time"
)

var ErrConcursoNotFound = errors.New("Concurso não encontrado")

type Concurso struct {
	ID              string
	Instituicao     string
	Cargo           string
	Banca           *string
	DataProva       *time.Time
	Prioritario     bool
	ProgressoEdital int
}

type CreateConcursoInput struct {
	Instituicao string
	Cargo       string
	Banca       *string
	DataProva   *time.Time
	Prioritario bool
}

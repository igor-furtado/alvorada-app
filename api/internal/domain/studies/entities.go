package studies

import "errors"

const MandatoryReviewTopicName = "Revisão de Véspera"

var ErrMandatoryTopic = errors.New("o Tópico Revisão de Véspera é obrigatório e não pode ser alterado ou excluído")
var ErrContentLinked = errors.New("o conteúdo está vinculado a um Edital e não pode ser excluído")

type Difficulty int

const (
	DifficultyVeryEasy Difficulty = 1
	DifficultyEasy     Difficulty = 2
	DifficultyMedium   Difficulty = 3
	DifficultyHard     Difficulty = 4
	DifficultyVeryHard Difficulty = 5
)

func (d Difficulty) Valid() bool {
	return d >= DifficultyVeryEasy && d <= DifficultyVeryHard
}

type Subject struct {
	ID         string     `json:"id"`
	Name       string     `json:"nome"`
	Difficulty Difficulty `json:"dificuldade"`
	Color      string     `json:"cor"`
	Topics     []Topic    `json:"topicos"`
}

type Topic struct {
	ID        string `json:"id"`
	Name      string `json:"nome"`
	Mandatory bool   `json:"obrigatorio"`
}

type CreateSubjectInput struct {
	Name       string
	Difficulty Difficulty
	Color      string
}

type UpdateSubjectInput struct {
	Name       *string
	Difficulty *Difficulty
	Color      *string
}

package concursos

import "context"

type Repository interface {
	FindActive(ctx context.Context) ([]Concurso, error)
	Create(ctx context.Context, input CreateConcursoInput) (string, error)
	Update(ctx context.Context, id string, input UpdateConcursoInput) error
	SetPrioritario(ctx context.Context, id string) error
	Archive(ctx context.Context, id string) error
	Restore(ctx context.Context, id string) error
	Delete(ctx context.Context, id string) error
	AddDisciplinaToEdital(ctx context.Context, concursoID, disciplinaID string) error
	AddTopicoToEdital(ctx context.Context, concursoID, topicoID string) error
	RemoveTopicoFromEdital(ctx context.Context, concursoID, topicoID string) error
}

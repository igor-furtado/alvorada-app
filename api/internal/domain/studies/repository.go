package studies

import "context"

type Repository interface {
	FindCatalog(ctx context.Context) ([]Subject, error)
	CreateSubject(ctx context.Context, input CreateSubjectInput) (string, error)
	UpdateSubject(ctx context.Context, id string, input UpdateSubjectInput) error
	DeleteSubject(ctx context.Context, id string) error
	CreateTopic(ctx context.Context, subjectID, name string) error
	UpdateTopic(ctx context.Context, id, name string) error
	DeleteTopic(ctx context.Context, id string) error
	CreateSubtopic(ctx context.Context, topicID, name string) error
	UpdateSubtopic(ctx context.Context, id, name string) error
	DeleteSubtopic(ctx context.Context, id string) error
}

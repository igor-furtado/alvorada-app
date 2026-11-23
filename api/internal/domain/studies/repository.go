package studies

import "context"

type Repository interface {
	FindCatalog(ctx context.Context) ([]Subject, error)
	CreateSubject(ctx context.Context, input CreateSubjectInput) (string, error)
	UpdateSubject(ctx context.Context, id string, input UpdateSubjectInput) error
	DeleteSubject(ctx context.Context, id string) error
	ReorderSubjects(ctx context.Context, subjectIDs []string) error
	CreateTopics(ctx context.Context, subjectID string, names []string) error
	ReplaceTopics(ctx context.Context, subjectID string, topics []ReplaceTopicInput) error
	ReorderTopics(ctx context.Context, subjectID string, topicIDs []string) error
	UpdateTopic(ctx context.Context, id, name string) error
	DeleteTopic(ctx context.Context, id string) error
}

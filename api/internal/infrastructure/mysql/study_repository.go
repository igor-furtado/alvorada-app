package mysqlrepo

import (
	"context"
	"crypto/rand"
	"database/sql"
	"fmt"
	"strings"

	domain "concursosapp/api/internal/domain/studies"
)

type StudyRepository struct {
	db *sql.DB
}

func NewStudyRepository(db *sql.DB) *StudyRepository {
	return &StudyRepository{db: db}
}

func (r *StudyRepository) FindCatalog(ctx context.Context) ([]domain.Subject, error) {
	tx, err := r.db.BeginTx(ctx, &sql.TxOptions{ReadOnly: true})
	if err != nil {
		return nil, fmt.Errorf("begin catalog transaction: %w", err)
	}
	defer tx.Rollback()

	catalog, subjectIndexes, err := querySubjects(ctx, tx)
	if err != nil {
		return nil, err
	}
	topicIndexes, err := queryTopics(ctx, tx, catalog, subjectIndexes)
	if err != nil {
		return nil, err
	}
	if err := querySubtopics(ctx, tx, topicIndexes); err != nil {
		return nil, err
	}
	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit catalog transaction: %w", err)
	}
	return catalog, nil
}

func querySubjects(ctx context.Context, tx *sql.Tx) ([]domain.Subject, map[string]int, error) {
	rows, err := tx.QueryContext(ctx, `
		SELECT id, name, difficulty, color
		FROM subjects
		ORDER BY position, created_at`)
	if err != nil {
		return nil, nil, fmt.Errorf("query subjects: %w", err)
	}
	defer rows.Close()

	catalog := make([]domain.Subject, 0)
	indexes := make(map[string]int)
	for rows.Next() {
		var subject domain.Subject
		if err := rows.Scan(&subject.ID, &subject.Name, &subject.Difficulty, &subject.Color); err != nil {
			return nil, nil, fmt.Errorf("scan subject: %w", err)
		}
		subject.Topics = make([]domain.Topic, 0)
		indexes[subject.ID] = len(catalog)
		catalog = append(catalog, subject)
	}
	if err := rows.Err(); err != nil {
		return nil, nil, fmt.Errorf("iterate subjects: %w", err)
	}
	return catalog, indexes, nil
}

func queryTopics(ctx context.Context, tx *sql.Tx, catalog []domain.Subject, subjectIndexes map[string]int) (map[string]*domain.Topic, error) {
	rows, err := tx.QueryContext(ctx, `
		SELECT id, subject_id, name
		FROM topics
		ORDER BY position, created_at`)
	if err != nil {
		return nil, fmt.Errorf("query topics: %w", err)
	}
	defer rows.Close()

	topicIndexes := make(map[string]*domain.Topic)
	for rows.Next() {
		var topic domain.Topic
		var subjectID string
		if err := rows.Scan(&topic.ID, &subjectID, &topic.Name); err != nil {
			return nil, fmt.Errorf("scan topic: %w", err)
		}
		topic.Subtopics = make([]domain.Subtopic, 0)
		subjectIndex, exists := subjectIndexes[subjectID]
		if !exists {
			continue
		}
		catalog[subjectIndex].Topics = append(catalog[subjectIndex].Topics, topic)
		topicIndexes[topic.ID] = &catalog[subjectIndex].Topics[len(catalog[subjectIndex].Topics)-1]
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate topics: %w", err)
	}
	return topicIndexes, nil
}

func querySubtopics(ctx context.Context, tx *sql.Tx, topicIndexes map[string]*domain.Topic) error {
	rows, err := tx.QueryContext(ctx, `
		SELECT id, topic_id, name
		FROM subtopics
		ORDER BY position, created_at`)
	if err != nil {
		return fmt.Errorf("query subtopics: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var subtopic domain.Subtopic
		var topicID string
		if err := rows.Scan(&subtopic.ID, &topicID, &subtopic.Name); err != nil {
			return fmt.Errorf("scan subtopic: %w", err)
		}
		if topic, exists := topicIndexes[topicID]; exists {
			topic.Subtopics = append(topic.Subtopics, subtopic)
		}
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate subtopics: %w", err)
	}
	return nil
}

func (r *StudyRepository) CreateSubject(ctx context.Context, input domain.CreateSubjectInput) (string, error) {
	id, err := newUUID()
	if err != nil {
		return "", err
	}
	_, err = r.db.ExecContext(ctx, `
		INSERT INTO subjects (id, name, difficulty, color)
		VALUES (?, ?, ?, ?)`, id, input.Name, input.Difficulty, input.Color)
	if err != nil {
		return "", fmt.Errorf("insert subject: %w", err)
	}
	return id, nil
}

func (r *StudyRepository) UpdateSubject(ctx context.Context, id string, input domain.UpdateSubjectInput) error {
	changes := make([]string, 0, 3)
	args := make([]any, 0, 4)
	if input.Name != nil {
		changes = append(changes, "name = ?")
		args = append(args, *input.Name)
	}
	if input.Difficulty != nil {
		changes = append(changes, "difficulty = ?")
		args = append(args, *input.Difficulty)
	}
	if input.Color != nil {
		changes = append(changes, "color = ?")
		args = append(args, *input.Color)
	}
	if len(changes) == 0 {
		return nil
	}
	args = append(args, id)
	_, err := r.db.ExecContext(ctx, "UPDATE subjects SET "+strings.Join(changes, ", ")+" WHERE id = ?", args...)
	if err != nil {
		return fmt.Errorf("update subject: %w", err)
	}
	return nil
}

func (r *StudyRepository) DeleteSubject(ctx context.Context, id string) error {
	return exec(ctx, r.db, "delete subject", "DELETE FROM subjects WHERE id = ?", id)
}

func (r *StudyRepository) CreateTopic(ctx context.Context, subjectID, name string) error {
	id, err := newUUID()
	if err != nil {
		return err
	}
	return exec(ctx, r.db, "insert topic", "INSERT INTO topics (id, subject_id, name) VALUES (?, ?, ?)", id, subjectID, name)
}

func (r *StudyRepository) UpdateTopic(ctx context.Context, id, name string) error {
	return exec(ctx, r.db, "update topic", "UPDATE topics SET name = ? WHERE id = ?", name, id)
}

func (r *StudyRepository) DeleteTopic(ctx context.Context, id string) error {
	return exec(ctx, r.db, "delete topic", "DELETE FROM topics WHERE id = ?", id)
}

func (r *StudyRepository) CreateSubtopic(ctx context.Context, topicID, name string) error {
	id, err := newUUID()
	if err != nil {
		return err
	}
	return exec(ctx, r.db, "insert subtopic", "INSERT INTO subtopics (id, topic_id, name) VALUES (?, ?, ?)", id, topicID, name)
}

func (r *StudyRepository) UpdateSubtopic(ctx context.Context, id, name string) error {
	return exec(ctx, r.db, "update subtopic", "UPDATE subtopics SET name = ? WHERE id = ?", name, id)
}

func (r *StudyRepository) DeleteSubtopic(ctx context.Context, id string) error {
	return exec(ctx, r.db, "delete subtopic", "DELETE FROM subtopics WHERE id = ?", id)
}

func exec(ctx context.Context, db *sql.DB, operation, query string, args ...any) error {
	if _, err := db.ExecContext(ctx, query, args...); err != nil {
		return fmt.Errorf("%s: %w", operation, err)
	}
	return nil
}

func newUUID() (string, error) {
	var value [16]byte
	if _, err := rand.Read(value[:]); err != nil {
		return "", fmt.Errorf("generate uuid: %w", err)
	}
	value[6] = (value[6] & 0x0f) | 0x40
	value[8] = (value[8] & 0x3f) | 0x80
	return fmt.Sprintf("%08x-%04x-%04x-%04x-%012x", value[0:4], value[4:6], value[6:8], value[8:10], value[10:16]), nil
}

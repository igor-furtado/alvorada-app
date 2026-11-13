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
	if err := queryTopics(ctx, tx, catalog, subjectIndexes); err != nil {
		return nil, err
	}
	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit catalog transaction: %w", err)
	}
	return catalog, nil
}

func querySubjects(ctx context.Context, tx *sql.Tx) ([]domain.Subject, map[string]int, error) {
	rows, err := tx.QueryContext(ctx, `
		SELECT id, nome, dificuldade, cor
		FROM disciplinas
		ORDER BY posicao, criado_em`)
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

func queryTopics(
	ctx context.Context,
	tx *sql.Tx,
	catalog []domain.Subject,
	subjectIndexes map[string]int,
) error {
	rows, err := tx.QueryContext(ctx, `
		SELECT id, disciplina_id, nome, BINARY nome = BINARY ? AS obrigatorio
		FROM topicos
		ORDER BY disciplina_id, obrigatorio, posicao, criado_em`, domain.MandatoryReviewTopicName)
	if err != nil {
		return fmt.Errorf("query topics: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var topic domain.Topic
		var subjectID string
		if err := rows.Scan(&topic.ID, &subjectID, &topic.Name, &topic.Mandatory); err != nil {
			return fmt.Errorf("scan topic: %w", err)
		}
		subjectIndex, exists := subjectIndexes[subjectID]
		if !exists {
			continue
		}
		catalog[subjectIndex].Topics = append(catalog[subjectIndex].Topics, topic)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate topics: %w", err)
	}
	return nil
}

func (r *StudyRepository) CreateSubject(ctx context.Context, input domain.CreateSubjectInput) (string, error) {
	subjectID, err := newUUID()
	if err != nil {
		return "", err
	}
	mandatoryTopicID, err := newUUID()
	if err != nil {
		return "", err
	}
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return "", fmt.Errorf("begin create subject transaction: %w", err)
	}
	defer tx.Rollback()
	_, err = tx.ExecContext(ctx, `
		INSERT INTO disciplinas (id, nome, dificuldade, cor)
		VALUES (?, ?, ?, ?)`, subjectID, input.Name, input.Difficulty, input.Color)
	if err != nil {
		return "", fmt.Errorf("insert subject: %w", err)
	}
	_, err = tx.ExecContext(ctx, `
		INSERT INTO topicos (id, disciplina_id, nome)
		VALUES (?, ?, ?)`, mandatoryTopicID, subjectID, domain.MandatoryReviewTopicName)
	if err != nil {
		return "", fmt.Errorf("insert mandatory review topic: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return "", fmt.Errorf("commit create subject transaction: %w", err)
	}
	return subjectID, nil
}

func (r *StudyRepository) UpdateSubject(ctx context.Context, id string, input domain.UpdateSubjectInput) error {
	changes := make([]string, 0, 3)
	args := make([]any, 0, 4)
	if input.Name != nil {
		changes = append(changes, "nome = ?")
		args = append(args, *input.Name)
	}
	if input.Difficulty != nil {
		changes = append(changes, "dificuldade = ?")
		args = append(args, *input.Difficulty)
	}
	if input.Color != nil {
		changes = append(changes, "cor = ?")
		args = append(args, *input.Color)
	}
	if len(changes) == 0 {
		return nil
	}
	args = append(args, id)
	_, err := r.db.ExecContext(ctx, "UPDATE disciplinas SET "+strings.Join(changes, ", ")+" WHERE id = ?", args...)
	if err != nil {
		return fmt.Errorf("update subject: %w", err)
	}
	return nil
}

func (r *StudyRepository) DeleteSubject(ctx context.Context, id string) error {
	var linked bool
	if err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1
			FROM concursos_topicos
			INNER JOIN topicos ON topicos.id = concursos_topicos.topico_id
			WHERE topicos.disciplina_id = ?
		)`, id).Scan(&linked); err != nil {
		return fmt.Errorf("check linked subject: %w", err)
	}
	if linked {
		return domain.ErrContentLinked
	}
	return exec(ctx, r.db, "delete subject", "DELETE FROM disciplinas WHERE id = ?", id)
}

func (r *StudyRepository) CreateTopics(ctx context.Context, subjectID string, names []string) error {
	if len(names) == 0 {
		return nil
	}
	ids := make([]string, len(names))
	for index := range names {
		id, err := newUUID()
		if err != nil {
			return err
		}
		ids[index] = id
	}
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin create topics transaction: %w", err)
	}
	defer tx.Rollback()
	var lockedSubjectID string
	if err := tx.QueryRowContext(
		ctx,
		"SELECT id FROM disciplinas WHERE id = ? FOR UPDATE",
		subjectID,
	).Scan(&lockedSubjectID); err != nil {
		return fmt.Errorf("lock subject for topics: %w", err)
	}
	var lastPosition int
	if err := tx.QueryRowContext(
		ctx,
		"SELECT COALESCE(MAX(posicao), 0) FROM topicos WHERE disciplina_id = ?",
		subjectID,
	).Scan(&lastPosition); err != nil {
		return fmt.Errorf("query last topic position: %w", err)
	}
	for index, name := range names {
		if _, err := tx.ExecContext(
			ctx,
			"INSERT INTO topicos (id, disciplina_id, nome, posicao) VALUES (?, ?, ?, ?)",
			ids[index],
			subjectID,
			name,
			lastPosition+index+1,
		); err != nil {
			return fmt.Errorf("insert topic: %w", err)
		}
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit create topics transaction: %w", err)
	}
	return nil
}

func (r *StudyRepository) UpdateTopic(ctx context.Context, id, name string) error {
	return execMutableTopic(
		ctx,
		r.db,
		"update topic",
		"UPDATE topicos SET nome = ? WHERE id = ? AND BINARY nome <> BINARY ?",
		id,
		name,
		id,
		domain.MandatoryReviewTopicName,
	)
}

func (r *StudyRepository) DeleteTopic(ctx context.Context, id string) error {
	var linked bool
	if err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(SELECT 1 FROM concursos_topicos WHERE topico_id = ?)`, id).Scan(&linked); err != nil {
		return fmt.Errorf("check linked topic: %w", err)
	}
	if linked {
		return domain.ErrContentLinked
	}
	return execMutableTopic(
		ctx,
		r.db,
		"delete topic",
		"DELETE FROM topicos WHERE id = ? AND BINARY nome <> BINARY ?",
		id,
		id,
		domain.MandatoryReviewTopicName,
	)
}

func exec(ctx context.Context, db *sql.DB, operation, query string, args ...any) error {
	if _, err := db.ExecContext(ctx, query, args...); err != nil {
		return fmt.Errorf("%s: %w", operation, err)
	}
	return nil
}

func execMutableTopic(
	ctx context.Context,
	db *sql.DB,
	operation string,
	query string,
	topicID string,
	args ...any,
) error {
	result, err := db.ExecContext(ctx, query, args...)
	if err != nil {
		return fmt.Errorf("%s: %w", operation, err)
	}
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("%s rows affected: %w", operation, err)
	}
	if affected > 0 {
		return nil
	}
	var mandatory bool
	err = db.QueryRowContext(
		ctx,
		"SELECT EXISTS(SELECT 1 FROM topicos WHERE id = ? AND BINARY nome = BINARY ?)",
		topicID,
		domain.MandatoryReviewTopicName,
	).Scan(&mandatory)
	if err != nil {
		return fmt.Errorf("check mandatory topic: %w", err)
	}
	if mandatory {
		return domain.ErrMandatoryTopic
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

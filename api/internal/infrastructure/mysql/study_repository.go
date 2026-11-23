package mysqlrepo

import (
	"context"
	"crypto/rand"
	"database/sql"
	"errors"
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
		ORDER BY posicao, criado_em, id`)
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
	var lastPosition int
	if err := tx.QueryRowContext(
		ctx,
		"SELECT COALESCE(MAX(posicao), 0) FROM disciplinas",
	).Scan(&lastPosition); err != nil {
		return "", fmt.Errorf("query last subject position: %w", err)
	}
	_, err = tx.ExecContext(ctx, `
		INSERT INTO disciplinas (id, nome, dificuldade, cor, posicao)
		VALUES (?, ?, ?, ?, ?)`, subjectID, input.Name, input.Difficulty, input.Color, lastPosition+1)
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

func (r *StudyRepository) ReorderSubjects(ctx context.Context, subjectIDs []string) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin reorder subjects transaction: %w", err)
	}
	defer tx.Rollback()

	rows, err := tx.QueryContext(ctx, `
		SELECT id
		FROM disciplinas
		ORDER BY posicao, criado_em, id
		FOR UPDATE`)
	if err != nil {
		return fmt.Errorf("lock subjects for reorder: %w", err)
	}
	currentIDs := make(map[string]struct{})
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return fmt.Errorf("scan subject for reorder: %w", err)
		}
		currentIDs[id] = struct{}{}
	}
	if err := rows.Close(); err != nil {
		return fmt.Errorf("close reordered subjects: %w", err)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate subjects for reorder: %w", err)
	}
	if len(currentIDs) != len(subjectIDs) {
		return domain.ErrInvalidSubjectOrder
	}
	for _, id := range subjectIDs {
		if _, exists := currentIDs[id]; !exists {
			return domain.ErrInvalidSubjectOrder
		}
	}
	for index, id := range subjectIDs {
		if _, err := tx.ExecContext(
			ctx,
			"UPDATE disciplinas SET posicao = ? WHERE id = ?",
			index+1,
			id,
		); err != nil {
			return fmt.Errorf("update subject position: %w", err)
		}
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit reorder subjects transaction: %w", err)
	}
	return nil
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

func (r *StudyRepository) ReplaceTopics(
	ctx context.Context,
	subjectID string,
	topics []domain.ReplaceTopicInput,
) error {
	resolved := make([]domain.ReplaceTopicInput, len(topics))
	copy(resolved, topics)
	for index := range resolved {
		if resolved[index].ID != "" {
			continue
		}
		id, err := newUUID()
		if err != nil {
			return err
		}
		resolved[index].ID = id
	}

	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin replace topics transaction: %w", err)
	}
	defer tx.Rollback()

	var lockedSubjectID string
	if err := tx.QueryRowContext(
		ctx,
		"SELECT id FROM disciplinas WHERE id = ? FOR UPDATE",
		subjectID,
	).Scan(&lockedSubjectID); err != nil {
		return fmt.Errorf("lock subject for topic replacement: %w", err)
	}

	rows, err := tx.QueryContext(ctx, `
		SELECT id
		FROM topicos
		WHERE disciplina_id = ? AND BINARY nome <> BINARY ?
		ORDER BY posicao, criado_em
		FOR UPDATE`, subjectID, domain.MandatoryReviewTopicName)
	if err != nil {
		return fmt.Errorf("lock topics for replacement: %w", err)
	}
	currentIDs := make(map[string]struct{})
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return fmt.Errorf("scan topic for replacement: %w", err)
		}
		currentIDs[id] = struct{}{}
	}
	if err := rows.Close(); err != nil {
		return fmt.Errorf("close topics for replacement: %w", err)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate topics for replacement: %w", err)
	}

	retainedIDs := make(map[string]struct{}, len(resolved))
	for index, topic := range resolved {
		if _, exists := currentIDs[topic.ID]; exists {
			retainedIDs[topic.ID] = struct{}{}
			continue
		}
		if topics[index].ID != "" {
			return domain.ErrInvalidTopicOrder
		}
	}

	removedIDs := make([]string, 0)
	for id := range currentIDs {
		if _, retained := retainedIDs[id]; !retained {
			removedIDs = append(removedIDs, id)
		}
	}
	for _, id := range removedIDs {
		var hasProgress bool
		if err := tx.QueryRowContext(ctx, `
			SELECT EXISTS(
				SELECT 1
				FROM concursos_topicos
				WHERE topico_id = ?
					AND (
						teoria_concluida = 1 OR memoria_concluida = 1 OR conferencia_concluida = 1
						OR acertos > 0 OR erros > 0 OR concluido_em IS NOT NULL
					)
			)`, id).Scan(&hasProgress); err != nil {
			return fmt.Errorf("check replaced topic study progress: %w", err)
		}
		if hasProgress {
			return domain.ErrContentLinked
		}
		if _, err := tx.ExecContext(ctx, "DELETE FROM concursos_topicos WHERE topico_id = ?", id); err != nil {
			return fmt.Errorf("unlink replaced topic from editais: %w", err)
		}
		if _, err := tx.ExecContext(ctx, "DELETE FROM topicos WHERE id = ?", id); err != nil {
			return fmt.Errorf("delete replaced topic: %w", err)
		}
	}

	for index, topic := range resolved {
		position := index + 1
		if _, exists := currentIDs[topic.ID]; exists {
			if _, err := tx.ExecContext(
				ctx,
				"UPDATE topicos SET nome = ?, posicao = ? WHERE id = ? AND disciplina_id = ?",
				topic.Name,
				position,
				topic.ID,
				subjectID,
			); err != nil {
				return fmt.Errorf("update replaced topic: %w", err)
			}
			continue
		}
		if _, err := tx.ExecContext(
			ctx,
			"INSERT INTO topicos (id, disciplina_id, nome, posicao) VALUES (?, ?, ?, ?)",
			topic.ID,
			subjectID,
			topic.Name,
			position,
		); err != nil {
			return fmt.Errorf("insert replaced topic: %w", err)
		}
	}
	if _, err := tx.ExecContext(
		ctx,
		"UPDATE topicos SET posicao = ? WHERE disciplina_id = ? AND BINARY nome = BINARY ?",
		len(resolved)+1,
		subjectID,
		domain.MandatoryReviewTopicName,
	); err != nil {
		return fmt.Errorf("position mandatory topic after replacement: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `
		DELETE relacao
		FROM concursos_disciplinas AS relacao
		WHERE relacao.disciplina_id = ?
			AND NOT EXISTS (
				SELECT 1
				FROM concursos_topicos AS vinculo
				INNER JOIN topicos AS topico ON topico.id = vinculo.topico_id
				WHERE vinculo.concurso_id = relacao.concurso_id
					AND vinculo.removido_em IS NULL
					AND topico.disciplina_id = relacao.disciplina_id
			)`, subjectID); err != nil {
		return fmt.Errorf("delete empty edital discipline metadata after replacement: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit replace topics transaction: %w", err)
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

func (r *StudyRepository) ReorderTopics(ctx context.Context, subjectID string, topicIDs []string) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin reorder topics transaction: %w", err)
	}
	defer tx.Rollback()

	rows, err := tx.QueryContext(ctx, `
		SELECT id
		FROM topicos
		WHERE disciplina_id = ? AND BINARY nome <> BINARY ?
		ORDER BY posicao, criado_em
		FOR UPDATE`, subjectID, domain.MandatoryReviewTopicName)
	if err != nil {
		return fmt.Errorf("lock topics for reorder: %w", err)
	}
	currentIDs := make(map[string]struct{})
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			rows.Close()
			return fmt.Errorf("scan topic for reorder: %w", err)
		}
		currentIDs[id] = struct{}{}
	}
	if err := rows.Close(); err != nil {
		return fmt.Errorf("close reordered topics: %w", err)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate topics for reorder: %w", err)
	}
	if len(currentIDs) != len(topicIDs) {
		return domain.ErrInvalidTopicOrder
	}
	for _, id := range topicIDs {
		if _, exists := currentIDs[id]; !exists {
			return domain.ErrInvalidTopicOrder
		}
	}
	for index, id := range topicIDs {
		if _, err := tx.ExecContext(
			ctx,
			"UPDATE topicos SET posicao = ? WHERE id = ? AND disciplina_id = ?",
			index+1,
			id,
			subjectID,
		); err != nil {
			return fmt.Errorf("update topic position: %w", err)
		}
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit reorder topics transaction: %w", err)
	}
	return nil
}

func (r *StudyRepository) DeleteTopic(ctx context.Context, id string) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin delete topic transaction: %w", err)
	}
	defer tx.Rollback()

	var topicName, subjectID string
	err = tx.QueryRowContext(ctx, "SELECT nome, disciplina_id FROM topicos WHERE id = ? FOR UPDATE", id).
		Scan(&topicName, &subjectID)
	if errors.Is(err, sql.ErrNoRows) {
		return nil
	}
	if err != nil {
		return fmt.Errorf("check mandatory topic: %w", err)
	}
	if topicName == domain.MandatoryReviewTopicName {
		return domain.ErrMandatoryTopic
	}
	var hasProgress bool
	if err := tx.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1
			FROM concursos_topicos
			WHERE topico_id = ?
				AND (
					teoria_concluida = 1 OR memoria_concluida = 1 OR conferencia_concluida = 1
					OR acertos > 0 OR erros > 0 OR concluido_em IS NOT NULL
				)
		)`, id).Scan(&hasProgress); err != nil {
		return fmt.Errorf("check topic study progress: %w", err)
	}
	if hasProgress {
		return domain.ErrContentLinked
	}
	if _, err := tx.ExecContext(ctx, "DELETE FROM concursos_topicos WHERE topico_id = ?", id); err != nil {
		return fmt.Errorf("unlink topic from editais: %w", err)
	}
	if _, err := tx.ExecContext(
		ctx,
		"DELETE FROM topicos WHERE id = ? AND BINARY nome <> BINARY ?",
		id,
		domain.MandatoryReviewTopicName,
	); err != nil {
		return fmt.Errorf("delete topic: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `
		DELETE relacao
		FROM concursos_disciplinas AS relacao
		WHERE relacao.disciplina_id = ?
			AND NOT EXISTS (
				SELECT 1
				FROM concursos_topicos AS vinculo
				INNER JOIN topicos AS topico ON topico.id = vinculo.topico_id
				WHERE vinculo.concurso_id = relacao.concurso_id
					AND vinculo.removido_em IS NULL
					AND topico.disciplina_id = relacao.disciplina_id
			)`, subjectID); err != nil {
		return fmt.Errorf("delete empty edital discipline metadata: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit delete topic transaction: %w", err)
	}
	return nil
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

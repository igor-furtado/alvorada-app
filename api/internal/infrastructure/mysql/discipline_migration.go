package mysqlrepo

import (
	"context"
	"database/sql"
	"fmt"

	domain "concursosapp/api/internal/domain/studies"
)

const (
	disciplineInvariantLock = "concursos_app_discipline_invariants"
	mandatoryTopicIndex     = "idx_topicos_revisao_vespera_unica"
)

// EnsureDisciplineInvariants repairs data created before mandatory review
// topics became part of the Discipline contract. It is serialized across app
// instances and remains safe to resume after an interrupted run.
func EnsureDisciplineInvariants(ctx context.Context, db *sql.DB) (resultErr error) {
	conn, err := db.Conn(ctx)
	if err != nil {
		return fmt.Errorf("open discipline migration connection: %w", err)
	}
	defer conn.Close()

	var acquired bool
	if err := conn.QueryRowContext(ctx, "SELECT GET_LOCK(?, 30)", disciplineInvariantLock).Scan(&acquired); err != nil {
		return fmt.Errorf("acquire discipline migration lock: %w", err)
	}
	if !acquired {
		return fmt.Errorf("acquire discipline migration lock: timed out")
	}
	defer func() {
		var released bool
		if err := conn.QueryRowContext(ctx, "SELECT RELEASE_LOCK(?)", disciplineInvariantLock).Scan(&released); err != nil && resultErr == nil {
			resultErr = fmt.Errorf("release discipline migration lock: %w", err)
		} else if !released && resultErr == nil {
			resultErr = fmt.Errorf("release discipline migration lock: lock was not owned")
		}
	}()

	tx, err := conn.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin discipline invariant repair: %w", err)
	}
	defer func() { _ = tx.Rollback() }()

	if _, err := tx.ExecContext(ctx, `
		DELETE subtopicos
		FROM subtopicos
		INNER JOIN topicos ON topicos.id = subtopicos.topico_id
		WHERE BINARY topicos.nome = BINARY ?`, domain.MandatoryReviewTopicName); err != nil {
		return fmt.Errorf("remove mandatory topic subtopics: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `
		DELETE duplicate
		FROM topicos AS duplicate
		INNER JOIN topicos AS canonical
			ON canonical.disciplina_id = duplicate.disciplina_id
			AND canonical.id < duplicate.id
		WHERE BINARY duplicate.nome = BINARY ?
			AND BINARY canonical.nome = BINARY ?`, domain.MandatoryReviewTopicName, domain.MandatoryReviewTopicName); err != nil {
		return fmt.Errorf("deduplicate mandatory topics: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO topicos (id, disciplina_id, nome)
		SELECT UUID(), disciplinas.id, ?
		FROM disciplinas
		WHERE NOT EXISTS (
			SELECT 1
			FROM topicos
			WHERE topicos.disciplina_id = disciplinas.id
				AND BINARY topicos.nome = BINARY ?
		)`, domain.MandatoryReviewTopicName, domain.MandatoryReviewTopicName); err != nil {
		return fmt.Errorf("backfill mandatory topics: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit discipline invariant repair: %w", err)
	}

	mandatoryColumnExists, err := columnExists(ctx, conn, "topicos", "obrigatorio")
	if err != nil {
		return err
	}
	if !mandatoryColumnExists {
		if _, err := conn.ExecContext(ctx, `
			ALTER TABLE topicos
			ADD COLUMN obrigatorio TINYINT
			GENERATED ALWAYS AS (
				IF(BINARY nome = BINARY 'Revisão de Véspera', 1, NULL)
			) STORED`); err != nil {
			return fmt.Errorf("add mandatory topic generated column: %w", err)
		}
	}

	mandatoryIndexExists, err := indexExists(ctx, conn, "topicos", mandatoryTopicIndex)
	if err != nil {
		return err
	}
	if !mandatoryIndexExists {
		if _, err := conn.ExecContext(ctx, `
			CREATE UNIQUE INDEX idx_topicos_revisao_vespera_unica
			ON topicos (disciplina_id, obrigatorio)`); err != nil {
			return fmt.Errorf("add mandatory topic unique index: %w", err)
		}
	}
	return nil
}

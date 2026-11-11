package mysqlrepo

import (
	"context"
	"database/sql"
	"fmt"

	domain "concursosapp/api/internal/domain/concursos"
)

type ConcursoRepository struct {
	db *sql.DB
}

func NewConcursoRepository(db *sql.DB) *ConcursoRepository {
	return &ConcursoRepository{db: db}
}

func (r *ConcursoRepository) FindActive(ctx context.Context) ([]domain.Concurso, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, instituicao, cargo, banca, data_prova, prioritario, progresso_edital
		FROM concursos
		WHERE arquivado_em IS NULL
		ORDER BY data_prova IS NULL, data_prova, criado_em, id`)
	if err != nil {
		return nil, fmt.Errorf("query concursos: %w", err)
	}
	defer rows.Close()

	result := make([]domain.Concurso, 0)
	for rows.Next() {
		var concurso domain.Concurso
		var banca sql.NullString
		var dataProva sql.NullTime
		if err := rows.Scan(
			&concurso.ID,
			&concurso.Instituicao,
			&concurso.Cargo,
			&banca,
			&dataProva,
			&concurso.Prioritario,
			&concurso.ProgressoEdital,
		); err != nil {
			return nil, fmt.Errorf("scan concurso: %w", err)
		}
		if banca.Valid {
			concurso.Banca = &banca.String
		}
		if dataProva.Valid {
			concurso.DataProva = &dataProva.Time
		}
		result = append(result, concurso)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate concursos: %w", err)
	}
	return result, nil
}

func (r *ConcursoRepository) Create(ctx context.Context, input domain.CreateConcursoInput) (string, error) {
	id, err := newUUID()
	if err != nil {
		return "", err
	}
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return "", fmt.Errorf("begin create concurso transaction: %w", err)
	}
	defer tx.Rollback()

	if input.Prioritario {
		if _, err := tx.ExecContext(ctx, `UPDATE concursos SET prioritario = 0 WHERE prioritario = 1`); err != nil {
			return "", fmt.Errorf("clear concurso prioritario: %w", err)
		}
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO concursos (id, instituicao, cargo, banca, data_prova, prioritario)
		VALUES (?, ?, ?, ?, ?, ?)`,
		id,
		input.Instituicao,
		input.Cargo,
		input.Banca,
		input.DataProva,
		input.Prioritario,
	); err != nil {
		return "", fmt.Errorf("insert concurso: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return "", fmt.Errorf("commit create concurso transaction: %w", err)
	}
	return id, nil
}

func (r *ConcursoRepository) SetPrioritario(ctx context.Context, id string) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin set concurso prioritario transaction: %w", err)
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, `UPDATE concursos SET prioritario = 0 WHERE prioritario = 1`); err != nil {
		return fmt.Errorf("clear concurso prioritario: %w", err)
	}
	result, err := tx.ExecContext(
		ctx,
		`UPDATE concursos SET prioritario = 1 WHERE id = ? AND arquivado_em IS NULL`,
		id,
	)
	if err != nil {
		return fmt.Errorf("set concurso prioritario: %w", err)
	}
	if err := requireAffected(result); err != nil {
		return err
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit set concurso prioritario transaction: %w", err)
	}
	return nil
}

func (r *ConcursoRepository) Archive(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(
		ctx,
		`UPDATE concursos SET arquivado_em = CURRENT_TIMESTAMP, prioritario = 0 WHERE id = ? AND arquivado_em IS NULL`,
		id,
	)
	if err != nil {
		return fmt.Errorf("archive concurso: %w", err)
	}
	return requireAffected(result)
}

func (r *ConcursoRepository) Restore(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(
		ctx,
		`UPDATE concursos SET arquivado_em = NULL WHERE id = ? AND arquivado_em IS NOT NULL`,
		id,
	)
	if err != nil {
		return fmt.Errorf("restore concurso: %w", err)
	}
	return requireAffected(result)
}

func (r *ConcursoRepository) Delete(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `DELETE FROM concursos WHERE id = ?`, id)
	if err != nil {
		return fmt.Errorf("delete concurso: %w", err)
	}
	return requireAffected(result)
}

func requireAffected(result sql.Result) error {
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("read concurso rows affected: %w", err)
	}
	if affected == 0 {
		return domain.ErrConcursoNotFound
	}
	return nil
}

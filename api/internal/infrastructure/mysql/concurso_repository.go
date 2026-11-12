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
		SELECT id, instituicao, cargo, banca, data_prova, prioritario, progresso_edital,
			sigla, quantidade_vagas, vencimento_centavos, carga_horaria_semanal,
			local_prova, TIME_FORMAT(horario_inicio_prova, '%H:%i'),
			TIME_FORMAT(horario_fim_prova, '%H:%i'), requisitos, criterios_pontuacao
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
		var sigla, localProva, horarioInicio, horarioFim, requisitos, criterios sql.NullString
		var quantidadeVagas, vencimentoCentavos, cargaHoraria sql.NullInt64
		if err := rows.Scan(
			&concurso.ID,
			&concurso.Instituicao,
			&concurso.Cargo,
			&banca,
			&dataProva,
			&concurso.Prioritario,
			&concurso.ProgressoEdital,
			&sigla,
			&quantidadeVagas,
			&vencimentoCentavos,
			&cargaHoraria,
			&localProva,
			&horarioInicio,
			&horarioFim,
			&requisitos,
			&criterios,
		); err != nil {
			return nil, fmt.Errorf("scan concurso: %w", err)
		}
		if banca.Valid {
			concurso.Banca = &banca.String
		}
		if dataProva.Valid {
			concurso.DataProva = &dataProva.Time
		}
		if sigla.Valid {
			concurso.Sigla = &sigla.String
		}
		if quantidadeVagas.Valid {
			value := int(quantidadeVagas.Int64)
			concurso.QuantidadeVagas = &value
		}
		if vencimentoCentavos.Valid {
			concurso.VencimentoCentavos = &vencimentoCentavos.Int64
		}
		if cargaHoraria.Valid {
			value := int(cargaHoraria.Int64)
			concurso.CargaHorariaSemanal = &value
		}
		if localProva.Valid {
			concurso.LocalProva = &localProva.String
		}
		if horarioInicio.Valid {
			concurso.HorarioInicioProva = &horarioInicio.String
		}
		if horarioFim.Valid {
			concurso.HorarioFimProva = &horarioFim.String
		}
		if requisitos.Valid {
			concurso.Requisitos = &requisitos.String
		}
		if criterios.Valid {
			concurso.CriteriosPontuacao = &criterios.String
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
		INSERT INTO concursos (
			id, instituicao, cargo, banca, data_prova, prioritario, sigla,
			quantidade_vagas, vencimento_centavos, carga_horaria_semanal,
			local_prova, horario_inicio_prova, horario_fim_prova, requisitos, criterios_pontuacao
		)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		id,
		input.Instituicao,
		input.Cargo,
		input.Banca,
		input.DataProva,
		input.Prioritario,
		input.Sigla,
		input.QuantidadeVagas,
		input.VencimentoCentavos,
		input.CargaHorariaSemanal,
		input.LocalProva,
		input.HorarioInicioProva,
		input.HorarioFimProva,
		input.Requisitos,
		input.CriteriosPontuacao,
	); err != nil {
		return "", fmt.Errorf("insert concurso: %w", err)
	}
	if err := tx.Commit(); err != nil {
		return "", fmt.Errorf("commit create concurso transaction: %w", err)
	}
	return id, nil
}

func (r *ConcursoRepository) Update(ctx context.Context, id string, input domain.UpdateConcursoInput) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin update concurso transaction: %w", err)
	}
	defer tx.Rollback()

	if input.Prioritario {
		if _, err := tx.ExecContext(ctx, `UPDATE concursos SET prioritario = 0 WHERE prioritario = 1`); err != nil {
			return fmt.Errorf("clear concurso prioritario: %w", err)
		}
	}
	result, err := tx.ExecContext(ctx, `
		UPDATE concursos
		SET instituicao = ?, cargo = ?, banca = ?, data_prova = ?, prioritario = ?,
			sigla = ?, quantidade_vagas = ?, vencimento_centavos = ?, carga_horaria_semanal = ?,
			local_prova = ?, horario_inicio_prova = ?, horario_fim_prova = ?,
			requisitos = ?, criterios_pontuacao = ?
		WHERE id = ? AND arquivado_em IS NULL`,
		input.Instituicao,
		input.Cargo,
		input.Banca,
		input.DataProva,
		input.Prioritario,
		input.Sigla,
		input.QuantidadeVagas,
		input.VencimentoCentavos,
		input.CargaHorariaSemanal,
		input.LocalProva,
		input.HorarioInicioProva,
		input.HorarioFimProva,
		input.Requisitos,
		input.CriteriosPontuacao,
		id,
	)
	if err != nil {
		return fmt.Errorf("update concurso: %w", err)
	}
	if err := requireUpdatedOrExisting(ctx, tx, result, id); err != nil {
		return err
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit update concurso transaction: %w", err)
	}
	return nil
}

func requireUpdatedOrExisting(ctx context.Context, tx *sql.Tx, result sql.Result, id string) error {
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("read concurso update rows affected: %w", err)
	}
	if affected > 0 {
		return nil
	}
	var exists bool
	if err := tx.QueryRowContext(
		ctx,
		`SELECT EXISTS(SELECT 1 FROM concursos WHERE id = ? AND arquivado_em IS NULL)`,
		id,
	).Scan(&exists); err != nil {
		return fmt.Errorf("check concurso after update: %w", err)
	}
	if !exists {
		return domain.ErrConcursoNotFound
	}
	return nil
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

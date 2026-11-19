package mysqlrepo

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sort"
	"time"

	domain "concursosapp/api/internal/domain/semana"
)

type SemanaRepository struct {
	db *sql.DB
}

func NewSemanaRepository(db *sql.DB) *SemanaRepository {
	return &SemanaRepository{db: db}
}

func (r *SemanaRepository) FindPlanejamento(
	ctx context.Context,
	inicio, fim time.Time,
) (domain.Planejamento, error) {
	plano := domain.Planejamento{
		Inicio: inicio, Fim: fim,
		Itens: make([]domain.Item, 0), Disponiveis: make([]domain.TopicoDisponivel, 0),
	}
	if err := r.queryEstudosIniciais(ctx, &plano, inicio, fim); err != nil {
		return domain.Planejamento{}, err
	}
	if err := r.queryRevisoes(ctx, &plano, inicio, fim); err != nil {
		return domain.Planejamento{}, err
	}
	if err := r.queryDisponiveis(ctx, &plano); err != nil {
		return domain.Planejamento{}, err
	}
	sort.SliceStable(plano.Itens, func(i, j int) bool {
		if !plano.Itens[i].DataPlanejada.Equal(plano.Itens[j].DataPlanejada) {
			return plano.Itens[i].DataPlanejada.Before(plano.Itens[j].DataPlanejada)
		}
		if plano.Itens[i].PosicaoDia != plano.Itens[j].PosicaoDia {
			return plano.Itens[i].PosicaoDia < plano.Itens[j].PosicaoDia
		}
		return plano.Itens[i].ID < plano.Itens[j].ID
	})
	return plano, nil
}

func (r *SemanaRepository) queryEstudosIniciais(
	ctx context.Context,
	plano *domain.Planejamento,
	inicio, fim time.Time,
) error {
	rows, err := r.db.QueryContext(ctx, `
		SELECT CONCAT('estudo:', vinculo.concurso_id, ':', vinculo.topico_id),
			vinculo.concurso_id, concurso.instituicao, concurso.sigla,
			vinculo.topico_id, topico.nome, disciplina.nome,
			vinculo.data_planejada, vinculo.posicao_dia,
			vinculo.teoria_concluida, vinculo.memoria_concluida, vinculo.conferencia_concluida,
			vinculo.acertos, vinculo.erros, vinculo.versao_metodologia, vinculo.concluido
		FROM concursos_topicos AS vinculo
		INNER JOIN concursos AS concurso ON concurso.id = vinculo.concurso_id
		INNER JOIN topicos AS topico ON topico.id = vinculo.topico_id
		INNER JOIN disciplinas AS disciplina ON disciplina.id = topico.disciplina_id
		WHERE vinculo.removido_em IS NULL
			AND concurso.arquivado_em IS NULL
			AND vinculo.data_planejada BETWEEN ? AND ?
		ORDER BY vinculo.data_planejada, vinculo.posicao_dia, vinculo.criado_em, vinculo.topico_id`, inicio, fim)
	if err != nil {
		return fmt.Errorf("query weekly initial studies: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var item domain.Item
		var sigla sql.NullString
		var versao sql.NullInt64
		if err := rows.Scan(
			&item.ID, &item.ConcursoID, &item.ConcursoNome, &sigla,
			&item.TopicoID, &item.TopicoNome, &item.DisciplinaNome,
			&item.DataPlanejada, &item.PosicaoDia,
			&item.TeoriaConcluida, &item.MemoriaConcluida, &item.ConferenciaConcluida,
			&item.Acertos, &item.Erros, &versao, &item.Concluido,
		); err != nil {
			return fmt.Errorf("scan weekly initial study: %w", err)
		}
		item.Tipo = domain.TipoEstudoInicial
		assignOptionalStudyValues(&item, sigla, versao)
		plano.Itens = append(plano.Itens, item)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate weekly initial studies: %w", err)
	}
	return nil
}

func (r *SemanaRepository) queryRevisoes(
	ctx context.Context,
	plano *domain.Planejamento,
	inicio, fim time.Time,
) error {
	rows, err := r.db.QueryContext(ctx, `
		SELECT revisao.id, revisao.concurso_id, concurso.instituicao, concurso.sigla,
			revisao.topico_id, topico.nome, disciplina.nome,
			revisao.data_planejada, revisao.posicao_dia,
			vinculo.teoria_concluida, vinculo.memoria_concluida, vinculo.conferencia_concluida,
			vinculo.acertos, vinculo.erros, vinculo.versao_metodologia,
			revisao.concluida_em IS NOT NULL, revisao.intervalo_dias
		FROM revisoes_programadas AS revisao
		INNER JOIN concursos_topicos AS vinculo
			ON vinculo.concurso_id = revisao.concurso_id AND vinculo.topico_id = revisao.topico_id
		INNER JOIN concursos AS concurso ON concurso.id = revisao.concurso_id
		INNER JOIN topicos AS topico ON topico.id = revisao.topico_id
		INNER JOIN disciplinas AS disciplina ON disciplina.id = topico.disciplina_id
		WHERE revisao.cancelada_em IS NULL
			AND vinculo.removido_em IS NULL
			AND concurso.arquivado_em IS NULL
			AND revisao.data_planejada BETWEEN ? AND ?
		ORDER BY revisao.data_planejada, revisao.posicao_dia, revisao.criado_em, revisao.id`, inicio, fim)
	if err != nil {
		return fmt.Errorf("query weekly reviews: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var item domain.Item
		var sigla sql.NullString
		var versao sql.NullInt64
		var intervalo uint8
		if err := rows.Scan(
			&item.ID, &item.ConcursoID, &item.ConcursoNome, &sigla,
			&item.TopicoID, &item.TopicoNome, &item.DisciplinaNome,
			&item.DataPlanejada, &item.PosicaoDia,
			&item.TeoriaConcluida, &item.MemoriaConcluida, &item.ConferenciaConcluida,
			&item.Acertos, &item.Erros, &versao, &item.Concluido, &intervalo,
		); err != nil {
			return fmt.Errorf("scan weekly review: %w", err)
		}
		item.Tipo = domain.TipoRevisao
		item.IntervaloRevisaoDias = &intervalo
		assignOptionalStudyValues(&item, sigla, versao)
		plano.Itens = append(plano.Itens, item)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate weekly reviews: %w", err)
	}
	return nil
}

func assignOptionalStudyValues(item *domain.Item, sigla sql.NullString, versao sql.NullInt64) {
	if sigla.Valid {
		item.ConcursoSigla = &sigla.String
	}
	if versao.Valid {
		value := uint16(versao.Int64)
		item.VersaoMetodologia = &value
	}
}

func (r *SemanaRepository) queryDisponiveis(ctx context.Context, plano *domain.Planejamento) error {
	rows, err := r.db.QueryContext(ctx, `
		SELECT vinculo.concurso_id, concurso.instituicao, concurso.sigla,
			vinculo.topico_id, topico.nome, disciplina.nome
		FROM concursos_topicos AS vinculo
		INNER JOIN concursos AS concurso ON concurso.id = vinculo.concurso_id
		INNER JOIN topicos AS topico ON topico.id = vinculo.topico_id
		INNER JOIN disciplinas AS disciplina ON disciplina.id = topico.disciplina_id
		LEFT JOIN concursos_disciplinas AS relacao
			ON relacao.concurso_id = vinculo.concurso_id AND relacao.disciplina_id = disciplina.id
		WHERE vinculo.removido_em IS NULL
			AND concurso.arquivado_em IS NULL
			AND vinculo.data_planejada IS NULL
			AND vinculo.concluido = 0
		ORDER BY concurso.prioritario DESC, concurso.data_prova IS NULL, concurso.data_prova,
			relacao.peso IS NULL, relacao.peso DESC,
			disciplina.posicao, topico.posicao, topico.criado_em, topico.id`)
	if err != nil {
		return fmt.Errorf("query available weekly topics: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var item domain.TopicoDisponivel
		var sigla sql.NullString
		if err := rows.Scan(
			&item.ConcursoID, &item.ConcursoNome, &sigla,
			&item.TopicoID, &item.TopicoNome, &item.DisciplinaNome,
		); err != nil {
			return fmt.Errorf("scan available weekly topic: %w", err)
		}
		if sigla.Valid {
			item.ConcursoSigla = &sigla.String
		}
		plano.Disponiveis = append(plano.Disponiveis, item)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("iterate available weekly topics: %w", err)
	}
	return nil
}

func (r *SemanaRepository) PlanejarTopico(
	ctx context.Context,
	concursoID, topicoID string,
	data time.Time,
	posicao uint,
) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE concursos_topicos
		SET data_planejada = ?, posicao_dia = ?
		WHERE concurso_id = ? AND topico_id = ? AND removido_em IS NULL`,
		data, posicao, concursoID, topicoID)
	if err != nil {
		return fmt.Errorf("schedule weekly topic: %w", err)
	}
	return requireSemanaAffected(result, domain.ErrTopicoNaoEncontrado)
}

func (r *SemanaRepository) AtualizarProgresso(
	ctx context.Context,
	concursoID, topicoID string,
	input domain.ProgressoInput,
	versao uint16,
) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE concursos_topicos
		SET teoria_concluida = COALESCE(?, teoria_concluida),
			memoria_concluida = COALESCE(?, memoria_concluida),
			conferencia_concluida = COALESCE(?, conferencia_concluida),
			versao_metodologia = COALESCE(versao_metodologia, ?),
			concluido_em = CASE
				WHEN COALESCE(?, teoria_concluida) = 1
					AND COALESCE(?, memoria_concluida) = 1
					AND COALESCE(?, conferencia_concluida) = 1
				THEN COALESCE(concluido_em, CURRENT_TIMESTAMP)
				ELSE NULL
			END
		WHERE concurso_id = ? AND topico_id = ? AND removido_em IS NULL`,
		input.TeoriaConcluida, input.MemoriaConcluida, input.ConferenciaConcluida, versao,
		input.TeoriaConcluida, input.MemoriaConcluida, input.ConferenciaConcluida,
		concursoID, topicoID)
	if err != nil {
		return fmt.Errorf("update topic study progress: %w", err)
	}
	return requireSemanaAffected(result, domain.ErrTopicoNaoEncontrado)
}

func (r *SemanaRepository) RegistrarQuestao(
	ctx context.Context,
	concursoID, topicoID string,
	resultado domain.ResultadoQuestao,
	versao uint16,
) error {
	column := "acertos"
	if resultado == domain.QuestaoErrada {
		column = "erros"
	}
	query := fmt.Sprintf(`
		UPDATE concursos_topicos
		SET %s = %s + 1, versao_metodologia = COALESCE(versao_metodologia, ?)
		WHERE concurso_id = ? AND topico_id = ? AND removido_em IS NULL`, column, column)
	result, err := r.db.ExecContext(ctx, query, versao, concursoID, topicoID)
	if err != nil {
		return fmt.Errorf("register topic question result: %w", err)
	}
	return requireSemanaAffected(result, domain.ErrTopicoNaoEncontrado)
}

func (r *SemanaRepository) SubstituirRevisoes(
	ctx context.Context,
	concursoID, topicoID string,
	intervalos []uint8,
) error {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin replace topic reviews transaction: %w", err)
	}
	defer tx.Rollback()
	var concluidoEm sql.NullTime
	if err := tx.QueryRowContext(ctx, `
		SELECT concluido_em
		FROM concursos_topicos
		WHERE concurso_id = ? AND topico_id = ? AND removido_em IS NULL
		FOR UPDATE`, concursoID, topicoID).Scan(&concluidoEm); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return domain.ErrTopicoNaoEncontrado
		}
		return fmt.Errorf("lock topic before reviews: %w", err)
	}
	if !concluidoEm.Valid {
		return domain.ErrTopicoNaoConcluido
	}
	if _, err := tx.ExecContext(ctx, `
		UPDATE revisoes_programadas
		SET cancelada_em = CURRENT_TIMESTAMP
		WHERE concurso_id = ? AND topico_id = ?
			AND concluida_em IS NULL AND cancelada_em IS NULL`, concursoID, topicoID); err != nil {
		return fmt.Errorf("cancel previous topic reviews: %w", err)
	}
	for _, intervalo := range intervalos {
		id, err := newUUID()
		if err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO revisoes_programadas (
				id, concurso_id, topico_id, intervalo_dias, data_planejada
			) VALUES (?, ?, ?, ?, DATE(?) + INTERVAL ? DAY)
			ON DUPLICATE KEY UPDATE
				data_planejada = VALUES(data_planejada), cancelada_em = NULL`,
			id, concursoID, topicoID, intervalo, concluidoEm.Time, intervalo); err != nil {
			return fmt.Errorf("schedule topic review D+%d: %w", intervalo, err)
		}
	}
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit replace topic reviews transaction: %w", err)
	}
	return nil
}

func (r *SemanaRepository) MoverRevisao(
	ctx context.Context,
	revisaoID string,
	data time.Time,
	posicao uint,
) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE revisoes_programadas
		SET data_planejada = ?, posicao_dia = ?
		WHERE id = ? AND cancelada_em IS NULL`, data, posicao, revisaoID)
	if err != nil {
		return fmt.Errorf("move scheduled review: %w", err)
	}
	return requireSemanaAffected(result, domain.ErrRevisaoNaoEncontrada)
}

func (r *SemanaRepository) ConcluirRevisao(ctx context.Context, revisaoID string) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE revisoes_programadas
		SET concluida_em = COALESCE(concluida_em, CURRENT_TIMESTAMP)
		WHERE id = ? AND cancelada_em IS NULL`, revisaoID)
	if err != nil {
		return fmt.Errorf("complete scheduled review: %w", err)
	}
	return requireSemanaAffected(result, domain.ErrRevisaoNaoEncontrada)
}

func requireSemanaAffected(result sql.Result, notFound error) error {
	affected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("read weekly operation rows affected: %w", err)
	}
	if affected == 0 {
		return notFound
	}
	return nil
}

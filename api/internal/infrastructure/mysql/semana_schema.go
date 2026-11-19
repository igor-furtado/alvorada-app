package mysqlrepo

import (
	"context"
	"database/sql"
	"fmt"
)

const revisoesProgramadasSchema = `
CREATE TABLE IF NOT EXISTS revisoes_programadas (
  id CHAR(36) PRIMARY KEY,
  concurso_id CHAR(36) NOT NULL,
  topico_id CHAR(36) NOT NULL,
  intervalo_dias TINYINT UNSIGNED NOT NULL,
  data_planejada DATE NOT NULL,
  posicao_dia INT UNSIGNED NOT NULL DEFAULT 0,
  concluida_em TIMESTAMP NULL,
  cancelada_em TIMESTAMP NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_revisao_concurso_topico FOREIGN KEY (concurso_id, topico_id)
    REFERENCES concursos_topicos(concurso_id, topico_id) ON DELETE CASCADE,
  CONSTRAINT chk_revisao_intervalo CHECK (intervalo_dias IN (1, 7, 30)),
  UNIQUE INDEX idx_revisoes_intervalo_unico (concurso_id, topico_id, intervalo_dias),
  INDEX idx_revisoes_semana (data_planejada, cancelada_em, posicao_dia, id)
) ENGINE=InnoDB`

// EnsureSemanaSchema promotes the Concurso–Tópico link to the source of truth
// for study progress and creates the optional review schedule. Every operation
// is idempotent so interrupted starts can safely resume.
func EnsureSemanaSchema(ctx context.Context, db *sql.DB) error {
	columns := []struct {
		name       string
		definition string
	}{
		{"teoria_concluida", "teoria_concluida TINYINT(1) NOT NULL DEFAULT 0"},
		{"memoria_concluida", "memoria_concluida TINYINT(1) NOT NULL DEFAULT 0"},
		{"conferencia_concluida", "conferencia_concluida TINYINT(1) NOT NULL DEFAULT 0"},
		{"acertos", "acertos INT UNSIGNED NOT NULL DEFAULT 0"},
		{"erros", "erros INT UNSIGNED NOT NULL DEFAULT 0"},
		{"versao_metodologia", "versao_metodologia SMALLINT UNSIGNED NULL"},
		{"concluido", `concluido TINYINT(1) GENERATED ALWAYS AS (
			IF(teoria_concluida = 1 AND memoria_concluida = 1 AND conferencia_concluida = 1, 1, 0)
		) STORED`},
		{"concluido_em", "concluido_em TIMESTAMP NULL"},
		{"data_planejada", "data_planejada DATE NULL"},
		{"posicao_dia", "posicao_dia INT UNSIGNED NOT NULL DEFAULT 0"},
		{"removido_em", "removido_em TIMESTAMP NULL"},
		{"atualizado_em", "atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"},
	}
	for _, column := range columns {
		exists, err := columnExists(ctx, db, "concursos_topicos", column.name)
		if err != nil {
			return err
		}
		if exists {
			continue
		}
		if _, err := db.ExecContext(ctx, "ALTER TABLE concursos_topicos ADD COLUMN "+column.definition); err != nil {
			return fmt.Errorf("add concursos_topicos column %s: %w", column.name, err)
		}
	}
	constraints := []struct {
		name       string
		definition string
	}{
		{"chk_concurso_topico_teoria", "CHECK (teoria_concluida IN (0, 1))"},
		{"chk_concurso_topico_memoria", "CHECK (memoria_concluida IN (0, 1))"},
		{"chk_concurso_topico_conferencia", "CHECK (conferencia_concluida IN (0, 1))"},
		{"chk_concurso_topico_metodologia", "CHECK (versao_metodologia IS NULL OR versao_metodologia > 0)"},
	}
	for _, constraint := range constraints {
		exists, err := constraintExists(ctx, db, "concursos_topicos", constraint.name)
		if err != nil {
			return err
		}
		if exists {
			continue
		}
		query := fmt.Sprintf(
			"ALTER TABLE concursos_topicos ADD CONSTRAINT %s %s",
			constraint.name,
			constraint.definition,
		)
		if _, err := db.ExecContext(ctx, query); err != nil {
			return fmt.Errorf("add concursos_topicos constraint %s: %w", constraint.name, err)
		}
	}
	indexes := []struct {
		name       string
		definition string
	}{
		{"idx_concursos_topicos_semana", "(data_planejada, removido_em, posicao_dia, concurso_id, topico_id)"},
		{"idx_concursos_topicos_progresso", "(concurso_id, removido_em, concluido, topico_id)"},
	}
	for _, index := range indexes {
		exists, err := indexExists(ctx, db, "concursos_topicos", index.name)
		if err != nil {
			return err
		}
		if exists {
			continue
		}
		if _, err := db.ExecContext(ctx, "CREATE INDEX "+index.name+" ON concursos_topicos "+index.definition); err != nil {
			return fmt.Errorf("add concursos_topicos index %s: %w", index.name, err)
		}
	}
	if _, err := db.ExecContext(ctx, revisoesProgramadasSchema); err != nil {
		return fmt.Errorf("ensure revisoes_programadas schema: %w", err)
	}
	return nil
}

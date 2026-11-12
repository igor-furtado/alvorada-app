package mysqlrepo

import (
	"context"
	"database/sql"
	"fmt"
)

const concursoSchema = `
CREATE TABLE IF NOT EXISTS concursos (
  id CHAR(36) PRIMARY KEY,
  instituicao VARCHAR(160) NOT NULL,
  cargo VARCHAR(160) NOT NULL,
  banca VARCHAR(120) NULL,
  data_prova DATE NULL,
  sigla VARCHAR(24) NULL,
  quantidade_vagas INT UNSIGNED NULL,
  vencimento_centavos BIGINT UNSIGNED NULL,
  carga_horaria_semanal SMALLINT UNSIGNED NULL,
  local_prova VARCHAR(240) NULL,
  horario_inicio_prova TIME NULL,
  horario_fim_prova TIME NULL,
  requisitos TEXT NULL,
  criterios_pontuacao TEXT NULL,
  prioritario TINYINT(1) NOT NULL DEFAULT 0,
  arquivado_em TIMESTAMP NULL,
  prioridade_ativa TINYINT GENERATED ALWAYS AS (
    IF(prioritario = 1 AND arquivado_em IS NULL, 1, NULL)
  ) STORED,
  progresso_edital TINYINT UNSIGNED NOT NULL DEFAULT 0,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_concurso_progresso_edital CHECK (progresso_edital BETWEEN 0 AND 100),
  CONSTRAINT chk_concurso_carga_horaria CHECK (
    carga_horaria_semanal IS NULL OR carga_horaria_semanal BETWEEN 1 AND 168
  ),
  CONSTRAINT chk_concurso_quantidade_vagas CHECK (
    quantidade_vagas IS NULL OR quantidade_vagas <= 1000000
  ),
  CONSTRAINT chk_concurso_textos_longos CHECK (
    (requisitos IS NULL OR CHAR_LENGTH(requisitos) <= 10000)
    AND (criterios_pontuacao IS NULL OR CHAR_LENGTH(criterios_pontuacao) <= 10000)
  ),
  CONSTRAINT chk_concurso_horarios_prova CHECK (
    (horario_inicio_prova IS NULL AND horario_fim_prova IS NULL)
    OR (horario_inicio_prova IS NOT NULL AND horario_fim_prova IS NOT NULL
      AND horario_fim_prova > horario_inicio_prova)
  ),
  INDEX idx_concursos_ativos_prova (arquivado_em, data_prova, criado_em),
  UNIQUE INDEX idx_concursos_prioridade_unica (prioridade_ativa)
) ENGINE=InnoDB`

// EnsureConcursoSchema creates the new aggregate storage without changing
// existing rows. CREATE TABLE IF NOT EXISTS makes interrupted runs resumable.
func EnsureConcursoSchema(ctx context.Context, db *sql.DB) error {
	if _, err := db.ExecContext(ctx, concursoSchema); err != nil {
		return fmt.Errorf("ensure concursos schema: %w", err)
	}
	columns := []struct {
		name       string
		definition string
	}{
		{"sigla", "sigla VARCHAR(24) NULL"},
		{"quantidade_vagas", "quantidade_vagas INT UNSIGNED NULL"},
		{"vencimento_centavos", "vencimento_centavos BIGINT UNSIGNED NULL"},
		{"carga_horaria_semanal", "carga_horaria_semanal SMALLINT UNSIGNED NULL"},
		{"local_prova", "local_prova VARCHAR(240) NULL"},
		{"horario_inicio_prova", "horario_inicio_prova TIME NULL"},
		{"horario_fim_prova", "horario_fim_prova TIME NULL"},
		{"requisitos", "requisitos TEXT NULL"},
		{"criterios_pontuacao", "criterios_pontuacao TEXT NULL"},
	}
	for _, column := range columns {
		exists, err := columnExists(ctx, db, "concursos", column.name)
		if err != nil {
			return err
		}
		if !exists {
			if _, err := db.ExecContext(ctx, "ALTER TABLE concursos ADD COLUMN "+column.definition); err != nil {
				return fmt.Errorf("add concurso column %s: %w", column.name, err)
			}
		}
	}
	constraints := []struct {
		name       string
		definition string
	}{
		{
			"chk_concurso_carga_horaria",
			"CHECK (carga_horaria_semanal IS NULL OR carga_horaria_semanal BETWEEN 1 AND 168)",
		},
		{
			"chk_concurso_horarios_prova",
			"CHECK ((horario_inicio_prova IS NULL AND horario_fim_prova IS NULL) OR " +
				"(horario_inicio_prova IS NOT NULL AND horario_fim_prova IS NOT NULL AND horario_fim_prova > horario_inicio_prova))",
		},
		{
			"chk_concurso_quantidade_vagas",
			"CHECK (quantidade_vagas IS NULL OR quantidade_vagas <= 1000000)",
		},
		{
			"chk_concurso_textos_longos",
			"CHECK ((requisitos IS NULL OR CHAR_LENGTH(requisitos) <= 10000) AND " +
				"(criterios_pontuacao IS NULL OR CHAR_LENGTH(criterios_pontuacao) <= 10000))",
		},
	}
	for _, constraint := range constraints {
		exists, err := constraintExists(ctx, db, "concursos", constraint.name)
		if err != nil {
			return err
		}
		if !exists {
			query := fmt.Sprintf("ALTER TABLE concursos ADD CONSTRAINT %s %s", constraint.name, constraint.definition)
			if _, err := db.ExecContext(ctx, query); err != nil {
				return fmt.Errorf("add concurso constraint %s: %w", constraint.name, err)
			}
		}
	}
	return nil
}

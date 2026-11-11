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
  prioritario TINYINT(1) NOT NULL DEFAULT 0,
  arquivado_em TIMESTAMP NULL,
  prioridade_ativa TINYINT GENERATED ALWAYS AS (
    IF(prioritario = 1 AND arquivado_em IS NULL, 1, NULL)
  ) STORED,
  progresso_edital TINYINT UNSIGNED NOT NULL DEFAULT 0,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_concurso_progresso_edital CHECK (progresso_edital BETWEEN 0 AND 100),
  INDEX idx_concursos_ativos_prova (arquivado_em, data_prova, criado_em),
  UNIQUE INDEX idx_concursos_prioridade_unica (prioridade_ativa)
) ENGINE=InnoDB`

// EnsureConcursoSchema creates the new aggregate storage without changing
// existing rows. CREATE TABLE IF NOT EXISTS makes interrupted runs resumable.
func EnsureConcursoSchema(ctx context.Context, db *sql.DB) error {
	if _, err := db.ExecContext(ctx, concursoSchema); err != nil {
		return fmt.Errorf("ensure concursos schema: %w", err)
	}
	return nil
}

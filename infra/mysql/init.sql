CREATE DATABASE IF NOT EXISTS estudos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE estudos;

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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS disciplinas (
  id CHAR(36) PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  dificuldade TINYINT UNSIGNED NOT NULL DEFAULT 3,
  cor CHAR(7) NOT NULL DEFAULT '#E8742A',
  posicao INT UNSIGNED NOT NULL DEFAULT 0,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_disciplina_dificuldade CHECK (dificuldade BETWEEN 1 AND 5),
  INDEX idx_disciplina_posicao (posicao, criado_em)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS topicos (
  id CHAR(36) PRIMARY KEY,
  disciplina_id CHAR(36) NOT NULL,
  nome VARCHAR(120) NOT NULL,
  posicao INT UNSIGNED NOT NULL DEFAULT 0,
  obrigatorio TINYINT GENERATED ALWAYS AS (
    IF(BINARY nome = BINARY 'Revisão de Véspera', 1, NULL)
  ) STORED,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_topico_disciplina FOREIGN KEY (disciplina_id)
    REFERENCES disciplinas(id) ON DELETE CASCADE,
  INDEX idx_topico_disciplina_posicao (disciplina_id, posicao, criado_em),
  UNIQUE INDEX idx_topicos_revisao_vespera_unica (disciplina_id, obrigatorio)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subtopicos (
  id CHAR(36) PRIMARY KEY,
  topico_id CHAR(36) NOT NULL,
  nome VARCHAR(120) NOT NULL,
  posicao INT UNSIGNED NOT NULL DEFAULT 0,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_subtopico_topico FOREIGN KEY (topico_id)
    REFERENCES topicos(id) ON DELETE CASCADE,
  INDEX idx_subtopico_topico_posicao (topico_id, posicao, criado_em)
) ENGINE=InnoDB;

-- Mantém bancos locais criados antes da invariável de produto coerentes ao
-- reaplicar este esquema manualmente.
INSERT INTO topicos (id, disciplina_id, nome)
SELECT UUID(), disciplinas.id, 'Revisão de Véspera'
FROM disciplinas
WHERE NOT EXISTS (
  SELECT 1
  FROM topicos
  WHERE topicos.disciplina_id = disciplinas.id
    AND BINARY topicos.nome = BINARY 'Revisão de Véspera'
);

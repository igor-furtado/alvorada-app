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
  sigla VARCHAR(24) NULL,
  regime_contratacao VARCHAR(12) NULL,
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
  CONSTRAINT chk_concurso_regime_contratacao CHECK (
    regime_contratacao IS NULL OR regime_contratacao IN ('estatutario', 'celetista')
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

CREATE TABLE IF NOT EXISTS concursos_topicos (
  concurso_id CHAR(36) NOT NULL,
  topico_id CHAR(36) NOT NULL,
  teoria_concluida TINYINT(1) NOT NULL DEFAULT 0,
  memoria_concluida TINYINT(1) NOT NULL DEFAULT 0,
  conferencia_concluida TINYINT(1) NOT NULL DEFAULT 0,
  acertos INT UNSIGNED NOT NULL DEFAULT 0,
  erros INT UNSIGNED NOT NULL DEFAULT 0,
  versao_metodologia SMALLINT UNSIGNED NULL,
  concluido TINYINT(1) GENERATED ALWAYS AS (
    IF(teoria_concluida = 1 AND memoria_concluida = 1 AND conferencia_concluida = 1, 1, 0)
  ) STORED,
  concluido_em TIMESTAMP NULL,
  data_planejada DATE NULL,
  posicao_dia INT UNSIGNED NOT NULL DEFAULT 0,
  removido_em TIMESTAMP NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (concurso_id, topico_id),
  CONSTRAINT fk_concurso_topico_concurso FOREIGN KEY (concurso_id)
    REFERENCES concursos(id) ON DELETE CASCADE,
  CONSTRAINT fk_concurso_topico_topico FOREIGN KEY (topico_id)
    REFERENCES topicos(id) ON DELETE RESTRICT,
  CONSTRAINT chk_concurso_topico_teoria CHECK (teoria_concluida IN (0, 1)),
  CONSTRAINT chk_concurso_topico_memoria CHECK (memoria_concluida IN (0, 1)),
  CONSTRAINT chk_concurso_topico_conferencia CHECK (conferencia_concluida IN (0, 1)),
  CONSTRAINT chk_concurso_topico_metodologia CHECK (
    versao_metodologia IS NULL OR versao_metodologia > 0
  ),
  INDEX idx_concursos_topicos_topico (topico_id, concurso_id),
  INDEX idx_concursos_topicos_semana (
    data_planejada, removido_em, posicao_dia, concurso_id, topico_id
  ),
  INDEX idx_concursos_topicos_progresso (
    concurso_id, removido_em, concluido, topico_id
  )
) ENGINE=InnoDB;

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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS concursos_disciplinas (
  concurso_id CHAR(36) NOT NULL,
  disciplina_id CHAR(36) NOT NULL,
  peso DECIMAL(8,2) NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (concurso_id, disciplina_id),
  CONSTRAINT fk_concurso_disciplina_concurso FOREIGN KEY (concurso_id)
    REFERENCES concursos(id) ON DELETE CASCADE,
  CONSTRAINT fk_concurso_disciplina_disciplina FOREIGN KEY (disciplina_id)
    REFERENCES disciplinas(id) ON DELETE RESTRICT,
  CONSTRAINT chk_concurso_disciplina_peso CHECK (peso IS NULL OR peso > 0),
  INDEX idx_concursos_disciplinas_disciplina (disciplina_id, concurso_id)
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

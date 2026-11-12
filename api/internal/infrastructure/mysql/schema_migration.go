package mysqlrepo

import (
	"context"
	"database/sql"
	"fmt"
)

type schemaQueryer interface {
	QueryRowContext(context.Context, string, ...any) *sql.Row
}

type tableRename struct {
	from string
	to   string
}

type columnRename struct {
	table string
	from  string
	to    string
}

type constraintMigration struct {
	table      string
	from       string
	to         string
	dropClause string
	definition string
}

type indexRename struct {
	table string
	from  string
	to    string
}

var portugueseTables = []tableRename{
	{from: "subjects", to: "disciplinas"},
	{from: "topics", to: "topicos"},
}

var portugueseColumns = []columnRename{
	{table: "disciplinas", from: "name", to: "nome"},
	{table: "disciplinas", from: "difficulty", to: "dificuldade"},
	{table: "disciplinas", from: "color", to: "cor"},
	{table: "disciplinas", from: "position", to: "posicao"},
	{table: "disciplinas", from: "created_at", to: "criado_em"},
	{table: "disciplinas", from: "updated_at", to: "atualizado_em"},
	{table: "topicos", from: "subject_id", to: "disciplina_id"},
	{table: "topicos", from: "name", to: "nome"},
	{table: "topicos", from: "position", to: "posicao"},
	{table: "topicos", from: "created_at", to: "criado_em"},
	{table: "topicos", from: "updated_at", to: "atualizado_em"},
}

var portugueseConstraints = []constraintMigration{
	{
		table:      "disciplinas",
		from:       "chk_subject_difficulty",
		to:         "chk_disciplina_dificuldade",
		dropClause: "DROP CHECK",
		definition: "CHECK (`dificuldade` BETWEEN 1 AND 5)",
	},
	{
		table:      "topicos",
		from:       "fk_topic_subject",
		to:         "fk_topico_disciplina",
		dropClause: "DROP FOREIGN KEY",
		definition: "FOREIGN KEY (`disciplina_id`) REFERENCES `disciplinas` (`id`) ON DELETE CASCADE",
	},
}

var portugueseIndexes = []indexRename{
	{table: "disciplinas", from: "idx_subject_position", to: "idx_disciplina_posicao"},
	{table: "topicos", from: "idx_topic_subject_position", to: "idx_topico_disciplina_posicao"},
}

// RemoveSubtopicsSchema permanently removes the abandoned concept from both
// current and legacy local schemas. The operation is idempotent.
func RemoveSubtopicsSchema(ctx context.Context, db *sql.DB) error {
	if _, err := db.ExecContext(ctx, "DROP TABLE IF EXISTS subtopicos, subtopics"); err != nil {
		return fmt.Errorf("remove subtopics schema: %w", err)
	}
	return nil
}

// EnsurePortugueseSchema renames the legacy English database schema without
// discarding data. Each operation is idempotent so an interrupted run resumes.
func EnsurePortugueseSchema(ctx context.Context, db *sql.DB) error {
	for _, rename := range portugueseTables {
		if err := renameTableIfNeeded(ctx, db, rename); err != nil {
			return err
		}
	}
	for _, migration := range portugueseConstraints {
		if err := dropLegacyConstraintIfNeeded(ctx, db, migration); err != nil {
			return err
		}
	}
	for _, rename := range portugueseColumns {
		if err := renameColumnIfNeeded(ctx, db, rename); err != nil {
			return err
		}
	}
	for _, rename := range portugueseIndexes {
		if err := renameIndexIfNeeded(ctx, db, rename); err != nil {
			return err
		}
	}
	for _, migration := range portugueseConstraints {
		if err := ensureCurrentConstraint(ctx, db, migration); err != nil {
			return err
		}
	}
	return nil
}

func dropLegacyConstraintIfNeeded(ctx context.Context, db *sql.DB, migration constraintMigration) error {
	legacyExists, err := constraintExists(ctx, db, migration.table, migration.from)
	if err != nil {
		return err
	}
	if !legacyExists {
		return nil
	}
	currentExists, err := constraintExists(ctx, db, migration.table, migration.to)
	if err != nil {
		return err
	}
	if currentExists {
		return fmt.Errorf(
			"cannot migrate constraint %s.%s: constraint %s already exists",
			migration.table,
			migration.from,
			migration.to,
		)
	}
	query := fmt.Sprintf(
		"ALTER TABLE `%s` %s `%s`",
		migration.table,
		migration.dropClause,
		migration.from,
	)
	if _, err := db.ExecContext(ctx, query); err != nil {
		return fmt.Errorf("drop legacy constraint %s.%s: %w", migration.table, migration.from, err)
	}
	return nil
}

func renameTableIfNeeded(ctx context.Context, db *sql.DB, rename tableRename) error {
	legacyExists, err := tableExists(ctx, db, rename.from)
	if err != nil {
		return err
	}
	if !legacyExists {
		return nil
	}
	currentExists, err := tableExists(ctx, db, rename.to)
	if err != nil {
		return err
	}
	if currentExists {
		return fmt.Errorf("cannot rename table %s: table %s already exists", rename.from, rename.to)
	}
	if _, err := db.ExecContext(ctx, fmt.Sprintf("RENAME TABLE `%s` TO `%s`", rename.from, rename.to)); err != nil {
		return fmt.Errorf("rename table %s to %s: %w", rename.from, rename.to, err)
	}
	return nil
}

func renameColumnIfNeeded(ctx context.Context, db *sql.DB, rename columnRename) error {
	legacyExists, err := columnExists(ctx, db, rename.table, rename.from)
	if err != nil {
		return err
	}
	if !legacyExists {
		return nil
	}
	currentExists, err := columnExists(ctx, db, rename.table, rename.to)
	if err != nil {
		return err
	}
	if currentExists {
		return fmt.Errorf("cannot rename column %s.%s: column %s already exists", rename.table, rename.from, rename.to)
	}
	query := fmt.Sprintf("ALTER TABLE `%s` RENAME COLUMN `%s` TO `%s`", rename.table, rename.from, rename.to)
	if _, err := db.ExecContext(ctx, query); err != nil {
		return fmt.Errorf("rename column %s.%s to %s: %w", rename.table, rename.from, rename.to, err)
	}
	return nil
}

func renameIndexIfNeeded(ctx context.Context, db *sql.DB, rename indexRename) error {
	legacyExists, err := indexExists(ctx, db, rename.table, rename.from)
	if err != nil {
		return err
	}
	if !legacyExists {
		return nil
	}
	currentExists, err := indexExists(ctx, db, rename.table, rename.to)
	if err != nil {
		return err
	}
	if currentExists {
		return fmt.Errorf("cannot rename index %s.%s: index %s already exists", rename.table, rename.from, rename.to)
	}
	query := fmt.Sprintf("ALTER TABLE `%s` RENAME INDEX `%s` TO `%s`", rename.table, rename.from, rename.to)
	if _, err := db.ExecContext(ctx, query); err != nil {
		return fmt.Errorf("rename index %s.%s to %s: %w", rename.table, rename.from, rename.to, err)
	}
	return nil
}

func ensureCurrentConstraint(ctx context.Context, db *sql.DB, migration constraintMigration) error {
	currentExists, err := constraintExists(ctx, db, migration.table, migration.to)
	if err != nil {
		return err
	}
	if currentExists {
		return nil
	}
	query := fmt.Sprintf(
		"ALTER TABLE `%s` ADD CONSTRAINT `%s` %s",
		migration.table,
		migration.to,
		migration.definition,
	)
	if _, err := db.ExecContext(ctx, query); err != nil {
		return fmt.Errorf("create constraint %s.%s: %w", migration.table, migration.to, err)
	}
	return nil
}

func tableExists(ctx context.Context, db schemaQueryer, name string) (bool, error) {
	return schemaObjectExists(
		ctx,
		db,
		`SELECT EXISTS(
			SELECT 1 FROM information_schema.tables
			WHERE table_schema = DATABASE() AND table_name = ?
		)`,
		"table "+name,
		name,
	)
}

func columnExists(ctx context.Context, db schemaQueryer, table, column string) (bool, error) {
	return schemaObjectExists(
		ctx,
		db,
		`SELECT EXISTS(
			SELECT 1 FROM information_schema.columns
			WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?
		)`,
		"column "+table+"."+column,
		table,
		column,
	)
}

func indexExists(ctx context.Context, db schemaQueryer, table, index string) (bool, error) {
	return schemaObjectExists(
		ctx,
		db,
		`SELECT EXISTS(
			SELECT 1 FROM information_schema.statistics
			WHERE table_schema = DATABASE() AND table_name = ? AND index_name = ?
		)`,
		"index "+table+"."+index,
		table,
		index,
	)
}

func constraintExists(ctx context.Context, db schemaQueryer, table, constraint string) (bool, error) {
	return schemaObjectExists(
		ctx,
		db,
		`SELECT EXISTS(
			SELECT 1 FROM information_schema.table_constraints
			WHERE constraint_schema = DATABASE() AND table_name = ? AND constraint_name = ?
		)`,
		"constraint "+table+"."+constraint,
		table,
		constraint,
	)
}

func schemaObjectExists(ctx context.Context, db schemaQueryer, query, description string, args ...any) (bool, error) {
	var exists bool
	if err := db.QueryRowContext(ctx, query, args...).Scan(&exists); err != nil {
		return false, fmt.Errorf("check %s: %w", description, err)
	}
	return exists, nil
}

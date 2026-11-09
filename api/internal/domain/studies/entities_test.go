package studies

import (
	"encoding/json"
	"strings"
	"testing"
)

func TestSubjectSerializesBusinessFieldsInPortuguese(t *testing.T) {
	payload, err := json.Marshal(Subject{
		ID:         "disciplina-1",
		Name:       "Português",
		Difficulty: DifficultyMedium,
		Color:      "#E8742A",
		Topics: []Topic{
			{
				ID:        "topico-1",
				Name:      MandatoryReviewTopicName,
				Mandatory: true,
				Subtopics: []Subtopic{},
			},
		},
	})
	if err != nil {
		t.Fatalf("json.Marshal() error = %v", err)
	}

	serialized := string(payload)
	for _, field := range []string{"nome", "dificuldade", "cor", "topicos", "obrigatorio", "subtopicos"} {
		if !strings.Contains(serialized, `"`+field+`"`) {
			t.Fatalf("serialized subject does not contain %q: %s", field, serialized)
		}
	}
	for _, legacyField := range []string{"name", "difficulty", "color", "topics", "mandatory", "subtopics"} {
		if strings.Contains(serialized, `"`+legacyField+`"`) {
			t.Fatalf("serialized subject contains legacy field %q: %s", legacyField, serialized)
		}
	}
}

package studies

type Difficulty int

const (
	DifficultyVeryEasy Difficulty = 1
	DifficultyEasy     Difficulty = 2
	DifficultyMedium   Difficulty = 3
	DifficultyHard     Difficulty = 4
	DifficultyVeryHard Difficulty = 5
)

func (d Difficulty) Valid() bool {
	return d >= DifficultyVeryEasy && d <= DifficultyVeryHard
}

type Subject struct {
	ID         string     `json:"id"`
	Name       string     `json:"name"`
	Difficulty Difficulty `json:"difficulty"`
	Color      string     `json:"color"`
	Topics     []Topic    `json:"topics"`
}

type Topic struct {
	ID        string     `json:"id"`
	Name      string     `json:"name"`
	Subtopics []Subtopic `json:"subtopics"`
}

type Subtopic struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

type CreateSubjectInput struct {
	Name       string
	Difficulty Difficulty
	Color      string
}

type UpdateSubjectInput struct {
	Name       *string
	Difficulty *Difficulty
	Color      *string
}

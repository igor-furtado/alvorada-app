package httpapi

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"strings"
	"time"

	apiDocs "concursosapp/api/docs"
	concursosApplication "concursosapp/api/internal/application/concursos"
	semanaApplication "concursosapp/api/internal/application/semana"
	application "concursosapp/api/internal/application/studies"
	concursosDomain "concursosapp/api/internal/domain/concursos"
	semanaDomain "concursosapp/api/internal/domain/semana"
	domain "concursosapp/api/internal/domain/studies"
)

type Handler struct {
	studies   *application.Service
	concursos *concursosApplication.Service
	semana    *semanaApplication.Service
	logger    *slog.Logger
}

func NewHandler(
	studies *application.Service,
	concursos *concursosApplication.Service,
	logger *slog.Logger,
	semanaServices ...*semanaApplication.Service,
) *Handler {
	var semanaService *semanaApplication.Service
	if len(semanaServices) > 0 {
		semanaService = semanaServices[0]
	}
	return &Handler{studies: studies, concursos: concursos, semana: semanaService, logger: logger}
}

func (h *Handler) Router() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /docs", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/docs/", http.StatusPermanentRedirect)
	})
	mux.HandleFunc("GET /docs/", h.documentation)
	mux.HandleFunc("GET /openapi.yaml", h.openAPI)
	mux.HandleFunc("GET /health", h.health)
	mux.HandleFunc("GET /api/v1/concursos", h.listConcursos)
	mux.HandleFunc("POST /api/v1/concursos", h.createConcurso)
	mux.HandleFunc("PUT /api/v1/concursos/{id}", h.updateConcurso)
	mux.HandleFunc("DELETE /api/v1/concursos/{id}", h.deleteConcurso)
	mux.HandleFunc("PUT /api/v1/concursos/{id}/prioridade", h.setConcursoPrioritario)
	mux.HandleFunc("PUT /api/v1/concursos/{id}/arquivamento", h.archiveConcurso)
	mux.HandleFunc("DELETE /api/v1/concursos/{id}/arquivamento", h.restoreConcurso)
	mux.HandleFunc("PUT /api/v1/concursos/{id}/edital/disciplinas/{disciplinaId}", h.addDisciplinaToEdital)
	mux.HandleFunc("PATCH /api/v1/concursos/{id}/edital/disciplinas/{disciplinaId}/peso", h.updateDisciplinaPeso)
	mux.HandleFunc("PUT /api/v1/concursos/{id}/edital/topicos/{topicoId}", h.addTopicoToEdital)
	mux.HandleFunc("DELETE /api/v1/concursos/{id}/edital/topicos/{topicoId}", h.removeTopicoFromEdital)
	mux.HandleFunc("GET /api/v1/subjects", h.catalog)
	mux.HandleFunc("POST /api/v1/subjects", h.createSubject)
	mux.HandleFunc("PUT /api/v1/subjects/order", h.reorderSubjects)
	mux.HandleFunc("PATCH /api/v1/subjects/{id}", h.updateSubject)
	mux.HandleFunc("DELETE /api/v1/subjects/{id}", h.deleteSubject)
	mux.HandleFunc("POST /api/v1/subjects/{id}/topics", h.createTopic)
	mux.HandleFunc("POST /api/v1/subjects/{id}/topics/batch", h.createTopics)
	mux.HandleFunc("PUT /api/v1/subjects/{id}/topics/order", h.reorderTopics)
	mux.HandleFunc("PATCH /api/v1/topics/{id}", h.updateTopic)
	mux.HandleFunc("DELETE /api/v1/topics/{id}", h.deleteTopic)
	mux.HandleFunc("GET /api/v1/semana", h.planejamentoSemanal)
	mux.HandleFunc("PUT /api/v1/concursos/{concursoId}/topicos/{topicoId}/planejamento", h.planejarTopico)
	mux.HandleFunc("PATCH /api/v1/concursos/{concursoId}/topicos/{topicoId}/progresso", h.atualizarProgressoTopico)
	mux.HandleFunc("POST /api/v1/concursos/{concursoId}/topicos/{topicoId}/questoes", h.registrarQuestao)
	mux.HandleFunc("PUT /api/v1/concursos/{concursoId}/topicos/{topicoId}/revisoes", h.substituirRevisoes)
	mux.HandleFunc("PATCH /api/v1/revisoes/{id}/planejamento", h.moverRevisao)
	mux.HandleFunc("PUT /api/v1/revisoes/{id}/conclusao", h.concluirRevisao)
	return recovery(h.logger, cors(requestLogger(h.logger, mux)))
}

type semanaItemResponse struct {
	ID                   string                `json:"id"`
	Tipo                 semanaDomain.TipoItem `json:"tipo"`
	ConcursoID           string                `json:"concurso_id"`
	ConcursoNome         string                `json:"concurso_nome"`
	ConcursoSigla        *string               `json:"concurso_sigla"`
	TopicoID             string                `json:"topico_id"`
	TopicoNome           string                `json:"topico_nome"`
	DisciplinaNome       string                `json:"disciplina_nome"`
	DataPlanejada        string                `json:"data_planejada"`
	PosicaoDia           uint                  `json:"posicao_dia"`
	TeoriaConcluida      bool                  `json:"teoria_concluida"`
	MemoriaConcluida     bool                  `json:"memoria_concluida"`
	ConferenciaConcluida bool                  `json:"conferencia_concluida"`
	Acertos              uint                  `json:"acertos"`
	Erros                uint                  `json:"erros"`
	VersaoMetodologia    *uint16               `json:"versao_metodologia"`
	Concluido            bool                  `json:"concluido"`
	IntervaloRevisaoDias *uint8                `json:"intervalo_revisao_dias"`
}

type topicoDisponivelResponse struct {
	ConcursoID     string  `json:"concurso_id"`
	ConcursoNome   string  `json:"concurso_nome"`
	ConcursoSigla  *string `json:"concurso_sigla"`
	TopicoID       string  `json:"topico_id"`
	TopicoNome     string  `json:"topico_nome"`
	DisciplinaNome string  `json:"disciplina_nome"`
}

type semanaResponse struct {
	Inicio      string                     `json:"inicio"`
	Fim         string                     `json:"fim"`
	Itens       []semanaItemResponse       `json:"itens"`
	Disponiveis []topicoDisponivelResponse `json:"disponiveis"`
}

func (h *Handler) planejamentoSemanal(w http.ResponseWriter, r *http.Request) {
	inicio, err := time.Parse(time.DateOnly, r.URL.Query().Get("inicio"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "o início deve usar o formato AAAA-MM-DD")
		return
	}
	fim, err := time.Parse(time.DateOnly, r.URL.Query().Get("fim"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "o fim deve usar o formato AAAA-MM-DD")
		return
	}
	plano, err := h.semana.Planejamento(r.Context(), inicio, fim)
	if err != nil {
		h.serviceError(w, r, err)
		return
	}
	response := semanaResponse{
		Inicio:      plano.Inicio.Format(time.DateOnly),
		Fim:         plano.Fim.Format(time.DateOnly),
		Itens:       make([]semanaItemResponse, 0, len(plano.Itens)),
		Disponiveis: make([]topicoDisponivelResponse, 0, len(plano.Disponiveis)),
	}
	for _, item := range plano.Itens {
		response.Itens = append(response.Itens, semanaItemResponse{
			ID: item.ID, Tipo: item.Tipo,
			ConcursoID: item.ConcursoID, ConcursoNome: item.ConcursoNome, ConcursoSigla: item.ConcursoSigla,
			TopicoID: item.TopicoID, TopicoNome: item.TopicoNome, DisciplinaNome: item.DisciplinaNome,
			DataPlanejada: item.DataPlanejada.Format(time.DateOnly), PosicaoDia: item.PosicaoDia,
			TeoriaConcluida: item.TeoriaConcluida, MemoriaConcluida: item.MemoriaConcluida,
			ConferenciaConcluida: item.ConferenciaConcluida,
			Acertos:              item.Acertos, Erros: item.Erros, VersaoMetodologia: item.VersaoMetodologia,
			Concluido: item.Concluido, IntervaloRevisaoDias: item.IntervaloRevisaoDias,
		})
	}
	for _, item := range plano.Disponiveis {
		response.Disponiveis = append(response.Disponiveis, topicoDisponivelResponse{
			ConcursoID: item.ConcursoID, ConcursoNome: item.ConcursoNome, ConcursoSigla: item.ConcursoSigla,
			TopicoID: item.TopicoID, TopicoNome: item.TopicoNome, DisciplinaNome: item.DisciplinaNome,
		})
	}
	writeJSON(w, http.StatusOK, response)
}

type planejamentoRequest struct {
	DataPlanejada string `json:"data_planejada"`
	PosicaoDia    uint   `json:"posicao_dia"`
}

func (h *Handler) planejarTopico(w http.ResponseWriter, r *http.Request) {
	var body planejamentoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	data, err := time.Parse(time.DateOnly, body.DataPlanejada)
	if err != nil {
		writeError(w, http.StatusBadRequest, "a data planejada deve usar o formato AAAA-MM-DD")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.semana.PlanejarTopico(
			r.Context(), r.PathValue("concursoId"), r.PathValue("topicoId"), data, body.PosicaoDia,
		)
	})
}

type progressoTopicoRequest struct {
	TeoriaConcluida      *bool `json:"teoria_concluida"`
	MemoriaConcluida     *bool `json:"memoria_concluida"`
	ConferenciaConcluida *bool `json:"conferencia_concluida"`
}

func (h *Handler) atualizarProgressoTopico(w http.ResponseWriter, r *http.Request) {
	var body progressoTopicoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.semana.AtualizarProgresso(
			r.Context(), r.PathValue("concursoId"), r.PathValue("topicoId"),
			semanaDomain.ProgressoInput{
				TeoriaConcluida:      body.TeoriaConcluida,
				MemoriaConcluida:     body.MemoriaConcluida,
				ConferenciaConcluida: body.ConferenciaConcluida,
			},
		)
	})
}

type questaoRequest struct {
	Resultado semanaDomain.ResultadoQuestao `json:"resultado"`
}

func (h *Handler) registrarQuestao(w http.ResponseWriter, r *http.Request) {
	var body questaoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.semana.RegistrarQuestao(
			r.Context(), r.PathValue("concursoId"), r.PathValue("topicoId"), body.Resultado,
		)
	})
}

type revisoesRequest struct {
	IntervalosDias []uint8 `json:"intervalos_dias"`
}

func (h *Handler) substituirRevisoes(w http.ResponseWriter, r *http.Request) {
	var body revisoesRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.semana.SubstituirRevisoes(
			r.Context(), r.PathValue("concursoId"), r.PathValue("topicoId"), body.IntervalosDias,
		)
	})
}

func (h *Handler) moverRevisao(w http.ResponseWriter, r *http.Request) {
	var body planejamentoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	data, err := time.Parse(time.DateOnly, body.DataPlanejada)
	if err != nil {
		writeError(w, http.StatusBadRequest, "a data planejada deve usar o formato AAAA-MM-DD")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.semana.MoverRevisao(r.Context(), r.PathValue("id"), data, body.PosicaoDia)
	})
}

func (h *Handler) concluirRevisao(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.semana.ConcluirRevisao(r.Context(), r.PathValue("id"))
	})
}

func (h *Handler) documentation(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(apiDocs.SwaggerUI)
}

func (h *Handler) openAPI(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/yaml; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(apiDocs.OpenAPI)
}

func (h *Handler) health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

type concursoRequest struct {
	Instituicao         string                             `json:"instituicao"`
	Cargo               string                             `json:"cargo"`
	Banca               *string                            `json:"banca"`
	DataProva           *string                            `json:"data_prova"`
	Prioritario         bool                               `json:"prioritario"`
	Sigla               *string                            `json:"sigla"`
	RegimeContratacao   *concursosDomain.RegimeContratacao `json:"regime_contratacao"`
	QuantidadeVagas     *int                               `json:"quantidade_vagas"`
	VencimentoCentavos  *int64                             `json:"vencimento_centavos"`
	CargaHorariaSemanal *int                               `json:"carga_horaria_semanal"`
	LocalProva          *string                            `json:"local_prova"`
	HorarioInicioProva  *string                            `json:"horario_inicio_prova"`
	HorarioFimProva     *string                            `json:"horario_fim_prova"`
	Requisitos          *string                            `json:"requisitos"`
	CriteriosPontuacao  *string                            `json:"criterios_pontuacao"`
}

type concursoResponse struct {
	ID                  string                             `json:"id"`
	Instituicao         string                             `json:"instituicao"`
	Cargo               string                             `json:"cargo"`
	Banca               *string                            `json:"banca"`
	DataProva           *string                            `json:"data_prova"`
	Prioritario         bool                               `json:"prioritario"`
	ProgressoEdital     int                                `json:"progresso_edital"`
	Sigla               *string                            `json:"sigla"`
	RegimeContratacao   *concursosDomain.RegimeContratacao `json:"regime_contratacao"`
	QuantidadeVagas     *int                               `json:"quantidade_vagas"`
	VencimentoCentavos  *int64                             `json:"vencimento_centavos"`
	CargaHorariaSemanal *int                               `json:"carga_horaria_semanal"`
	LocalProva          *string                            `json:"local_prova"`
	HorarioInicioProva  *string                            `json:"horario_inicio_prova"`
	HorarioFimProva     *string                            `json:"horario_fim_prova"`
	Requisitos          *string                            `json:"requisitos"`
	CriteriosPontuacao  *string                            `json:"criterios_pontuacao"`
	Disciplinas         []concursosDomain.EditalDisciplina `json:"disciplinas"`
}

func (h *Handler) listConcursos(w http.ResponseWriter, r *http.Request) {
	items, err := h.concursos.ListActive(r.Context())
	if err != nil {
		h.internalError(w, r, err)
		return
	}
	response := make([]concursoResponse, 0, len(items))
	for _, item := range items {
		var dataProva *string
		if item.DataProva != nil {
			value := item.DataProva.Format(time.DateOnly)
			dataProva = &value
		}
		response = append(response, concursoResponse{
			ID:                  item.ID,
			Instituicao:         item.Instituicao,
			Cargo:               item.Cargo,
			Banca:               item.Banca,
			DataProva:           dataProva,
			Prioritario:         item.Prioritario,
			ProgressoEdital:     item.ProgressoEdital,
			Sigla:               item.Sigla,
			RegimeContratacao:   item.RegimeContratacao,
			QuantidadeVagas:     item.QuantidadeVagas,
			VencimentoCentavos:  item.VencimentoCentavos,
			CargaHorariaSemanal: item.CargaHorariaSemanal,
			LocalProva:          item.LocalProva,
			HorarioInicioProva:  item.HorarioInicioProva,
			HorarioFimProva:     item.HorarioFimProva,
			Requisitos:          item.Requisitos,
			CriteriosPontuacao:  item.CriteriosPontuacao,
			Disciplinas:         item.Disciplinas,
		})
	}
	writeJSON(w, http.StatusOK, response)
}

func (h *Handler) createConcurso(w http.ResponseWriter, r *http.Request) {
	var body concursoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	dataProva, err := parseOptionalDate(body.DataProva)
	if err != nil {
		writeError(w, http.StatusBadRequest, "a data da prova deve usar o formato AAAA-MM-DD")
		return
	}
	id, err := h.concursos.Create(r.Context(), concursosDomain.CreateConcursoInput{
		Instituicao:         body.Instituicao,
		Cargo:               body.Cargo,
		Banca:               body.Banca,
		DataProva:           dataProva,
		Prioritario:         body.Prioritario,
		Sigla:               body.Sigla,
		RegimeContratacao:   body.RegimeContratacao,
		QuantidadeVagas:     body.QuantidadeVagas,
		VencimentoCentavos:  body.VencimentoCentavos,
		CargaHorariaSemanal: body.CargaHorariaSemanal,
		LocalProva:          body.LocalProva,
		HorarioInicioProva:  body.HorarioInicioProva,
		HorarioFimProva:     body.HorarioFimProva,
		Requisitos:          body.Requisitos,
		CriteriosPontuacao:  body.CriteriosPontuacao,
	})
	if err != nil {
		h.serviceError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"id": id})
}

func (h *Handler) updateConcurso(w http.ResponseWriter, r *http.Request) {
	var body concursoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	dataProva, err := parseOptionalDate(body.DataProva)
	if err != nil {
		writeError(w, http.StatusBadRequest, "a data da prova deve usar o formato AAAA-MM-DD")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.concursos.Update(r.Context(), r.PathValue("id"), concursosDomain.UpdateConcursoInput{
			Instituicao:         body.Instituicao,
			Cargo:               body.Cargo,
			Banca:               body.Banca,
			DataProva:           dataProva,
			Prioritario:         body.Prioritario,
			Sigla:               body.Sigla,
			RegimeContratacao:   body.RegimeContratacao,
			QuantidadeVagas:     body.QuantidadeVagas,
			VencimentoCentavos:  body.VencimentoCentavos,
			CargaHorariaSemanal: body.CargaHorariaSemanal,
			LocalProva:          body.LocalProva,
			HorarioInicioProva:  body.HorarioInicioProva,
			HorarioFimProva:     body.HorarioFimProva,
			Requisitos:          body.Requisitos,
			CriteriosPontuacao:  body.CriteriosPontuacao,
		})
	})
}

func (h *Handler) setConcursoPrioritario(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.SetPrioritario(r.Context(), r.PathValue("id"))
	})
}

func (h *Handler) archiveConcurso(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.Archive(r.Context(), r.PathValue("id"))
	})
}

func (h *Handler) restoreConcurso(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.Restore(r.Context(), r.PathValue("id"))
	})
}

func (h *Handler) deleteConcurso(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.Delete(r.Context(), r.PathValue("id"))
	})
}

func (h *Handler) addDisciplinaToEdital(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.AddDisciplinaToEdital(r.Context(), r.PathValue("id"), r.PathValue("disciplinaId"))
	})
}

type disciplinaPesoRequest struct {
	Peso float64 `json:"peso"`
}

func (h *Handler) updateDisciplinaPeso(w http.ResponseWriter, r *http.Request) {
	var body disciplinaPesoRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.concursos.UpdateDisciplinaPeso(
			r.Context(),
			r.PathValue("id"),
			r.PathValue("disciplinaId"),
			body.Peso,
		)
	})
}

func (h *Handler) addTopicoToEdital(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.AddTopicoToEdital(r.Context(), r.PathValue("id"), r.PathValue("topicoId"))
	})
}

func (h *Handler) removeTopicoFromEdital(w http.ResponseWriter, r *http.Request) {
	h.runNoContent(w, r, func() error {
		return h.concursos.RemoveTopicoFromEdital(r.Context(), r.PathValue("id"), r.PathValue("topicoId"))
	})
}

func (h *Handler) runNoContent(w http.ResponseWriter, r *http.Request, operation func() error) {
	if err := operation(); err != nil {
		h.serviceError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func parseOptionalDate(value *string) (*time.Time, error) {
	if value == nil || strings.TrimSpace(*value) == "" {
		return nil, nil
	}
	parsed, err := time.Parse(time.DateOnly, strings.TrimSpace(*value))
	if err != nil {
		return nil, err
	}
	return &parsed, nil
}

func (h *Handler) catalog(w http.ResponseWriter, r *http.Request) {
	catalog, err := h.studies.Catalog(r.Context())
	if err != nil {
		h.internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, catalog)
}

type subjectRequest struct {
	Name       string `json:"nome"`
	Difficulty int    `json:"dificuldade"`
	Color      string `json:"cor"`
}

type updateSubjectRequest struct {
	Name       *string `json:"nome"`
	Difficulty *int    `json:"dificuldade"`
	Color      *string `json:"cor"`
}

type nameRequest struct {
	Name string `json:"nome"`
}

type namesRequest struct {
	Names []string `json:"nomes"`
}

type topicOrderRequest struct {
	TopicIDs []string `json:"topico_ids"`
}

type subjectOrderRequest struct {
	SubjectIDs []string `json:"disciplina_ids"`
}

func (h *Handler) createSubject(w http.ResponseWriter, r *http.Request) {
	var body subjectRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	if body.Difficulty == 0 {
		body.Difficulty = int(domain.DifficultyMedium)
	}
	if body.Color == "" {
		body.Color = "#E8742A"
	}
	id, err := h.studies.CreateSubject(r.Context(), domain.CreateSubjectInput{
		Name: body.Name, Difficulty: domain.Difficulty(body.Difficulty), Color: body.Color,
	})
	if err != nil {
		h.serviceError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"id": id})
}

func (h *Handler) updateSubject(w http.ResponseWriter, r *http.Request) {
	var body updateSubjectRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	var difficulty *domain.Difficulty
	if body.Difficulty != nil {
		value := domain.Difficulty(*body.Difficulty)
		difficulty = &value
	}
	err := h.studies.UpdateSubject(r.Context(), r.PathValue("id"), domain.UpdateSubjectInput{
		Name: body.Name, Difficulty: difficulty, Color: body.Color,
	})
	if err != nil {
		h.serviceError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) deleteSubject(w http.ResponseWriter, r *http.Request) {
	h.runDelete(w, r, func() error { return h.studies.DeleteSubject(r.Context(), r.PathValue("id")) })
}

func (h *Handler) reorderSubjects(w http.ResponseWriter, r *http.Request) {
	var body subjectOrderRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.studies.ReorderSubjects(r.Context(), body.SubjectIDs)
	})
}

func (h *Handler) createTopic(w http.ResponseWriter, r *http.Request) {
	h.runCreateName(w, r, func(name string) error { return h.studies.CreateTopic(r.Context(), r.PathValue("id"), name) })
}

func (h *Handler) createTopics(w http.ResponseWriter, r *http.Request) {
	var body namesRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	if err := h.studies.CreateTopics(r.Context(), r.PathValue("id"), body.Names); err != nil {
		h.serviceError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{})
}

func (h *Handler) reorderTopics(w http.ResponseWriter, r *http.Request) {
	var body topicOrderRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	h.runNoContent(w, r, func() error {
		return h.studies.ReorderTopics(r.Context(), r.PathValue("id"), body.TopicIDs)
	})
}

func (h *Handler) updateTopic(w http.ResponseWriter, r *http.Request) {
	h.runUpdateName(w, r, func(name string) error { return h.studies.UpdateTopic(r.Context(), r.PathValue("id"), name) })
}

func (h *Handler) deleteTopic(w http.ResponseWriter, r *http.Request) {
	h.runDelete(w, r, func() error { return h.studies.DeleteTopic(r.Context(), r.PathValue("id")) })
}

func (h *Handler) runCreateName(w http.ResponseWriter, r *http.Request, operation func(string) error) {
	var body nameRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	if err := operation(body.Name); err != nil {
		h.serviceError(w, r, err)
		return
	}
	writeJSON(w, http.StatusCreated, map[string]any{})
}

func (h *Handler) runUpdateName(w http.ResponseWriter, r *http.Request, operation func(string) error) {
	var body nameRequest
	if err := decodeJSON(r, &body); err != nil {
		writeError(w, http.StatusBadRequest, "corpo da requisição inválido")
		return
	}
	if err := operation(body.Name); err != nil {
		h.serviceError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) runDelete(w http.ResponseWriter, r *http.Request, operation func() error) {
	if err := operation(); err != nil {
		h.serviceError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) serviceError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, concursosDomain.ErrConcursoNotFound) {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}
	if errors.Is(err, concursosApplication.ErrInstituicaoRequired) ||
		errors.Is(err, concursosApplication.ErrCargoRequired) ||
		errors.Is(err, concursosApplication.ErrInstituicaoTooLong) ||
		errors.Is(err, concursosApplication.ErrCargoTooLong) ||
		errors.Is(err, concursosApplication.ErrBancaTooLong) ||
		errors.Is(err, concursosApplication.ErrSiglaTooLong) ||
		errors.Is(err, concursosApplication.ErrRegimeContratacao) ||
		errors.Is(err, concursosApplication.ErrQuantidadeVagas) ||
		errors.Is(err, concursosApplication.ErrVencimento) ||
		errors.Is(err, concursosApplication.ErrCargaHoraria) ||
		errors.Is(err, concursosApplication.ErrLocalProvaTooLong) ||
		errors.Is(err, concursosApplication.ErrHorariosProva) ||
		errors.Is(err, concursosApplication.ErrRequisitosTooLong) ||
		errors.Is(err, concursosApplication.ErrPontuacaoTooLong) {
		// validation errors are reported as a stable client error
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if errors.Is(err, concursosApplication.ErrPesoDisciplina) {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if errors.Is(err, semanaApplication.ErrPeriodoInvalido) ||
		errors.Is(err, semanaApplication.ErrDataInvalida) ||
		errors.Is(err, semanaApplication.ErrProgressoVazio) ||
		errors.Is(err, semanaApplication.ErrResultadoQuestao) ||
		errors.Is(err, semanaApplication.ErrIntervaloRevisao) ||
		errors.Is(err, semanaApplication.ErrTopicoNaoConcluido) {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if errors.Is(err, semanaApplication.ErrTopicoNaoEncontrado) ||
		errors.Is(err, semanaApplication.ErrRevisaoNaoEncontrada) {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}
	if errors.Is(err, application.ErrNameRequired) || errors.Is(err, application.ErrTopicsRequired) ||
		errors.Is(err, application.ErrNameTooLong) ||
		errors.Is(err, application.ErrInvalidDifficulty) || errors.Is(err, application.ErrInvalidColor) ||
		errors.Is(err, domain.ErrMandatoryTopic) || errors.Is(err, domain.ErrInvalidSubjectOrder) ||
		errors.Is(err, domain.ErrInvalidTopicOrder) {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if errors.Is(err, domain.ErrContentLinked) {
		writeError(w, http.StatusConflict, err.Error())
		return
	}
	h.internalError(w, r, err)
}

func (h *Handler) internalError(w http.ResponseWriter, r *http.Request, err error) {
	h.logger.Error("request failed", "method", r.Method, "path", r.URL.Path, "error", err)
	writeError(w, http.StatusInternalServerError, "não foi possível concluir a operação")
}

func decodeJSON(r *http.Request, target any) error {
	decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return err
	}
	if err := decoder.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return errors.New("request body must contain a single JSON object")
	}
	return nil
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"erro": message})
}

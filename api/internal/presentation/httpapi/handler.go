package httpapi

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"

	apiDocs "concursosapp/api/docs"
	application "concursosapp/api/internal/application/studies"
	domain "concursosapp/api/internal/domain/studies"
)

type Handler struct {
	studies *application.Service
	logger  *slog.Logger
}

func NewHandler(studies *application.Service, logger *slog.Logger) *Handler {
	return &Handler{studies: studies, logger: logger}
}

func (h *Handler) Router() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /docs", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/docs/", http.StatusPermanentRedirect)
	})
	mux.HandleFunc("GET /docs/", h.documentation)
	mux.HandleFunc("GET /openapi.yaml", h.openAPI)
	mux.HandleFunc("GET /health", h.health)
	mux.HandleFunc("GET /api/v1/subjects", h.catalog)
	mux.HandleFunc("POST /api/v1/subjects", h.createSubject)
	mux.HandleFunc("PATCH /api/v1/subjects/{id}", h.updateSubject)
	mux.HandleFunc("DELETE /api/v1/subjects/{id}", h.deleteSubject)
	mux.HandleFunc("POST /api/v1/subjects/{id}/topics", h.createTopic)
	mux.HandleFunc("PATCH /api/v1/topics/{id}", h.updateTopic)
	mux.HandleFunc("DELETE /api/v1/topics/{id}", h.deleteTopic)
	mux.HandleFunc("POST /api/v1/topics/{id}/subtopics", h.createSubtopic)
	mux.HandleFunc("PATCH /api/v1/subtopics/{id}", h.updateSubtopic)
	mux.HandleFunc("DELETE /api/v1/subtopics/{id}", h.deleteSubtopic)
	return recovery(h.logger, cors(requestLogger(h.logger, mux)))
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

func (h *Handler) catalog(w http.ResponseWriter, r *http.Request) {
	catalog, err := h.studies.Catalog(r.Context())
	if err != nil {
		h.internalError(w, r, err)
		return
	}
	writeJSON(w, http.StatusOK, catalog)
}

type subjectRequest struct {
	Name       string `json:"name"`
	Difficulty int    `json:"difficulty"`
	Color      string `json:"color"`
}

type updateSubjectRequest struct {
	Name       *string `json:"name"`
	Difficulty *int    `json:"difficulty"`
	Color      *string `json:"color"`
}

type nameRequest struct {
	Name string `json:"name"`
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

func (h *Handler) createTopic(w http.ResponseWriter, r *http.Request) {
	h.runCreateName(w, r, func(name string) error { return h.studies.CreateTopic(r.Context(), r.PathValue("id"), name) })
}

func (h *Handler) updateTopic(w http.ResponseWriter, r *http.Request) {
	h.runUpdateName(w, r, func(name string) error { return h.studies.UpdateTopic(r.Context(), r.PathValue("id"), name) })
}

func (h *Handler) deleteTopic(w http.ResponseWriter, r *http.Request) {
	h.runDelete(w, r, func() error { return h.studies.DeleteTopic(r.Context(), r.PathValue("id")) })
}

func (h *Handler) createSubtopic(w http.ResponseWriter, r *http.Request) {
	h.runCreateName(w, r, func(name string) error { return h.studies.CreateSubtopic(r.Context(), r.PathValue("id"), name) })
}

func (h *Handler) updateSubtopic(w http.ResponseWriter, r *http.Request) {
	h.runUpdateName(w, r, func(name string) error { return h.studies.UpdateSubtopic(r.Context(), r.PathValue("id"), name) })
}

func (h *Handler) deleteSubtopic(w http.ResponseWriter, r *http.Request) {
	h.runDelete(w, r, func() error { return h.studies.DeleteSubtopic(r.Context(), r.PathValue("id")) })
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
		h.internalError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) serviceError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, application.ErrNameRequired) || errors.Is(err, application.ErrNameTooLong) ||
		errors.Is(err, application.ErrInvalidDifficulty) || errors.Is(err, application.ErrInvalidColor) {
		writeError(w, http.StatusBadRequest, err.Error())
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
	writeJSON(w, status, map[string]string{"error": message})
}

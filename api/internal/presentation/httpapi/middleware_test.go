package httpapi

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestCORSAllowsPutForConcursoMutations(t *testing.T) {
	handler := cors(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Fatal("preflight must not reach the application handler")
	}))
	request := httptest.NewRequest(http.MethodOptions, "/api/v1/concursos/concurso-1/prioridade", nil)
	request.Header.Set("Access-Control-Request-Method", http.MethodPut)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusNoContent {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusNoContent)
	}
	methods := response.Header().Get("Access-Control-Allow-Methods")
	if !strings.Contains(methods, http.MethodPut) {
		t.Fatalf("Access-Control-Allow-Methods = %q, want PUT", methods)
	}
}

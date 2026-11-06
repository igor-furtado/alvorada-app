package httpapi

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestOpenAPISpecIsServed(t *testing.T) {
	handler := NewHandler(nil, slog.New(slog.NewTextHandler(&strings.Builder{}, nil))).Router()
	request := httptest.NewRequest(http.MethodGet, "/openapi.yaml", nil)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	if contentType := response.Header().Get("Content-Type"); !strings.Contains(contentType, "application/yaml") {
		t.Fatalf("Content-Type = %q", contentType)
	}
	if !strings.Contains(response.Body.String(), "openapi: 3.1.0") {
		t.Fatal("response does not contain the OpenAPI version")
	}
}

func TestDocumentationPageIsServed(t *testing.T) {
	handler := NewHandler(nil, slog.New(slog.NewTextHandler(&strings.Builder{}, nil))).Router()
	request := httptest.NewRequest(http.MethodGet, "/docs/", nil)
	response := httptest.NewRecorder()

	handler.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	if !strings.Contains(response.Body.String(), "SwaggerUIBundle") {
		t.Fatal("response does not contain the interactive documentation")
	}
}

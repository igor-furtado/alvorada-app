package docs

import _ "embed"

// OpenAPI contains the canonical API contract.
//
//go:embed openapi.yaml
var OpenAPI []byte

// SwaggerUI contains the interactive documentation page.
//
//go:embed index.html
var SwaggerUI []byte

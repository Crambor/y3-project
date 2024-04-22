package middleware

import (
    "net/http"
    "github.com/caddyserver/caddy/v2"
    "github.com/caddyserver/caddy/v2/modules/caddyhttp"
)

func init() {
    caddy.RegisterModule(MyMiddleware{})
}

// MyMiddleware is a simple Caddy HTTP middleware example
type MyMiddleware struct {
    // Configuration fields, if any
    Message string `json:"message,omitempty"`
}

// CaddyModule returns the Caddy module information required to register the middleware.
func (MyMiddleware) CaddyModule() caddy.ModuleInfo {
    return caddy.ModuleInfo{
        ID:  "http.handlers.my_middleware",
        New: func() caddy.Module { return new(MyMiddleware) },
    }
}

// Provision is called by Caddy to prepare the module's setup.
func (m *MyMiddleware) Provision(ctx caddy.Context) error {
    // Initialization logic here, e.g., set default values
    if m.Message == "" {
        m.Message = "Hello, Caddy!"
    }
    return nil
}

// Validate ensures the module's configuration is valid.
func (m *MyMiddleware) Validate() error {
    // Validation logic here
    return nil
}

// ServeHTTP implements the caddyhttp.MiddlewareHandler interface.
func (m MyMiddleware) ServeHTTP(w http.ResponseWriter, r *http.Request, next caddyhttp.Handler) error {
    // Your middleware logic here
    // For example, adding a header to responses
    w.Header().Add("X-Custom-Message", m.Message)
    
    // Call the next handler in the chain
    return next.ServeHTTP(w, r)
}

// Interface guards
var (
    _ caddyhttp.MiddlewareHandler = (*MyMiddleware)(nil)
    _ caddy.Provisioner           = (*MyMiddleware)(nil)
)


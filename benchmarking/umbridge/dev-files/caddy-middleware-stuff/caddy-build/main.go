package main

import (
    "github.com/caddyserver/caddy/v2"
    _ "github.com/caddyserver/caddy/v2/modules/standard"
    // Import your custom middleware so it's registered
    _ "load-balancer/caddy-build/middleware"
)

func main() {
    // Start Caddy with your configuration
    caddy.Main()
}


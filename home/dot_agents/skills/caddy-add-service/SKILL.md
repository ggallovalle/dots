---
name: caddy-add-service
description: Add a new reverse-proxy service to a local Caddy instance exposed via Tailscale. Reads Caddyfile, adds route, updates portal index, reloads Caddy, and verifies reachability. Use when user wants to expose a new local service through Caddy + Tailscale.
---

# Caddy Add Service

## Quick start

User says something like "add service foo on port 3000" or "expose opencode on port 4096". Derive service name (path slug) and internal port from their request.

Ask if they need a link added to the portal index (`$HOME/.local/share/caddy-site/index.html`).

**Heads-up — SPAs with absolute asset paths** (e.g. opencode): serving under a subpath like `/name/` breaks because the SPA's HTML loads JS/CSS from `/assets/...` (root level). Use a **separate Caddy port** instead:

```
$PORT_NEW {
    reverse_proxy 127.0.0.1:$INTERNAL_PORT
}
```
Link to `http://$TS_IP:$PORT_NEW/` in the index.

## Workflow

1. **Read Caddyfile**
   ```
   $HOME/.config/caddy/Caddyfile
   ```
   Check existing routes to match style.

2. **Add trailing-slash redirect** (if not already present)
   ```
   redir /<name> /<name>/ 308
   ```
   Insert after the last existing `redir` line.

3. **Add reverse_proxy handle block**
   ```
   handle /<name>/* {
       reverse_proxy 127.0.0.1:<port>
   }
   ```
   Insert before the catch-all `handle { ... }` block.

4. **Update portal index** (if user wants a link)
   Read `$HOME/.local/share/caddy-site/index.html` and add:
   ```html
   <li><a href="/<name>/"><Name></a></li>
   ```

5. **Reload Caddy**
   ```
   systemctl --user reload caddy
   ```

6. **Verify via Tailscale**
   ```
   ts_ip=$(tailscale ip -4)
   curl -s -o /dev/null -w "%{http_code}" "http://$ts_ip:8080/<name>/"
   ```
   A non-5xx response (e.g. 200, 302, 401) confirms the proxy chain works.

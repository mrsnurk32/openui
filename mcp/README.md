# MCP with Open WebUI

Open WebUI native MCP is Streamable HTTP. Only admins can register servers.
Then grant each server to users or groups.

Official notes: https://docs.openwebui.com/features/extensibility/mcp

## Remote / HTTP MCP

1. Open Admin Panel → Settings → Integrations.
2. Add Connection → type **MCP (Streamable HTTP)**.
3. Enter the server URL and auth.
4. Set Access Control to the right group (`engineering`, `analysts`, …).

## Local stdio MCP via mcpo

This repo includes an optional `mcpo` service.

```bash
docker compose --profile mcp up -d
```

Default example server: `@modelcontextprotocol/server-time` on `http://localhost:8001`.

In Open WebUI add:

- From the same compose network: `http://mcpo:8000`
- If Open WebUI cannot resolve `mcpo`: `http://host.docker.internal:8001`

Use the `MCPO_API_KEY` from `.env` as the API key.

To expose filesystem or other stdio servers, change the `mcpo` `command` in `docker-compose.yml` or add another mcpo service.

Do not mount sensitive host paths until you have tightened group ACLs.

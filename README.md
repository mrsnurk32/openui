# openui

Self-hosted [Open WebUI](https://github.com/open-webui/open-webui) stack for Qwen, with login, pending-user roles, and MCP hooks.

- UI: http://localhost:3000
- Ollama API: http://localhost:11434
- Optional MCP proxy (mcpo): http://localhost:8001

## Requirements

- Docker Engine + Compose plugin
- 4 GB RAM minimum, 8 GB+ to run Qwen locally
- Optional NVIDIA GPU + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## 1. Configure

```bash
cp .env.example .env
```

Set a stable secret (required for sessions and MCP OAuth tokens):

```bash
# Linux / macOS
sed -i.bak "s/replace-with-openssl-rand-hex-32/$(openssl rand -hex 32)/" .env && rm -f .env.bak
```

Or edit `.env` and paste the output of `openssl rand -hex 32` into `WEBUI_SECRET_KEY`.

Do not commit `.env`.

## 2. Start

CPU:

```bash
docker compose up -d
```

NVIDIA GPU:

```bash
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d
```

With the example MCP proxy:

```bash
docker compose --profile mcp up -d
```

Logs:

```bash
docker compose logs -f open-webui
```

## 3. Create the admin account

1. Open http://localhost:3000 (or `http://SERVER_IP:3000`).
2. Sign up first. That account becomes **admin**.
3. Keep the password. Losing it locks admin settings.
4. Later signups get role **pending** until you approve them in **Admin Panel → Users**.

After your team has accounts, set `ENABLE_SIGNUP=false` in `.env` and run `docker compose up -d`, or leave signup on and keep pending approval.

Do not set `WEBUI_AUTH=false`. That change is effectively one-way.

## 4. Load Qwen

```bash
chmod +x scripts/pull-qwen.sh
./scripts/pull-qwen.sh
```

Default models: `qwen2.5:7b` and `qwen2.5-coder:7b` (tool-calling instruct builds). Override:

```bash
MODELS="qwen2.5:14b qwen2.5-coder:14b" ./scripts/pull-qwen.sh
```

If models do not show up: **Admin Panel → Settings → Connections → Ollama** should be `http://ollama:11434`.

### Cloud / vLLM Qwen

Set in `.env`:

```bash
OPENAI_API_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
OPENAI_API_KEY=your-key
```

Then recreate: `docker compose up -d`.
You can also add the same connection in **Admin Panel → Settings → Connections → OpenAI**.

## 5. Roles and groups

| Role | Meaning |
|---|---|
| `admin` | Users, models, MCP, settings |
| `user` | Approved people |
| `pending` | Waiting for approval |

Create groups under **Admin Panel → Users → Groups** (for example `engineering`, `analysts`). Permissions are additive: grant features on the group, keep global defaults tight, then share models and MCP servers to the group.

## 6. MCP

See [mcp/README.md](mcp/README.md).

Short version:

1. Only admins add MCP servers (**Admin Panel → Settings → Integrations**).
2. Type: **MCP (Streamable HTTP)** for native MCP.
3. Grant the server to a group.
4. Chat with a Qwen instruct/coder model and enable tools.

`WEBUI_SECRET_KEY` must stay stable or OAuth-connected MCP tools break on restart.

## 7. Update and backup

```bash
docker compose pull
docker compose up -d
```

Backup the Open WebUI volume:

```bash
mkdir -p backup
docker run --rm \
  -v openui_open-webui:/data \
  -v "$PWD/backup":/backup \
  alpine tar czf /backup/open-webui-$(date +%Y%m%d).tgz -C /data .
```

Volume name is `{project}_open-webui`. Confirm with `docker volume ls`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| No Ollama models | Wrong `OLLAMA_BASE_URL`, or Ollama not running |
| Logged out after recreate | `WEBUI_SECRET_KEY` missing or changed |
| MCP OAuth dies on restart | Same secret key |
| New users can do everything | Tighten default permissions; grant via groups |
| MCP tools never fire | Use a tool-calling Qwen instruct/coder model |
| Cannot add MCP as a normal user | Expected. Admin adds, then ACL |

Official docs: https://docs.openwebui.com/getting-started/quick-start/

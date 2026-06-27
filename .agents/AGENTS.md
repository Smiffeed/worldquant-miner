# WorldQuant Miner — Agent Rules

## Project Purpose
This workspace is used to **automate the generation, simulation, and submission of alpha factors
to the WorldQuant Brain platform** (https://platform.worldquantbrain.com).
The primary goal is hands-off, continuous alpha discovery and submission.

---

## Repository Layout
```
worldquant-miner/
├── generation_one/
│   └── naive-ollama/          ← RECOMMENDED for Docker-based 24/7 automation
│       ├── alpha_generator_ollama.py    # Generates alphas via Ollama LLM
│       ├── alpha_orchestrator.py        # Schedules & coordinates everything
│       ├── improved_alpha_submitter.py  # Submits successful alphas to WQ
│       ├── web_dashboard.py             # Flask dashboard at localhost:5000
│       ├── docker-compose.gpu.yml       # GPU deployment (recommended)
│       ├── docker-compose.yml           # CPU deployment
│       └── credential.txt               # WQ credentials [email, password]
├── generation_two/             ← Advanced: Desktop GUI + genetic evolution
│   ├── gui/run_gui.py          # Launch desktop GUI
│   ├── core/                   # Expression compiler, simulator, validator
│   ├── evolution/              # Genetic algorithm alpha evolution
│   └── requirements.txt
└── .agents/                    ← This directory (agent config)
```

---

## Credential Convention
- Credential file format: `["email@example.com", "password"]` (JSON array)
- Location: `generation_one/naive-ollama/credential.txt` OR `generation_two/credential.txt`
- **NEVER hardcode credentials in code or commit them to git**
- The `.gitignore` already excludes `credential.txt` — verify before any commit

---

## Recommended Workflow for Automation

### Step 1 — Setup credentials
```bash
echo '["your.email@worldquant.com", "your_password"]' \
  > generation_one/naive-ollama/credential.txt
```

### Step 2 — Start Docker stack (GPU)
```bash
cd generation_one/naive-ollama
docker-compose -f docker-compose.gpu.yml up -d
```

### Step 3 — Monitor
- Dashboard: http://localhost:5000
- Ollama API: http://localhost:11434
- Logs: `docker-compose logs -f`

### Step 4 — Stop
```bash
docker-compose -f docker-compose.gpu.yml down
```

---

## Key Python Entry Points

| Purpose | Command |
|---|---|
| Generate alphas (standalone) | `python alpha_generator_ollama.py` |
| Orchestrate everything | `python alpha_orchestrator.py` |
| Submit successful alphas | `python improved_alpha_submitter.py` |
| Desktop GUI (gen2) | `python generation_two/gui/run_gui.py` |

---

## WorldQuant Brain API
- Base URL: `https://api.worldquantbrain.com`
- Auth endpoint: `POST /authentication` (returns session cookie, status 201)
- Alphas endpoint: `GET /users/self/alphas`
- Simulate: `POST /simulations`
- Submit: `POST /alphas/{id}/submit`
- Rate limit: ~5,000 simulations/day (Pre-Consultant tier)

---

## Alpha Expression Language (FASTEXPR)
WorldQuant uses a custom expression language called **FASTEXPR**. Key rules:
- Multi-line: use `;` to separate variable assignments
- Final line is the alpha signal (no semicolon)
- Supported regions: `USA`, `GLB`, `EUR`, `ASI`, `CHN`, `IND`
- Common operators: `ts_rank`, `ts_mean`, `zscore`, `rank`, `neutralize`
- Data fields come from the WQ API (`/data-fields` endpoint)

Example valid alpha:
```
momentum = ts_mean(close / delay(close, 20), 5);
-rank(momentum)
```

---

## Ollama LLM Setup
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull recommended model (small, fast, code-capable)
ollama pull qwen2.5-coder:1.5b

# Or for better quality (needs more VRAM)
ollama pull deepseek-r1:8b

# Start Ollama server
ollama serve
```

---

## Git Remotes (Fork Setup)
- `origin` → `https://github.com/Smiffeed/worldquant-miner` (YOUR fork — push here)
- `upstream` → `https://github.com/zhutoutoutousan/worldquant-miner` (original — pull updates)

---

## Coding Conventions
- Python 3.8+ compatible code
- Use `logging` (not `print`) for operational messages
- Store results as JSON in local files or SQLite (`generation_two_backtests.db`)
- Respect WQ API rate limits — add `time.sleep()` between batch calls
- All new alpha generation scripts go in `generation_one/` or `generation_two/`
- Do not modify `agent-dify-api/` or `agent-dify-web/` — these are Apache 2.0 Dify components

---

## Security Rules
- Never commit `credential.txt` to git
- Never log passwords or raw credential content
- Do not add `shell=True` to subprocess calls with user-controlled input
- Treat `pickle` files as untrusted — do not load external `.pkl` files

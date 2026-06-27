---
name: worldquant-alpha-automation
description: >
  Automate alpha factor generation, simulation, and submission on the WorldQuant Brain platform
  using this repository. Activate when the user wants to: generate alpha expressions, run
  simulations, submit alphas, debug orchestration, extend the pipeline, configure Ollama models,
  interpret simulation results (Sharpe, fitness, turnover, drawdown), or manage Docker services
  for 24/7 automated mining. Also activate when editing any file under generation_one/ or
  generation_two/.
---

# WorldQuant Alpha Automation Skill

## What This Skill Covers

This skill helps you work with the `worldquant-miner` repository to achieve
**automated, continuous alpha discovery and submission** on WorldQuant Brain.

---

## Architecture at a Glance

```
WorldQuant Brain API  ←→  AlphaGenerator (Ollama LLM)
                               ↓
                         AlphaOrchestrator  (schedules, coordinates)
                               ↓
                    ┌──────────┴──────────┐
             Simulation              Submission
          (test via WQ API)    (improved_alpha_submitter.py)
                    └──────────┬──────────┘
                          Web Dashboard
                        (localhost:5000)
```

**Generation Two** adds on top of this:
- `ExpressionCompiler` — validates alpha syntax locally before sending to WQ
- `AlphaEvolutionEngine` — breeds better alphas using genetic algorithms
- `SelfOptimizer` — auto-tunes generation parameters every 100 runs
- `BacktestStorage` — stores all results in SQLite for analysis

---

## Key Files to Know

### generation_one/naive-ollama/
| File | Role |
|---|---|
| `alpha_generator_ollama.py` | Calls Ollama → generates alpha expression text |
| `alpha_orchestrator.py` | Master scheduler: triggers generation, mining, submission |
| `improved_alpha_submitter.py` | Reads `hopeful_alphas.json` → submits to WQ (once/day) |
| `web_dashboard.py` | Flask app — real-time status at localhost:5000 |
| `machine_lib.py` | Low-level WQ API wrapper (auth, simulate, fetch fields) |
| `docker-compose.gpu.yml` | Full stack with GPU + Ollama + Dashboard |

### generation_two/
| File | Role |
|---|---|
| `core/enhanced_template_generator_v3.py` | Main orchestrator class |
| `core/template_generator.py` | LLM-based alpha text generation |
| `core/simulator_tester.py` | Concurrent simulation submission |
| `core/template_validator.py` | Self-correcting AST validation |
| `core/expression_compiler.py` | 6-stage compiler pipeline |
| `evolution/alpha_evolution_engine.py` | Genetic crossover + mutation |
| `evolution/self_optimizer.py` | Adaptive parameter tuning |
| `gui/run_gui.py` | Entry point for desktop GUI |
| `storage/backtest_storage.py` | SQLite result storage |

---

## WorldQuant Brain API Reference

### Authentication
```python
import requests, json
from requests.auth import HTTPBasicAuth

sess = requests.Session()
with open('credential.txt') as f:
    email, password = json.load(f)
sess.auth = HTTPBasicAuth(email, password)
r = sess.post('https://api.worldquantbrain.com/authentication')
# Expect status 201
```

### Submit Simulation
```python
payload = {
    "type": "REGULAR",
    "settings": {
        "instrumentType": "EQUITY",
        "region": "USA",
        "universe": "TOP3000",
        "delay": 1,
        "decay": 0,
        "neutralization": "INDUSTRY",
        "truncation": 0.08,
        "pasteurization": "ON",
        "language": "FASTEXPR",
        "testPeriod": "P5Y0M0D"
    },
    "regular": "rank(ts_mean(close/delay(close,20), 5))"
}
r = sess.post('https://api.worldquantbrain.com/simulations', json=payload)
sim_id = r.json()['id']
```

### Poll Simulation Result
```python
import time
while True:
    r = sess.get(f'https://api.worldquantbrain.com/simulations/{sim_id}')
    data = r.json()
    status = data.get('status')
    if status in ('COMPLETE', 'ERROR', 'FAILED'):
        break
    time.sleep(10)

# Key metrics
sharpe   = data.get('is', 0)           # Information Ratio (Sharpe proxy)
fitness  = data.get('fitness', 0)
turnover = data.get('turnover', 0)
returns  = data.get('returns', 0)
```

### Submit Successful Alpha
```python
alpha_id = data.get('alpha')   # from simulation result
r = sess.post(f'https://api.worldquantbrain.com/alphas/{alpha_id}/submit')
```

### Fetch Your Alphas
```python
r = sess.get('https://api.worldquantbrain.com/users/self/alphas',
             params={'limit': 50, 'offset': 0})
```

---

## FASTEXPR Alpha Language

### Structure
```
# Optional variable assignments (semicolon-separated)
var1 = expression1;
var2 = expression2;
# Final line = the alpha signal
rank(var1 - var2)
```

### Common Operators
| Operator | Description |
|---|---|
| `ts_mean(x, n)` | Rolling mean over n days |
| `ts_rank(x, n)` | Rolling rank over n days |
| `ts_std_dev(x, n)` | Rolling std dev |
| `delay(x, n)` | Lag by n days |
| `delta(x, n)` | x - delay(x, n) |
| `rank(x)` | Cross-sectional rank |
| `zscore(x)` | Cross-sectional z-score |
| `neutralize(x, g)` | Neutralize by group g |
| `correlation(x, y, n)` | Rolling correlation |
| `min(x, y)` / `max(x, y)` | Element-wise min/max |

### Common Data Fields
| Field | Meaning |
|---|---|
| `close` | Adjusted close price |
| `open`, `high`, `low` | OHLC prices |
| `volume` | Daily volume |
| `returns` | Daily returns |
| `cap` | Market cap |
| `assets`, `debt_lt` | Balance sheet items |
| `cashflow_op` | Operating cash flow |

---

## Simulation Quality Thresholds (WQ Guidelines)
| Metric | Acceptable Range |
|---|---|
| Sharpe (IS) | > 1.0 (ideally > 1.5) |
| Fitness | > 1.0 |
| Turnover | < 0.7 (ideally 0.05 – 0.7) |
| Returns | > 0 |
| Drawdown | As low as possible |

---

## Starting the Full Automation Stack

### Docker (Recommended)
```bash
cd generation_one/naive-ollama

# GPU stack
docker-compose -f docker-compose.gpu.yml up -d

# CPU-only stack
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose -f docker-compose.gpu.yml down
```

### Without Docker (Manual)
```bash
# Terminal 1: Start Ollama
ollama serve

# Terminal 2: Start orchestrator
cd generation_one/naive-ollama
python alpha_orchestrator.py

# Terminal 3: Start dashboard
python web_dashboard.py

# Terminal 4 (optional): Submit alphas
python improved_alpha_submitter.py
```

### Generation Two GUI
```bash
cd /path/to/worldquant-miner
pip install -r generation_two/requirements.txt
ollama pull qwen2.5-coder:1.5b
ollama serve &
python generation_two/gui/run_gui.py generation_one/naive-ollama/credential.txt
```

---

## Git Fork Sync Commands

```bash
# Save your changes to YOUR fork
git add .
git commit -m "your message"
git push origin master

# Pull updates FROM the original author
git fetch upstream
git merge upstream/master
git push origin master   # Push merged updates to your fork

# See what the original author changed
git log upstream/master --oneline -10
```

---

## Common Troubleshooting

| Problem | Fix |
|---|---|
| `Authentication failed` | Check `credential.txt` format: `["email", "pass"]` |
| `Ollama connection failed` | Run `ollama serve` or check Docker container is up |
| `SIMULATION_LIMIT_EXCEEDED` | You hit 5,000/day cap — wait until next day |
| `Unknown operator` in alpha | Check `generation_two/constants/operatorRAW.json` for valid ops |
| Template generation hangs | Ollama model not downloaded — run `ollama pull <model>` |
| Docker GPU error | Install `nvidia-container-toolkit` and restart Docker daemon |

---

## How to Add a New Alpha Strategy

1. **Write the expression** in FASTEXPR syntax
2. **Validate locally** using `generation_two`:
   ```python
   from generation_two.core.expression_compiler import ExpressionCompiler
   # ... compile and check result.success
   ```
3. **Test via simulation** — check Sharpe > 1.0, Fitness > 1.0
4. **If good** — `improved_alpha_submitter.py` will pick it up from `hopeful_alphas.json`
5. **Commit your alpha ideas** to `generation_one/naive-ollama/mined_expressions.json`

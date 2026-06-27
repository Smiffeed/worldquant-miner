# WorldQuant Miner — Automation & Side Hustle Roadmap

<AI_CONTEXT>
**Target System:** WorldQuant Brain (platform.worldquantbrain.com)
**Agent Objective:** Transform this repository into a fully autonomous, rate-limit-aware alpha generation pipeline. The agent must prioritize API efficiency, avoid 429/401 loops, and integrate external knowledge (Graph RAG) before running brute-force tests.
**Current State:** API stabilization complete. Graph RAG ingestion complete. Ready for Phase 1 (Efficiency).
</AI_CONTEXT>

## Strategic Goals
1. **Prevent Rate Limits & Wasted API Calls:** Ensure we never hit the 5,000/day simulation cap by filtering out bad or duplicate alphas locally *before* hitting the WorldQuant Brain API.
2. **Increase Alpha Quality (RAG + Knowledge Graph):** Stop relying on "naive" random generation. Ground the AI's logic in actual quantitative finance theory extracted via `graphifyy`.
3. **Upgrade LLM Intelligence:** Integrate the OpenRouter API to use smarter, free frontier models alongside local Ollama instances.

---

## 📋 To-Do List

### Phase 1: Efficiency & Local Validation
- [ ] **Local Alpha Cache (SQLite):** Implement a local database to hash and store every alpha string ever generated. Before sending an alpha to WQ for simulation, check if it already exists in the cache. This prevents duplicate API calls.
- [ ] **Syntax Validator Integration:** Port the `ExpressionCompiler` from the `generation_two` folder into the `consultant-naive-ollama` pipeline. This will validate FASTEXPR math and syntax locally, discarding malformed alphas for free.
- [ ] **Simulation Pacing:** Ensure the orchestrator paces out submissions evenly (e.g., 3-4 per minute) over a 24-hour period to stay under the 5,000/day cap safely and avoid `BIOMETRICS_THROTTLED`.

### Phase 2: OpenRouter Integration
- [ ] **OpenRouter Client:** Update `alpha_generator_ollama.py` to support the standard OpenAI Python client format.
- [ ] **Environment Configuration:** Add an `OPENROUTER_API_KEY` to the `docker-compose.gpu.yml` environment.
- [ ] **Free-Tier Optimization:** Configure the generator to exclusively target high-quality **free** OpenRouter models (e.g., `openrouter/owl-alpha` or other top-tier free reasoning models) to keep operational costs at absolute zero while massively upgrading reasoning logic.
- [ ] **Multi-Agent Setup (Optional):** Use OpenRouter for the high-level quantitative theory (the "Quant Researcher"), and use the local free Ollama GPU model for brute-force formatting and variations (the "Coder").

### Phase 3: Graph RAG (Knowledge Graph)
- [x] **Knowledge Base Preparation:** Created `knowledge_base` folder and successfully downloaded EPUBs/PDFs of "101 Formulaic Alphas", "151 Trading Strategies", and "Advances in Financial Machine Learning". Installed `graphifyy` tool locally in virtual environment.
- [x] **Ingestion Pipeline (Graphify):** Run the script/tool to parse the PDFs/EPUBs into the graph structure. (Completed via OpenRouter `owl-alpha` semantic extraction).
- [ ] **Knowledge Graph Construction:** Extract financial anomalies, statistical arbitrage concepts, and market inefficiencies, mapping them into a graph database (Neo4j) or Vector DB (ChromaDB).
- [ ] **Contextual Alpha Generation:** Before calling OpenRouter, the orchestrator queries the graph for a specific strategy concept. It then prompts the LLM: *"Based on this mean-reversion theory from the knowledge graph, translate it into a WorldQuant FASTEXPR using the provided data fields."*

### Phase 4: Non-AI Optimization Methods
- [ ] **Grid Search / Parameter Sweeping:** When a basic formula structure works (e.g., `rank(ts_mean(close, X) / ts_mean(close, Y))`), bypass the AI entirely. Run a simple Python loop that brute-forces every combination of X and Y (e.g., from 5 to 100 days) to mathematically find the peak Sharpe ratio.
- [ ] **Genetic Algorithms:** Activate the `evolution` engine from `generation_two`. This uses algorithmic "breeding" to take two mediocre alphas, swap their operators (crossover), and randomly change numbers (mutation) to evolve them without any LLM inference.
- [ ] **Alpha Ensembling (Blending):** Find 5 mediocre alphas (Sharpe ~1.0) that have very low correlation to each other. Combine them mathematically: `(alpha1 + alpha2 + alpha3)`. Because the noise cancels out, the resulting blended alpha often hits a Sharpe of 1.5+.

---

## 📚 Best Knowledge Sources for the Graph
If you want to feed the AI (or yourself) the highest quality financial logic, source documents from:
1. **Value and Momentum Everywhere** (Asness, Moskowitz, Pedersen, 2013)
2. **Returns to Buying Winners and Selling Losers** (Jegadeesh & Titman, 1993)
3. **Short-Term Return Reversal: A Momentum Oscillator** (Various)
4. **The Volatility Effect in Stocks** (Blitz & van Vliet, 2007)
5. **Idiosyncratic Volatility and the Cross-Section of Expected Returns** (Ang, Hodrick, Xing, Zhang, 2006)
6. **Expected Skewness and Momentum** (Bali, Cakici, Whitelaw, 2011)
7. **Order Imbalance and Stock Returns** (Chordia, Roll, Subrahmanyam, 2002)
8. **Liquidity as an Investment Style** (Ibbotson, Chen, Kim, Hu, 2013)
9. **The Other Side of Value: The Gross Profitability Premium** (Novy-Marx, 2013)
10. **Characteristics are Covariances** (Kelly, Pruitt, Su, 2019)
11. **"101 Formulaic Alphas" & "151 Trading Strategies"** (Zura Kakushadze)

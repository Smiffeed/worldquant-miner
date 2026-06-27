# WorldQuant Miner — Workflow Journal

This file tracks the problems faced and solutions applied while working in this repository. 
As per the rules in `.agents/AGENTS.md`, any significant roadblock or fix should be documented here.

## 2026-06-27

### Problem 1: Determining which setup to use for automation
- **Context:** The repository has multiple folders (`generation_one/naive-ollama`, `generation_one/consultant-naive-ollama`, `generation_two`, etc.). It was unclear which one is best for hands-off 24/7 automation with a Consultant tier account.
- **Solution:** Identified that `generation_one/consultant-naive-ollama` is the exact right fit because it contains extra operators/fields specifically for the Consultant tier, runs entirely inside a Docker stack, and has a web dashboard, whereas `generation_two` is a native desktop app better suited for active research/breeding of alphas.

### Problem 2: Missing dependencies during Docker image build
- **Context:** While building the `consultant-naive-ollama` GPU Docker image, the build failed at the `curl -fsSL https://ollama.ai/install.sh | sh` step with the error: `This version requires zstd for extraction.`
- **Solution:** Modified the `Dockerfile` to include `zstd` and `ca-certificates` in the `apt-get install` list. Also upgraded the base CUDA image from `11.8.0` to `12.4.1` because the host has an NVIDIA RTX 5070 which requires a newer CUDA runtime.

### Problem 3: Docker could not start the container with NVIDIA runtime
- **Context:** The Docker image built successfully, but the container failed to start with the error: `unknown or invalid runtime name: nvidia`.
- **Solution:** The host OS (CachyOS / Arch Linux) did not have the NVIDIA Container Toolkit installed. We ran the manual installation commands:
  ```bash
  sudo pacman -S --noconfirm nvidia-container-toolkit
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
  ```
  After this, the `nvidia` runtime was correctly recognized by Docker.

### Problem 4: Port conflict when starting Docker Compose
- **Context:** When running `docker-compose up -d`, the `naive-ollma-gpu` container failed to bind to port `11434` because `address already in use`.
- **Solution:** Discovered that a local `ollama` systemd service was already running on the host machine and occupying port 11434. The user stopped the local service (`sudo systemctl stop ollama`), which freed the port and allowed the Docker container to start successfully.

<PROBLEM_LOG id="5">
### Problem 5: Docker crash loop due to API rate limits (BIOMETRICS_THROTTLED)
- **Context:** The WorldQuant Brain API returned a `429 Too Many Requests` status code with the payload `{"detail":"BIOMETRICS_THROTTLED"}` (an anti-bot measure). Because the Python scripts (`machine_lib.py`, `alpha_orchestrator.py`, `improved_alpha_submitter.py`) were set to throw an Exception on any status code other than `201`, the scripts crashed. Docker Compose's `restart: unless-stopped` policy immediately restarted them, causing an endless loop of rapid API pings that resulted in a hard IP block and an eventual website-wide login limit.
- **Solution:** Modified the authentication logic in `machine_lib.py`, `alpha_orchestrator.py`, and `improved_alpha_submitter.py`. The scripts now enter a `while True` loop and gracefully `time.sleep(300)` (5 minutes) whenever a 429 error or `BIOMETRICS_THROTTLED` is encountered, rather than throwing an Exception. This prevents the Docker containers from crashing and gives the WorldQuant servers enough silence to lift the IP block. The containers have been taken `down` to allow the total login limit to reset overnight.
</PROBLEM_LOG>

<PROBLEM_LOG id="6">
### Problem 6: Persona (Captcha) Verification Link not supported in Docker
- **Context:** If the WorldQuant API returns a `401 Unauthorized` with the `WWW-Authenticate: persona` header, it means the API demands the user click a verification link to solve a captcha/prove they are human. The old scripts did not handle this and crashed.
- **Solution:** Reviewed the user's old `~/Workspaces/worldquant` repo (`ace_lib.py`) and ported its Persona-handling logic to the `consultant-naive-ollama` scripts. Now, if the API returns a 401 Persona error, the script prints the verification URL to the Docker logs and pauses for 60 seconds at a time. The user clicks the link in their browser to verify, and the script's internal loop successfully claims the session via a POST request once complete.
</PROBLEM_LOG>

<PROBLEM_LOG id="7">
### Problem 7: Preparing for Graph RAG
- **Context:** The AI needs advanced quantitative finance knowledge to generate better alphas without wasting API limits. The user downloaded research papers and books but placed them in a LaTeX project folder (`paper/sources/`). Later, Graphify failed because the OpenRouter `owl-alpha` model does not support computer vision (images), and it attempted to parse 580 LaTeX images.
- **Solution:** Created a new, dedicated `knowledge_base` folder at the root of the repository. Moved `101 Formulaic Alphas.pdf`, `151 Trading Strategies.pdf`, and `Advances in Financial Machine Learning.epub` into the new folder. The user installed `graphifyy` into a local virtual environment. Created a `.graphifyignore` file to completely ignore the `paper/` directory and all image formats (`*.png`, `*.jpg`, etc.). The Graphify semantic extraction then completed successfully across the knowledge base using OpenRouter.
</PROBLEM_LOG>

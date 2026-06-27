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

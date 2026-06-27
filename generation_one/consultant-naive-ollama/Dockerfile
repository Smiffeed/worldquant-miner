FROM nvidia/cuda:12.4.1-base-ubuntu22.04

# Set environment variables for CUDA
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Set working directory
WORKDIR /app

# Install system dependencies including Python, CUDA tools, and zstd (required by Ollama installer)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-pip \
    curl \
    wget \
    git \
    build-essential \
    zstd \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Ollama
RUN curl -fsSL https://ollama.ai/install.sh | sh

# Copy application code
COPY . .

# Copy the start scripts and make them executable
COPY start.sh /app/start.sh
COPY start_ollama.sh /app/start_ollama.sh
RUN chmod +x /app/start.sh /app/start_ollama.sh

# Expose Ollama port
EXPOSE 11434

# Set the entrypoint (will be overridden by docker-compose)
ENTRYPOINT ["/app/start.sh"]

── Stage: Base image ──────────────────────────────────────────────────────────
# python:3.11-slim is lightweight (~45MB vs ~900MB for the full image)
# Fewer packages = smaller attack surface = better Docker Scout results
FROM python:3.11-slim

# ── Working directory inside the container ─────────────────────────────────────
WORKDIR /app

# ── Install dependencies ───────────────────────────────────────────────────────
# Copy requirements FIRST — Docker caches this layer.
# If only app.py changes later, Docker skips re-installing packages (faster builds).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Copy application source code ───────────────────────────────────────────────
COPY app.py .

# ── Expose port ────────────────────────────────────────────────────────────────
# Documents that the container listens on port 5000 (Flask default)
EXPOSE 5000

# ── Start the application ──────────────────────────────────────────────────────
CMD ["python", "app.py"]

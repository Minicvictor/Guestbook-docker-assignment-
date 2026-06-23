# 📖 Containerized Guestbook Application

**Student:** Egwu Chidiebere Agha
**GitHub:** [@minicvictor](https://github.com/minicvictor)
**Email:** vickilance50@gmail.com
**LinkedIn:** [chidiebere-egwu](https://linkedin.com/in/chidiebere-egwu)

-----

## Project Overview

A multi-container **Guestbook web application** where users submit messages through a **Python Flask** frontend, which stores them in a **Redis** database. The entire stack runs via Docker Compose with a custom network for container communication and a named volume for data persistence.

**Technologies used:**

- Python 3.11 + Flask (web frontend)
- Redis 7 (in-memory data store)
- Docker + Docker Compose (containerization & orchestration)
- Docker Scout (vulnerability scanning)
- Docker Hub (image registry)

-----

## Architecture Diagram

```
                   ┌─────────────────────────────────────────┐
                   │           Docker Host Machine           │
                   │                                         │
  Browser ────────►│  localhost:5000                         │
                   │       │                                 │
                   │       ▼                                 │
                   │  ┌─────────────────┐  guestbook_network │
                   │  │   web container │◄──────────────┐   │
                   │  │  Flask : 5000   │               │   │
                   │  └────────┬────────┘               │   │
                   │           │  host='redis' (DNS)    │   │
                   │           ▼                        │   │
                   │  ┌─────────────────┐               │   │
                   │  │ redis container │───────────────┘   │
                   │  │  Redis : 6379   │                   │
                   │  └────────┬────────┘                   │
                   │           │                            │
                   │  ┌────────▼────────┐                   │
                   │  │   redis_data    │  ← Named Volume   │
                   │  │    (volume)     │                   │
                   │  └─────────────────┘                   │
                   └─────────────────────────────────────────┘
```

**Flow:** User submits a message → Flask (`web`) receives it → Flask talks to Redis using hostname `redis` over `guestbook_network` → Redis stores it in `redis_data` volume → Flask reads back all messages on page load.

-----

## Project Structure

```
guestbook-app/
├── app.py                 # Flask web application (provided by instructor)
├── requirements.txt       # Python dependencies
├── Dockerfile             # Container build instructions for Flask app
├── docker-compose.yml     # Multi-container orchestration config
└── README.md              # This file
```

-----

## Build Steps

### 1. Clone the repository

```bash
git clone https://github.com/minicvictor/guestbook-app.git
cd guestbook-app
```

### 2. Build the Docker image manually (optional — Compose does this automatically)

```bash
docker build -t guestbook .
```

### 3. Verify the image was created

```bash
docker images
```

-----

## Run Steps

### Start all services with Docker Compose

```bash
docker compose up -d
```

The `-d` flag runs containers in the background (detached mode).

### Check running containers

```bash
docker compose ps
```

Expected output:

```
NAME               IMAGE        STATUS    PORTS
guestbook_web      guestbook    Up        0.0.0.0:5000->5000/tcp
guestbook_redis    redis:7-alpine  Up     6379/tcp
```

### Access the application

Open your browser at: **http://localhost:5000**

### View container logs

```bash
docker compose logs web
docker compose logs redis
```

### Stop all services (data is preserved)

```bash
docker compose down
```

### Stop and remove everything including volume data

```bash
docker compose down -v
```

-----

## Docker Compose Explanation

The `docker-compose.yml` defines two services that work together:

|Setting                      |Value                      |Why                                         |
|-----------------------------|---------------------------|--------------------------------------------|
|`build: .`                   |Build from local Dockerfile|Creates the Flask image automatically       |
|`ports: "5000:5000"`         |Host → Container           |Exposes the app on your machine             |
|`depends_on: redis`          |Start order                |Ensures Redis is running before Flask starts|
|`image: redis:7-alpine`      |Official Redis image       |Lightweight, production-grade Redis         |
|`volumes: redis_data:/data`  |Named volume               |Persists Redis data across restarts         |
|`networks: guestbook_network`|Both services              |Allows containers to find each other by name|

The `depends_on` field controls **startup order** — Docker starts the `redis` container first, then starts `web`. This prevents Flask from crashing on startup because Redis isn’t ready yet.

-----

## Docker Network Explanation

A custom **bridge network** called `guestbook_network` connects both containers:

```yaml
networks:
  guestbook_network:
    driver: bridge
```

**Why a custom network matters:**

Within a user-defined bridge network, Docker provides automatic **DNS resolution by service name**. This means the Flask app can connect to Redis using `host='redis'` (the service name in `docker-compose.yml`) instead of a hardcoded IP address.

```python
# From app.py — this works because of the custom network
r = redis.Redis(host='redis', port=6379, decode_responses=True)
```

Without this network, containers would be isolated and could not communicate.

**Verify network connectivity:**

```bash
# Inspect the network
docker network ls
docker network inspect guestbook_app_guestbook_network

# Test that web can reach redis by name
docker exec guestbook_web ping redis
```

-----

## Docker Volume Explanation

Redis is configured with a **named volume** so messages persist even after containers stop:

```yaml
volumes:
  redis_data:          # Declared here at the bottom

services:
  redis:
    volumes:
      - redis_data:/data   # Mounted here in the redis service
```

Redis saves its data to `/data` inside its container. By mapping that path to the named volume `redis_data`, Docker preserves the data on the host even when the container is deleted.

**Prove persistence works:**

```bash
# Step 1: Start the app and submit a message at http://localhost:5000

# Step 2: Bring containers down
docker compose down

# Step 3: Confirm containers are gone
docker compose ps

# Step 4: Start them again
docker compose up -d

# Step 5: Visit http://localhost:5000 — your messages are still there ✅
```

**Inspect the volume:**

```bash
docker volume ls
docker volume inspect guestbook_app_redis_data
```

-----

## Docker Scout Results

Docker Scout scans your image for known CVEs (Common Vulnerabilities and Exposures).

### Run the scan

```bash
# Quick summary
docker scout quickview guest_book_app-web

# Detailed CVE list
docker scout cves guest_book_app-web
```

### Sample Scout Output


## Overview

                   │                Analyzed Image                 
───────────────────┼───────────────────────────────────────────────
 Target            │  guest_book_app-web:latest                    
   digest          │  14920340973a                                 
   platform        │ linux/amd64                                   
   provenance      │ https://github.com/highbee2810/Guest_book_app 
                   │  0d00d9e34347d75eae6a4608f0af9f23545c2e3f     
   vulnerabilities │    1C     3H     7M    26L     2?             
   size            │ 53 MB                                         
   packages        │ 149                                           
                   │                                               
 Base image        │  python:3.11-slim                             
                   │  a01e48f10f90                                 


## Packages and Vulnerabilities

   1C     2H     2M     2L  perl 5.40.1-6
pkg:deb/debian/perl@5.40.1-6?os_distro=trixie&os_name=debian&os_version=13

39 vulnerabilities found in 12 packages
  CRITICAL     1  
  HIGH         3  
  MEDIUM       7  
  LOW          26 
  UNSPECIFIED  2  

```


### How vulnerabilities were minimized

- Used `python:3.11-slim` as the base image — significantly fewer packages than `python:3.11` full
- Used `--no-cache-dir` during `pip install` to avoid stale cached packages
- Pinned exact versions in `requirements.txt` for reproducibility

-----

## Docker Hub

### Tag and push the image

```bash
# Log in to Docker Hub
docker login

# Tag the locally built image
docker tag guestbook victorminic/guestbook-app:v1

# Push to Docker Hub
docker push victorminic/guestbook-app:v1
```

### Verify on Docker Hub

```bash
docker pull victorminic/guestbook-app:v1
```

### Docker Hub Image Link

🔗 <https://hub.docker.com/repository/docker/victorminic/guestbook-app/general>

-----

## Submission

|Item             |Link                                          |
|-----------------|----------------------------------------------|
|GitHub Repository|https://github.com/Minicvictor/Guestbook-docker-assignment |
|Docker Hub Image |https://hub.docker.com/repository/docker/victorminic/guestbook-app|

-----

## Submission Checklist

- [x] Forked / cloned the instructor’s repo
- [x] `Dockerfile` created for Flask app
- [x] `docker-compose.yml` created with both services
- [x] Custom Docker network configured (`guestbook_network`)
- [x] Named volume configured for Redis persistence (`redis_data`)
- [x] Volume persistence tested and confirmed (down → up → data intact)
- [x] Docker Scout vulnerability scan run and documented
- [x] Image tagged and pushed to Docker Hub (`minicvictor/guestbook:v1`)
- [x] `README.md` completed with all required sections
- [x] GitHub repository link ready
- [x] Docker Hub image link ready
- [x] Submission form filled out

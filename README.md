# BARQ Systems DevOps Assessment

This repository contains the implementation, investigation evidence, validation
scripts, failure testing, persistence testing, backup/restore procedures,
security review, engineering decisions, and CI configuration for the BARQ
Systems DevOps assessment.

## Current verified environment

The currently verified environment contains:

- NGINX as the only public entry point
- Flask application instances `app-01` and `app-02`
- PostgreSQL 16
- Redis 7.4 with AOF persistence
- Separate frontend and backend Docker networks
- Internal backend network
- PostgreSQL named-volume persistence
- Redis named-volume persistence
- Application readiness checks
- Container health checks
- Restart policies
- Resource limits
- Non-root application container
- Pinned container image digests
- No host ports for applications, PostgreSQL, or Redis

Current verified development endpoint:

    http://127.0.0.1:8080

The final assessment video will demonstrate the required three-instance
configuration on port 8090.

## Architecture

Current request flow:

    Client
      |
      v
    NGINX :80
      |
      +---- app-01:8080
      |
      +---- app-02:8080
                  |
                  +---- PostgreSQL :5432
                  |
                  +---- Redis :6379

Networks:

- frontend: NGINX and application containers
- backend: application containers, PostgreSQL, and Redis
- backend is an internal Docker network

PostgreSQL and Redis do not expose host ports.

See `docs/ARCHITECTURE.md` and the final `architecture.png` or
`architecture.pdf`.

## Repository structure

    app/                    Flask application
    database/               PostgreSQL initialization
    nginx/                  NGINX configuration
    logs/                   Original assessment logs
    tests/                  Application tests
    docs/                   Documentation and evidence
    assessment/             Assessment material
    assets/                 Assessment assets

    docker-compose.yml      Docker Compose configuration
    Dockerfile              Application image
    requirements.txt        Python dependencies

    validate.py             Environment validation
    failure_test.py         Backend failure/recovery test
    backup.sh               PostgreSQL backup
    restore.sh              PostgreSQL restore
    video_challenge.sh      Final live troubleshooting challenge

    log_analysis.md         Correlated log analysis
    troubleshooting.md      Investigation journal
    decisions.md            Engineering decisions
    security_review.md      Security review
    AI_USAGE.md             AI/tool usage disclosure

## Prerequisites

Install or have available:

- Ubuntu/Linux
- Docker Engine
- Docker Compose v2
- Git
- Python 3

Verify:

    git --version
    docker version
    docker compose version
    python3 --version

Docker commands may require `sudo` depending on local Docker permissions.

## Configuration

Create a local environment file:

    cp .env.example .env

Edit `.env` and set a local PostgreSQL password:

    nano .env

Example:

    PUBLIC_PORT=8080
    POSTGRES_PASSWORD=change-this-locally

Never commit `.env` or real credentials.

## Build

    sudo docker compose build

## Start

    sudo docker compose up -d

Check the services:

    sudo docker compose ps

Wait until all required health checks report healthy.

## Stop

Stop containers:

    sudo docker compose stop

Remove containers while preserving named volumes:

    sudo docker compose down

Do not use `docker compose down -v` during persistence testing because
that removes the PostgreSQL and Redis named volumes.

## HTTP endpoints

Required endpoints:

    /
    /health
    /ready
    /instance
    /records
    /counter

Test them:

    curl -i http://127.0.0.1:8080/
    curl -i http://127.0.0.1:8080/health
    curl -i http://127.0.0.1:8080/ready
    curl -i http://127.0.0.1:8080/instance
    curl -i http://127.0.0.1:8080/records
    curl -i http://127.0.0.1:8080/counter

Repeated `/instance` requests demonstrate load balancing:

    for i in {1..10}; do
        curl -s http://127.0.0.1:8080/instance
        echo
    done

## Automated validation

Run:

    ./validate.py

The validator checks:

- Container health
- Public NGINX access
- Required HTTP endpoints
- Application readiness
- PostgreSQL readiness
- Redis readiness
- Load balancing
- Host port exposure
- Network isolation
- Internal backend network
- PostgreSQL records
- Redis counter

The verified environment currently ends with:

    === VALIDATION PASSED ===
    All required checks passed.

## Failure and recovery test

Run:

    ./failure_test.py

The test:

1. Measures baseline traffic.
2. Stops `app-01`.
3. Sends traffic through NGINX.
4. Confirms `app-02` continues serving requests.
5. Restores `app-01`.
6. Waits for it to become healthy.
7. Confirms traffic returns to both instances.

The verified run achieved:

    Baseline:       20/20 successful
    During failure: 20/20 successful
    Errors:          0/20
    After recovery: 20/20 successful

## PostgreSQL persistence

Create a record:

    curl -s -X POST http://127.0.0.1:8080/records \
      -H 'Content-Type: application/json' \
      -d '{"name":"CONTAINER_RECREATE_TEST","description":"Prove PostgreSQL data survives container recreation"}'

Verify it:

    curl -s http://127.0.0.1:8080/records

PostgreSQL uses the named volume `postgres-data`.

The persistence test recreates the PostgreSQL container while retaining the
volume and verifies that the record survives.

## PostgreSQL backup

Run:

    ./backup.sh

Backups are written to:

    backups/

Generated backup files are ignored by Git.

## PostgreSQL restore

Usage:

    ./restore.sh backups/<backup-file>.sql

The restore script restores a compatible PostgreSQL dump into the target
database. A clean full restore may require recreating the target database
first.

## Log investigation

The original logs are preserved under:

    logs/

The investigation is documented in:

    log_analysis.md

The analysis covers:

- Log validity
- Status-code counts
- Duplicate request IDs
- NGINX retry behavior
- Dependency failures
- Upstream failures
- Timeout incidents
- Latency
- Cross-log correlation
- Timeline
- Root-cause conclusions

The original log files were not modified.

## Troubleshooting journal

Investigation steps, hypotheses, commands, failed attempts, fixes, and retests
are documented in:

    troubleshooting.md

## Engineering decisions

Engineering decisions, assumptions, alternatives, trade-offs, and limitations
are documented in:

    decisions.md

## Security review

The security review covers:

- Secrets
- Host ports
- Container users
- Image pinning
- Docker networks
- Persistence and backups
- Logging
- Availability
- Resource limits

See:

    security_review.md

Implemented fixes are separated from future recommendations.

## CI

The GitHub Actions workflow is:

    .github/workflows/ci.yml

The pipeline is intended to run on pushes and pull requests and performs:

1. Checkout
2. Python syntax checks
3. Docker Compose configuration validation
4. Image build
5. Environment startup
6. Readiness wait
7. Full validation

The final successful CI run will be recorded in the evidence index.

## Final video challenge

The assessment requires a live troubleshooting demonstration using:

    ./video_challenge.sh

The challenge must be run for the first time in the video working copy.

The final demonstration will:

- Diagnose and fix the injected runtime problem
- Avoid `docker compose down`
- Change the public port from 8080 to 8090
- Add a third application instance
- Demonstrate all three instances
- Re-run validation
- Show Git status and diffs
- Show commit hashes
- Push the final commits

## Evidence

Assessment evidence is tracked in:

    docs/EVIDENCE_INDEX.md

The evidence index maps requirements to repository files, commands,
commits, validation evidence, and final video timestamps.

## Cleanup

To remove containers while preserving data:

    sudo docker compose down

To intentionally delete persistent data:

    sudo docker compose down -v

The second command is destructive to the PostgreSQL and Redis volumes.

## Verification rule

Only claim a fix when it has been reproduced and verified.

Commands, failed attempts, test results, and conclusions used as assessment
evidence are documented in the investigation and evidence files.


## Assessment Questions

### 1. What failed first? What proved the cause? Which failed attempt taught you something?

The first major runtime failure was an application readiness problem caused by missing database and Redis connection configuration. The application could not correctly report dependency readiness until `DATABASE_URL` and `REDIS_URL` were supplied.

A later NGINX failure produced HTTP 502 responses. Investigation showed that NGINX was attempting to connect to the application upstreams using the wrong port. The Flask applications listen on port `8080` inside the containers, so configuring NGINX to use another port caused upstream connection failures.

The failed NGINX reload attempt was particularly useful because it produced an upstream resolution error when an application container was unavailable. This demonstrated that NGINX configuration reloads and runtime backend availability are separate concerns and that the backend must be healthy and resolvable before applying the configuration.

The fixes were verified by:

* checking container health;
* testing application `/health` and `/ready`;
* testing application connectivity from NGINX;
* testing NGINX configuration with `nginx -t`;
* sending requests through the public endpoint;
* repeating the tests after recovery.

Detailed investigation evidence is documented in `troubleshooting.md`.

### 2. What patterns did the logs reveal? How did you avoid double-counting requests?

The logs showed several distinct failure patterns:

* application/upstream connectivity failures;
* Redis-related failures;
* PostgreSQL authentication failures;
* NGINX upstream timeouts;
* HTTP 502, 503 and 504 responses;
* successful upstream retries;
* a small number of malformed log records;
* duplicate request IDs.

The access log contained 726 lines. After removing the malformed entry and accounting for duplicate request IDs, there were 720 distinct valid requests.

Requests were therefore not counted simply by counting every log line. Request IDs were used to identify duplicate records, while malformed entries were excluded from request-level calculations. NGINX retry behavior was also correlated with upstream/application logs so that one client request was not incorrectly interpreted as multiple independent requests.

The detailed counts, commands, correlations and timeline are documented in `log_analysis.md`.

### 3. How do requests flow? Why these ports, networks and readiness checks?

The request flow is:

```text
Client
   |
   v
NGINX :80
   |
   +---- app-01:8080
   |
   +---- app-02:8080
   |
   +---- app-03:8080
             |
             +---- PostgreSQL :5432
             |
             +---- Redis :6379
```

Only NGINX publishes a host port. The final assessment configuration exposes NGINX through host port `8090`, which maps to NGINX port `80`.

The Flask applications listen on container port `8080`. PostgreSQL uses `5432` and Redis uses `6379`, but these services do not publish host ports.

The `frontend` network connects NGINX to the application containers. The `backend` network connects the application containers to PostgreSQL and Redis. The backend network is internal, preventing direct external access.

Docker service names such as `app-01`, `postgres` and `redis` are used instead of hard-coded container IP addresses.

Health checks determine whether individual containers are functioning. Application readiness checks additionally verify that required dependencies are available before the application is considered ready.

### 4. Why these timeouts, retries, restart settings and resource limits?

NGINX uses short connection and read timeouts so a failed backend does not block requests indefinitely.

NGINX is configured to retry suitable upstream failures such as connection errors, timeouts and selected `502`, `503` and `504` responses. This allows traffic to continue when another healthy application instance is available.

Containers use:

```text
restart: unless-stopped
```

so unexpected container failures can be recovered automatically while still allowing intentional administrative stops.

Resource limits prevent one container from consuming unlimited CPU or memory. The application containers are limited to `0.50` CPU and `256M` memory, while PostgreSQL and Redis have limits appropriate to their roles.

These values are engineering choices for the assessment environment rather than production capacity guarantees. Production values should be based on measured workload, resource usage and service-level objectives.

### 5. When should validation fail? What does green CI prove, or not prove?

Validation should fail whenever a required architectural, availability, networking, persistence or HTTP requirement is not satisfied.

Examples include:

* an unhealthy required container;
* an inaccessible public endpoint;
* failed application readiness;
* missing PostgreSQL or Redis connectivity;
* incorrect host-port exposure;
* incorrect network configuration;
* failure of load balancing;
* failure of persistence checks;
* incorrect application instance behavior.

The validator returns a non-zero exit status when required checks fail, allowing CI to fail automatically.

Green CI proves that the automated checks passed in the CI environment at that point in time. It does **not** prove that the system is production-ready, immune to failures, secure against every attack, or equivalent to the developer's environment.

CI is therefore evidence of repeatable automated checks, not proof of absence of all possible defects.

### 6. Which single points of failure remain? How would you fix them in production?

The current architecture still contains several potential single points of failure.

**NGINX:** There is one NGINX container and therefore one frontend entry point.

Production improvement:

* deploy multiple NGINX/load-balancer instances;
* place them behind a highly available load balancer;
* use health-aware routing and automatic failover.

**PostgreSQL:** There is one PostgreSQL instance.

Production improvement:

* use PostgreSQL replication and automated failover;
* maintain tested backups;
* use monitoring and recovery procedures.

**Redis:** There is currently one Redis instance.

Production improvement:

* use Redis replication/sentinel or a managed highly available Redis service;
* monitor persistence and recovery.

**Host/VM:** The complete Compose deployment depends on the host running the Docker engine.

Production improvement:

* deploy across multiple hosts or an orchestrated platform.

The assessment intentionally uses a compact Docker Compose architecture, so these limitations are documented rather than hidden.

### 7. What would you improve? How did you verify AI-assisted work?

Potential improvements include:

* highly available NGINX/load balancing;
* PostgreSQL replication and automated failover;
* highly available Redis;
* centralized logging and monitoring;
* metrics and alerting;
* automated vulnerability scanning;
* stronger secret management;
* automated backup verification and restore drills;
* deployment across multiple hosts;
* more comprehensive integration and failure testing.

AI assistance was used during development for explanation, troubleshooting guidance, documentation drafting and review.

AI-generated suggestions were not treated as proof of correctness. They were verified by inspecting the actual repository, running Docker Compose validation, building the images, checking container health, testing HTTP endpoints, testing network connectivity, running validation and failure/recovery tests, inspecting logs, and reviewing Git diffs and history.

The detailed disclosure of AI-assisted work is provided in `AI_USAGE.md`.

---

## Final verification principle

Assessment claims are supported by reproducible commands and recorded evidence rather than assumptions.

The repository separates:

* historical troubleshooting evidence;
* log analysis;
* engineering decisions;
* security review;
* automated validation;
* failure/recovery testing;
* CI evidence;
* final video evidence.

Only results that were actually reproduced and verified should be presented as successful.


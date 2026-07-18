# Makefile — standard entry point. Run `make help` to list targets.
.DEFAULT_GOAL := help
.PHONY: help doctor setup dev test db-seed down logs lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[33m%-12s\033[0m %s\n", $$1, $$2}'

doctor: ## Preflight: verify Docker is ready and required host ports are free
	@command -v docker >/dev/null 2>&1 && echo "✓ docker installed" || { echo "✗ docker missing — https://docs.docker.com/get-docker/"; exit 1; }
	@docker compose version >/dev/null 2>&1 && echo "✓ docker compose v2" || { echo "✗ docker compose v2 not found"; exit 1; }
	@docker info >/dev/null 2>&1 && echo "✓ docker daemon running" || { echo "✗ docker daemon not running — start Docker Desktop"; exit 1; }
	@for p in 3000 5432 6379; do \
		if command -v lsof >/dev/null 2>&1; then \
			lsof -iTCP:$$p -sTCP:LISTEN >/dev/null 2>&1 && echo "✗ port $$p is in use" || echo "✓ port $$p free"; \
		else echo "? port $$p (install lsof to check)"; fi; \
	done

setup: doctor ## Preflight, then install toolchain + dependencies and build images
	asdf install || true
	bundle install
	docker compose build

dev: ## Start the full stack (app + services) with hot reload
	docker compose up

db-seed: ## Re-run seed SQL against the database
	docker compose exec -T postgres psql -U postgres -d app < docker/init.sql

test: ## Run the test suite inside the app container
	docker compose run --rm app bundle exec rspec

lint: ## Run linter / formatter checks
	rubocop .

logs: ## Tail logs for all services
	docker compose logs -f

down: ## Stop and remove containers (keeps named volumes)
	docker compose down

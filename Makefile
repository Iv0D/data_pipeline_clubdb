# Club Analytics Pipeline - Makefile

.PHONY: help setup start stop test clean logs

# Default target
help:
	@echo "Club Analytics Pipeline - Available Commands:"
	@echo "  setup     - Initial setup and dependency installation"
	@echo "  start     - Start all services with Docker Compose"
	@echo "  stop      - Stop all services"
	@echo "  test      - Run all tests (pytest, dbt, soda)"
	@echo "  clean     - Clean up containers and volumes"
	@echo "  logs      - View service logs"
	@echo "  dbt-run   - Run dbt models"
	@echo "  dbt-test  - Run dbt tests"
	@echo "  streamlit - Start Streamlit dashboard"

# Setup
setup:
	@echo "Setting up Club Analytics Pipeline..."
	pip install -r requirements.txt
	docker-compose pull
	@echo "Setup complete!"

# Start services
start:
	@echo "Starting Club Analytics services..."
	docker-compose up -d
	@echo "Waiting for services to initialize..."
	sleep 30
	@echo "Services started! Access Airflow at http://localhost:8080"

# Stop services
stop:
	@echo "Stopping services..."
	docker-compose down

# Run tests
test:
	@echo "Running Python tests..."
	pytest tests/ -v
	@echo "Running dbt tests..."
	cd dbt && dbt test --profiles-dir .
	@echo "Running Soda data quality checks..."
	soda scan -d postgres_local -c soda/configuration.yml tables/

# Clean up
clean:
	@echo "Cleaning up containers and volumes..."
	docker-compose down -v
	docker system prune -f

# View logs
logs:
	docker-compose logs -f

# dbt commands
dbt-run:
	cd dbt && dbt run --profiles-dir .

dbt-test:
	cd dbt && dbt test --profiles-dir .

dbt-docs:
	cd dbt && dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir .

# Data ingestion
ingest:
	python scripts/data_ingestion.py

# Streamlit dashboard
streamlit:
	streamlit run streamlit_app.py

# Development
dev-setup:
	@echo "Setting up development environment..."
	pip install -r requirements.txt
	pip install black flake8 isort mypy pytest-cov
	@echo "Development setup complete!"

# Format code
format:
	black scripts/ tests/ streamlit_app.py
	isort scripts/ tests/ streamlit_app.py

# Lint code
lint:
	flake8 scripts/ tests/ streamlit_app.py
	mypy scripts/ tests/ streamlit_app.py --ignore-missing-imports

# Full pipeline test
pipeline-test:
	@echo "Running full pipeline test..."
	make start
	sleep 60
	make ingest
	make dbt-run
	make dbt-test
	make test
	@echo "Pipeline test complete!"

# Production deployment
deploy:
	@echo "Deploying to production..."
	docker-compose -f docker-compose.prod.yml up -d
	@echo "Production deployment complete!"



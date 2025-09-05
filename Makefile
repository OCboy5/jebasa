.PHONY: help install install-dev test lint format type-check clean build release docs

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install package
	pip install -e .

install-dev: ## Install package with development dependencies
	pip install -e .[dev]
	pre-commit install

test: ## Run tests
	pytest

test-cov: ## Run tests with coverage
	pytest --cov=jebasa --cov-report=html --cov-report=term

lint: ## Run linting
	flake8 src tests
	black --check src tests
	isort --check-only src tests

format: ## Format code
	black src tests
	isort src tests

type-check: ## Run type checking
	mypy src

clean: ## Clean build artifacts
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf htmlcov/
	rm -rf .coverage
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	find . -type d -name __pycache__ -delete
	find . -type f -name "*.pyc" -delete

build: ## Build package
	python -m build

release-test: ## Release to test PyPI
	python -m build
	twine upload --repository testpypi dist/*

release: ## Release to PyPI
	python -m build
	twine upload dist/*

docs: ## Build documentation
	mkdocs build

docs-serve: ## Serve documentation locally
	mkdocs serve

# Development workflow
dev-setup: install-dev ## Set up development environment
	@echo "Development environment ready!"

check: lint type-check test ## Run all checks

# CI workflow
ci: check ## Run CI checks (same as check)

# Quick development cycle
dev: format lint test ## Quick development cycle (format, lint, test)
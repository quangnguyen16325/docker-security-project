# Repository Guidelines

## Project Structure & Module Organization

This repository is currently a blank project scaffold: no source, test, or build files have been committed yet. Keep the root focused on entry-point documentation and orchestration files. As the project grows, use a predictable layout:

- `src/` for application or security-tool source code.
- `tests/` for automated tests, mirroring paths under `src/`.
- `docker/` for Dockerfiles, Compose fragments, and container configuration.
- `scripts/` for repeatable setup, scan, and maintenance commands.
- `docs/` for threat models, architecture notes, and operational guidance.

Do not commit generated reports, image archives, credentials, or local environment files.

## Build, Test, and Development Commands

No build or test runner is configured yet. When adding one, expose common tasks through a `Makefile` or documented scripts so contributors have a stable interface. Recommended targets include:

- `make build` — build container images with reproducible tags.
- `make test` — run the complete automated test suite.
- `make lint` — run formatters, linters, and Dockerfile checks.
- `docker compose up --build` — start the local stack when a Compose file is added.

Update this section whenever tooling changes; commands documented here must work from the repository root.

## Coding Style & Naming Conventions

Use the formatter and linter standard for each language introduced, and commit their configuration with the code. Prefer two-space indentation for YAML and four spaces for Python. Use `snake_case` for Python modules and functions, `kebab-case` for shell scripts, and descriptive lowercase names for container services. Pin base-image versions and keep Dockerfile stages narrowly scoped.

## Testing Guidelines

Add tests with every behavior change and security fix. Name tests after the behavior they verify (for example, `test_rejects_privileged_container`). Include unit tests for logic and integration tests for container boundaries, permissions, health checks, and failure paths. A pull request should not reduce coverage for modified code.

## Commit & Pull Request Guidelines

There is no existing commit history from which to infer a convention. Use concise, imperative subjects, optionally following Conventional Commits, such as `feat: add image vulnerability scan` or `fix: drop unnecessary capability`. Keep commits focused.

Pull requests should explain the change, security impact, verification steps, and any configuration or migration requirements. Link relevant issues and include logs or screenshots when they clarify observable behavior. Never place secrets, tokens, or sensitive scan data in commits or review artifacts.

## Lab Safety & Team Workflow

Run every experiment only in an isolated VM/LAB on systems owned by the team or explicitly authorized. Never scan or attack external systems. Before testing, document the topology, snapshot, commands, expected result, and rollback procedure. Stop immediately if traffic leaves the LAB or an unexpected impact occurs.

Work according to `TASKS.md`; cross-area changes require team-lead review. Do not run `sudo` or alter a development host without explicit approval. Never read, print, commit, or share `.env` files, API keys, passwords, tokens, private keys, personal data, or database dumps. If a task requires a secret, stop and ask the team lead.

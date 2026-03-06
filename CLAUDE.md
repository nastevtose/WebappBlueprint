# Development Guidelines

This document contains critical information about working with this codebase. Follow these guidelines precisely.

## Python

→ See [docs/agent_docs/python.md](docs/agent_docs/python.md)

## Development Philosophy

- **Simplicity**: Write simple, straightforward code
- **Readability**: Make code easy to understand
- **Performance**: Consider performance without sacrificing readability
- **Maintainability**: Write code that's easy to update
- **Testability**: Ensure code is testable
- **Reusability**: Create reusable components and functions
- **Less Code = Less Debt**: Minimize code footprint

## Coding Best Practices

- **Early Returns**: Use to avoid nested conditions
- **Descriptive Names**: Use clear variable/function names (prefix handlers with "handle")
- **Constants Over Functions**: Use constants where possible
- **DRY Code**: Don't repeat yourself
- **Functional Style**: Prefer functional, immutable approaches when not verbose
- **Minimal Changes**: Only modify code related to the task at hand
- **Function Ordering**: Define composing functions before their components
- **TODO Comments**: Mark issues in existing code with "TODO:" prefix
- **Simplicity**: Prioritize simplicity and readability over clever solutions
- **Build Iteratively**: Start with minimal functionality and verify it works before adding complexity
- **Run Tests**: Test your code frequently with realistic inputs and validate outputs
- **Build Test Environments**: Create testing environments for components that are difficult to validate directly
- **Functional Code**: Use functional and stateless approaches where they improve clarity
- **Clean logic**: Keep core logic clean and push implementation details to the edges
- **File Organisation**: Balance file organization with simplicity - use an appropriate number of files for the project scale

## File Size & Documentation Rule

- **300-line limit applies to `CLAUDE.md` and all files under `docs/agent_docs/`**
- When `CLAUDE.md` exceeds 300 lines:
  - Extract the verbose section into `docs/agent_docs/<topic>.md`
  - Keep each doc focused on a single topic (e.g., `testing.md`, `git_workflow.md`)
  - Replace the section in `CLAUDE.md` with a one-line reference: `→ See [docs/agent_docs/<topic>.md]`
- When a `docs/agent_docs/<topic>.md` file exceeds 300 lines, split it into more focused sub-topic files

## Frontend

→ See [docs/agent_docs/frontend.md](docs/agent_docs/frontend.md)

## System Architecture

- use pydantic and langchain
- this project is a very simple chatbot. Keep files to a minimum

## Git Workflow

→ See [docs/agent_docs/git_workflow.md](docs/agent_docs/git_workflow.md)

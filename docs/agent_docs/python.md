# Python Guidelines

## Package Management

- ONLY use uv, NEVER pip
- Installation: `uv add package`
- Running tools: `uv run tool`
- Upgrading: `uv add --dev package --upgrade-package package`
- FORBIDDEN: `uv pip install`, `@latest` syntax

## Code Quality

- Type hints required for all code
- Use pyrefly for type checking
  - run `pyrefly init` to start
  - run `pyrefly check` after every change and fix resulting errors
- Public APIs must have docstrings
- Functions must be focused and small
- Follow existing patterns exactly
- Line length: 88 chars maximum

## Code Style

- PEP 8 naming (snake_case for functions/variables)
- Class names in PascalCase
- Constants in UPPER_SNAKE_CASE
- Document with docstrings
- Use f-strings for formatting

## Testing

- Framework: `uv run pytest`
- Async testing: use anyio, not asyncio
- Coverage: test edge cases and errors
- New features require tests
- Bug fixes require regression tests

## Code Formatting

### Ruff

- Format: `uv run ruff format .`
- Check: `uv run ruff check .`
- Fix: `uv run ruff check . --fix`
- Critical issues:
  - Line length (88 chars)
  - Import sorting (I001)
  - Unused imports
- Line wrapping:
  - Strings: use parentheses
  - Function calls: multi-line with proper indent
  - Imports: split into multiple lines

### Type Checking

- run `pyrefly init` to start
- run `pyrefly check` after every change and fix resulting errors
- Requirements:
  - Explicit None checks for Optional
  - Type narrowing for strings
  - Version warnings can be ignored if checks pass

## Tools

- Use context7 MCP to check details of libraries

## Error Resolution

### CI Failures — Fix Order

1. Formatting
2. Type errors
3. Linting

### Type Errors

- Get full line context
- Check Optional types
- Add type narrowing
- Verify function signatures

### Common Issues

- Line length: break strings with parentheses, multi-line function calls, split imports
- Types: add None checks, narrow string types, match existing patterns

### Best Practices

- Run formatters before type checks
- Keep changes minimal
- Follow existing patterns
- Document public APIs
- Test thoroughly

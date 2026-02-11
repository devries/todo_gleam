# AGENTS.md - Coding Agent Instructions for todo_gleam

## Project Overview

A todo list web application built with Gleam on the BEAM (Erlang VM), using the
GWHELT stack: Gleam, Wisp (web framework), HTMX (frontend interactivity),
Erlang/OTP, Lustre (server-side HTML), and Tailwind CSS. Data is stored in
SQLite via the sqlight library.

The project follows **Hexagonal Architecture** (Ports & Adapters):
- **Domain core:** `Item` type (with `CompletedItem`/`IncompleteItem` variants),
  port record types (`TodoService`, `ItemReader`, `ItemWriter`), and service logic.
- **Input adapters:** HTML/HTMX UI adapter and JSON API adapter.
- **Output adapter:** SQLite adapter implementing `ItemReader` and `ItemWriter`.
- Ports are defined as **record types wrapping function fields** in `domain/ports.gleam`.

## Build / Run / Test Commands

```bash
# Install dependencies
gleam deps download

# Run all tests
gleam test

# Run a single test file (e.g., only database_test.gleam)
gleam test -- --module database_test

# Format all source and test files
gleam format

# Check formatting without modifying (used in CI)
gleam format --check src test

# Build the project
gleam build

# Run the application (builds Tailwind CSS first via Makefile)
make run

# Run the application directly (without Tailwind rebuild)
gleam run

# Clean build artifacts
make clean
```

### Snapshot Testing (Birdie)

When a snapshot test fails, review the new snapshot and accept it if correct:

```bash
birdie accept-all    # Accept all new snapshots
birdie review        # Review interactively
```

Accepted snapshots live in `birdie_snapshots/` and are committed to the repo.

### CI Pipeline

GitHub Actions runs on push to main/master and on PRs:
- `gleam deps download` -> `gleam test` -> `gleam format --check src test`
- Toolchain: OTP 28, Gleam 1.14.0

## Project Structure (Hexagonal Architecture)

```
src/
  todo_gleam.gleam                      # Entry point: wires adapters -> service -> server
  todo_gleam/
    domain/
      item.gleam                        # Item type: CompletedItem | IncompleteItem
      ports.gleam                       # Port record types: TodoService, ItemReader, ItemWriter
      service.gleam                     # TodoService implementation wiring reader/writer
    adapters/
      input/
        html_adapter.gleam              # Input adapter: HTML/HTMX UI handlers
        json_adapter.gleam              # Input adapter: JSON API handlers
      output/
        sqlite_adapter.gleam            # Output adapter: SQLite ItemReader + ItemWriter
    router.gleam                        # Dispatches routes to input adapters
    web.gleam                           # Shared middleware, Context type (holds TodoService)
    index.gleam                         # Full HTML page rendering
    todo_item.gleam                     # Single item HTML/JSON rendering
    style.gleam                         # Tailwind CSS class helpers, SVG icons
    htmx.gleam                          # HTMX attribute helpers
    logger.gleam                        # Timestamped logging wrappers
test/
  todo_gleam_test.gleam                 # Gleeunit entry point
  database_test.gleam                   # In-memory SQLite CRUD tests via service
  decode_test.gleam                     # JSON decode tests
  snapshot_test.gleam                   # Birdie snapshot tests for HTML/JSON output
birdie_snapshots/                       # Accepted snapshot files
priv/static/                            # Static assets (HTMX, CSS, favicon)
```

### Architecture Wiring (in `todo_gleam.gleam`)

```
SQLite connection
  -> sqlite_adapter.new_reader(conn)    -- ItemReader port
  -> sqlite_adapter.new_writer(conn)    -- ItemWriter port
  -> service.new(reader, writer)        -- TodoService port
  -> Context(service: todo_service)     -- passed to router
  -> router dispatches to html_adapter / json_adapter
```

## Code Style Guidelines

### Formatting

- Use `gleam format` exclusively. The formatter is opinionated and non-configurable.
- 2-space indentation, trailing commas in multi-line argument lists (enforced by formatter).
- Always run `gleam format` before committing. CI will reject unformatted code.

### Imports

- Place all imports at the top of the file, sorted alphabetically.
- **Prefer qualified imports** for functions (e.g., `item.id(...)`, `result.map_error(...)`).
- **Import types and constructors unqualified** when used frequently:
  ```gleam
  import wisp.{type Request, type Response}
  import gleam/http.{Delete, Get, Put}
  import todo_gleam/domain/item.{type Item, CompletedItem, IncompleteItem}
  import todo_gleam/domain/ports.{type TodoService}
  ```
- Import a function unqualified only to avoid redundancy like `attribute.attribute()`.

### Naming Conventions

- **Modules:** `snake_case`, under `todo_gleam/domain/`, `todo_gleam/adapters/input/`, etc.
- **Types:** `PascalCase`, short and descriptive (e.g., `Item`, `Context`, `TodoService`).
- **Functions:** `snake_case`, verb-oriented for actions (e.g., `add`, `complete`, `new_reader`).
- **Variables:** `snake_case`, short but meaningful. Common abbreviations: `ctx` (context), `conn` (connection), `req` (request), `tid` (todo id), `svc` (service).
- **Test functions:** `pub fn <descriptive_name>_test()` -- the `_test` suffix is required by gleeunit.

### Type Annotations

- All function parameters must have explicit type annotations.
- Public functions should have explicit return type annotations.
- Private functions should have return type annotations when the type is non-obvious.
- Local `let` bindings use type inference -- do not annotate them.
- Use the record shorthand when variable names match field names:
  ```gleam
  decode.success(CompletedItem(id:, text:))
  ```

### Error Handling

- **Use `Result(a, String)` as the error type** for fallible operations.
- **Map external errors** to strings at the boundary (output adapter):
  ```gleam
  sqlight.exec(statement, conn)
  |> result.map_error(fn(e) { "SQL Error: " <> e.message })
  ```
- **Use the `use` callback pattern** for error short-circuiting in input adapters:
  ```gleam
  use new_item <- emessage_to_isa(service.add(trimmed_text))
  ```
- **Use `result.try`** for monadic chaining in service/adapter code.
- **Use `let assert`** only for unrecoverable failures (server startup) or in tests.
- **Never use `panic` or `todo`** in production code.

### Hexagonal Architecture Rules

- **Domain modules** (`domain/`) must NOT import adapter or web modules.
- **Input adapters** depend on domain ports and rendering modules, never on output adapters.
- **Output adapters** depend on domain types and ports, never on input adapters or web.
- **Ports are record types** with function fields -- not modules with pub functions.
- The **service** wires output ports into a `TodoService` input port.
- The **router** dispatches to input adapters, passing the `TodoService` from `Context`.

### Control Flow Patterns

- Use `use` callbacks for middleware, resource management, method guards, and errors.
- Use pipe chains (`|>`) for data transformation and response building.
- Use `case` with explicit `True`/`False` or `Ok`/`Error` arms (Gleam has no `if`/`else`).

### Comments

- Use `//` comments (not `///` doc comments) to describe function purpose.
- Place a comment above each function explaining what it does.
- Add module-level comments explaining the module's role in the architecture.

### Module Organization

- Keep modules small and single-purpose (most are 50-150 lines).
- Domain types live in `domain/item.gleam`; port types in `domain/ports.gleam`.
- `Context` type lives in `web.gleam` and holds `TodoService` + `static_directory`.
- `router.gleam` exposes only `handle_request`; input adapter handlers are `pub`.

### Tests

- Use `gleeunit` as the test runner and `birdie` for snapshot testing.
- Database tests use in-memory SQLite (`"file::memory:"`) with full service wiring.
- Assert with `assert expr == expected` for equality checks.
- Assert with `let assert Ok(val) = expr` for extracting from expected-Ok results.
- Snapshot tests use `CompletedItem`/`IncompleteItem` constructors directly.

### Dependencies

- Runtime: gleam_stdlib, wisp, mist, sqlight, lustre, gleam_json, gleam_erlang, gleam_otp, gleam_http, gleam_time, envoy
- Dev: gleeunit, birdie
- Managed via `gleam.toml` and locked in `manifest.toml`

# Agent Guidelines for todo_gleam

This repository contains a todo list application built with **Gleam**, **Wisp** (web framework), **Lustre** (HTML generation), **HTMX**, and **SQLite**.

## Build and Development Commands

- **Build project**: `gleam build`
- **Run server**: `gleam run` (Starts on port 8080 by default)
- **Run all tests**: `gleam test`
- **Run specific tests**: `gleam test` (Gleeunit automatically runs all functions ending in `_test` in the `test/` directory)
- **Format code**: `gleam format`
- **Lint code**: `gleam format --check`
- **Tailwind CSS**: `tailwindcss -i input.css -o priv/static/main.css --minify` (Managed via `Makefile`)
- **Clean build**: `make clean` (Removes the `build/` directory and compiled CSS)

## Project Architecture

### 1. Web Server (Wisp + Mist)
- **Entry point**: `src/todo_gleam.gleam` initializes the SQLite connection, context, and starts the `mist` server.
- **Router**: `src/todo_gleam/router.gleam` matches path segments (e.g., `["delete", id]`) to specific handler functions.
- **Context**: A `Context` record (in `web.gleam`) carries the database connection and static directory path throughout the application.
- **Middleware**: `web.middleware` handles method overriding, request logging, crash rescue, and serving static files from `priv/static`.

### 2. HTML and UI (Lustre + HTMX)
- **Components**: UI is built using Lustre elements in `src/todo_gleam/index.gleam` and `src/todo_gleam/todo_item.gleam`.
- **Interactivity**: HTMX is used for AJAX-style updates. Custom attributes are wrapped in `src/todo_gleam/htmx.gleam` (e.g., `htmx.target("closest li")`).
- **Styling**: Tailwind CSS classes are stored in `src/todo_gleam/style.gleam` and applied via Lustre attributes.

### 3. Database (SQLite + sqlight)
- **Schema**: Simple `items` table with `id`, `value` (text), and `done` (integer 0/1).
- **Operations**: `src/todo_gleam/database.gleam` contains all CRUD operations.
- **Decoding**: Uses `gleam/dynamic/decode` and `sqlight`'s boolean decoder to map rows to the `Todo` record.

## Code Style and Conventions

### 1. Naming and Formatting
- **Functions/Variables**: `snake_case`.
- **Types/Constructors**: `PascalCase`.
- Always run `gleam format` before committing.

### 2. The `use` Keyword
Extensively used for callbacks and Result handling:
- **Middleware**: `use req <- web.middleware(req, ctx)`
- **Database**: `use conn <- sqlight.with_connection(...)`
- **Result Chaining**: `use val <- result.try(...)` or custom helpers like `emessage_to_isa`.

### 3. Error Handling
- Favor `Result(a, String)` for operations that can fail.
- **Web Errors**: Use `emessage_to_isa` (in `router.gleam`) to transform `Error(String)` into a Wisp `InternalServerError` response with a descriptive message.
- **Database Errors**: Map `sqlight` errors to strings using `result.map_error(fn(e) { "SQL Error: " <> e.message })`.

### 4. Imports
- Grouping: 
    1. Gleam standard library (e.g., `gleam/list`)
    2. External packages (e.g., `wisp`, `lustre`)
    3. Local modules (e.g., `todo_gleam/database`)
- Sort alphabetized within groups.
- Prefer explicit type imports: `import wisp.{type Request, type Response}`.

## Testing Strategy

- **Unit Tests**: Place in `test/`. Use `gleeunit/should` for assertions (e.g., `should.equal`).
- **Snapshot Tests**: Use **Birdie** to verify HTML/JSON structure. Snapshots are in `birdie_snapshots/`.
- **Running Tests**: `gleam test` runs everything. If you modify UI structure, you may need to update snapshots via the Birdie CLI or by verifying the `gleam test` output.

## Common Tasks and Patterns

### 1. Adding a New Route
1.  Define the handler in `src/todo_gleam/router.gleam`.
2.  Add a pattern match in `handle_request`.
3.  Ensure the handler returns a `wisp.Response`.
4.  If it returns HTML, use `lustre/element.to_string_tree` followed by `wisp.html_body`.

### 2. Modifying the Database
1.  Update the `create_database` function in `src/todo_gleam/database.gleam` if schema changes.
2.  Add or update functions for CRUD operations.
3.  Ensure all new functions return `Result(a, String)`.
4.  Update the `Todo` type and decoders if necessary.

### 3. Creating UI Components
1.  Add functions to `src/todo_gleam/index.gleam` or separate component modules.
2.  Use `lustre/element/html` for standard tags.
3.  Apply styles using constants from `src/todo_gleam/style.gleam`.
4.  Add HTMX attributes using the `htmx` module for interactivity.

### 4. Handling Form Data
1.  Use `use form <- wisp.require_form(req)` in handlers.
2.  Access values with `list.find(form.values, ...)` and handle missing keys with `result.replace_error`.

## Deployment and Environment

- The application uses `envoy` to read environment variables (e.g., `DBFILE`).
- Default port is 8080, bound to `::`.
- Secret key base is generated randomly on start in `src/todo_gleam.gleam`.
- SQLite database is initialized automatically on startup.

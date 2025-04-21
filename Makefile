.PHONY: run

priv/static/main.css: src/todo_gleam/index.gleam src/todo_gleam/todo_item.gleam css/input.css
	tailwindcss -i css/input.css -o $@ --minify

run: priv/static/main.css
	gleam run

docker: priv/static/main.css
	gcloud builds submit

clean:
	rm -r build || true
	rm priv/static/main.css || true

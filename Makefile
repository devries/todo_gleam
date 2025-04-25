.PHONY: run docker clean

priv/static/main.css: src/todo_gleam/index.gleam src/todo_gleam/todo_item.gleam input.css build/bin/tailwindcss
	tailwindcss -i input.css -o $@ --minify

run: priv/static/main.css
	gleam run

docker:
	gcloud builds submit

clean:
	rm -r build || true
	rm priv/static/main.css || true

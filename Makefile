.PHONY: run docker clean

build/bin/tailwindcss:
	gleam run -m tailwind/install

priv/static/main.css: src/todo_gleam/index.gleam src/todo_gleam/todo_item.gleam css/input.css build/bin/tailwindcss
	gleam run -m tailwind/run

run: priv/static/main.css
	gleam run

docker:
	gcloud builds submit

clean:
	rm -r build || true
	rm priv/static/main.css || true

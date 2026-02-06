# include .env
# export TODO_IMAGE
# export LITESTREAM_IMAGE
# export REGION
# export BUCKET_URL
# export SERVICE_ACCOUNT

.PHONY: run docker clean deploy

priv/static/main.css: src/todo_gleam/index.gleam src/todo_gleam/todo_item.gleam src/todo_gleam/style.gleam input.css
	tailwindcss -i input.css -o $@ --minify

run: priv/static/main.css
	gleam run

docker: cloudbuild.yaml
	gcloud builds submit

clean:
	rm -r build || true
	rm priv/static/main.css || true

cloudbuild.yaml: cloudbuild.yaml.template .env
	envsubst < $< > $@

todo-gleam.yaml: todo-gleam.yaml.template .env
	envsubst < $< > $@

deploy: todo-gleam.yaml
	gcloud run services replace todo-gleam.yaml

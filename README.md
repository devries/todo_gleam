# TODO list

This is a todo list program written with a server in [Gleam](https://gleam.run/)
and [HTMX](https://htmx.org/) on the
frontend in order to get a better understanding how Gleam and HTMX can work
together. Todo items are saved to a [sqlite](https://www.sqlite.org/) database.
I use the [wisp](https://gleam-wisp.github.io/wisp/) web framework and the
[Lustre](https://hexdocs.pm/lustre/index.html) library to generate HTML. 

I also decided to use this as a test implementation for trying
[tailwindcss](https://tailwindcss.com/), and [Litestream](https://litestream.io/).
It also does snapshot testing with [Birdie](https://hexdocs.pm/birdie/).

This is based on my [Go implementation](https://github.com/devries/todo) of
the same thing.

I'll just call this the Gleam Wisp Htmx Erlang Lustre Tailscale (GWHELT) stack.

## Deployment to Cloud Run

Initial steps:
- Create a bucket in Google Cloud Storage to store database updates from Litstream.
- Create a service account which has the Storage Object Admin role in that bucket.
- Create a docker image registry in Google Artifact Registry.

The following environment variables must be set in your `.env` file:
- TODO_IMAGE - The full image name (without tags)
  for the gleam application. It should have the prefix given to your Google
  Artifact Registry image registry.
- LITESTREAM_IMAGE - The full image  name (without tags) for the litestream
  database streaming image. It should have the prefix given to your Google
  Artifact Registry image registry.
- REGION - Google Cloud Platform Region name in which to deploy.
- BUCKET_URL - The url (prefixed by gcs://) for the Google Cloud Storage
  bucket you created.
- SERVICE_ACCOUNT - The id (looks like an email address) for the service
  account you created.

The `make docker` command will create a `cloudbuild.yaml` file and submit the
project to Google Cloud Build.

The `make deploy` command will create a `todo-gleam.yaml` file and deploy the
containers as a Cloud Run service open to the public internet.

# Soul

This is the umbrella app for Soul.  SoulWeb is a web server, and SoulGut talks
to various APIs.

To use the APIs, you'll need a `apps/soul_gut/config/services.ex`, as described
in `apps/soul_gut/README.md`.

## Running

Use `mix phoenix.server` and visit `localhost:4000`.  The most interesting
endpoint currently is `/api/music`.

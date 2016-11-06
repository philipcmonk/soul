# Soul

This is the umbrella app for Soul.  SoulWeb is a web server, and SoulGut talks
to various APIs.

## Configuration

You'll need a postgres database as described in
`apps/soul_gut/config/config.exs`.  In particular, you'll need a
database called `soul_gut_repo`, accessible with username
`postgres` and password `supersecure`.

Once that's set up, I think you'll need to run `mix ecto.create`
and possibly `mix ecto.migrate`.  At any rate, it can't hurt.

Then, run `iex -S mix phoenix.server`, and visit
`localhost:4000/api/services` to see a list of implemented
services and whether or not you have credentials for them (you
shouldn't).

Choose a service, we'll use Facebook as an example.  Give your
app id and secret by posting `{"client_id": "XXX",
"client_secret": "XXX"}` to
`http://localhost:4000/api/services/facebook/app`.

Then, visit `http://localhost:4000/auth/facebook` to
authenticate.  Then you should be able to visit
`http://localhost:4000/api/facebook/me/feed`.


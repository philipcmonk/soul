# Soul

## Configuration

You'll need a `config/services.ex` that looks like this (fill in the app ids
and secrets from your own app that you create).

    use Mix.Config
    
    config :soul,
      github_client_id: "XXX",
      github_client_secret: "XXX",
      spotify_client_id: "XXX",
      spotify_client_secret: "XXX",
      facebook_client_id: "XXX",
      facebook_client_secret: "XXX",
      facebook_test_access_token: "XXX"

## Source organization

    lib/
      soul.ex
      sources/
        facebook.ex
        github.ex
        spotify.ex
        music.ex
        misc.ex
        ...
      strategies/
        facebook.ex
        github.ex
        spotify.ex
        ...
          
## Installation

  1. Add soul to your list of dependencies in mix.exs:

        def deps do
          [{:soul, "~> 0.0.1"}]
        end

  2. Ensure soul is started before your application:

        def application do
          [applications: [:soul]]
        end

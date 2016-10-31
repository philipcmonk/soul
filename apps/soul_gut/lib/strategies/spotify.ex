defmodule Strategies.Spotify do
  use OAuth2.Strategy

  @default_scopes "playlist-read-private playlist-read-collaborative " <>
    "playlist-modify-public playlist-modify-private user-follow-modify " <>
    "user-follow-read user-library-read user-library-modify " <>
    "user-read-private user-read-birthdate user-read-email user-top-read"

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: Application.get_env(:soul_gut, :spotify_client_id),
      client_secret: Application.get_env(:soul_gut, :spotify_client_secret),
      redirect_uri: "http://dev.pcmonk.me:4000",
      site: "https://api.spotify.com/v1",
      authorize_url: "https://accounts.spotify.com/authorize",
      token_url: "https://accounts.spotify.com/api/token"
    ])
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: @default_scopes)
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end

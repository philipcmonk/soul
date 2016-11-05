defmodule Strategies.Spotify do
  @behaviour Strategies
  use OAuth2.Strategy

  @service "spotify"
  @bare_client %OAuth2.Client{
                 strategy: __MODULE__,
                 authorize_url: "https://accounts.spotify.com/authorize",
                 redirect_uri: "http://dev.pcmonk.me:4000/",
                 site: "https://api.spotify.com/v1",
                 token_url: "https://accounts.spotify.com/api/token"
               }
  @default_scopes "playlist-read-private playlist-read-collaborative " <>
    "playlist-modify-public playlist-modify-private user-follow-modify " <>
    "user-follow-read user-library-read user-library-modify " <>
    "user-read-private user-read-birthdate user-read-email user-top-read"

  def client, do: Strategies.client(@service, @bare_client)
  def has_client?, do: @service |> Strategies.has_client?
  def del_client, do: @service |> Strategies.del_client
  def set_client(client), do: @service |> Strategies.set_client(client)
  def set_client(id, secret, token) do
    @service |> Strategies.set_client(id, secret, token)
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: @default_scopes)
  end

  def take_code(code) do
    [code: code]
    |> __MODULE__.get_token!
    |> set_client
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  # Strategy Callbacks

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

defmodule Strategy.Github do
  @behaviour Strategy
  use OAuth2.Strategy

  @service "github"
  @bare_client %OAuth2.Client{
                 strategy: __MODULE__,
                 authorize_url: "https://github.com/login/oauth/authorize",
                 redirect_uri: "http://localhost:4000/api/services/" <>
                   @service <> "/auth",
                 site: "https://api.github.com",
                 token_url: "https://github.com/login/oauth/access_token"
               }
  @default_scopes "user,public_repo"

  def client, do: Strategy.client(@service, @bare_client)
  def has_client?, do: @service |> Strategy.has_client?
  def del_client, do: @service |> Strategy.del_client
  def set_client(client), do: @service |> Strategy.set_client(client)
  def set_client(id, secret, token \\ nil) do
    @service |> Strategy.set_client(id, secret, token)
  end
  def get_settings, do: @service |> Strategy.get_settings

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

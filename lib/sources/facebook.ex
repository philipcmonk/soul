require Logger

defmodule Sources.Facebook do
  alias OAuth2.Client

  def getName(client) do
    case Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

	def getTestClient() do
    %OAuth2.Client{authorize_url: "https://www.facebook.com/v2.8/dialog/oauth",
     client_id: System.get_env("FACEBOOK_CLIENT_ID"),
     client_secret: System.get_env("FACEBOOK_CLIENT_SECRET"), headers: [], params: %{},
     redirect_uri: "http://dev.pcmonk.me:4000/",
     site: "https://graph.facebook.com/v2.5", strategy: Strategies.Facebook,
     token: %OAuth2.AccessToken{access_token: System.get_env("FACEBOOK_TEST_ACCESS_TOKEN"),
      expires_at: 1482823240, other_params: %{}, refresh_token: nil,
      token_type: "Bearer"}, token_method: :post,
     token_url: "https://graph.facebook.com/v2.8/oauth/access_token"}

	end

  def streamEndpoint(client, endpoint) do
    Stream.resource(
      fn -> endpoint end,
      fn(cursor) ->
        if !cursor do
          {:halt, :done}
        else
          Logger.debug("cursor " <> inspect(cursor))
          # params = if cursor == :start, do: [], else: [params: %{"after" => cursor}]
          case Client.get(client, cursor) do
            {:ok, %OAuth2.Response{status_code: status_code, body: body}} ->
              Logger.debug("body " <> inspect({cursor,body["paging"],body["paging"]["cursors"],body["paging"]["next"]}))
              Logger.debug("fullbody " <> inspect({status_code,body}))
              {body["data"], body["paging"]["next"]}
            {:error, %OAuth2.Error{reason: reason}} ->
              Logger.debug("halting " <> inspect(reason))
              {:halt, :done}
          end
        end
      end,
      fn(cursor) -> cursor end
    )
  end
end

require Logger
alias Strategy.Foursquare, as: Fs


defmodule Sources.Foursquare do
  alias OAuth2.Client

  def get_endpoint(endpoint) do
    client = Fs.client
    case Client.get(client, "/" <> Enum.join(endpoint, "/"), [],
                    params: [oauth_token: client.token.access_token,
                             v: "20161229", m: "swarm"]) do
      {:ok, %OAuth2.Response{status_code: _status_code, body: body}} ->
        body
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.debug("endpoint error " <> inspect(reason))
        %{error: inspect(reason)}
    end
  end
end

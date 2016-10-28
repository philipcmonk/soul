require Logger

defmodule Soul do
  def add(x, y) do
    x + y + y
  end

  def getGithubUsername() do
    IO.puts "go to this url:  " <> Github.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Github.get_token!(code: code)
    case OAuth2.Client.get(client, "/user") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: status_code, body: user}} ->
        user["login"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def getSpotifyName() do
    IO.puts "go to this url:  " <> Spotify.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Spotify.get_token!(code: code)
    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: status_code, body: user}} ->
        user["display_name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def getFacebookName() do
    IO.puts "go to this url:  " <> Facebook.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Facebook.get_token!(code: code)
    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: status_code, body: user}} ->
        user["name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end
end

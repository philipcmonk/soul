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
end

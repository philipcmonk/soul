require Logger

defmodule Soul do
  def add(x, y) do
    x + y + y
  end

  def getGithubUsername() do
    IO.puts "go to this url:  " <> Strategies.Github.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategies.Github.get_token!(code: code)
    case OAuth2.Client.get(client, "/user") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["login"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def getSpotifyName() do
    IO.puts "go to this url:  " <> Strategies.Spotify.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategies.Spotify.get_token!(code: code)
    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["display_name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def getFacebookName() do
    IO.puts "go to this url:  " <> Strategies.Facebook.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategies.Facebook.get_token!(code: code)
    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def startFacebook() do
    IO.puts "go to this url:  " <> Strategies.Facebook.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategies.Facebook.get_token!(code: code)
    if !client.token.access_token do
      raise client
    else
      client
    end
  end

  @doc """
  Gets the most recently played song previous to a time.  If the given time
  is in the middle of us playing a song, we tag the result with `:during`, else
  we tag it with `:after`.  If the time is before we played any song, we produce
  nil.

  TODO: traverse pagination
  """
  @spec getSongAtTime(%OAuth2.Client{}, %DateTime{}) ::
      {:during, String.t, String.t | nil} |
      {:after, String.t, String.t | nil} |
      {:error, any} |
      nil
  def getSongAtTime(client, t) do
    case OAuth2.Client.get(client, "/me/music.listens") do
      {:ok, %OAuth2.Response{body: body}} ->
        findSong(body["data"], t)
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  @type song :: %{id: String.t, title: String.t, type: String.t, url: String.t}
  @type playlist :: %{id: String.t, title: String.t, type: String.t,
                       url: String.t}
  @type song_data :: %{song: song} | %{song: song, playlist: playlist}
  @type song_entry :: %{data: song_data, end_time: String.t, id: String.t,
                     start_time: String.t, type: String.t}

  @spec findSong([song_entry], %DateTime{}) ::
      {:during, String.t, String.t | nil} |
      {:after, String.t, String.t | nil} |
      nil
  defp findSong([], _), do: nil
  defp findSong([entry | entries], t) do
    starting = Timex.parse!(entry["start_time"], "{ISO:Extended}")
    ending = Timex.parse!(entry["end_time"], "{ISO:Extended}")
    Logger.debug(inspect(entry))
    Logger.debug(inspect(t))
    Logger.debug(inspect(starting))
    cond do
      Timex.before?(ending, t) ->
        {:after, entry["data"]["song"]["title"], getPlaylist(entry["data"])}
      Timex.before?(starting, t) ->
        {:during, entry["data"]["song"]["title"], getPlaylist(entry["data"])}
      true ->
        findSong(entries, t)
    end
  end

  @spec getPlaylist(song_data) :: String.t | nil
  defp getPlaylist(data) do
    if Map.has_key?(data, "playlist") do
      data["playlist"]["title"]
    else
      nil
    end
  end
end

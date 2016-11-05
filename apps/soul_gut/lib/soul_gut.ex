require Logger

defmodule SoulGut do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(SoulGut.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: SoulGut.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def add(x, y) do
    x + y + y
  end

  def get_github_username() do
    IO.puts "go to this url:  " <> Strategy.Github.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategy.Github.get_token!(code: code)
    case OAuth2.Client.get(client, "/user") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["login"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def get_spotify_name() do
    IO.puts "go to this url:  " <> Strategy.Spotify.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategy.Spotify.get_token!(code: code)
    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["display_name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def get_facebook_name() do
    IO.puts "go to this url:  " <> Strategy.Facebook.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategy.Facebook.get_token!(code: code)
    case OAuth2.Client.get(client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def start_facebook() do
    IO.puts "go to this url:  " <> Strategy.Facebook.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategy.Facebook.get_token!(code: code)
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

  XXX: deprecated by Sources.Facebook.get_song_at_time
  """
  @spec get_song_at_time(%OAuth2.Client{}, %DateTime{}) ::
      {:during, String.t, String.t | nil} |
      {:after, String.t, String.t | nil} |
      {:error, any} |
      nil
  def get_song_at_time(client, t) do
    case OAuth2.Client.get(client, "/me/music.listens") do
      {:ok, %OAuth2.Response{body: body}} ->
        find_song(body["data"], t)
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

  @spec find_song([song_entry], %DateTime{}) ::
      {:during, String.t, String.t | nil} |
      {:after, String.t, String.t | nil} |
      nil
  defp find_song([], _), do: nil
  defp find_song([entry | entries], t) do
    starting = Timex.parse!(entry["start_time"], "{ISO:Extended}")
    ending = Timex.parse!(entry["end_time"], "{ISO:Extended}")
    Logger.debug(inspect(entry))
    Logger.debug(inspect(t))
    Logger.debug(inspect(starting))
    cond do
      Timex.before?(ending, t) ->
        {:after, entry["data"]["song"]["title"], get_playlist(entry["data"])}
      Timex.before?(starting, t) ->
        {:during, entry["data"]["song"]["title"], get_playlist(entry["data"])}
      true ->
        find_song(entries, t)
    end
  end

  @spec get_playlist(song_data) :: String.t | nil
  defp get_playlist(data) do
    if Map.has_key?(data, "playlist") do
      data["playlist"]["title"]
    else
      nil
    end
  end
end

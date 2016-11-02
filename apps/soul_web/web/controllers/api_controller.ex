require Logger

defmodule SoulWeb.ApiController do
  use SoulWeb.Web, :controller

  def index(conn, _params) do
    json conn, %{ok: true}
  end

  def music(conn, _params) do
    client = Sources.Facebook.getClient
    Logger.debug("music0 " <> inspect(client))
    s = Sources.Facebook.streamEndpoint(client, "/me/music.listens")
    Logger.debug("music1 " <> inspect(s))
    json conn, Enum.take(s, 5)
  end

  def music_at(conn, %{"time" => time}) do
    client = Sources.Facebook.getClient
    t = Timex.parse!(time, "{ISO:Extended}")
    {during, song, playlist} =
      Sources.Facebook.getSongAtTime(client, t)
    json conn, %{when: during, song: song, playlist: playlist}
  end

  def services(conn, _params) do
    services = MapSet.new([
                            :facebook,
                            :spotify,
                            :github
                          ])
    json conn,
      services
      |> Enum.map(fn s -> {s, false} end)
      |> Map.new
  end
end

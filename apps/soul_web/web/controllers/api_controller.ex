require Logger

defmodule SoulWeb.ApiController do
  use SoulWeb.Web, :controller

  def index(conn, _params) do
    json conn, %{ok: true}
  end

  def music(conn, _params) do
    client = Sources.Facebook.getTestClient
    Logger.debug("music0 " <> inspect(client))
    s = Sources.Facebook.streamEndpoint(client, "/me/music.listens")
    Logger.debug("music1 " <> inspect(s))
    json conn, Enum.take(s, 5)
  end
end

require Logger

defmodule SoulWeb.ApiController do
  use SoulWeb.Web, :controller


  @services %{"facebook" => Strategies.Facebook,
              "spotify"  => Strategies.Spotify,
              "github"   => Strategies.Github
            }

  def index(conn, _params) do
    json conn, %{ok: true}
  end

  def music(conn, _params) do
    s = Sources.Facebook.streamEndpoint("/me/music.listens")
    Logger.debug("music1 " <> inspect(s))
    json conn, Enum.take(s, 5)
  end

  def music_at(conn, %{"time" => time}) do
    t = Timex.parse!(time, "{ISO:Extended}")
    {during, song, playlist} =
      Sources.Facebook.getSongAtTime(t)
    json conn, %{when: during, song: song, playlist: playlist}
  end

  def services(conn, _params) do
    json conn,
      @services
      |> Enum.map(fn {service, module} -> {service, module.hasClient?} end)
      |> Map.new
  end

  def auth(conn, %{"service" => service, "code" => code}) do
    unless Map.has_key?(@services, service) do
      %{ok: false, error: "service not recognized"}
    else
      case @services[service].takeCode(code) do
        {:ok, _}         -> %{ok: true}
        {:error, reason} -> %{ok: false, error: reason}
      end
    end
    |> (&json(conn, &1)).()
  end

  def auth_url(conn, %{"service" => service}) do
    unless Map.has_key?(@services, service) do
      %{ok: false, error: "service not recognized"}
    else
      @services[service].authorize_url!
    end
    |> (&json(conn, &1)).()
  end

  def facebook(conn, %{"endpoint" => endpoint}) do
    json conn, Sources.Facebook.getEndpoint(endpoint)
  end
end

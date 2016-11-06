require Logger

defmodule SoulWeb.ApiController do
  use SoulWeb.Web, :controller


  @services %{"facebook" => Strategy.Facebook,
              "spotify"  => Strategy.Spotify,
              "github"   => Strategy.Github
            }

  def index(conn, _params) do
    json conn, %{ok: true}
  end

  def music(conn, _params) do
    s = Sources.Facebook.stream_endpoint("/me/music.listens")
    Logger.debug("music1 " <> inspect(s))
    json conn, Enum.take(s, 5)
  end

  def music_at(conn, %{"time" => time}) do
    t = Timex.parse!(time, "{ISO:Extended}")
    {during, song, playlist} =
      Sources.Facebook.get_song_at_time(t)
    json conn, %{when: during, song: song, playlist: playlist}
  end

  def services(conn, _params) do
    json conn,
      @services
      |> Enum.map(fn {service, module} -> {service, module.has_client?} end)
      |> Map.new
  end

  def auth(conn, %{"service" => service, "code" => code}) do
    unless Map.has_key?(@services, service) do
      %{ok: false, error: "service not recognized"}
    else
      case @services[service].take_code(code) do
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

  def auth_redirect(conn, %{"service" => service}) do
    unless Map.has_key?(@services, service) do
      json conn, %{ok: false, error: "service not recognized"}
    else
      redirect conn, external: @services[service].authorize_url!
    end
  end

  def app(conn, %{"service" => service,
                  "client_id" => id,
                  "client_secret" => secret}) do
    case @services[service].set_client(id, secret) do
      {:ok, _} -> %{ok: true}
      {:error, any} -> %{ok: false, error: inspect(any)}
    end
    |> (&json(conn, &1)).()
  end

  def facebook(conn, %{"endpoint" => endpoint}) do
    json conn, Sources.Facebook.get_endpoint(endpoint)
  end
end

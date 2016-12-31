defmodule SoulWeb.Router do
  use SoulWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    # plug :fetch_session
    # plug :fetch_flash
    # plug :protect_from_forgery
    # plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ~r/https?:\/\/localhost:[0-9]{4}$/
  end

  scope "/", SoulWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/auth/:service", ApiController, :auth_redirect
  end

  # Other scopes may use custom stacks.
  scope "/api", SoulWeb do
    pipe_through :api

    get "/", ApiController, :index
    get "/services", ApiController, :services
    get "/services/:service/auth", ApiController, :auth
    get "/services/:service/auth_url", ApiController, :auth_url
    put "/services/:service/app", ApiController, :app
    get "/facebook/*endpoint", ApiController, :facebook
    get "/foursquare/*endpoint", ApiController, :foursquare
    get "/music", ApiController, :music
    get "/music/:time", ApiController, :music_at
    get "/events", ApiController, :events
  end
end

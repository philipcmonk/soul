defmodule SoulWeb.Router do
  use SoulWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SoulWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", SoulWeb do
    pipe_through :api

    get "/", ApiController, :index
    get "/services", ApiController, :services
    get "/services/:service/auth", ApiController, :auth
    get "/services/:service/auth_url", ApiController, :auth_url
    get "/facebook/*endpoint", ApiController, :facebook
    get "/music", ApiController, :music
    get "/music/:time", ApiController, :music_at
  end
end

defmodule Soul.PageController do
  use Soul.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

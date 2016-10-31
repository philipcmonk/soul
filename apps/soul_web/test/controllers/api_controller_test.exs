defmodule SoulWeb.ApiControllerTest do
  use SoulWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "{ok: true}"
  end
end

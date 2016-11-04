require Logger
alias Strategies.Facebook, as: Fb

defmodule Sources.Facebook do
  alias OAuth2.Client

  def get_name() do
    case Client.get(Fb.client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  # def get_test_client() do
  #   get_client(Application.get_env(:soul_gut, :facebook_client_id),
  #             Application.get_env(:soul_gut, :facebook_client_secret),
  #             Application.get_env(:soul_gut, :facebook_test_access_token))
	# end

  def stream_endpoint(endpoint) do
    Stream.resource(
      fn -> endpoint end,
      fn(cursor) ->
        if !cursor do
          {:halt, :done}
        else
          Logger.debug("cursor " <> inspect(cursor))
          # params = if cursor == :start, do: [], else: [params: %{"after" => cursor}]
          case Client.get(Fb.client, cursor) do
            {:ok, %OAuth2.Response{status_code: status_code, body: body}} ->
              Logger.debug("body " <> inspect({cursor,body["paging"],body["paging"]["cursors"],body["paging"]["next"]}))
              Logger.debug("fullbody " <> inspect({status_code,body}))
              {body["data"], body["paging"]["next"]}
            {:error, %OAuth2.Error{reason: reason}} ->
              Logger.debug("halting " <> inspect(reason))
              {:halt, :done}
          end
        end
      end,
      fn(cursor) -> cursor end
    )
  end

  def get_endpoint(endpoint) do
    case Client.get(Fb.client, "/" <> Enum.join(endpoint, "/")) do
      {:ok, %OAuth2.Response{status_code: _status_code, body: body}} ->
        body["data"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.debug("endpoint error " <> inspect(reason))
        %{error: inspect(reason)}
    end
  end

  @doc """
  Gets the most recently played song previous to a time.  If the given time
  is in the middle of us playing a song, we tag the result with `:during`, else
  we tag it with `:after`.  If the time is before we played any song, we produce
  nil.
  """
  def get_song_at_time(t) do
    maybe_song =
      stream_endpoint("/me/music.listens")
      |> Stream.filter(&is_song?(&1, t))
      |> Enum.take(1)
    case maybe_song do
      nil -> nil
      [song] ->
        ending = Timex.parse!(song["end_time"], "{ISO:Extended}")
        {if(Timex.before?(ending, t), do: :after, else: :during),
            song["data"]["song"]["title"],
            get_playlist(song["data"])}
    end
  end

  defp is_song?(song, t) do
    starting = Timex.parse!(song["start_time"], "{ISO:Extended}")
    Timex.before?(starting, t)
  end

  defp get_playlist(data) do
    Logger.debug(inspect(data))
    if Map.has_key?(data, "playlist") do
      data["playlist"]["title"]
    else
      nil
    end
  end
end

require Logger
alias Strategies.Facebook, as: Fb

defmodule Sources.Facebook do
  alias OAuth2.Client

  def getName() do
    case Client.get(Fb.client, "/me") do
      {:ok, %OAuth2.Response{status_code: 401, body: _}} ->
        Logger.error("Unauthorized token")
      {:ok, %OAuth2.Response{status_code: _, body: user}} ->
        user["name"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  # def getTestClient() do
  #   getClient(Application.get_env(:soul_gut, :facebook_client_id),
  #             Application.get_env(:soul_gut, :facebook_client_secret),
  #             Application.get_env(:soul_gut, :facebook_test_access_token))
	# end

  def streamEndpoint(endpoint) do
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

  def getEndpoint(endpoint) do
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
  def getSongAtTime(t) do
    maybe_song =
      streamEndpoint("/me/music.listens")
      |> Stream.filter(&isSong?(&1, t))
      |> Enum.take(1)
    case maybe_song do
      nil -> nil
      [song] ->
        ending = Timex.parse!(song["end_time"], "{ISO:Extended}")
        {if(Timex.before?(ending, t), do: :after, else: :during),
            song["data"]["song"]["title"],
            getPlaylist(song["data"])}
    end
  end

  defp isSong?(song, t) do
    starting = Timex.parse!(song["start_time"], "{ISO:Extended}")
    Timex.before?(starting, t)
  end

  defp getPlaylist(data) do
    Logger.debug(inspect(data))
    if Map.has_key?(data, "playlist") do
      data["playlist"]["title"]
    else
      nil
    end
  end
end

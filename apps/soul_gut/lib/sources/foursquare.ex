require Logger
import Ecto.Query, only: [from: 2]
alias SoulGut.{Repo,Events}
alias Strategy.Foursquare, as: Fs


defmodule Sources.Foursquare do
  alias OAuth2.Client

  def get_endpoint(endpoint) do
    client = Fs.client
    case Client.get(client, "/" <> Enum.join(endpoint, "/"), [],
                    params: [oauth_token: client.token.access_token,
                             v: "20161229", m: "swarm"]) do
      {:ok, %OAuth2.Response{status_code: _status_code, body: body}} ->
        body["response"]
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.debug("endpoint error " <> inspect(reason))
        %{error: inspect(reason)}
    end
  end

  def update_events do
    feed = get_endpoint([:users, :self, :checkins])["checkins"]
    Logger.debug("FEED " <> inspect(feed))
    Enum.map(feed["items"], fn item ->
      Logger.debug("item " <> inspect(item["id"]))
      %{orig_id: item["id"],
        name: item["venue"]["name"],
        images: [],
        date_recorded: DateTime.from_unix!(item["createdAt"]),
        location: 0 # XXX
      } end)
   
    |> Enum.reject(fn event ->
      Repo.one(from s in Events,
        where: s.orig_id == ^event[:orig_id],
        select: s.id)
    end)

    |> Enum.map(fn event -> Events.changeset(%Events{}, event) end)

    |> Enum.map(fn changeset ->
      case Repo.insert(changeset) do
        {:ok, _model} -> 
          Logger.debug("added new event. " <> inspect(changeset))
          :ok
        {:error, changeset} ->
          Logger.error("couldn't add new event. " <> inspect(changeset))
          nil
      end
    end)
  end
end

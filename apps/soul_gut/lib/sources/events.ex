require Logger
import Ecto.Query, only: [from: 2]
alias SoulGut.{Repo,Events}
# alias Sources.Facebook, as: Fb
alias Sources.Foursquare, as: Fs

defmodule Sources.Events do
  def get_events do
    update_events
    query = from s in Events,
      select: {s.id, s.service, s.name, s.images, s.date_recorded, s.location, s.inserted_at}

    case Repo.all(query) do
      [] -> []
      events ->
        Enum.map(events,
          fn {id, service, name, images, date_recorded, location, inserted_at} ->
            %{id: id,
              service: service,
              name: name,
              images: images,
              date_created: Timex.format!(inserted_at, "{ISO:Extended}"),
              date_recorded: date_recorded,
              location: location
            }
          end)
    end
  end

  def update_events do
    # Fb.update_events
    Fs.update_events
  end
end

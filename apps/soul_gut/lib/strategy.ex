require Logger
import Ecto.Query, only: [from: 2]
alias SoulGut.{Repo,Service}

defmodule Strategy do
  @callback authorize_url! :: String.t
  @callback take_code(String.t) :: {:ok, any} | {:error, any}
  @callback client :: %OAuth2.Client{}
  @callback has_client? :: false | integer
  @callback del_client :: {:ok, struct} | {:error, any}
  @callback set_client(%OAuth2.Client{}) :: {:ok, any} | {:error, any}
  @callback set_client(String.t, String.t, String.t | nil) ::
    {:ok, any} | {:error, any}

  def client(service, bare_client) do
    query = from s in Service,
      where: s.name == ^service,
      select: {s.client_id, s.client_secret, s.access_token}

    
    case Repo.one(query) do
      nil -> bare_client
      {id, secret, nil} ->
        %OAuth2.Client{bare_client |
          client_id: id,
          client_secret: secret,
          token: nil
        }
      {id, secret, token} ->
        %OAuth2.Client{bare_client |
          client_id: id,
          client_secret: secret,
          token: %OAuth2.AccessToken{
            access_token: token,
            expires_at: 1482823240
        }}
    end

  end

  def has_entry?(service) do
    query = from s in Service,
      where: s.name == ^service,
      select: s.id

    case Repo.one(query) do
      nil -> false # either no service row or access token doesn't exist
      id -> id
    end
  end

  def has_client?(service) do
    query = from s in Service,
      where: s.name == ^service,
      where: not is_nil(s.access_token),
      select: s.id

    case Repo.one(query) do
      nil -> false # either no service row or access token doesn't exist
      id -> id
    end
  end

  def set_client(service, c) do
    set_client(service, c.client_id, c.client_secret, c.token.access_token)
  end

  def set_client(service, id, secret, token) do
    case has_entry?(service) do
      false ->
        changeset = Service.changeset(%Service{},
          %{name: service,
            client_id: id,
            client_secret: secret,
            access_token: token
          })
        case Repo.insert(changeset) do
          {:ok, _model} -> {:ok, "great new one!"}
          {:error, changeset} ->
            Logger.error("couldn't set new client.  " <> inspect(changeset))
            {:error, "couldn't set new client.  " <> inspect(changeset)}
        end

      key ->
        changeset = Service.update_changeset(%Service{id: key},
          %{client_id: id,
            client_secret: secret,
            access_token: token
          })
        Logger.debug("changeset " <> inspect(changeset))
        case Repo.update(changeset) do
          {:ok, _model} -> {:ok, "great old one!"}
          {:error, changeset} ->
            Logger.error("couldn't set old client.  " <> inspect(changeset))
            {:error, "couldn't set old client.  " <> inspect(changeset)}
        end
    end
  end

  def del_client(service) do
    from(s in Service, where: s.name == ^service)
    case has_client?(service) do
      false -> {:error, "no client"}
      key -> Repo.delete(%Service{id: key})
    end
  end
end

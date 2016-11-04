require Logger
import Ecto.Query, only: [from: 2]
alias SoulGut.{Repo,Service}

defmodule Strategies.Facebook do
  use OAuth2.Strategy

  @default_scopes "public_profile,user_friends,email,user_about_me," <>
    "user_actions.books,user_actions.fitness,user_actions.music," <>
    "user_actions.news,user_actions.video," <> # user_actions:{app_namespace}," <>
    "user_birthday,user_education_history,user_events,user_games_activity," <>
    "user_hometown,user_likes,user_location,user_managed_groups," <>
    "user_photos,user_posts,user_relationships,user_relationship_details," <>
    "user_religion_politics,user_tagged_places,user_videos,user_website," <>
    "user_work_history,read_custom_friendlists,read_insights," <>
    "read_audience_network_insights,read_page_mailboxes,manage_pages," <>
    "publish_pages,publish_actions,rsvp_event,pages_show_list," <>
    "pages_manage_cta,pages_manage_instant_articles,ads_read," <>
    "ads_management,business_management,pages_messaging," <>
    "pages_messaging_phone_number"


  def makeClient(id, secret, token) do
    %OAuth2.Client{authorize_url: "https://www.facebook.com/v2.8/dialog/oauth",
     client_id: id,
     client_secret: secret, headers: [], params: %{},
     redirect_uri: "http://dev.pcmonk.me:4000/",
     site: "https://graph.facebook.com/v2.5", strategy: Strategies.Facebook,
     token: %OAuth2.AccessToken{access_token: token,
      expires_at: 1482823240, other_params: %{}, refresh_token: nil,
      token_type: "Bearer"}, token_method: :post,
     token_url: "https://graph.facebook.com/v2.8/oauth/access_token"}
  end

  def client do
    query = from s in Service,
      where: s.name == "facebook",
      select: {s.client_id, s.client_secret, s.access_token}

    {id, secret, token} = Repo.one!(query)

    makeClient(id, secret, token)
  end

  def hasClient?() do
    query = from s in Service,
      where: s.name == "facebook",
      where: not is_nil(s.access_token),
      select: s.id

    case Repo.one(query) do
      nil -> false # either no facebook row or access token doesn't exist
      id -> id
    end
  end

  def setTestClient() do
    setClient(Application.get_env(:soul_gut, :facebook_client_id),
      Application.get_env(:soul_gut, :facebook_client_secret),
      Application.get_env(:soul_gut, :facebook_test_access_token))
  end

  def setClient(client) do
    setClient(client.client_id, client.client_secret, client.token.access_token)
  end

  def setClient(id, secret, token) do
    case hasClient?() do
      false ->
        changeset = Service.changeset(%Service{},
          %{name: "facebook",
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
          %{name: "facebook",
            client_id: id,
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

  def delClient() do
    from(s in Service, where: s.name == "facebook")
    |> Repo.delete_all
  end

  def takeCode(code) do
    Logger.debug("hrm")
    c = Strategies.Facebook.get_token!(code: code)
    Logger.debug("taking code" <> inspect(c))
    Logger.debug("harm")
    setClient(c)
  end


  # These are the ones you need!
  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: @default_scopes)
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end

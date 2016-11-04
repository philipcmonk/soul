require Logger

defmodule Strategies.Facebook do
  use OAuth2.Strategy

  @service "facebook"
  @bare_client %OAuth2.Client{
                 authorize_url: "/dialog/oauth",
                 redirect_uri: "http://dev.pcmonk.me:4000/",
                 site: "https://graph.facebook.com/v2.8",
                 strategy: Strategies.Facebook,
                 token_url: "/oauth/access_token"
               }
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


  def client, do: Strategies.client(@service, @bare_client)
  def has_client, do: @service |> Strategies.has_client?
  def del_client, do: @service |> Strategies.del_client
  def set_client(client), do: @service |> Strategies.set_client(client)
  def set_client(id, secret, token) do
    @service |> Strategies.set_client(id, secret, token)
  end

  def take_code(code) do
    [code: code]
    |> Strategies.Facebook.get_token!
    |> set_client
  end

  def set_test_client() do
    set_client(Application.get_env(:soul_gut, :facebook_client_id),
      Application.get_env(:soul_gut, :facebook_client_secret),
      Application.get_env(:soul_gut, :facebook_test_access_token))
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

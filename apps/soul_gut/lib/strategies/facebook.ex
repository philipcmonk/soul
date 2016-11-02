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


  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: Application.get_env(:soul_gut, :facebook_client_id),
      client_secret: Application.get_env(:soul_gut, :facebook_client_secret),
      redirect_uri: Application.get_env(:soul_gut, :authorize_redirect_uri),
      site: "https://graph.facebook.com/v2.8",
      authorize_url: "https://www.facebook.com/v2.8/dialog/oauth",
      token_url: "https://graph.facebook.com/v2.8/oauth/access_token"
    ])
  end

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

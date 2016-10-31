OAuth client libraries for various services.  In general, they
should be usable like this (for service `Service`):

    IO.puts "go to this url:  " <> Strategies.Service.authorize_url!
    code = String.strip(IO.gets "code: ")
    client = Strategies.Service.get_token!(code: code)
    if !client.token.access_token do
      raise client
    else
      client
    end

The `client` contains all authentication state, and the user of
the strategy should be able to just treat it as an opaque blob to
pass into a source or (if it's oauth2) `OAuth2.Client.get()`.

Strategies should only deal with authentication.  Anything
dealing with the actual data should be in `sources/`.

TODO: what if a service doesn't use OAuth2?
TODO: add clients to a global authentication registry.

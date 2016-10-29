# Soul

## Source organization

lib/
  soul.ex
  sources/
    facebook.ex
    github.ex
    spotify.ex
    music.ex
    misc.ex
    ...
  strategies/
    facebook.ex
    github.ex
    spotify.ex
    ...
          

**TODO: Add description**

## Installation

  1. Add soul to your list of dependencies in mix.exs:

        def deps do
          [{:soul, "~> 0.0.1"}]
        end

  2. Ensure soul is started before your application:

        def application do
          [applications: [:soul]]
        end

defmodule ProbMapWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ProbMapWeb, :controller
      use ProbMapWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  @spec static_paths() :: [<<_::40, _::_*8>>, ...]
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  @spec router() :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @spec channel() ::
          {:use, [{:context, ProbMapWeb} | {:end_of_expression, [...]} | {:imports, [...]}, ...],
           [{:__aliases__, [...], [...]}, ...]}
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      use Gettext, backend: ProbMapWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  @spec verified_routes() ::
          {:use, [{:context, ProbMapWeb} | {:end_of_expression, [...]} | {:imports, [...]}, ...],
           [[{any(), any()}, ...] | {:__aliases__, [...], [...]}, ...]}
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ProbMapWeb.Endpoint,
        router: ProbMapWeb.Router,
        statics: ProbMapWeb.static_paths()
    end
  end

  @spec __using__(atom()) :: any()
  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

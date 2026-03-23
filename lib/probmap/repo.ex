defmodule ProbMap.Repo do
  use Ecto.Repo,
    otp_app: :probmap,
    adapter: Ecto.Adapters.SQLite3
end

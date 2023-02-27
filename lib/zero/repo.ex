defmodule Zero.Repo do
  use Ecto.Repo,
    otp_app: :zero,
    adapter: Ecto.Adapters.Postgres
end

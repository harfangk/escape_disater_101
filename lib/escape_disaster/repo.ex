defmodule EscapeDisaster.Repo do
  use Ecto.Repo,
    otp_app: :escape_disaster,
    adapter: Ecto.Adapters.Postgres
end

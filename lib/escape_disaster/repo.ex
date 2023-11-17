defmodule EscapeDisaster.Repo do
  use Ecto.Repo,
    otp_app: :escape_disaster,
    adapter: Ecto.Adapters.Postgres

  # Add PostGIS types to Ecto
  Postgrex.Types.define(
    EscapeDisaster.PostgresTypes,
    [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
    json: Jason
  )
end

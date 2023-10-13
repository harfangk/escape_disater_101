defmodule Mix.Tasks.GetCoordinates do
  @moduledoc "Retrieve x,y coordinates in EPSG:4326 from Naver NCloud Geocoding API based on address.jk"
  @shortdoc "Get coordinates from address"

  import EscapeDisaster.CSV.CivilDefenseShelters

  use Mix.Task

  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
  end
end

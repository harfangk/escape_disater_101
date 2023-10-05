defmodule EscapeDisaster.Utils do
  def camel_cased_map_keys(%Date{} = val), do: val
  def camel_cased_map_keys(%DateTime{} = val), do: val
  def camel_cased_map_keys(%NaiveDateTime{} = val), do: val

  def camel_cased_map_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      {Inflex.camelize(key, :lower), camel_cased_map_keys(val)}
    end
  end

  def camel_cased_map_keys(val), do: val
end

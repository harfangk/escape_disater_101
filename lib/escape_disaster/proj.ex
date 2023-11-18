defmodule EscapeDisaster.Proj do
  @x 20_037_508.34
  @e 2.7182818284
  def epsg_4326_to_epsg_3857({lon, lat}) do
    x = lon * @x / 180

    y =
      :math.log(:math.tan((90 + lat) * :math.pi() / 360)) / (:math.pi() / 180) * @x /
        180

    {x, y}
  end

  def epsg_3857_to_epsg_4326({x, y}) do
    lon = x * 180 / @x

    lat =
      :math.atan(:math.pow(@e, :math.pi() / 180 * (y / (@x / 180)))) / (:math.pi() / 360) - 90

    {lon, lat}
  end
end

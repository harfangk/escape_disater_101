defmodule EscapeDisaster.Proj do
  def epsg_4326_to_epsg_3857([lon, lat]) do
    x = lon * 20_037_508.34 / 180

    y =
      :math.log(:math.tan((90 + lat) * :math.pi() / 360)) / (:math.pi() / 180) * 20_037_508.34 /
        180

    [x, y]
  end
end

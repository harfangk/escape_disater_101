defmodule EscapeDisaster.CSV.CivilDefenseWaterSources do
  alias EscapeDisaster.CivilDefenseWaterSource
  alias NimbleCSV.RFC4180, as: CSV

  def upsert(file_path) do
    file_path
    |> parse()
    |> process()
    |> Stream.run()
  end

  defp parse(file_path, encoding \\ "euc-kr") do
    file_path
    |> File.stream!()
    |> convert_encoding(encoding)
    |> CSV.parse_stream()
  end

  defp convert_encoding(stream, encoding) do
    stream
    |> Stream.map(fn r -> :iconv.convert(encoding, "utf-8", r) end)
  end

  defp process(stream) do
    stream
    |> Stream.chunk_every(100)
    |> Stream.map(fn chunk ->
      entries = 
        chunk
        |> Enum.map(fn row ->
          Task.async(fn -> add_coordinates(row) end)
          |> Task.await()
        end)
        |> serialize_rows()
        |> Enum.filter(fn changeset -> changeset.valid? end)
        |> Enum.map(fn changeset -> changeset.changes end)

      EscapeDisaster.Repo.insert_all(EscapeDisaster.CivilDefenseWaterSource, entries,
        conflict_target: :id,
        on_conflict: :replace_all
      )
    end)
  end

  defp add_coordinates(row) do
    query_result =
      get_addresses(row)
      |> query_addresses()

    case query_result do
      {:ok, {lon, lat}} ->
        {x_3857, y_3857} = EscapeDisaster.Proj.epsg_4326_to_epsg_3857({lon, lat})
        row ++ [lon, lat, x_3857, y_3857]

      {:error, _} ->
        row ++ [nil, nil, nil, nil]
    end
  end

  defp get_addresses(row) do
    road_name_address = Enum.at(row, 19)
    land_lot_number_address = Enum.at(row, 18)

    [road_name_address, land_lot_number_address]
  end

  defp query_addresses(addresses) do
    addresses
    |> Enum.filter(fn s -> s !== "" end)
    |> Enum.reduce_while({:error, :empty_addresses_error}, fn address, _result ->
      case EscapeDisaster.Apis.Naver.get_coordinates(address) do
        {:ok, coordinates} -> {:halt, {:ok, coordinates}}
        {:error, error} -> {:cont, {:error, error}}
      end
    end)
  end

  defp serialize_rows(rows) do
    Enum.map(rows, fn row ->
      CivilDefenseWaterSource.changeset(%CivilDefenseWaterSource{}, serialize(row))
    end)
  end

  defp serialize([
    number,
    open_api_service_name,
    open_api_service_id,
    open_api_local_government_code,
    id,
    license_date,
    license_cancellation_date,
    operation_state_code,
    operation_state_name,
    precise_operation_state_code,
    precise_operation_state_name,
    close_date,
    temporary_close_start_date,
    temporary_close_end_date,
    reopen_date,
    phone_number,
    surface_area,
    land_lot_number_postal_code,
    land_lot_number_address,
    road_name_address,
    road_name_postal_code,
    operator_name,
    source_data_submitted_at,
    data_update_state,
    data_updated_at,
    operator_business_type_name,
    x_epsg_2097,
    y_epsg_2097,
    facility_location,
    facility_type,
    building_name,
    expiration_date,
    lon,
    lat,
    x_epsg_3857,
    y_epsg_3857
  ]) do
    with {parsed_number, _rem} <- Integer.parse(number),
      {parsed_operation_state_code, _rem} <- Integer.parse(operation_state_code),
      {parsed_precise_operation_state_code, _rem} <-
        Integer.parse(precise_operation_state_code),
      {parsed_surface_area, _rem} <- Float.parse(surface_area),
      {:ok, parsed_license_date} <- Date.from_iso8601(license_date),
      {:ok, parsed_license_cancellation_date} <-
        serialize_optional_date(license_cancellation_date),
      {:ok, parsed_close_date} <- serialize_optional_date(close_date),
      {:ok, parsed_temporary_close_start_date} <-
        serialize_optional_date(temporary_close_start_date),
      {:ok, parsed_temporary_close_end_date} <-
        serialize_optional_date(temporary_close_end_date),
      {:ok, parsed_reopen_date} <- serialize_optional_date(reopen_date),
      {:ok, parsed_expiration_date} <- serialize_expiration_date(expiration_date),
      {:ok, parsed_source_data_submitted_at, _offset} <-
        serialize_datetime(source_data_submitted_at),
      {:ok, parsed_data_updated_at, _offset} <- serialize_datetime(data_updated_at) do
      %{
        number: parsed_number,
        open_api_service_name: open_api_service_name,
        open_api_service_id: open_api_service_id,
        open_api_local_government_code: open_api_local_government_code,
        id: id,
        license_date: parsed_license_date,
        license_cancellation_date: parsed_license_cancellation_date,
        operation_state_code: parsed_operation_state_code,
        operation_state_name: operation_state_name,
        precise_operation_state_code: parsed_precise_operation_state_code,
        precise_operation_state_name: precise_operation_state_name,
        close_date: parsed_close_date,
        temporary_close_start_date: parsed_temporary_close_start_date,
        temporary_close_end_date: parsed_temporary_close_end_date,
        reopen_date: parsed_reopen_date,
        phone_number: phone_number,
        surface_area: parsed_surface_area,
        land_lot_number_postal_code: land_lot_number_postal_code,
        land_lot_number_address: land_lot_number_address,
        road_name_address: road_name_address,
        road_name_postal_code: road_name_postal_code,
        operator_name: operator_name,
        source_data_submitted_at: parsed_source_data_submitted_at,
        data_update_state: data_update_state,
        data_updated_at: parsed_data_updated_at,
        operator_business_type_name: operator_business_type_name,
        x_epsg_2097: serialize_optional_float(x_epsg_2097),
        y_epsg_2097: serialize_optional_float(y_epsg_2097),
        facility_location: facility_location,
        facility_type: facility_type,
        building_name: building_name,
        expiration_date: parsed_expiration_date,
        lon: lon,
        lat: lat,
        x_epsg_3857: x_epsg_3857,
        y_epsg_3857: y_epsg_3857,
        geom: %Geo.Point{coordinates: {lon, lat}, srid: 4326}
      }
    else
      _err -> %{}
    end
  end

  defp serialize_optional_date(""), do: {:ok, nil}
  defp serialize_optional_date(date), do: Date.from_iso8601(date)

  defp serialize_expiration_date(""), do: {:ok, nil}

  defp serialize_expiration_date(s) do
    {year, monthdate} = String.split_at(s, 4)
    {month, date} = String.split_at(monthdate, 2)

    Enum.join([year, month, date], "-")
    |> serialize_optional_date()
  end

  defp serialize_datetime(datetime), do: (datetime <> "+09:00") |> DateTime.from_iso8601()
  defp serialize_optional_float(""), do: nil
  defp serialize_optional_float(float), do: Float.parse(float) |> elem(0)
end

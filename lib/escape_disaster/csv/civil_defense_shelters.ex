defmodule EscapeDisaster.CSV.CivilDefenseShelters do
  alias EscapeDisaster.CivilDefenseShelter
  NimbleCSV.define(CivilDefenseShelters, [])

  def parse(file_path, encoding \\ "euc-kr") do
    file_path
    |> build_stream
    |> convert_encoding(encoding)
    |> parse_stream
    |> serialize_rows
    |> filter_valid_rows
  end

  def add_coords(file_path, encoding \\ "euc-kr") do
    file_path
    |> build_stream
    |> convert_encoding(encoding)
    |> parse_stream
  end

  defp build_stream(file_path) do
    file_path
    |> File.stream!()
  end

  defp convert_encoding(stream, encoding) do
    # TODO: Rows with invalid CSV format exists, including double quotes inside cells. Deal with them.
    stream
    |> Stream.map(fn r -> :iconv.convert(encoding, "utf-8", r) end)
  end

  defp parse_stream(stream) do
    CivilDefenseShelters.parse_stream(stream)
  end

  defp serialize_rows(stream) do
    Stream.map(stream, fn row ->
      CivilDefenseShelter.changeset(%CivilDefenseShelter{}, serialize(row))
    end)
  end

  defp get_coordinates(stream) do
    Stream.map(stream, fn row ->
      nil
    end)
  end

  defp filter_valid_rows(stream) do
    Stream.filter(stream, fn changeset -> changeset.valid? end)
  end

  defp serialize([
         number,
         open_api_service_name,
         open_api_service_id,
         open_api_local_government_code,
         shelter_id,
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
         x_coord,
         y_coord,
         shelter_location,
         shelter_type,
         shelter_building_name,
         expiration_date
       ]) do
    with {parsed_number, _rem} <- Integer.parse(number),
         {parsed_operation_state_code, _rem} <- Integer.parse(operation_state_code),
         {parsed_precise_operation_state_code, _rem} <-
           Integer.parse(precise_operation_state_code),
         {parsed_surface_area, _rem} <- Float.parse(surface_area),
         # TODO: Convert from EPSG:2097 to EPSG:3857
         {parsed_x_coord, _rem} <- Float.parse(x_coord),
         {parsed_y_coord, _rem} <- Float.parse(y_coord),
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
        shelter_id: shelter_id,
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
        x_coord: parsed_x_coord,
        y_coord: parsed_y_coord,
        shelter_location: shelter_location,
        shelter_type: shelter_type,
        shelter_building_name: shelter_building_name,
        expiration_date: parsed_expiration_date
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

  def upsert(stream) do
    entries = stream |> Enum.to_list()

    Enum.reduce(entries, Ecto.Multi.new(), fn entry, acc ->
      Ecto.Multi.insert(acc, entry.changes.shelter_id, entry,
        conflict_target: :shelter_id,
        on_conflict: :replace_all
      )
    end)
    |> EscapeDisaster.Repo.transaction()
  end
end

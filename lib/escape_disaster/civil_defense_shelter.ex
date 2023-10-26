defmodule EscapeDisaster.CivilDefenseShelter do
  alias EscapeDisaster.CivilDefenseShelter
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  # 전국민방위대피시설표준데이터
  # https://www.data.go.kr/data/15021098/standard.do

  # 번호	개방서비스명	개방서비스아이디	개방자치단체코드	관리번호	인허가일자	인허가취소일자	영업상태구분코드	영업상태명	
  # 상세영업상태코드	상세영업상태명	폐업일자	휴업시작일자	휴업종료일자	재개업일자	소재지전화	소재지면적	소재지우편번호	
  # 소재지전체주소	도로명전체주소	도로명우편번호	사업장명	최종수정시점	데이터갱신구분	데이터갱신일자	업태구분명	좌표정보(x)	좌표정보(y)	
  # 비상시설위치	시설구분명	시설명건물명	해제일자

  @primary_key false
  schema "civil_defense_shelters" do
    field :number, :integer
    field :open_api_service_name, :string
    field :open_api_service_id, :string
    field :open_api_local_government_code, :string
    field :id, :string, primary_key: true
    field :license_date, :date
    field :license_cancellation_date, :date
    field :operation_state_code, :integer
    field :operation_state_name, :string
    field :precise_operation_state_code, :integer
    field :precise_operation_state_name, :string
    field :close_date, :date
    field :temporary_close_start_date, :date
    field :temporary_close_end_date, :date
    field :reopen_date, :date
    field :phone_number, :string
    field :surface_area, :float
    field :land_lot_number_postal_code, :string
    field :land_lot_number_address, :string
    field :road_name_address, :string
    field :road_name_postal_code, :string
    field :operator_name, :string
    field :source_data_submitted_at, :utc_datetime
    field :data_update_state, :string
    field :data_updated_at, :utc_datetime
    field :operator_business_type_name, :string
    field :x_epsg_2097, :float
    field :y_epsg_2097, :float
    field :facility_location, :string
    field :facility_type, :string
    field :building_name, :string
    field :expiration_date, :date
    field :lon, :float
    field :lat, :float
    field :x_epsg_3857, :float
    field :y_epsg_3857, :float
  end

  def changeset(civil_defense_shelter, params \\ %{}) do
    civil_defense_shelter
    |> cast(params, [
      :number,
      :open_api_service_name,
      :open_api_service_id,
      :open_api_local_government_code,
      :id,
      :license_date,
      :license_cancellation_date,
      :operation_state_code,
      :operation_state_name,
      :precise_operation_state_code,
      :precise_operation_state_name,
      :close_date,
      :temporary_close_start_date,
      :temporary_close_end_date,
      :reopen_date,
      :phone_number,
      :surface_area,
      :land_lot_number_postal_code,
      :land_lot_number_address,
      :road_name_address,
      :road_name_postal_code,
      :operator_name,
      :source_data_submitted_at,
      :data_update_state,
      :data_updated_at,
      :operator_business_type_name,
      :x_epsg_2097,
      :y_epsg_2097,
      :facility_location,
      :facility_type,
      :building_name,
      :expiration_date,
      :lon,
      :lat,
      :x_epsg_3857,
      :y_epsg_3857
    ])
    |> validate_required([
      :number,
      :open_api_service_id,
      :open_api_service_name,
      :open_api_local_government_code,
      :id,
      :license_date,
      :operation_state_name,
      :operation_state_code,
      :precise_operation_state_name,
      :precise_operation_state_code,
      :source_data_submitted_at,
      :data_updated_at,
      :data_update_state,
      :facility_type,
      :lon,
      :lat,
      :x_epsg_3857,
      :y_epsg_3857
    ])
  end

  def get_shelters_to_show({bottom_left_x, bottom_left_y}, {top_right_x, top_right_y}) do
    query =
      from c in CivilDefenseShelter,
        where:
          c.x_epsg_3857 >= ^bottom_left_x and c.x_epsg_3857 <= ^top_right_x and
            c.y_epsg_3857 >= ^bottom_left_y and c.y_epsg_3857 <= ^top_right_y and
            c.operation_state_code == 1,
        select:
          map(c, [
            :id,
            :license_date,
            :road_name_address,
            :road_name_postal_code,
            :x_epsg_3857,
            :y_epsg_3857,
            :operator_name,
            :building_name
          ])

    EscapeDisaster.Repo.all(query)
    |> limit_response_items({bottom_left_x, bottom_left_y}, {top_right_x, top_right_y})
  end

  defp limit_response_items(shelters, {bottom_left_x, bottom_left_y}, {top_right_x, top_right_y})
       when length(shelters) > 100 do
    quarter_x_diff = (top_right_x - bottom_left_x) / 4
    quarter_y_diff = (top_right_y - bottom_left_y) / 4
    new_bottom_left_x = bottom_left_x + quarter_x_diff
    new_bottom_left_y = bottom_left_y + quarter_y_diff
    new_top_right_x = top_right_x - quarter_x_diff
    new_top_right_y = top_right_y - quarter_y_diff

    shelters
    |> Enum.filter(fn s ->
      s.x_epsg_3857 >= new_bottom_left_x and s.x_epsg_3857 <= new_top_right_x and
        s.y_epsg_3857 >= new_bottom_left_y and s.y_epsg_3857 <= new_top_right_y
    end)
    |> limit_response_items(
      {new_bottom_left_x, new_bottom_left_y},
      {new_top_right_x, new_top_right_y}
    )
  end

  defp limit_response_items(shelters, _, _), do: shelters
end

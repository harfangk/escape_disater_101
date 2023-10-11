defmodule EscapeDisaster.CivilDefenseShelter do
  use Ecto.Schema
  import Ecto.Changeset

  # 전국민방위대피시설표준데이터
  # https://www.data.go.kr/data/15021098/standard.do

  # 번호	개방서비스명	개방서비스아이디	개방자치단체코드	관리번호	인허가일자	인허가취소일자	영업상태구분코드	영업상태명	
  # 상세영업상태코드	상세영업상태명	폐업일자	휴업시작일자	휴업종료일자	재개업일자	소재지전화	소재지면적	소재지우편번호	
  # 소재지전체주소	도로명전체주소	도로명우편번호	사업장명	최종수정시점	데이터갱신구분	데이터갱신일자	업태구분명	좌표정보(x)	좌표정보(y)	
  # 비상시설위치	시설구분명	시설명건물명	해제일자

  schema "civil_defense_shelters" do
    field :number, :integer
    field :open_api_service_name, :string
    field :open_api_service_id, :string
    field :open_api_local_government_code, :string
    field :shelter_id, :string
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
    field :x_coord, :float
    field :y_coord, :float
    field :shelter_location, :string
    field :shelter_type, :string
    field :shelter_building_name, :string
    field :expiration_date, :date
  end

  def changeset(civil_defense_shelter, params \\ %{}) do
    civil_defense_shelter
    |> cast(params, [
      :number,
      :open_api_service_name,
      :open_api_service_id,
      :open_api_local_government_code,
      :shelter_id,
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
      :x_coord,
      :y_coord,
      :shelter_location,
      :shelter_type,
      :shelter_building_name,
      :expiration_date
    ])
    |> validate_required([
      :number,
      :open_api_service_id,
      :open_api_service_name,
      :open_api_local_government_code,
      :shelter_id,
      :license_date,
      :operation_state_name,
      :operation_state_code,
      :precise_operation_state_name,
      :precise_operation_state_code,
      :source_data_submitted_at,
      :data_updated_at,
      :data_update_state,
      :x_coord,
      :y_coord,
      :shelter_type
    ])
  end
end

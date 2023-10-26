defmodule EscapeDisaster.Repo.Migrations.CreateCivilDefenseWaterSources do
  use Ecto.Migration

  def change do
    create table(:civil_defense_water_sources, primary_key: false) do
      add :number, :integer, null: false
      add :open_api_service_name, :string, null: false
      add :open_api_service_id, :string, null: false
      add :open_api_local_government_code, :string, null: false
      add :id, :string, null: false, primary_key: true
      add :license_date, :date, null: false
      add :license_cancellation_date, :date
      add :operation_state_code, :integer, null: false
      add :operation_state_name, :string, null: false
      add :precise_operation_state_code, :integer, null: false
      add :precise_operation_state_name, :string, null: false
      add :close_date, :date
      add :temporary_close_start_date, :date
      add :temporary_close_end_date, :date
      add :reopen_date, :date
      add :phone_number, :string
      add :surface_area, :float, null: false
      add :land_lot_number_postal_code, :string
      add :land_lot_number_address, :string
      add :road_name_address, :string
      add :road_name_postal_code, :string
      add :operator_name, :string
      add :source_data_submitted_at, :utc_datetime, null: false
      add :data_update_state, :string, null: false
      add :data_updated_at, :utc_datetime, null: false
      add :operator_business_type_name, :string
      add :x_epsg_2097, :float
      add :y_epsg_2097, :float
      add :facility_location, :string
      add :facility_type, :string, null: false
      add :building_name, :string
      add :expiration_date, :date
      add :lon, :float, null: false
      add :lat, :float, null: false
      add :x_epsg_3857, :float, null: false
      add :y_epsg_3857, :float, null: false
    end

    create index(:civil_defense_water_sources, [:x_epsg_3857])
    create index(:civil_defense_water_sources, [:y_epsg_3857])
    create unique_index(:civil_defense_water_sources, [:id])
  end
end

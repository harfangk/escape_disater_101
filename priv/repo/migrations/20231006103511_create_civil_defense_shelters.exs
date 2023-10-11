defmodule EscapeDisaster.Repo.Migrations.CreateCivilDefenseShelters do
  use Ecto.Migration

  def change do
    create table(:civil_defense_shelters) do
      add :number, :integer, null: false
      add :open_api_service_name, :string, null: false
      add :open_api_service_id, :string, null: false
      add :open_api_local_government_code, :string, null: false
      add :shelter_id, :string, null: false
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
      add :x_coord, :float, null: false
      add :y_coord, :float, null: false
      add :shelter_location, :string
      add :shelter_type, :string, null: false
      add :shelter_building_name, :string
      add :expiration_date, :date
    end

    create index(:civil_defense_shelters, [:x_coord])
    create index(:civil_defense_shelters, [:y_coord])
    create unique_index(:civil_defense_shelters, [:shelter_id])
  end
end

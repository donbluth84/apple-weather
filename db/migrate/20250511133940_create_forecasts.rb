class CreateForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :forecasts do |t|
      t.integer :zip_code, null: false
      t.integer :current_temperature
      t.string  :current_conditions
      t.integer :humidity
      t.integer :wind_speed
      t.string  :wind_direction
      t.float   :barometric_pressure

      t.timestamps
    end
  end
end

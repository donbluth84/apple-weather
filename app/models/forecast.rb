class Forecast < ApplicationRecord
  validates :zip_code, presence: true

  # We need a 'cached' attribute to denote when the UI needs
  # to display a message that the forecast was retrieved within
  # the past 30 minutes
  attr_accessor :cached

  # Constant to convert barometric pressure to imperial values (inHg)
  HPA_TO_INHG_MULTIPLIER = 0.02952998057228

  # Convert barometric pressure from hPa to inHg
  def barometric_pressure=(value)
    pressure = value * HPA_TO_INHG_MULTIPLIER
    write_attribute(:barometric_pressure, pressure.round(2))
  end

  # Convert the wind direction, specified in degrees, into
  # map directions
  def wind_direction=value
    direction = case value
      when 0..23
        'N'
      when 24..67
        'NE'
      when 68..112
        'E'
      when 113..157
        'SE'
      when 158..202
        'S'
      when 203..247
        'SW'
      when 248..292
        'W'
      when 293..337
        'NW'
      when 338..359
        'N'
    end
    write_attribute(:wind_direction, direction)
  end
end

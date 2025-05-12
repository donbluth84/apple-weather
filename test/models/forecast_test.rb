require "test_helper"

class ForecastTest < ActiveSupport::TestCase
  # Verify that cached can be set
  test "allow cached value to be set" do
    forecast = Forecast.new
    forecast.cached = true
    assert_equal(true, forecast.cached)
  end

  # Validate the barometric pressure calculation
  test "convert barometric pressure value" do
    forecast = Forecast.new
    pressure_in_hPa = 1024
    pressure_in_inHg = pressure_in_hPa * Forecast::HPA_TO_INHG_MULTIPLIER
    forecast.barometric_pressure = pressure_in_hPa
    assert_equal(pressure_in_inHg.round(2), forecast.barometric_pressure)
  end

  # Multiple validations of wind angle to wind map direction
  test "convert wind direction value" do
    forecast = Forecast.new
    forecast.wind_direction = 160
    assert_equal('S', forecast.wind_direction)
    forecast.wind_direction = 21
    assert_equal('N', forecast.wind_direction)
    forecast.wind_direction = 240
    assert_equal('SW', forecast.wind_direction)
    forecast.wind_direction = 25
    assert_equal('NE', forecast.wind_direction)
  end
end

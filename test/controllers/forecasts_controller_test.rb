require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get forecasts_url
    assert_response :success
  end

  # Validate show page with proper zip code
  test "should get show page with valid zip code" do
    get forecasts_show_url, params: {zip_code: 20111}
    assert_response :success
  end

  # Validate error when no zip code given
  test "should not proceed with an empty zip code" do
    get forecasts_show_url, params: {zip_code: ''}
    error = assigns(:error)
    assert_equal("You must submit a zip code", error)
  end

  # Validate error when invalid zip code given
  test "should not proceed with a zip code that is not 5 digits long" do
    get forecasts_show_url, params: {zip_code: '1'}
    error = assigns(:error)
    assert_equal("You must submit a 5 digit zip code", error)
  end

  # Validate error when invalid zip code given
  test "should not proceed with a zip code containing anything but 5 digits" do
    get forecasts_show_url, params: {zip_code: '123a5'}
    error = assigns(:error)
    assert_equal("You must submit a 5 digit zip code", error)
  end

  # Validate the data being retrieved for a valid zip code
  test "a new zip code should create a record in the database and not set cached" do
    get forecasts_show_url, params: {zip_code: 20111}
    forecast = assigns(:forecast)
    assert_equal(20111, forecast.zip_code)
    assert_not_nil(forecast.current_temperature)
    assert_not_nil(forecast.current_conditions)
    assert_not_nil(forecast.humidity)
    assert_not_nil(forecast.wind_speed)
    assert_not_nil(forecast.wind_direction)
    assert_not_nil(forecast.barometric_pressure)
    assert_not_equal(true, forecast.cached)
  end

  # Validate the data not being retrieved for a valid zip code when is has not been 30 minutes since last pull
  test "a repeated zip code within 30 minutes should not update a record in the database and set cached" do
    get forecasts_show_url, params: {zip_code: 20111}
    forecast = assigns(:forecast)
    assert_equal(20111, forecast.zip_code)
    assert_not_nil(forecast.current_temperature)
    assert_not_nil(forecast.current_conditions)
    assert_not_nil(forecast.humidity)
    assert_not_nil(forecast.wind_speed)
    assert_not_nil(forecast.wind_direction)
    assert_not_nil(forecast.barometric_pressure)

    updated_at = forecast.updated_at

    get forecasts_show_url, params: {zip_code: 20111}
    forecast = assigns(:forecast)
    assert_equal(updated_at, forecast.updated_at)
    assert_equal(true, forecast.cached)
  end

  # Validate the data being retrieved for a valid zip code when it has been longer than 30 minutes since last call
  test "a repeated zip code after 30 minutes should update a record in the database and not set cached" do
    get forecasts_show_url, params: {zip_code: 20111}
    forecast = assigns(:forecast)
    assert_equal(20111, forecast.zip_code)
    assert_not_nil(forecast.current_temperature)
    assert_not_nil(forecast.current_conditions)
    assert_not_nil(forecast.humidity)
    assert_not_nil(forecast.wind_speed)
    assert_not_nil(forecast.wind_direction)
    assert_not_nil(forecast.barometric_pressure)

    updated_at = "2010-01-01 00:00:00"
    forecast.update_attribute(:updated_at, updated_at)

    get forecasts_show_url, params: {zip_code: 20111}
    forecast = assigns(:forecast)
    assert_not_equal(updated_at, forecast.updated_at)
    assert_not_equal(true, forecast.cached)
  end

  # Validate that a non-existant 5 digit zip code will return an error
  test "a call with a non-existant zip code should return an error" do
    get forecasts_show_url, params: {zip_code: 11111}
    error = assigns(:error)
    assert_equal("You must submit a valid zip code", error)
  end
end

require 'uri'
require 'net/http'

class ForecastsController < ApplicationController
  # Forecast page comes here first, only displaying form
  def index
  end

  # Once an address/zip code is entered, show is called
  def show
    @zip_code = forecast_params[:zip_code]
    # Verify that the zip code as entered is validated to be a 5 digit number
    if @zip_code.empty?
      @error = "You must submit a zip code"
      return
    end
    if @zip_code !~ /\d{5}/
      @error = "You must submit a 5 digit zip code"
      return
    end

    # See if there is a current forecast for that zip code in the database
    @forecast = Forecast.find_by_zip_code(@zip_code)

    # If it doesn' exist, or is the data is more than 30 minute old, we need to refresh it
    if @forecast.nil? || @forecast.updated_at < Time.now - 30.minutes
      latest_forecast = retrieve_forecast @zip_code
      # All errors are returned to the UI via defining @error
      if @error
        return
      end
      @forecast = update_forecast latest_forecast
    else
      # Otherwise, we set the 'cached' value to true for the UI
      @forecast.cached = true
    end

    @forecast
  end

  private
    def forecast_params
      # At the moment, the only parameter being used is the zip code
      params.permit(:zip_code)
    end

    def update_forecast forecast
      # Create or update the forecast record within the database
      begin
        if @forecast.nil?
          @forecast = Forecast.create!(
            zip_code: @zip_code,
            current_temperature: forecast[:current_temperature],
            current_conditions: forecast[:current_conditions],
            humidity: forecast[:humidity],
            wind_speed: forecast[:wind_speed],
            wind_direction: forecast[:wind_direction],
            barometric_pressure: forecast[:barometric_pressure]
          )
        else
          @forecast.update!(
            current_temperature: forecast[:current_temperature],
            current_conditions: forecast[:current_conditions],
            humidity: forecast[:humidity],
            wind_speed: forecast[:wind_speed],
            wind_direction: forecast[:wind_direction],
            barometric_pressure: forecast[:barometric_pressure]
          )
          # Just in case the values do not change, we want to make sure
          # that the updated_at time is adjusted
          @forecast.touch
          @forecast.reload
        end
      rescue
        @error = "There was a problem updating the database"
      end
    end

    # Gather the forecast data from openweathermap
    def retrieve_forecast zip_code
      retrieved_forecast = find_forecast @zip_code
      if @error
        return
      end

      # Validate that we have data (a 'cod' of 200
      forecast_hash = JSON.parse(retrieved_forecast)
      if forecast_hash['cod'] != 200
        @error = "You must submit a valid zip code"
        return
      end

      # Return the hash of forecast values
      return {
        current_temperature: forecast_hash['main']['temp'].round(),
        current_conditions: forecast_hash['weather'][0]['main'],
        humidity: forecast_hash['main']['humidity'],
        wind_speed: forecast_hash['wind']['speed'],
        wind_direction: forecast_hash['wind']['deg'],
        barometric_pressure: forecast_hash['main']['pressure']
      }
    end

    # Actually retrieve the forecast from the openweathermap.org API
    def find_forecast zip_code
      url = URI(
              "https://api.openweathermap.org/data/2.5/weather?" +
              "zip=#{zip_code}&" +
              "appid=#{Rails.application.credentials.weather_api_key}" +
              "&units=imperial"
            )

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)

      begin
        response = http.request(request)
      rescue
        @error = "Could not retrieve current weather"
        return
      end
 
f=File.open('/tmp/weather','w')
f.write(response.body)
f.close

      response.body
    end
end

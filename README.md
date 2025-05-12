James A. MacKenzie weather application

* Ruby version
The required ruby version is 3.2.2

* System dependencies
This relies upon sqlite3, and the following gems:
Rails 8.0.2 Gem
SQLite3 2.6 Gem

* Configuration
In order for the system to work, you need to obtain a free API key from
https://home.openweathermap.org/users/sign_up

This will allow you to gather the necessary current weather information.

You will need to add the api key to the configuration by running:

rails credentials:edit

And add:
weather_api_key: <your api key>

* Database creation
The database is currently relatively simple and can just be migrated by a standard rails db:migrate

* Database
The database consists of one table "forecasts" which contain the following column types (beyond the standard Rails columns):

  t.integer :zip_code, null: false
  t.integer :current_temperature
  t.string  :current_conditions
  t.integer :humidity
  t.integer :wind_speed
  t.string  :wind_direction
  t.float   :barometric_pressure

* How to run the test suite
To run the test suite, simply run rails test

* Considerations
The project was to take an address and look up the weather.  Another stipulation was to save the weather
per zip code and use that as a cached value for 30 minutes.

openweathermap.org already has an API that uses the zip code.

Due to the openness allowed in interpretation, for this implementation, the form does request a full address, as it was in the instructions.

However, only the zip code is currently being utilized, due to the methods available at openweathermap.org

The call being made to api.openweathermap.org follows the below format:

https://api.openweathermap.org/data/2.5/weather?zip={zip code}&appid={api key}&units=imperial

"units=imperial" added to get the results in standard fahrenheit/etc values.

Data returned via api.openweathermap.org will look like this:

{
  "coord": {
    "lon": -80.0177,
    "lat": 42.1553
  },
  "weather": [
    {
      "id": 802,
      "main": "Clouds", // This is used as current_conditions
      "description": "scattered clouds",
      "icon": "03d"
    }
  ],
  "base": "stations",
  "main": {
    "temp": 72.27, // This is used as current_temperature
    "feels_like": 72.01,
    "temp_min": 72.27,
    "temp_max": 72.27,
    "pressure": 1022, // This is used as barometric_pressure (after conversion)
    "humidity": 60, // This is used as humidity
    "sea_level": 1022,
    "grnd_level": 991
  },
  "visibility": 10000,
  "wind": {
    "speed": 2.89, // This is used as wind_speed
    "deg": 164, // This is used as wind_direction (after conversion)
    "gust": 5.84
  },
  "clouds": {
    "all": 27
  },
  "dt": 1747061027,
  "sys": {
    "country": "US",
    "sunrise": 1747044126,
    "sunset": 1747096251
  },
  "timezone": -14400,
  "id": 0,
  "name": "Erie",
  "cod": 200
}

'cod' will come back as a 200 for success.  Any other code will be a failure.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using WpfApp123123.Models;

namespace WpfApp123123.Services
{
    class WeatherService
    {
        private readonly HttpClient _client;
        private const string API_KEY = "677a82b5f2e455cdf96abef8144ad21e";
        private const string baseUrl = "https://api.openweathermap.org/data/2.5/weather?q={0}&appid={1}&units=metric";

        public WeatherService()
        {
            this._client = new HttpClient();
        }

        public async Task<WeatherModel> GetWeatherInfo(string city)
        {
            string url = string.Format(baseUrl, city, API_KEY);

            HttpResponseMessage response = await _client.GetAsync(url);

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("Failed to fetch information");
            }

            string jsonResponse = await response.Content.ReadAsStringAsync();

            // Trace.WriteLine(jsonResponse);

            MemoryStream stream = new MemoryStream(Encoding.UTF8.GetBytes(jsonResponse));
            JsonSerializerOptions options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };

            WeatherModel weather = await JsonSerializer.DeserializeAsync<WeatherModel>(stream, options);

            string save_json = JsonSerializer.Serialize(weather);

            File.WriteAllText("D:\\Programko\\UJEP\\GUI\\wpf_app\\WpfApp123123\\WpfApp123123\\cache.json", save_json);


            return weather;
        }

        // cpu-bound operations, have to by sync
        public string ConvertTime(long datetime, int offset)
        {
            DateTimeOffset utcDateTime = DateTimeOffset.FromUnixTimeSeconds(datetime);

            TimeSpan utcOffset = TimeSpan.FromSeconds(offset);
            DateTimeOffset localDateTime = utcDateTime.ToOffset(utcOffset);

            string formattedTime = localDateTime.ToString("HH:mm");

            return formattedTime;
        }

        public WeatherModel LoadCachedWeatherData(string filePath)
        {
            if (File.Exists(filePath))
            {
                // Read the JSON string from the file
                string jsonString = File.ReadAllText(filePath);

                // Deserialize the JSON string back into a WeatherData object
                WeatherModel weatherData = JsonSerializer.Deserialize<WeatherModel>(jsonString);

                return weatherData;
            }

            return null; // No cached data found
        }
    }
}
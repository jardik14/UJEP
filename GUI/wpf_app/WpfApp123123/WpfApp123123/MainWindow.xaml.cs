using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

using WpfApp123123.Models;
using WpfApp123123.Services;

namespace WpfApp123123;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    private readonly WeatherService _weatherService;

    public MainWindow()
    {
        InitializeComponent();

        this._weatherService = new WeatherService();
    }

    // cpu-bound
    private void UpdateSunPosition(long sunriseUnix, long sunsetUnix, long currentUnix)
    {
        bool isDaytime = currentUnix > sunriseUnix && currentUnix < sunsetUnix;

        if (!isDaytime)
        {
            SunStroke.Stroke = new SolidColorBrush(Color.FromRgb(170, 170, 200));
            Sun.Visibility = Visibility.Collapsed;
            return;
        }
        else
        {
            SunStroke.Stroke = new SolidColorBrush(Color.FromRgb(255, 165, 0));
            Sun.Visibility = Visibility.Visible;
        }

        // Ensure current time is within bounds
        currentUnix = Math.Max(sunriseUnix, Math.Min(currentUnix, sunsetUnix));

        // Calculate progress of the sun across the day (0 to 1)
        double progress = (double)(currentUnix - sunriseUnix) / (sunsetUnix - sunriseUnix);

        // Arc path parameters (matching the XAML ArcSegment)
        double startX = 0;
        double endX = 300;
        double radiusX = 150;
        double radiusY = 100;
        double centerX = (startX + endX) / 2;
        double centerY = 120;  // Base height of the arc

        // Parametric equation for an ellipse (to get the sun's X, Y)
        double angle = progress * Math.PI;  // Progress mapped to [0, π]
        double sunX = centerX + radiusX * Math.Cos(angle);
        double sunY = centerY - radiusY * Math.Sin(angle); // Inverted to go upwards

        // Create DoubleAnimation to move the sun smoothly in X and Y
        DoubleAnimation moveSunX = new DoubleAnimation
        {
            From = Canvas.GetLeft(Sun),
            To = sunX - Sun.Width / 2,
            Duration = TimeSpan.FromSeconds(1),
            //EasingFunction = new QuadraticEase() { EasingMode = EasingMode.EaseInOut }
        };

        DoubleAnimation moveSunY = new DoubleAnimation
        {
            From = Canvas.GetTop(Sun),
            To = sunY - Sun.Height / 2,
            Duration = TimeSpan.FromSeconds(1),
            //EasingFunction = new QuadraticEase() { EasingMode = EasingMode.EaseInOut }
        };

        // Apply animations to the sun's position
        Sun.BeginAnimation(Canvas.LeftProperty, moveSunX);
        Sun.BeginAnimation(Canvas.TopProperty, moveSunY);
    }



    private async void Search_Click(object sender, RoutedEventArgs e)
    {
        string city = CityName.Text;

        string cacheFilePath = "D:\\Programko\\UJEP\\GUI\\wpf_app\\WpfApp123123\\WpfApp123123\\cache.json";

        try
        {
            if (File.Exists(cacheFilePath))
            {
                WeatherModel old_weather = _weatherService.LoadCachedWeatherData(cacheFilePath);

                CityNameTextOld.Text = $"{old_weather.name} (old)";
                TemperatureTextOld.Text = string.Format("Temperature was: {0:N2}", old_weather.main.temp);
                FeelsLikeTextOld.Text = $"Felt like: {old_weather.main.feelsLike}";
                HumidityTextOld.Text = $"Humidity was: {old_weather.main.humidity}";
                CloudsTextOld.Text = $"Clouds were: {old_weather.main.clouds}";
                DescriptionTextOld.Text = $"Description was: {old_weather.weather[0].description}";

                string oldTime = _weatherService.ConvertTime(old_weather.datetime, old_weather.timezoneOffset);
                CurrentTimeTextOld.Text = $"Old time in {old_weather.name}: {oldTime}";
            }

            WeatherModel weather = await _weatherService.GetWeatherInfo(city);

            CityNameText.Text = weather.name;
            TemperatureText.Text = string.Format("Temperature: {0:N2}", weather.main.temp);
            FeelsLikeText.Text = $"Feels like: {weather.main.feelsLike}";
            HumidityText.Text = $"Humidity: {weather.main.humidity}";
            CloudsText.Text = $"Clouds: {weather.main.clouds}";
            DescriptionText.Text = $"Description: {weather.weather[0].description}";

            UpdateSunPosition(weather.sys.sunrise, weather.sys.sunset, weather.datetime);

            string currentTime = _weatherService.ConvertTime(weather.datetime, weather.timezoneOffset);
            CurrentTimeText.Text = $"Current time in {weather.name}: {currentTime}";

            SunCanvas.Visibility = Visibility.Visible;

            string sunriseTime = _weatherService.ConvertTime(weather.sys.sunrise, weather.timezoneOffset);
            SunriseText.Text = sunriseTime;

            string sunsetTime = _weatherService.ConvertTime(weather.sys.sunset, weather.timezoneOffset);
            SunsetText.Text = sunsetTime;

            // 🔥 Fetch and set weather icon
            if (weather.weather[0].description != null)
            {
                string iconCode = weather.weather[0].icon; // Get icon code from API response
                string iconUrl = $"https://openweathermap.org/img/wn/{iconCode}@2x.png";

                WeatherIcon.Source = new BitmapImage(new Uri(iconUrl, UriKind.Absolute));
            }
        }
        catch (Exception ex)
        {
            Trace.WriteLine("Error!");
        }
    }

}
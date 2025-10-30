import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Clock, 
  MapPin, 
  Thermometer, 
  Droplets, 
  Wind, 
  RefreshCw,
  Sun,
  Cloud
} from 'lucide-react';

const API_BASE = process.env.REACT_APP_API_URL || '/api';

function App() {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [location, setLocation] = useState(null);
  const [weather, setWeather] = useState(null);
  const [forecast, setForecast] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [refreshing, setRefreshing] = useState(false);

  // Update time every second
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  // Load initial data
  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Get user location
      const locationResponse = await axios.get(`${API_BASE}/location`);
      const locationData = locationResponse.data;
      setLocation(locationData);

      // Get weather data
      const weatherResponse = await axios.get(`${API_BASE}/weather`, {
        params: {
          lat: locationData.lat,
          lon: locationData.lon
        }
      });
      setWeather(weatherResponse.data);

      // Get forecast data
      const forecastResponse = await axios.get(`${API_BASE}/forecast`, {
        params: {
          lat: locationData.lat,
          lon: locationData.lon
        }
      });
      setForecast(forecastResponse.data);

    } catch (err) {
      console.error('Error loading data:', err);
      setError('Failed to load weather data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const formatTime = (date, timezone) => {
    try {
      return date.toLocaleTimeString('en-US', {
        timeZone: timezone,
        hour12: false,
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
    } catch (error) {
      return date.toLocaleTimeString('en-US', {
        hour12: false,
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
    }
  };

  const formatDate = (date, timezone) => {
    try {
      return date.toLocaleDateString('en-US', {
        timeZone: timezone,
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    } catch (error) {
      return date.toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      });
    }
  };

  if (loading) {
    return (
      <div className="container">
        <div className="loading">
          <RefreshCw className="animate-spin" size={48} />
          <p>Loading weather data...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container">
      <header className="header">
        <h1>Weather Dashboard</h1>
        <p>Real-time weather and time information</p>
      </header>

      {error && (
        <div className="error">
          {error}
        </div>
      )}

      <div className="dashboard">
        {/* Time Card */}
        <div className="card">
          <h2>
            <Clock size={24} />
            Current Time
          </h2>
          <div className="time-display">
            {formatTime(currentTime, location?.timezone)}
          </div>
          <div className="date-display">
            {formatDate(currentTime, location?.timezone)}
          </div>
          {location?.timezone && (
            <div className="timezone">
              {location.timezone}
            </div>
          )}
        </div>

        {/* Weather Card */}
        {weather && (
          <div className="card">
            <h2>
              <Sun size={24} />
              Current Weather
            </h2>
            <div className="weather-main">
              <img 
                src={`https://openweathermap.org/img/wn/${weather.icon}@2x.png`}
                alt={weather.description}
                className="weather-icon"
              />
              <div className="temperature">
                {weather.temperature}°C
              </div>
            </div>
            <div className="weather-description">
              {weather.description}
            </div>
            <div className="weather-details">
              <div className="weather-detail">
                <Droplets size={16} />
                Humidity: {weather.humidity}%
              </div>
              <div className="weather-detail">
                <Wind size={16} />
                Wind: {weather.windSpeed} m/s
              </div>
            </div>
            {location && (
              <div className="location">
                <MapPin size={16} />
                {location.city}, {location.country}
              </div>
            )}
          </div>
        )}

        {/* Location Card */}
        {location && (
          <div className="card">
            <h2>
              <MapPin size={24} />
              Your Location
            </h2>
            <p><strong>City:</strong> {location.city}</p>
            <p><strong>Country:</strong> {location.country}</p>
            <p><strong>Coordinates:</strong> {location.lat.toFixed(4)}, {location.lon.toFixed(4)}</p>
            <p><strong>Timezone:</strong> {location.timezone}</p>
          </div>
        )}
      </div>

      {/* Forecast */}
      {forecast.length > 0 && (
        <div className="card">
          <h2>
            <Cloud size={24} />
            5-Day Forecast
          </h2>
          <div className="forecast">
            {forecast.map((day, index) => (
              <div key={index} className="forecast-item">
                <div className="forecast-date">{day.date}</div>
                <img 
                  src={`https://openweathermap.org/img/wn/${day.icon}.png`}
                  alt={day.description}
                  className="forecast-icon"
                />
                <div className="forecast-temp">{day.temperature}°C</div>
                <div className="forecast-desc">{day.description}</div>
              </div>
            ))}
          </div>
        </div>
      )}

      <button 
        className="refresh-btn" 
        onClick={handleRefresh}
        disabled={refreshing}
      >
        <RefreshCw size={16} className={refreshing ? 'animate-spin' : ''} />
        {refreshing ? 'Refreshing...' : 'Refresh Data'}
      </button>
    </div>
  );
}

export default App;
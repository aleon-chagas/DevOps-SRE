const express = require('express');
const cors = require('cors');
const axios = require('axios');
const redis = require('redis');
const client = require('prom-client');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestsTotal = new client.Counter({
  name: 'weather_api_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new client.Histogram({
  name: 'weather_api_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  registers: [register]
});

const weatherApiCalls = new client.Counter({
  name: 'weather_external_api_calls_total',
  help: 'Total calls to external weather API',
  labelNames: ['provider', 'status'],
  registers: [register]
});

const cacheHits = new client.Counter({
  name: 'weather_cache_hits_total',
  help: 'Total cache hits',
  registers: [register]
});

const cacheMisses = new client.Counter({
  name: 'weather_cache_misses_total',
  help: 'Total cache misses',
  registers: [register]
});

// Redis client
let redisClient;
(async () => {
  try {
    redisClient = redis.createClient({
      url: process.env.REDIS_URL || 'redis://redis-service:6379'
    });
    await redisClient.connect();
    console.log('✅ Connected to Redis');
  } catch (error) {
    console.log('❌ Redis connection failed:', error.message);
    redisClient = null;
  }
})();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
});
app.use('/api/', limiter);

// Metrics middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestsTotal.inc({
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    });
    httpRequestDuration.observe({
      method: req.method,
      route: req.route?.path || req.path
    }, duration);
  });
  
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    redis: redisClient ? 'connected' : 'disconnected'
  });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Get user location by IP
app.get('/api/location', async (req, res) => {
  try {
    const clientIP = req.headers['x-forwarded-for'] || 
                    req.connection.remoteAddress || 
                    req.socket.remoteAddress ||
                    '8.8.8.8'; // fallback for local testing

    const cacheKey = `location:${clientIP}`;
    
    // Check cache first
    if (redisClient) {
      try {
        const cached = await redisClient.get(cacheKey);
        if (cached) {
          cacheHits.inc();
          return res.json(JSON.parse(cached));
        }
      } catch (error) {
        console.log('Cache read error:', error.message);
      }
    }
    
    cacheMisses.inc();
    
    // Get location from IP
    const response = await axios.get(`http://ip-api.com/json/${clientIP}`);
    weatherApiCalls.inc({ provider: 'ip-api', status: 'success' });
    
    const locationData = {
      city: response.data.city,
      country: response.data.country,
      lat: response.data.lat,
      lon: response.data.lon,
      timezone: response.data.timezone
    };
    
    // Cache for 1 hour
    if (redisClient) {
      try {
        await redisClient.setEx(cacheKey, 3600, JSON.stringify(locationData));
      } catch (error) {
        console.log('Cache write error:', error.message);
      }
    }
    
    res.json(locationData);
  } catch (error) {
    weatherApiCalls.inc({ provider: 'ip-api', status: 'error' });
    console.error('Location error:', error.message);
    res.status(500).json({ error: 'Failed to get location' });
  }
});

// Get current time
app.get('/api/time', async (req, res) => {
  try {
    const { timezone } = req.query;
    const now = new Date();
    
    const timeData = {
      utc: now.toISOString(),
      local: timezone ? 
        now.toLocaleString('en-US', { timeZone: timezone }) : 
        now.toLocaleString(),
      timestamp: now.getTime(),
      timezone: timezone || 'UTC'
    };
    
    res.json(timeData);
  } catch (error) {
    console.error('Time error:', error.message);
    res.status(500).json({ error: 'Failed to get time' });
  }
});

// Get weather data
app.get('/api/weather', async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }
    
    const cacheKey = `weather:${lat}:${lon}`;
    
    // Check cache first (5 minutes)
    if (redisClient) {
      try {
        const cached = await redisClient.get(cacheKey);
        if (cached) {
          cacheHits.inc();
          return res.json(JSON.parse(cached));
        }
      } catch (error) {
        console.log('Cache read error:', error.message);
      }
    }
    
    cacheMisses.inc();
    
    const API_KEY = process.env.OPENWEATHER_API_KEY || 'demo_key';
    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`;
    
    const response = await axios.get(url);
    weatherApiCalls.inc({ provider: 'openweather', status: 'success' });
    
    const weatherData = {
      temperature: Math.round(response.data.main.temp),
      description: response.data.weather[0].description,
      humidity: response.data.main.humidity,
      windSpeed: response.data.wind.speed,
      icon: response.data.weather[0].icon,
      city: response.data.name,
      country: response.data.sys.country
    };
    
    // Cache for 5 minutes
    if (redisClient) {
      try {
        await redisClient.setEx(cacheKey, 300, JSON.stringify(weatherData));
      } catch (error) {
        console.log('Cache write error:', error.message);
      }
    }
    
    res.json(weatherData);
  } catch (error) {
    weatherApiCalls.inc({ provider: 'openweather', status: 'error' });
    console.error('Weather error:', error.message);
    res.status(500).json({ error: 'Failed to get weather data' });
  }
});

// Get weather forecast
app.get('/api/forecast', async (req, res) => {
  try {
    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }
    
    const cacheKey = `forecast:${lat}:${lon}`;
    
    // Check cache first (30 minutes)
    if (redisClient) {
      try {
        const cached = await redisClient.get(cacheKey);
        if (cached) {
          cacheHits.inc();
          return res.json(JSON.parse(cached));
        }
      } catch (error) {
        console.log('Cache read error:', error.message);
      }
    }
    
    cacheMisses.inc();
    
    const API_KEY = process.env.OPENWEATHER_API_KEY || 'demo_key';
    const url = `https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`;
    
    const response = await axios.get(url);
    weatherApiCalls.inc({ provider: 'openweather', status: 'success' });
    
    // Process forecast data (next 5 days, one per day)
    const forecastData = response.data.list
      .filter((item, index) => index % 8 === 0) // Every 24 hours
      .slice(0, 5)
      .map(item => ({
        date: new Date(item.dt * 1000).toLocaleDateString(),
        temperature: Math.round(item.main.temp),
        description: item.weather[0].description,
        icon: item.weather[0].icon
      }));
    
    // Cache for 30 minutes
    if (redisClient) {
      try {
        await redisClient.setEx(cacheKey, 1800, JSON.stringify(forecastData));
      } catch (error) {
        console.log('Cache write error:', error.message);
      }
    }
    
    res.json(forecastData);
  } catch (error) {
    weatherApiCalls.inc({ provider: 'openweather', status: 'error' });
    console.error('Forecast error:', error.message);
    res.status(500).json({ error: 'Failed to get forecast data' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Weather API running on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`❤️  Health check at http://localhost:${PORT}/health`);
});
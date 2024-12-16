import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController();
  String? _temperature;
  String? _description;
  String? _cityName;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name.';
        _temperature = null;
        _description = null;
        _cityName = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const apiKey = 'API_KEY'; // Replace with OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = data['main']['temp'].toString();
          _description = data['weather'][0]['description'];
          _cityName = data['name'];
        });
      } else {
        setState(() {
          _errorMessage = 'City not found. Please try again.';
          _temperature = null;
          _description = null;
          _cityName = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to fetch weather. Please try again later.';
        _temperature = null;
        _description = null;
        _cityName = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => fetchWeather(_cityController.text),
                child: const Text('Get Weather')),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (_temperature != null &&
                _description != null &&
                _cityName != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_cityName',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_temperature\u00b0c',
                        style: const TextStyle(fontSize: 48),
                      ),
                      Text(
                        '$_description',
                        style: const TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

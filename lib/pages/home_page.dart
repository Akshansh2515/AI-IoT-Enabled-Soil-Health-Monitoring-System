import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../soil_parameter.dart';
import 'crop_selection_page.dart';
import 'package:shm/constants.dart';

const String WEATHER_API_KEY =
    "ea234ca963df621a5a93413217dce69b"; // Replace with your actual API key

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Parameters for the sliders
  double nitrogen = SoilParameters.nitrogen;
  double phosphorus = SoilParameters.phosphorus;
  double potassium = SoilParameters.potassium;
  String selectedCity = "Ghaziabad"; // Default city
  String selectedSoilType = "Loamy"; // Default soil type
  String weatherError = "";

  double temperature = 0.0;
  double humidity = 0.0;
  double rainfall = 0.0;
  double pHLevel = 5.9 + Random().nextDouble() * (7.9 - 5.9);
  String recommendedCrop = '🌾 Rice';
  int _selectedIndex = 0;

  Future<String> getLocationByIP() async {
    try {
      final response = await http.get(Uri.parse("https://ipinfo.io/json"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['city'] ?? 'Delhi';
      } else {
        if (kDebugMode) {
          print("Failed to get location by IP: ${response.statusCode}");
        }
        return 'Delhi';
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location by IP: $e");
      }
      return 'Delhi';
    }
  }

  Future<Map<String, dynamic>?> getWeatherData(String city) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city,India&appid=$WEATHER_API_KEY&units=metric");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "temperature": data["main"]["temp"] as double,
          "humidity": data["main"]["humidity"] as int,
          "rainfall": data.containsKey('rain') &&
                  data['rain'] != null &&
                  data['rain'].containsKey('1h')
              ? data['rain']['1h'] as double
              : double.parse(
                  (Random().nextDouble() * (200 - 80) + 80).toStringAsFixed(2)),
          "ph": double.parse(
              (Random().nextDouble() * (7.5 - 5.5) + 5.5).toStringAsFixed(1)),
        };
      } else {
        if (kDebugMode) {
          print("Failed to get weather data for $city: ${response.statusCode}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting weather data for $city: $e");
      }
      return null;
    }
  }

  Future<void> fetchWeatherData({String? specificCity}) async {
    String cityToFetch = specificCity ?? selectedCity;
    final weatherData = await getWeatherData(cityToFetch);

    if (weatherData != null) {
      setState(() {
        temperature = weatherData['temperature'];
        humidity = weatherData['humidity'].toDouble();
        rainfall = weatherData['rainfall'];
        pHLevel = weatherData['ph'];
        weatherError = "";
      });
    } else {
      setState(() {
        weatherError = "⚠️ Error fetching weather data for $cityToFetch";
        temperature = 0.0;
        humidity = 0.0;
        rainfall = generateRainfall();
        pHLevel = 5.9 + Random().nextDouble() * (7.9 - 5.9);
      });
    }
  }

  double generateRainfall() {
    return double.parse(
        (Random().nextDouble() * (200 - 80) + 80).toStringAsFixed(2));
  }

  Future<void> recommendCropUsingModel() async {
    try {
      final interpreter =
          await Interpreter.fromAsset('asset/crop_recommendation_model.tflite');

      final input = [
        [
          nitrogen,
          phosphorus,
          potassium,
          pHLevel,
          temperature,
          humidity,
          rainfall,
        ]
      ];

      final output = List.filled(1 * 22, 0.0).reshape([1, 22]);

      interpreter.run(input, output);

      final cropIndex =
          output[0].map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b);

      final recommendedCropIndex = output[0].indexOf(cropIndex);

      setState(() {
        recommendedCrop = ' ${crops[recommendedCropIndex]}';
      });

      interpreter.close();
    } catch (e) {
      setState(() {
        recommendedCrop = '❌ Error: $e';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      storeParameters();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CropSelectionPage()),
      );
    }
  }

  void storeParameters() {
    SoilParameters.nitrogen = nitrogen;
    SoilParameters.phosphorus = phosphorus;
    SoilParameters.potassium = potassium;
    SoilParameters.pHLevel = pHLevel;
    SoilParameters.temperature = temperature;
    SoilParameters.humidity = humidity;
    SoilParameters.rainfall = rainfall;
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // Light green background
      appBar: AppBar(
        title: const Text('🌿 Soil Health Monitor 🌿'),
        centerTitle: true, // Center the title
        titleTextStyle: const TextStyle(fontSize: 24), // Make the title larger
        backgroundColor: Colors.green[400], // Darker green app bar
      ),
      body: _buildHomePage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.green[400],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Crop',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Selector
          const Text(
            '📍 Select City',
            style: TextStyle(
                color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: selectedCity,
              isExpanded: true,
              dropdownColor: Colors.lightGreen[100],
              items: cities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value!;
                  fetchWeatherData(specificCity: value);
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '⚙️ Adjust Soil Parameters',
            style: TextStyle(
                color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          // Sliders for parameters
          _buildSlider("💧 Nitrogen (N)", nitrogen, 0, 100, (value) {
            setState(() => nitrogen = value);
          }),
          _buildSlider("🧪 Phosphorus (P)", phosphorus, 0, 100, (value) {
            setState(() => phosphorus = value);
          }),
          _buildSlider("🪴 Potassium (K)", potassium, 0, 100, (value) {
            setState(() => potassium = value);
          }),
          const SizedBox(height: 20),
          // Soil Type Selector
          const Text(
            '🌍 Select Soil Type',
            style: TextStyle(
                color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: selectedSoilType,
              isExpanded: true,
              dropdownColor: Colors.lightGreen[100],
              items: soilTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSoilType = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          // Display Weather Data
          if (weatherError.isEmpty) ...[
            _buildResultCard("🌡️ Temperature", "${temperature.toString()} °C"),
            _buildResultCard("💧 Humidity", "${humidity.toString()} %"),
            _buildResultCard("🌧️ Rainfall", "${rainfall.toString()} mm"),
            _buildResultCard("🧪 pH Level", pHLevel.toStringAsFixed(2)),
          ],
          if (weatherError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                weatherError,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          const SizedBox(height: 30),
          // Crop Recommendation Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[300],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 3,
            ),
            onPressed: recommendCropUsingModel,
            child: const Text(
              '🌿 Get Crop Recommendation',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          // Recommended Crop Display
          _buildResultCard(
            "🌱 Recommended Crop",
            recommendedCrop,
            resultTextStyle: const TextStyle(fontSize: 16), // Reduced font size
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(color: Colors.black87),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(1),
          activeColor: Colors.green[300],
          inactiveColor: Colors.grey[300],
          thumbColor: Colors.green[400],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String result,
      {TextStyle? resultTextStyle}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              result,
              style: resultTextStyle ??
                  const TextStyle(
                      fontSize: 18), // Use provided style or default
            ),
          ],
        ),
      ),
    );
  }
}

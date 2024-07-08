import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Result extends StatefulWidget {
  final String place;

  const Result({super.key, required this.place});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Future<Map<String, dynamic>> getDataFromAPI() async {
    try {
      final response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=${widget.place}&appid=2ecf1c24589c328ac7e1491a7c368734&units=metric"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  String getWeatherIcon(String main) {
    if (main == "Clear") {
      return "assets/cloudy-day.png";
    } else if (main == "Clouds") {
      return "assets/heavycloud.png";
    } else if (main == "Rain") {
      return "assets/rain.png";
    }
    return "assets/cloudy-day.png"; 
  }

  String getWeatherText(String main) {
    if (main == "Clear") {
      return "Clear";
    } else if (main == "Clouds") {
      return "Cloudy";
    } else if (main == "Rain") {
      return "Rain";
    }
    return "Unknown"; 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Hasil Tracking",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: FutureBuilder(
          future: getDataFromAPI(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.hasData) {
              final data = snapshot.data as Map<String, dynamic>;

              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://flagsapi.com/${data["sys"]["country"]}/shiny/64.png',
                        width: 64,
                        height: 64,
                      ),
                      const SizedBox(height: 10),
                      _buildWeatherDetail(
                        "Location",
                        "${data["name"]}, ${data["sys"]["country"]}",
                        Icons.location_pin,
                      ),
                      const SizedBox(height: 10),
                      _buildWeatherCard(data),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text("Tempat tidak diketahui"));
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> data) {
    String mainWeather = data["weather"][0]["main"];
    String weatherIcon = getWeatherIcon(mainWeather);
    String weatherText = getWeatherText(mainWeather);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            weatherIcon,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 10),
          Text(
            weatherText,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildWeatherInfo("Temperature", "${data["main"]["temp"]}°C"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherInfo("Wind Speed", "${data["wind"]["speed"]} m/s", "assets/wind.png"),
              _buildWeatherInfo("Humidity", "${data["main"]["humidity"]}%", "assets/humidity.png"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String title, String value, [String? assetPath]) {
    return Column(
      children: [
        if (assetPath != null)
          Image.asset(
            assetPath,
            width: 40,
            height: 40,
          ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

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
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=${widget.place}&appid=2ecf1c24589c328ac7e1491a7c368734&units=metric"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data;
    } else {
      throw Exception("Error");
    }
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
              backgroundColor: Color.fromRGBO(218, 21, 119, 0.747),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              )),
          body: Container(
            padding: const EdgeInsets.only(left: 70, right: 70),
            child: FutureBuilder(
              future: getDataFromAPI(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  final data = snapshot.data!; // non nullabel

                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Image(image: NetworkImage('https://flagsapi.com/${data["sys"]["country"]}/shiny/64.png')),

                        Text(
                          "suhu: ${data["main"]["feels_like"]} C",
                          style: const TextStyle(fontSize: 20),
                        ),

                        Text(
                          'Kecepatan angin: ${data["wind"]["speed"]} m/s',
                          style: const TextStyle(fontSize: 20),
                        ),

                        
                      ],
                    ),
                  );
                } else {
                  return const Text("Tempat tidak diketahui");
                }
              },
            ),
          )),
    );
  }
}

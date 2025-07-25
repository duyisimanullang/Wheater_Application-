import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'weather_data.dart';

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  late WeatherData weather;
  String kota = "tangerang";
  bool loading = true;
  bool searchSuccess = true;
  bool error = false;
  final TextEditingController controller = TextEditingController();

  Future<void> getHttp() async {
    try {
      setState(() {
        loading = true;
        searchSuccess = true;
        error = false;
      });
      var dio = Dio();
      var response = await dio.get(
          "https://api.openweathermap.org/data/2.5/weather?q=$kota&appid=4e1524cb39602e6f31e4f45f725f0077");

      if (response.statusCode == 200) {
        Map<String, dynamic> weatherMap = response.data;
        setState(() {
          weather = WeatherData(
            name: weatherMap['name'],
            timezone: weatherMap['timezone'],
            tempMin: weatherMap['main']['temp_min'],
            tempMax: weatherMap['main']['temp_max'],
            temp: weatherMap['main']['temp'],
            icon: weatherMap['weather'][0]['icon'],
            main: weatherMap['weather'][0]['main'],
          );
          loading = false;
        });
      } else {
        setState(() {
          searchSuccess = false;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        searchSuccess = false;
        error = true;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  List<Color> getColor() {
    if (weather.main == "Clear") {
      return [
        Color(0xFF81D4FA),
        Color(0xFF01579B),
      ];
    } else if (weather.main == "Clouds") {
      return [
        Color(0xFFB0BEC5),
        Color(0xFF37474F),
      ];
    } else if (weather.main == "Rain") {
      return [
        Color.fromARGB(255, 19, 64, 101),
        Color.fromARGB(255, 96, 115, 142),
      ];
    } else if (weather.main == "Snow") {
      return [
        Color(0xFFE1F5FE),
        Color(0xFF81D4FA),
      ];
    } else {
      return [
        Color.fromARGB(255, 201, 43, 43),
        Color.fromARGB(255, 102, 80, 102),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    var time = DateTime.now().add(Duration(
        seconds: weather.timezone - DateTime.now().timeZoneOffset.inSeconds));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Deteksi Cuaca',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    'Pindah Kota',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                      'Kota mana lagi yang ingin kamu ketahui cuacanya?'),
                  actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  actions: [
                    TextField(
                      controller: controller,
                      onChanged: (value) {
                        setState(() {
                          kota = value;
                        });
                      },
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ketik disini',
                      ),
                    ),
                    if (error) ...[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('*Kota tidak ditemukan',
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.start),
                        ],
                      )
                    ],
                    TextButton(
                      onPressed: () async {
                        await getHttp();
                        if (searchSuccess) {
                          setState(() {
                            error = false;
                          });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            error = true;
                          });
                        }
                      },
                      child: const Text('Cari',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Icon(Icons.search, color: Colors.black),
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: loading ? [Colors.white, Colors.white] : getColor(),
            ),
          ),
          child: loading
              ? CircularProgressIndicator(color: Colors.black)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weather.name,
                      style: const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    Text(
                      'Updated: ${time.hour}:${time.minute}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 199, 199, 199),
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                            "https://openweathermap.org/img/wn/${weather.icon}@2x.png"),
                        Text(
                          '${(weather.temp - 273.15).round()}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              'max: ${(weather.tempMax - 273.15).round()}°',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              'min: ${(weather.tempMin - 273.15).round()}°',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                    Text(
                      weather.main,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

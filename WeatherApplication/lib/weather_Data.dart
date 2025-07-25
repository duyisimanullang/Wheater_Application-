class WeatherData {
  final String name;
  final int timezone;
  final double tempMin;
  final double tempMax;
  final double temp;
  final String icon;
  final String main;

  WeatherData({
    required this.name,
    required this.timezone,
    required this.tempMin,
    required this.tempMax,
    required this.temp,
    required this.icon,
    required this.main,
  });
}

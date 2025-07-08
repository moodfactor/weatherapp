class Location {
  String name;
  String region;
  String country;
  double lat;
  double lon;
  String tzId;
  int localtimeEpoch;
  String localtime;

  Location({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tzId,
    required this.localtimeEpoch,
    required this.localtime,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    name: json['name']?.toString() ?? '',
    region: json['region']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    lat: json['lat']?.toDouble() ?? 0.0,
    lon: json['lon']?.toDouble() ?? 0.0,
    tzId: json['tz_id']?.toString() ?? '',
    localtimeEpoch: json['localtime_epoch'] ?? 0,
    localtime: json['localtime']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'country': country,
    'lat': lat,
    'lon': lon,
    'tz_id': tzId,
    'localtime_epoch': localtimeEpoch,
    'localtime': localtime,
  };
}
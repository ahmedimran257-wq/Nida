class LocationCity {
  final String id;
  final String cityName;
  final String state;
  final String country;
  final String countryCode;
  final bool isActive;
  final int adminCount;
  final int maxAdmins;
  final double latitude;
  final double longitude;
  final String timezone;
  final String calculationMethod;
  final bool? ramadanOverride;

  LocationCity({
    required this.id,
    required this.cityName,
    required this.state,
    required this.country,
    required this.countryCode,
    required this.isActive,
    required this.adminCount,
    this.maxAdmins = 10,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.calculationMethod,
    this.ramadanOverride,
  });

  factory LocationCity.fromMap(Map<String, dynamic> map, String docId) {
    return LocationCity(
      id: docId,
      cityName: map['cityName'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? false,
      adminCount: map['adminCount'] as int? ?? 0,
      maxAdmins: map['maxAdmins'] as int? ?? 10,
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      timezone: map['timezone'] as String? ?? 'UTC',
      calculationMethod: map['calculationMethod'] as String? ?? 'muslimWorldLeague',
      ramadanOverride: map['ramadanOverride'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'state': state,
      'country': country,
      'countryCode': countryCode,
      'isActive': isActive,
      'adminCount': adminCount,
      'maxAdmins': maxAdmins,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'calculationMethod': calculationMethod,
      'ramadanOverride': ramadanOverride,
    };
  }
}

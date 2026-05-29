import 'dart:math';
import '../../models/city.dart';
import '../interfaces/cities_interface.dart';
import 'mock_data.dart';

class MockCitiesService implements ICitiesService {
  @override
  Future<List<LocationCity>> searchCities(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (query.trim().isEmpty) {
      // Return all cities sorted: active first, then alphabetical
      final all = MockData.cities
          .map((c) => LocationCity.fromMap(c, c['id'] as String))
          .toList();
      all.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return a.cityName.compareTo(b.cityName);
      });
      return all;
    }
    
    final lq = query.toLowerCase().trim();
    return MockData.cities
        .where((c) =>
            (c['cityName'] as String).toLowerCase().contains(lq) ||
            (c['country'] as String).toLowerCase().contains(lq) ||
            (c['state'] as String).toLowerCase().contains(lq) ||
            (c['countryCode'] as String).toLowerCase() == lq)
        .map((c) => LocationCity.fromMap(c, c['id'] as String))
        .toList();
  }

  @override
  Future<LocationCity?> getCityById(String cityId) async {
    final idx = MockData.cities.indexWhere((c) => c['id'] == cityId);
    if (idx == -1) return null;
    return LocationCity.fromMap(MockData.cities[idx], cityId);
  }

  @override
  Future<LocationCity?> getCityByName(String name, String countryCode) async {
    final lName = name.toLowerCase().trim();
    final lCc = countryCode.toLowerCase().trim();
    final idx = MockData.cities.indexWhere((c) =>
        (c['cityName'] as String).toLowerCase() == lName &&
        (c['countryCode'] as String).toLowerCase() == lCc);
    if (idx == -1) return null;
    return LocationCity.fromMap(MockData.cities[idx], MockData.cities[idx]['id'] as String);
  }

  @override
  Future<bool> isCityActive(String cityId) async {
    final city = await getCityById(cityId);
    return city?.isActive ?? false;
  }

  @override
  Future<void> joinWaitlist({required String cityId, required String fcmToken}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final city = await getCityById(cityId);
    if (city != null) {
      final exists = MockData.waitlist.any((w) => w['cityId'] == cityId && w['fcmToken'] == fcmToken);
      if (!exists) {
        MockData.waitlist.add({
          'fcmToken': fcmToken,
          'cityId': cityId,
          'cityName': city.cityName,
          'countryCode': city.countryCode,
          'registeredAt': DateTime.now(),
        });
      }
    }
  }

  @override
  Future<LocationCity?> getCityByProximity(double latitude, double longitude) async {
    await Future.delayed(const Duration(milliseconds: 150));
    double minDistance = double.infinity;
    Map<String, dynamic>? closestCity;

    for (final c in MockData.cities) {
      final lat = c['latitude'] as double;
      final lon = c['longitude'] as double;
      final dist = _calculateDistance(latitude, longitude, lat, lon);
      
      // Proximity limit is 50km
      if (dist < 50.0 && dist < minDistance) {
        minDistance = dist;
        closestCity = c;
      }
    }

    if (closestCity == null) return null;
    return LocationCity.fromMap(closestCity, closestCity['id'] as String);
  }

  @override
  Future<void> setCityActive(String cityId, bool isActive) async {
    final idx = MockData.cities.indexWhere((c) => c['id'] == cityId);
    if (idx != -1) {
      MockData.cities[idx]['isActive'] = isActive;
    }
  }

  // Haversine formula to compute distance in km
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371; // Earth's radius in km
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _rad(double deg) => deg * (pi / 180);
}

import '../../models/city.dart';

abstract class ICitiesService {
  Future<List<LocationCity>> searchCities(String query);
  Future<LocationCity?> getCityById(String cityId);
  Future<LocationCity?> getCityByName(String name, String countryCode);
  Future<bool> isCityActive(String cityId);
  Future<void> joinWaitlist({required String cityId, required String fcmToken});
  Future<LocationCity?> getCityByProximity(double latitude, double longitude);
  Future<void> setCityActive(String cityId, bool isActive); // for admin demo
}

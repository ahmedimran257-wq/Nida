import '../service_locator.dart';
import '../../models/city.dart';

class GeocodingStub {
  static Future<LocationCity?> detectCityFromCoordinates(double lat, double lon) async {
    // Proximity search via cities service
    return await citiesService.getCityByProximity(lat, lon);
  }

  // Simulator helper that returns coordinates for predefined cities for testing
  static Map<String, double> getMockCoordinates(String cityId) {
    switch (cityId) {
      case 'kurnool_in':
        return {'latitude': 15.8281, 'longitude': 78.0373};
      case 'london_gb':
        return {'latitude': 51.5074, 'longitude': -0.1278};
      case 'chicago_us':
        return {'latitude': 41.8781, 'longitude': -87.6298};
      case 'sydney_au':
        return {'latitude': -33.8688, 'longitude': 151.2093};
      default:
        return {'latitude': 0.0, 'longitude': 0.0};
    }
  }
}

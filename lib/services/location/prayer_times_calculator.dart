import 'package:adhan/adhan.dart';
import '../../models/city.dart';

class PrayerTimesCalculator {
  static CalculationParameters _getParameters(String method) {
    switch (method) {
      case 'karachi':
        return CalculationMethod.karachi.getParameters();
      case 'northAmerica':
        return CalculationMethod.north_america.getParameters();
      case 'dubai':
        return CalculationMethod.dubai.getParameters();
      case 'singapore':
        return CalculationMethod.singapore.getParameters();
      case 'egypt':
        return CalculationMethod.egyptian.getParameters();
      case 'ummAlQura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'muslimWorldLeague':
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  static PrayerTimes getTimes(LocationCity city, DateTime date) {
    final coordinates = Coordinates(city.latitude, city.longitude);
    final dateComponents = DateComponents.from(date);
    final params = _getParameters(city.calculationMethod);
    
    // Default to Hanafi madhab for Kurnool, India or Karachi method
    if (city.calculationMethod == 'karachi') {
      params.madhab = Madhab.hanafi;
    }
    
    return PrayerTimes(coordinates, dateComponents, params);
  }

  static String getRelativePrayerLabel(LocationCity city, DateTime scheduledTime) {
    final times = getTimes(city, scheduledTime);
    
    final fajr = times.fajr;
    final dhuhr = times.dhuhr;
    final asr = times.asr;
    final maghrib = times.maghrib;
    final isha = times.isha;

    // Checks the relation between scheduledTime and prayer times of that day
    if (scheduledTime.isBefore(fajr)) {
      return 'Before Fajr';
    } else if (scheduledTime.isBefore(dhuhr)) {
      // Fajr to Dhuhr
      final diff = dhuhr.difference(scheduledTime);
      if (diff.inMinutes < 60) {
        return 'Before Zuhr';
      }
      return 'After Fajr';
    } else if (scheduledTime.isBefore(asr)) {
      // Dhuhr to Asr
      return 'After Zuhr';
    } else if (scheduledTime.isBefore(maghrib)) {
      // Asr to Maghrib
      return 'After Asr';
    } else if (scheduledTime.isBefore(isha)) {
      // Maghrib to Isha
      return 'After Maghrib';
    } else {
      // After Isha
      return 'After Isha';
    }
  }
}

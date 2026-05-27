import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nida_app/models/city.dart';
import 'package:nida_app/services/location/prayer_times_calculator.dart';
import 'package:nida_app/utils/arabic_numbers.dart';
import 'package:nida_app/utils/text_direction.dart';

void main() {
  group('Arabic Numbers Utilities', () {
    test('toArabicDigits converts English digits to Arabic digits', () {
      expect(toArabicDigits('0123456789'), '٠١٢٣٤٥٦٧٨٩');
      expect(toArabicDigits('Zuhr at 18:30'), 'Zuhr at ١٨:٣٠');
      expect(toArabicDigits('No numbers here'), 'No numbers here');
    });

    test('formatMinutesToDuration returns correct duration labels based on locale', () {
      // 85 minutes = 1h 25m
      expect(formatMinutesToDuration(85, 'en'), '1h 25m');
      expect(formatMinutesToDuration(85, 'ur'), '١h ٢٥m');
      expect(formatMinutesToDuration(85, 'ar'), '١h ٢٥m');

      // 45 minutes = 45m
      expect(formatMinutesToDuration(45, 'en'), '45m');
      expect(formatMinutesToDuration(45, 'te'), '45m');
      expect(formatMinutesToDuration(45, 'ar'), '٤٥m');
    });
  });

  group('Text Direction Utilities', () {
    test('textDirectionFor returns RTL for Urdu and Arabic, LTR for others', () {
      expect(textDirectionFor('ur'), TextDirection.rtl);
      expect(textDirectionFor('ar'), TextDirection.rtl);
      expect(textDirectionFor('en'), TextDirection.ltr);
      expect(textDirectionFor('te'), TextDirection.ltr);
      expect(textDirectionFor('hi'), TextDirection.ltr);
    });
  });

  group('Prayer Times Calculator', () {
    final mockCityKurnool = LocationCity(
      id: 'kurnool_in',
      cityName: 'Kurnool',
      state: 'Andhra Pradesh',
      country: 'India',
      countryCode: 'IN',
      isActive: true,
      adminCount: 2,
      latitude: 15.8281,
      longitude: 78.0373,
      timezone: 'Asia/Kolkata',
      calculationMethod: 'karachi',
    );

    test('getTimes returns a valid PrayerTimes object with Hanafi madhab for Karachi method', () {
      final date = DateTime(2026, 5, 27);
      final times = PrayerTimesCalculator.getTimes(mockCityKurnool, date);
      
      expect(times, isNotNull);
      // Verify basic chronological order of prayers
      expect(times.fajr.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
    });

    test('getRelativePrayerLabel returns appropriate relative labels throughout the day', () {
      final date = DateTime(2026, 5, 27);
      final times = PrayerTimesCalculator.getTimes(mockCityKurnool, date);

      // 1. Time before Fajr
      final timeBeforeFajr = times.fajr.subtract(const Duration(minutes: 30));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeBeforeFajr), 'Before Fajr');

      // 2. Time after Fajr (e.g. 2 hours after Fajr, well before Dhuhr)
      final timeAfterFajr = times.fajr.add(const Duration(hours: 2));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeAfterFajr), 'After Fajr');

      // 3. Time just before Zuhr (within 60 minutes of Dhuhr)
      final timeBeforeZuhr = times.dhuhr.subtract(const Duration(minutes: 15));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeBeforeZuhr), 'Before Zuhr');

      // 4. Time after Zuhr
      final timeAfterZuhr = times.dhuhr.add(const Duration(minutes: 30));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeAfterZuhr), 'After Zuhr');

      // 5. Time after Asr
      final timeAfterAsr = times.asr.add(const Duration(minutes: 30));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeAfterAsr), 'After Asr');

      // 6. Time after Maghrib
      final timeAfterMaghrib = times.maghrib.add(const Duration(minutes: 15));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeAfterMaghrib), 'After Maghrib');

      // 7. Time after Isha
      final timeAfterIsha = times.isha.add(const Duration(minutes: 45));
      expect(PrayerTimesCalculator.getRelativePrayerLabel(mockCityKurnool, timeAfterIsha), 'After Isha');
    });
  });
}

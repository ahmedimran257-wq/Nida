import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nida_app/models/city.dart';
import 'package:nida_app/models/announcement.dart';
import 'package:nida_app/services/location/prayer_times_calculator.dart';
import 'package:nida_app/utils/arabic_numbers.dart';
import 'package:nida_app/utils/text_direction.dart';
import 'package:nida_app/services/mock/mock_data.dart';
import 'package:nida_app/services/service_locator.dart';
import 'package:nida_app/providers/superadmin_provider.dart';

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

  group('Admins Service Tests', () {
    test('getAdminsByCity returns correct admins list', () async {
      final list = await adminsService.getAdminsByCity('kurnool_in');
      expect(list.length, greaterThanOrEqualTo(2));
      expect(list.any((a) => a['name'] == 'Imam Rashid'), isTrue);
    });

    test('submitAdminRequest adds request to list', () async {
      final initialCount = MockData.adminRequests.length;
      await adminsService.submitAdminRequest(
        name: 'Test Imam',
        phone: '+91 99999 88888',
        masjidName: 'Test Masjid',
        cityName: 'Mumbai',
        note: 'Test note',
      );
      expect(MockData.adminRequests.length, initialCount + 1);
      final req = MockData.adminRequests.last;
      expect(req['name'], 'Test Imam');
      expect(req['cityName'], 'Mumbai');
      expect(req['status'], 'pending');
    });

    test('softDeactivateAdmin enforces minimum of 2 active admins limit', () async {
      // Current count in kurnool_in is 2 active admins
      // Deactivating one should fail if it drops <= 2
      final result = await adminsService.softDeactivateAdmin(
        adminId: 'admin_002',
        deactivatedBy: 'admin_001',
      );
      expect(result, isNotNull);
      expect(result, contains('Minimum 2 active admins must remain'));

      // Invite a 3rd admin
      final inviteResult = await adminsService.inviteAdmin(
        name: 'Imam Three',
        phone: '+91 77777 77777',
        cityId: 'kurnool_in',
        addedBy: 'admin_001',
      );
      expect(inviteResult, isNull);

      // Deactivating now should succeed
      final result2 = await adminsService.softDeactivateAdmin(
        adminId: 'admin_002',
        deactivatedBy: 'admin_001',
      );
      expect(result2, isNull);
    });

    test('createAnnouncement works and parses String dates successfully without crash', () async {
      final initialCount = MockData.announcements.length;
      final newAnn = Announcement(
        id: 'test_ann_123',
        title: 'Test Dars',
        description: 'Test details',
        programType: 'DARS',
        importanceLevel: 'STANDARD',
        scholarId: 'scholar_001',
        scholarNameSnapshot: 'Sheikh Abdullah',
        scholarNameArabicSnapshot: 'الشيخ عبدالله',
        masjidId: 'masjid_001',
        masjidNameSnapshot: 'Masjid Tawheed',
        masjidLocalitySnapshot: 'Old Town',
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 1, hours: 4)),
        createdAt: DateTime.now(),
        cityId: 'kurnool_in',
        countryCode: 'IN',
        isRecurring: false,
        postedBy: 'admin_001',
        reportedByUids: const [],
      );

      await announcementsService.createAnnouncement(newAnn);
      expect(MockData.announcements.length, initialCount + 1);
      
      // Verify that watchActiveAnnouncements stream does not crash
      final activeList = await announcementsService.watchActiveAnnouncements('kurnool_in').first;
      expect(activeList.any((a) => a.id == 'test_ann_123'), isTrue);
    });
  });

  group('Super Admin State Notifier Tests', () {
    test('login with correct credentials succeeds', () async {
      final notifier = SuperAdminNotifier();
      final loggedIn = await notifier.login('superadmin@nida.app', 'nida_super_2024');
      expect(loggedIn, isTrue);
      expect(notifier.state.isLoggedIn, isTrue);
    });

    test('login with incorrect credentials fails', () async {
      final notifier = SuperAdminNotifier();
      final loggedIn = await notifier.login('wrong@nida.app', 'wrongpass');
      expect(loggedIn, isFalse);
      expect(notifier.state.isLoggedIn, isFalse);
      expect(notifier.state.error, isNotNull);
    });

    test('approving admin request sets active admin and activates city', () async {
      final notifier = SuperAdminNotifier();
      await notifier.login('superadmin@nida.app', 'nida_super_2024');

      // Submit a pending request for Hyderabad (currently inactive, 0 admins)
      final initialAdminsCount = MockData.imamAdmins.length;
      await adminsService.submitAdminRequest(
        name: 'Hyd Imam',
        phone: '+91 88888 22222',
        masjidName: 'Hyderabad Masjid',
        cityName: 'Hyderabad',
      );

      final reqId = MockData.adminRequests.last['id'];
      
      // Hyderabad is inactive before approval
      final hydCityBefore = MockData.cities.firstWhere((c) => c['id'] == 'hyderabad_in');
      expect(hydCityBefore['isActive'], isFalse);

      await notifier.approveAdminRequest(reqId);

      // Verify approved status
      final req = MockData.adminRequests.firstWhere((r) => r['id'] == reqId);
      expect(req['status'], 'approved');

      // Verify active admin was added
      expect(MockData.imamAdmins.length, initialAdminsCount + 1);
      final newAdmin = MockData.imamAdmins.last;
      expect(newAdmin['name'], 'Hyd Imam');
      expect(newAdmin['cityId'], 'hyderabad_in');

      // Verify city is now active and has admin count incremented
      final hydCityAfter = MockData.cities.firstWhere((c) => c['id'] == 'hyderabad_in');
      expect(hydCityAfter['isActive'], isTrue);
      expect(hydCityAfter['adminCount'], 1);
    });
  });
}

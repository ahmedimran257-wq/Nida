import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scholar.dart';
import '../services/service_locator.dart';

// Stream of scholars in a city
final scholarsProvider = StreamProvider.family<List<Scholar>, String>((ref, cityId) {
  return scholarsService.watchScholars(cityId);
});

// Single scholar details provider
final scholarDetailsProvider = FutureProvider.family<Scholar?, String>((ref, scholarId) {
  return scholarsService.getScholar(scholarId);
});

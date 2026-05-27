import 'dart:async';
import '../../models/scholar.dart';
import '../interfaces/scholars_interface.dart';
import 'mock_data.dart';

class MockScholarsService implements IScholarsService {
  static final _scholarsController = StreamController<List<Scholar>>.broadcast();

  void _notifyListeners(String cityId) {
    final list = MockData.scholars
        .where((s) => s['cityId'] == cityId && (s['isActive'] as bool? ?? true))
        .map((s) => Scholar.fromMap(s, s['id'] as String))
        .toList();
    _scholarsController.add(list);
  }

  @override
  Stream<List<Scholar>> watchScholars(String cityId) {
    Timer.run(() => _notifyListeners(cityId));
    return _scholarsController.stream;
  }

  @override
  Future<Scholar?> getScholar(String scholarId) async {
    final idx = MockData.scholars.indexWhere((s) => s['id'] == scholarId);
    if (idx == -1) return null;
    return Scholar.fromMap(MockData.scholars[idx], scholarId);
  }

  @override
  Future<void> createScholar(Scholar scholar) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockData.scholars.add(scholar.toMap()..['id'] = scholar.id);
    _notifyListeners(scholar.cityId);
  }
}

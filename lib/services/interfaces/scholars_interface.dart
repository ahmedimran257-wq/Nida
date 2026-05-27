import '../../models/scholar.dart';

abstract class IScholarsService {
  Stream<List<Scholar>> watchScholars(String cityId);
  Future<Scholar?> getScholar(String scholarId);
  Future<void> createScholar(Scholar scholar);
}

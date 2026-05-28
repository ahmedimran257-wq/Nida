import '../../models/masjid.dart';

abstract class IMasjidsService {
  Stream<List<Masjid>> watchMasjids(String cityId);
  Future<void> followMasjid({required String uid, required String masjidId});
  Future<void> unfollowMasjid({required String uid, required String masjidId});
  Future<List<String>> getFollowedMasjidIds(String uid);
  Future<void> createMasjid(Masjid masjid);
  Future<void> updateMasjid(Masjid masjid);
  Future<List<Masjid>> getMasjids(String cityId);
}

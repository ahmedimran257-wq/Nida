class Masjid {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final String locality;
  final String address;
  final String cityId;
  final String countryCode;
  final bool isVerified;
  final int followerCount;
  final String addedBy;
  final DateTime createdAt;
  final bool isActive;
  final double latitude;
  final double longitude;

  Masjid({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.locality,
    required this.address,
    required this.cityId,
    required this.countryCode,
    required this.isVerified,
    required this.followerCount,
    required this.addedBy,
    required this.createdAt,
    required this.isActive,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Masjid.fromMap(Map<String, dynamic> map, String docId) {
    return Masjid(
      id: docId,
      nameArabic: map['nameArabic'] as String? ?? '',
      nameEnglish: map['nameEnglish'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      address: map['address'] as String? ?? '',
      cityId: map['cityId'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '',
      isVerified: map['isVerified'] as bool? ?? false,
      followerCount: map['followerCount'] as int? ?? 0,
      addedBy: map['addedBy'] as String? ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'locality': locality,
      'address': address,
      'cityId': cityId,
      'countryCode': countryCode,
      'isVerified': isVerified,
      'followerCount': followerCount,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

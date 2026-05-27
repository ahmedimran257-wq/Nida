class Scholar {
  final String id;
  final String nameEnglish;
  final String nameArabic;
  final List<String> specializations;
  final String bio;
  final String? profileImageUrl;
  final String addedBy;
  final String cityId;
  final String countryCode;
  final DateTime createdAt;
  final bool isActive;
  final int totalPrograms;

  Scholar({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
    required this.specializations,
    required this.bio,
    this.profileImageUrl,
    required this.addedBy,
    required this.cityId,
    required this.countryCode,
    required this.createdAt,
    required this.isActive,
    this.totalPrograms = 0,
  });

  factory Scholar.fromMap(Map<String, dynamic> map, String docId) {
    return Scholar(
      id: docId,
      nameEnglish: map['nameEnglish'] as String? ?? '',
      nameArabic: map['nameArabic'] as String? ?? '',
      specializations: List<String>.from(map['specializations'] ?? []),
      bio: map['bio'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
      addedBy: map['addedBy'] as String? ?? '',
      cityId: map['cityId'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      totalPrograms: map['totalPrograms'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEnglish': nameEnglish,
      'nameArabic': nameArabic,
      'specializations': specializations,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'addedBy': addedBy,
      'cityId': cityId,
      'countryCode': countryCode,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'totalPrograms': totalPrograms,
    };
  }
}

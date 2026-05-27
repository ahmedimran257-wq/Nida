class Announcement {
  final String id;
  final String title;
  final String? description;
  final String programType; // BAYAN | DARS | JUMUAH | SPECIAL | JANAZAH | TARAWEEH | QIYAAM | IFTAR | ITIKAF
  final String importanceLevel; // STANDARD | MAJOR
  final String scholarId;
  final String scholarNameSnapshot;
  final String scholarNameArabicSnapshot;
  final String masjidId;
  final String masjidNameSnapshot;
  final String masjidLocalitySnapshot;
  final DateTime scheduledTime;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String cityId;
  final String countryCode;
  final String? posterUrl;
  final bool isRecurring;
  final String? templateAnnouncementId;
  final String? recurringRule;
  final DateTime? nextOccurrence;
  final String postedBy;
  final bool notificationSentInitial;
  final bool notificationSentReminder;
  final int reportCount;
  final List<String> reportedByUids;
  final bool isFlaggedForReview;
  final bool isHidden;

  Announcement({
    required this.id,
    required this.title,
    this.description,
    required this.programType,
    required this.importanceLevel,
    required this.scholarId,
    required this.scholarNameSnapshot,
    required this.scholarNameArabicSnapshot,
    required this.masjidId,
    required this.masjidNameSnapshot,
    required this.masjidLocalitySnapshot,
    required this.scheduledTime,
    required this.expiresAt,
    required this.createdAt,
    required this.cityId,
    required this.countryCode,
    this.posterUrl,
    required this.isRecurring,
    this.templateAnnouncementId,
    this.recurringRule,
    this.nextOccurrence,
    required this.postedBy,
    this.notificationSentInitial = false,
    this.notificationSentReminder = false,
    this.reportCount = 0,
    required this.reportedByUids,
    this.isFlaggedForReview = false,
    this.isHidden = false,
  });

  // Mock maps use DateTime directly
  factory Announcement.fromMockMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      programType: map['programType'] as String? ?? 'BAYAN',
      importanceLevel: map['importanceLevel'] as String? ?? 'STANDARD',
      scholarId: map['scholarId'] as String? ?? '',
      scholarNameSnapshot: map['scholarNameSnapshot'] as String? ?? '',
      scholarNameArabicSnapshot: map['scholarNameArabicSnapshot'] as String? ?? '',
      masjidId: map['masjidId'] as String? ?? '',
      masjidNameSnapshot: map['masjidNameSnapshot'] as String? ?? '',
      masjidLocalitySnapshot: map['masjidLocalitySnapshot'] as String? ?? '',
      scheduledTime: map['scheduledTime'] is DateTime
          ? map['scheduledTime'] as DateTime
          : DateTime.parse(map['scheduledTime'] as String),
      expiresAt: map['expiresAt'] is DateTime
          ? map['expiresAt'] as DateTime
          : DateTime.parse(map['expiresAt'] as String),
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt'] as String),
      cityId: map['cityId'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '',
      posterUrl: map['posterUrl'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      templateAnnouncementId: map['templateAnnouncementId'] as String?,
      recurringRule: map['recurringRule'] as String?,
      nextOccurrence: map['nextOccurrence'] is DateTime
          ? map['nextOccurrence'] as DateTime
          : map['nextOccurrence'] != null
              ? DateTime.parse(map['nextOccurrence'] as String)
              : null,
      postedBy: map['postedBy'] as String? ?? '',
      notificationSentInitial: map['notificationSentInitial'] as bool? ?? false,
      notificationSentReminder: map['notificationSentReminder'] as bool? ?? false,
      reportCount: map['reportCount'] as int? ?? 0,
      reportedByUids: List<String>.from(map['reportedByUids'] ?? []),
      isFlaggedForReview: map['isFlaggedForReview'] as bool? ?? false,
      isHidden: map['isHidden'] as bool? ?? false,
    );
  }

  // Firestore returns dynamic fields (can be Timestamps, run-time types, etc.)
  factory Announcement.fromFirestoreMap(Map<String, dynamic> map, String docId) {
    DateTime parseTime(dynamic val) {
      if (val == null) return DateTime.now();
      // In Firestore, this will be a Timestamp.
      // We check for the method toDate() via duck typing or check its type string if not imported.
      // To prevent crashes when we flip the switch to Firestore, we check if it has a toDate method.
      try {
        return (val as dynamic).toDate() as DateTime;
      } catch (_) {
        try {
          if (val is String) return DateTime.parse(val);
          if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
          return val as DateTime;
        } catch (_) {
          return DateTime.now();
        }
      }
    }

    return Announcement(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      programType: map['programType'] as String? ?? 'BAYAN',
      importanceLevel: map['importanceLevel'] as String? ?? 'STANDARD',
      scholarId: map['scholarId'] as String? ?? '',
      scholarNameSnapshot: map['scholarNameSnapshot'] as String? ?? '',
      scholarNameArabicSnapshot: map['scholarNameArabicSnapshot'] as String? ?? '',
      masjidId: map['masjidId'] as String? ?? '',
      masjidNameSnapshot: map['masjidNameSnapshot'] as String? ?? '',
      masjidLocalitySnapshot: map['masjidLocalitySnapshot'] as String? ?? '',
      scheduledTime: parseTime(map['scheduledTime']),
      expiresAt: parseTime(map['expiresAt']),
      createdAt: parseTime(map['createdAt']),
      cityId: map['cityId'] as String? ?? '',
      countryCode: map['countryCode'] as String? ?? '',
      posterUrl: map['posterUrl'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      templateAnnouncementId: map['templateAnnouncementId'] as String?,
      recurringRule: map['recurringRule'] as String?,
      nextOccurrence: map['nextOccurrence'] != null ? parseTime(map['nextOccurrence']) : null,
      postedBy: map['postedBy'] as String? ?? '',
      notificationSentInitial: map['notificationSentInitial'] as bool? ?? false,
      notificationSentReminder: map['notificationSentReminder'] as bool? ?? false,
      reportCount: map['reportCount'] as int? ?? 0,
      reportedByUids: List<String>.from(map['reportedByUids'] ?? []),
      isFlaggedForReview: map['isFlaggedForReview'] as bool? ?? false,
      isHidden: map['isHidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'programType': programType,
      'importanceLevel': importanceLevel,
      'scholarId': scholarId,
      'scholarNameSnapshot': scholarNameSnapshot,
      'scholarNameArabicSnapshot': scholarNameArabicSnapshot,
      'masjidId': masjidId,
      'masjidNameSnapshot': masjidNameSnapshot,
      'masjidLocalitySnapshot': masjidLocalitySnapshot,
      'scheduledTime': scheduledTime.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'cityId': cityId,
      'countryCode': countryCode,
      'posterUrl': posterUrl,
      'isRecurring': isRecurring,
      'templateAnnouncementId': templateAnnouncementId,
      'recurringRule': recurringRule,
      'nextOccurrence': nextOccurrence?.toIso8601String(),
      'postedBy': postedBy,
      'notificationSentInitial': notificationSentInitial,
      'notificationSentReminder': notificationSentReminder,
      'reportCount': reportCount,
      'reportedByUids': reportedByUids,
      'isFlaggedForReview': isFlaggedForReview,
      'isHidden': isHidden,
    };
  }
}

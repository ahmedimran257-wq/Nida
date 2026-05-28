import 'interfaces/announcements_interface.dart';
import 'interfaces/cities_interface.dart';
import 'interfaces/masjids_interface.dart';
import 'interfaces/scholars_interface.dart';
import 'interfaces/saved_interface.dart';
import 'interfaces/admins_interface.dart';
import 'mock/mock_announcements_service.dart';
import 'mock/mock_cities_service.dart';
import 'mock/mock_masjids_service.dart';
import 'mock/mock_scholars_service.dart';
import 'mock/mock_saved_service.dart';
import 'mock/mock_admins_service.dart';

// ─── FLIP THIS ONE BOOLEAN TO GO LIVE ───────────────────────────
const bool useMock = true;
// ────────────────────────────────────────────────────────────────

// Instances are cached for singleton-like usage.
final IAnnouncementsService _announcementsService = MockAnnouncementsService();
final ICitiesService _citiesService = MockCitiesService();
final IMasjidsService _masjidsService = MockMasjidsService();
final IScholarsService _scholarsService = MockScholarsService();
final ISavedService _savedService = MockSavedService();
final IAdminsService _adminsService = MockAdminsService();

IAnnouncementsService get announcementsService => _announcementsService;
ICitiesService get citiesService => _citiesService;
IMasjidsService get masjidsService => _masjidsService;
IScholarsService get scholarsService => _scholarsService;
ISavedService get savedService => _savedService;
IAdminsService get adminsService => _adminsService;

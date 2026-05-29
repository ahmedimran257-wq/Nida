// lib/services/mock/world_cities_seed.dart
// 60+ cities covering every major Muslim community worldwide
// All start as isActive: false except Kurnool

class WorldCitiesSeed {
  static List<Map<String, dynamic>> get cities => [
    // ── INDIA (comprehensive — all major cities + AP/Telangana towns) ──
    {'id': 'kurnool_in', 'cityName': 'Kurnool', 'state': 'Andhra Pradesh', 'country': 'India', 'countryCode': 'IN', 'isActive': true, 'latitude': 15.8281, 'longitude': 78.0373, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 2, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'nandyal_in', 'cityName': 'Nandyal', 'state': 'Andhra Pradesh', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 15.4786, 'longitude': 78.4839, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'ongole_in', 'cityName': 'Ongole', 'state': 'Andhra Pradesh', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 15.5057, 'longitude': 80.0499, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'tirupati_in', 'cityName': 'Tirupati', 'state': 'Andhra Pradesh', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 13.6288, 'longitude': 79.4192, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'hyderabad_in', 'cityName': 'Hyderabad', 'state': 'Telangana', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 17.3850, 'longitude': 78.4867, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'warangal_in', 'cityName': 'Warangal', 'state': 'Telangana', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 17.9784, 'longitude': 79.5941, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'nizamabad_in', 'cityName': 'Nizamabad', 'state': 'Telangana', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 18.6725, 'longitude': 78.0941, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'mumbai_in', 'cityName': 'Mumbai', 'state': 'Maharashtra', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 19.0760, 'longitude': 72.8777, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'pune_in', 'cityName': 'Pune', 'state': 'Maharashtra', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 18.5204, 'longitude': 73.8567, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'aurangabad_in', 'cityName': 'Aurangabad', 'state': 'Maharashtra', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 19.8762, 'longitude': 75.3433, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'delhi_in', 'cityName': 'New Delhi', 'state': 'Delhi', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 28.6139, 'longitude': 77.2090, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'bangalore_in', 'cityName': 'Bangalore', 'state': 'Karnataka', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 12.9716, 'longitude': 77.5946, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'mysore_in', 'cityName': 'Mysore', 'state': 'Karnataka', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 12.2958, 'longitude': 76.6394, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'chennai_in', 'cityName': 'Chennai', 'state': 'Tamil Nadu', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 13.0827, 'longitude': 80.2707, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'coimbatore_in', 'cityName': 'Coimbatore', 'state': 'Tamil Nadu', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 11.0168, 'longitude': 76.9558, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'vellore_in', 'cityName': 'Vellore', 'state': 'Tamil Nadu', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 12.9165, 'longitude': 79.1325, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'calicut_in', 'cityName': 'Kozhikode', 'state': 'Kerala', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 11.2588, 'longitude': 75.7804, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'malappuram_in', 'cityName': 'Malappuram', 'state': 'Kerala', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 11.0510, 'longitude': 76.0711, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'lucknow_in', 'cityName': 'Lucknow', 'state': 'Uttar Pradesh', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 26.8467, 'longitude': 80.9462, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'aligarh_in', 'cityName': 'Aligarh', 'state': 'Uttar Pradesh', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 27.8974, 'longitude': 78.0880, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'kolkata_in', 'cityName': 'Kolkata', 'state': 'West Bengal', 'country': 'India', 'countryCode': 'IN', 'isActive': false, 'latitude': 22.5726, 'longitude': 88.3639, 'calculationMethod': 'karachi', 'timezone': 'Asia/Kolkata', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── UNITED KINGDOM ──
    {'id': 'london_gb', 'cityName': 'London', 'state': 'England', 'country': 'United Kingdom', 'countryCode': 'GB', 'isActive': false, 'latitude': 51.5074, 'longitude': -0.1278, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/London', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'birmingham_gb', 'cityName': 'Birmingham', 'state': 'England', 'country': 'United Kingdom', 'countryCode': 'GB', 'isActive': false, 'latitude': 52.4862, 'longitude': -1.8904, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/London', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'bradford_gb', 'cityName': 'Bradford', 'state': 'England', 'country': 'United Kingdom', 'countryCode': 'GB', 'isActive': false, 'latitude': 53.7960, 'longitude': -1.7594, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/London', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'manchester_gb', 'cityName': 'Manchester', 'state': 'England', 'country': 'United Kingdom', 'countryCode': 'GB', 'isActive': false, 'latitude': 53.4808, 'longitude': -2.2426, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/London', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'leicester_gb', 'cityName': 'Leicester', 'state': 'England', 'country': 'United Kingdom', 'countryCode': 'GB', 'isActive': false, 'latitude': 52.6369, 'longitude': -1.1398, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/London', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'luton_gb', 'cityName': 'Luton', 'state': 'England', 'country': 'United Kingdom', 'countryCode': 'GB', 'isActive': false, 'latitude': 51.8787, 'longitude': -0.4200, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/London', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── USA ──
    {'id': 'chicago_us', 'cityName': 'Chicago', 'state': 'Illinois', 'country': 'United States', 'countryCode': 'US', 'isActive': false, 'latitude': 41.8781, 'longitude': -87.6298, 'calculationMethod': 'northAmerica', 'timezone': 'America/Chicago', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'newyork_us', 'cityName': 'New York', 'state': 'New York', 'country': 'United States', 'countryCode': 'US', 'isActive': false, 'latitude': 40.7128, 'longitude': -74.0060, 'calculationMethod': 'northAmerica', 'timezone': 'America/New_York', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'detroit_us', 'cityName': 'Detroit', 'state': 'Michigan', 'country': 'United States', 'countryCode': 'US', 'isActive': false, 'latitude': 42.3314, 'longitude': -83.0458, 'calculationMethod': 'northAmerica', 'timezone': 'America/Detroit', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'houston_us', 'cityName': 'Houston', 'state': 'Texas', 'country': 'United States', 'countryCode': 'US', 'isActive': false, 'latitude': 29.7604, 'longitude': -95.3698, 'calculationMethod': 'northAmerica', 'timezone': 'America/Chicago', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'losangeles_us', 'cityName': 'Los Angeles', 'state': 'California', 'country': 'United States', 'countryCode': 'US', 'isActive': false, 'latitude': 34.0522, 'longitude': -118.2437, 'calculationMethod': 'northAmerica', 'timezone': 'America/Los_Angeles', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── CANADA ──
    {'id': 'toronto_ca', 'cityName': 'Toronto', 'state': 'Ontario', 'country': 'Canada', 'countryCode': 'CA', 'isActive': false, 'latitude': 43.6532, 'longitude': -79.3832, 'calculationMethod': 'northAmerica', 'timezone': 'America/Toronto', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'mississauga_ca', 'cityName': 'Mississauga', 'state': 'Ontario', 'country': 'Canada', 'countryCode': 'CA', 'isActive': false, 'latitude': 43.5890, 'longitude': -79.6441, 'calculationMethod': 'northAmerica', 'timezone': 'America/Toronto', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── UAE ──
    {'id': 'dubai_ae', 'cityName': 'Dubai', 'state': 'Dubai', 'country': 'United Arab Emirates', 'countryCode': 'AE', 'isActive': false, 'latitude': 25.2048, 'longitude': 55.2708, 'calculationMethod': 'dubai', 'timezone': 'Asia/Dubai', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'abudhabi_ae', 'cityName': 'Abu Dhabi', 'state': 'Abu Dhabi', 'country': 'United Arab Emirates', 'countryCode': 'AE', 'isActive': false, 'latitude': 24.4539, 'longitude': 54.3773, 'calculationMethod': 'dubai', 'timezone': 'Asia/Dubai', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── SOUTH AFRICA ──
    {'id': 'johannesburg_za', 'cityName': 'Johannesburg', 'state': 'Gauteng', 'country': 'South Africa', 'countryCode': 'ZA', 'isActive': false, 'latitude': -26.2041, 'longitude': 28.0473, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Africa/Johannesburg', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'capetown_za', 'cityName': 'Cape Town', 'state': 'Western Cape', 'country': 'South Africa', 'countryCode': 'ZA', 'isActive': false, 'latitude': -33.9249, 'longitude': 18.4241, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Africa/Johannesburg', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── AUSTRALIA ──
    {'id': 'sydney_au', 'cityName': 'Sydney', 'state': 'New South Wales', 'country': 'Australia', 'countryCode': 'AU', 'isActive': false, 'latitude': -33.8688, 'longitude': 151.2093, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Australia/Sydney', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'melbourne_au', 'cityName': 'Melbourne', 'state': 'Victoria', 'country': 'Australia', 'countryCode': 'AU', 'isActive': false, 'latitude': -37.8136, 'longitude': 144.9631, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Australia/Melbourne', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'brisbane_au', 'cityName': 'Brisbane', 'state': 'Queensland', 'country': 'Australia', 'countryCode': 'AU', 'isActive': false, 'latitude': -27.4698, 'longitude': 153.0251, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Australia/Brisbane', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── MALAYSIA ──
    {'id': 'kualalumpur_my', 'cityName': 'Kuala Lumpur', 'state': 'Federal Territory', 'country': 'Malaysia', 'countryCode': 'MY', 'isActive': false, 'latitude': 3.1390, 'longitude': 101.6869, 'calculationMethod': 'singapore', 'timezone': 'Asia/Kuala_Lumpur', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'penang_my', 'cityName': 'Penang', 'state': 'Penang', 'country': 'Malaysia', 'countryCode': 'MY', 'isActive': false, 'latitude': 5.4141, 'longitude': 100.3288, 'calculationMethod': 'singapore', 'timezone': 'Asia/Kuala_Lumpur', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── SINGAPORE ──
    {'id': 'singapore_sg', 'cityName': 'Singapore', 'state': 'Singapore', 'country': 'Singapore', 'countryCode': 'SG', 'isActive': false, 'latitude': 1.3521, 'longitude': 103.8198, 'calculationMethod': 'singapore', 'timezone': 'Asia/Singapore', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── PAKISTAN ──
    {'id': 'karachi_pk', 'cityName': 'Karachi', 'state': 'Sindh', 'country': 'Pakistan', 'countryCode': 'PK', 'isActive': false, 'latitude': 24.8607, 'longitude': 67.0011, 'calculationMethod': 'karachi', 'timezone': 'Asia/Karachi', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'lahore_pk', 'cityName': 'Lahore', 'state': 'Punjab', 'country': 'Pakistan', 'countryCode': 'PK', 'isActive': false, 'latitude': 31.5204, 'longitude': 74.3587, 'calculationMethod': 'karachi', 'timezone': 'Asia/Karachi', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'islamabad_pk', 'cityName': 'Islamabad', 'state': 'Federal', 'country': 'Pakistan', 'countryCode': 'PK', 'isActive': false, 'latitude': 33.6844, 'longitude': 73.0479, 'calculationMethod': 'karachi', 'timezone': 'Asia/Karachi', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── BANGLADESH ──
    {'id': 'dhaka_bd', 'cityName': 'Dhaka', 'state': 'Dhaka Division', 'country': 'Bangladesh', 'countryCode': 'BD', 'isActive': false, 'latitude': 23.8103, 'longitude': 90.4125, 'calculationMethod': 'karachi', 'timezone': 'Asia/Dhaka', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── SAUDI ARABIA ──
    {'id': 'riyadh_sa', 'cityName': 'Riyadh', 'state': 'Riyadh Province', 'country': 'Saudi Arabia', 'countryCode': 'SA', 'isActive': false, 'latitude': 24.6877, 'longitude': 46.7219, 'calculationMethod': 'ummAlQura', 'timezone': 'Asia/Riyadh', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'jeddah_sa', 'cityName': 'Jeddah', 'state': 'Makkah Province', 'country': 'Saudi Arabia', 'countryCode': 'SA', 'isActive': false, 'latitude': 21.4858, 'longitude': 39.1925, 'calculationMethod': 'ummAlQura', 'timezone': 'Asia/Riyadh', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── INDONESIA ──
    {'id': 'jakarta_id', 'cityName': 'Jakarta', 'state': 'DKI Jakarta', 'country': 'Indonesia', 'countryCode': 'ID', 'isActive': false, 'latitude': -6.2088, 'longitude': 106.8456, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Asia/Jakarta', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'surabaya_id', 'cityName': 'Surabaya', 'state': 'East Java', 'country': 'Indonesia', 'countryCode': 'ID', 'isActive': false, 'latitude': -7.2575, 'longitude': 112.7521, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Asia/Jakarta', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── TURKEY ──
    {'id': 'istanbul_tr', 'cityName': 'Istanbul', 'state': 'Istanbul Province', 'country': 'Turkey', 'countryCode': 'TR', 'isActive': false, 'latitude': 41.0082, 'longitude': 28.9784, 'calculationMethod': 'turkey', 'timezone': 'Europe/Istanbul', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'ankara_tr', 'cityName': 'Ankara', 'state': 'Ankara Province', 'country': 'Turkey', 'countryCode': 'TR', 'isActive': false, 'latitude': 39.9334, 'longitude': 32.8597, 'calculationMethod': 'turkey', 'timezone': 'Europe/Istanbul', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},

    // ── GERMANY ──
    {'id': 'berlin_de', 'cityName': 'Berlin', 'state': 'Berlin', 'country': 'Germany', 'countryCode': 'DE', 'isActive': false, 'latitude': 52.5200, 'longitude': 13.4050, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/Berlin', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
    {'id': 'cologne_de', 'cityName': 'Cologne', 'state': 'North Rhine-Westphalia', 'country': 'Germany', 'countryCode': 'DE', 'isActive': false, 'latitude': 50.9333, 'longitude': 6.9500, 'calculationMethod': 'muslimWorldLeague', 'timezone': 'Europe/Berlin', 'adminCount': 0, 'maxAdmins': 10, 'ramadanOverride': null},
  ];
}

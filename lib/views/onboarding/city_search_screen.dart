import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../models/city.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/service_locator.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  final _searchController = TextEditingController();
  List<LocationCity> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final results = await citiesService.searchCities(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _selectCity(LocationCity city) async {
    if (city.isActive) {
      await ref.read(preferencesProvider.notifier).setCityId(city.id);
      await ref.read(preferencesProvider.notifier).setFirstLaunchComplete();
      if (mounted) {
        context.go('/feed');
      }
    } else {
      context.push('/city-gate/${city.id}/${city.cityName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocale = ref.watch(localeProvider);
    final lang = selectedLocale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ur' ? 'شہر منتخب کریں' : 'Choose Your City'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input field
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: getTranslation(lang, 'searchCity'),
                  prefixIcon: const Icon(Icons.search, color: AppColors.accentGold),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.accentGold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                    ),
                  ),
                )
              else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      lang == 'ur' ? 'کوئی شہر نہیں ملا' : 'No cities found.',
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  ),
                )
              else if (_searchResults.isEmpty && _searchController.text.isEmpty)
                Expanded(
                  child: FutureBuilder<List<LocationCity>>(
                    future: citiesService.searchCities(''),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final allCities = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              lang == 'ur'
                                  ? '${allCities.length} شہر دنیا بھر میں دستیاب ہیں'
                                  : '${allCities.length} cities available worldwide',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: allCities.length,
                              itemBuilder: (context, index) {
                                final city = allCities[index];
                                return _buildCityTile(city, isDark, lang);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final city = _searchResults[index];
                      return _buildCityTile(city, isDark, lang);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(LocationCity city, bool isDark, String lang) {
    return Card(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(city.cityName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${city.state}, ${city.country}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: city.isActive
                ? AppColors.success.withOpacity(0.15)
                : AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            city.isActive
                ? getTranslation(lang, 'live')
                : getTranslation(lang, 'comingSoon'),
            style: TextStyle(
              color: city.isActive ? AppColors.success : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _selectCity(city),
      ),
    );
  }
}

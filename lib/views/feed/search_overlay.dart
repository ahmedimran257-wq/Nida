import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../providers/locale_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../services/service_locator.dart';
import 'widgets/announcement_card.dart';

void showSearchOverlay(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Search',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return const SearchOverlay();
    },
  );
}

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final _searchController = TextEditingController();
  List<Announcement> _results = [];
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
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final prefs = ref.read(preferencesProvider);
    final cityId = prefs.cityId ?? 'kurnool_in';

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final list = await announcementsService.searchAnnouncements(
        cityId: cityId,
        query: query,
      );
      if (mounted) {
        setState(() {
          _results = list;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: lang == 'ur' ? 'علماء، مساجد، یا عنوان تلاش کریں...' : 'Search scholars, masjids, titles...',
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Search Results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                      ),
                    )
                  : _results.isEmpty && _searchController.text.isNotEmpty
                      ? Center(
                          child: Text(
                            lang == 'ur' ? 'کوئی پروگرام نہیں ملا' : 'No results found.',
                            style: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        )
                      : _results.isEmpty && _searchController.text.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    lang == 'ur' ? 'برادری کے پروگرام تلاش کریں' : 'Type to search NIDA',
                                    style: GoogleFonts.outfit(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                return AnnouncementCard(announcement: _results[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../models/masjid.dart';
import '../../models/scholar.dart';
import '../../providers/admin_provider.dart';
import '../../providers/masjid_provider.dart';
import '../../providers/scholar_provider.dart';
import 'package:adhan/adhan.dart';
import '../../../services/location/prayer_times_calculator.dart';
import '../../../services/service_locator.dart';

class PostAnnouncementScreen extends ConsumerStatefulWidget {
  final Announcement? announcement;
  const PostAnnouncementScreen({super.key, this.announcement});

  @override
  ConsumerState<PostAnnouncementScreen> createState() => _PostAnnouncementScreenState();
}

class _PostAnnouncementScreenState extends ConsumerState<PostAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _programType = 'BAYAN';
  String _importanceLevel = 'STANDARD';
  String? _selectedMasjidId;
  String? _selectedScholarId;
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  
  bool _isRecurring = false;
  String _recurringRule = 'FREQ=WEEKLY';
  bool _isLoading = false;
  File? _posterImage;
  String? _existingPosterUrl;

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      final a = widget.announcement!;
      _titleController.text = a.title;
      _descController.text = a.description ?? '';
      _programType = a.programType;
      _importanceLevel = a.importanceLevel;
      _selectedMasjidId = a.masjidId;
      _selectedScholarId = a.scholarId;
      _scheduledDate = a.scheduledTime;
      _scheduledTime = TimeOfDay.fromDateTime(a.scheduledTime);
      _isRecurring = a.isRecurring;
      _recurringRule = a.recurringRule ?? 'FREQ=WEEKLY';
      _existingPosterUrl = a.posterUrl;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (picked == null) return;
    setState(() {
      _posterImage = File(picked.path);
      _existingPosterUrl = null;
    });
  }

  Widget _buildImagePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.4), width: 1),
          color: AppColors.primaryEmerald.withOpacity(0.04),
        ),
        child: _posterImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_posterImage!, fit: BoxFit.cover, width: double.infinity),
              )
            : (_existingPosterUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _existingPosterUrl!.startsWith('http')
                        ? Image.network(_existingPosterUrl!, fit: BoxFit.cover, width: double.infinity)
                        : Image.file(File(_existingPosterUrl!), fit: BoxFit.cover, width: double.infinity),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined, color: AppColors.accentGold, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Add Poster Image (Optional)',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ],
                  )),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  void _setFromPrayer(Prayer prayer, {required bool today}) async {
    final adminState = ref.read(adminProvider);
    final cityId = adminState.cityId ?? 'kurnool_in';
    final city = await citiesService.getCityById(cityId);
    if (city == null) return;

    final targetDate = today ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
    final prayerTimes = PrayerTimesCalculator.getTimes(city, targetDate);
    
    final DateTime prayerDateTime;
    switch (prayer) {
      case Prayer.fajr:
        prayerDateTime = prayerTimes.fajr.add(const Duration(minutes: 15));
        break;
      case Prayer.dhuhr:
        prayerDateTime = prayerTimes.dhuhr.add(const Duration(minutes: 15));
        break;
      case Prayer.maghrib:
        prayerDateTime = prayerTimes.maghrib.add(const Duration(minutes: 10));
        break;
      case Prayer.isha:
        prayerDateTime = prayerTimes.isha.add(const Duration(minutes: 15));
        break;
      default:
        return;
    }
    
    setState(() {
      _scheduledDate = prayerDateTime;
      _scheduledTime = TimeOfDay.fromDateTime(prayerDateTime);
    });
  }

  Widget _buildQuickTimeChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: AppColors.primaryEmerald.withOpacity(0.08),
      side: const BorderSide(color: AppColors.primaryEmerald, width: 0.5),
    );
  }

  Future<void> _handleSubmit(String cityId, List<Masjid> masjids, List<Scholar> scholars) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMasjidId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a masjid.')));
      return;
    }
    if (_selectedScholarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a scholar.')));
      return;
    }

    setState(() => _isLoading = true);

    // Construct scheduled DateTime
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    final expiresAt = scheduledDateTime.add(const Duration(hours: 4)); // Auto-expiry TTL definition

    // Find models for snapshotted values
    final masjid = masjids.firstWhere((m) => m.id == _selectedMasjidId);
    final scholar = scholars.firstWhere((s) => s.id == _selectedScholarId);
    
    final admin = ref.read(adminProvider);

    final newAnnouncement = Announcement(
      id: widget.announcement?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      programType: _programType,
      importanceLevel: _importanceLevel,
      scholarId: scholar.id,
      scholarNameSnapshot: scholar.nameEnglish,
      scholarNameArabicSnapshot: scholar.nameArabic,
      masjidId: masjid.id,
      masjidNameSnapshot: masjid.nameEnglish,
      masjidLocalitySnapshot: masjid.locality,
      scheduledTime: scheduledDateTime,
      expiresAt: expiresAt,
      createdAt: widget.announcement?.createdAt ?? DateTime.now(),
      cityId: cityId,
      countryCode: masjid.countryCode,
      posterUrl: _posterImage?.path ?? _existingPosterUrl,
      isRecurring: _isRecurring,
      recurringRule: _isRecurring ? _recurringRule : null,
      postedBy: admin.adminId!,
      reportedByUids: widget.announcement?.reportedByUids ?? const [],
      reportCount: widget.announcement?.reportCount ?? 0,
      isFlaggedForReview: widget.announcement?.isFlaggedForReview ?? false,
      isHidden: widget.announcement?.isHidden ?? false,
    );

    if (widget.announcement != null) {
      await ref.read(adminProvider.notifier).updateAnnouncement(newAnnouncement);
    } else {
      await ref.read(adminProvider.notifier).postAnnouncement(newAnnouncement);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.announcement != null ? 'Announcement updated successfully!' : 'Announcement published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final cityId = adminState.cityId ?? 'kurnool_in';

    // Watch masjids and scholars to populate dropdown selectors
    final masjidsAsync = ref.watch(masjidsProvider(cityId));
    final scholarsAsync = ref.watch(scholarsProvider(cityId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.announcement != null ? 'Edit Announcement' : 'Post Announcement')),
      body: masjidsAsync.when(
        data: (masjids) => scholarsAsync.when(
          data: (scholars) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Program Title',
                      hintText: 'e.g. Weekly Hadith Dars',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Program Details (Optional)',
                      hintText: 'e.g. Dinner will be served. Special session for children.',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Program Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _programType,
                    decoration: const InputDecoration(labelText: 'Program Type', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'BAYAN', child: Text('Bayan')),
                      DropdownMenuItem(value: 'DARS', child: Text('Dars')),
                      DropdownMenuItem(value: 'JUMUAH', child: Text('Jumu\'ah')),
                      DropdownMenuItem(value: 'SPECIAL', child: Text('Special Program')),
                      DropdownMenuItem(value: 'JANAZAH', child: Text('Janazah Notice')),
                      DropdownMenuItem(value: 'TARAWEEH', child: Text('Taraweeh')),
                    ],
                    onChanged: (val) => setState(() => _programType = val!),
                  ),
                  const SizedBox(height: 16),

                   // Masjid Selector Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMasjidId,
                    decoration: const InputDecoration(labelText: 'Select Masjid', border: OutlineInputBorder()),
                    items: [
                      ...masjids.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text(m.nameEnglish));
                      }),
                      DropdownMenuItem(
                        value: '__ADD_NEW__',
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 16, color: AppColors.accentGold),
                            const SizedBox(width: 8),
                            Text('Add New Masjid', style: TextStyle(color: AppColors.accentGold)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == '__ADD_NEW__') {
                        context.push('/admin/add-masjid');
                      } else {
                        setState(() => _selectedMasjidId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Scholar Selector Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedScholarId,
                    decoration: const InputDecoration(labelText: 'Select Scholar', border: OutlineInputBorder()),
                    items: [
                      ...scholars.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.nameEnglish));
                      }),
                      DropdownMenuItem(
                        value: '__ADD_NEW__',
                        child: Row(
                          children: [
                            const Icon(Icons.add, size: 16, color: AppColors.accentGold),
                            const SizedBox(width: 8),
                            Text('Add New Scholar', style: TextStyle(color: AppColors.accentGold)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == '__ADD_NEW__') {
                        context.push('/admin/add-scholar');
                      } else {
                        setState(() => _selectedScholarId = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quick Schedule Chips
                  const Text('QUICK SCHEDULE (TODAY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickTimeChip('After Fajr', () => _setFromPrayer(Prayer.fajr, today: true)),
                      _buildQuickTimeChip('After Zuhr', () => _setFromPrayer(Prayer.dhuhr, today: true)),
                      _buildQuickTimeChip('After Maghrib', () => _setFromPrayer(Prayer.maghrib, today: true)),
                      _buildQuickTimeChip('After Isha', () => _setFromPrayer(Prayer.isha, today: true)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date & Time pickers
                  const Text('PROGRAM TIMING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_month, color: AppColors.accentGold),
                          label: Text('${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time, color: AppColors.accentGold),
                          label: Text(_scheduledTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recurrence switches
                  SwitchListTile(
                    title: const Text('Recurring Announcement'),
                    subtitle: const Text('Automatically post this event periodically'),
                    value: _isRecurring,
                    activeColor: AppColors.primaryEmerald,
                    onChanged: (val) => setState(() => _isRecurring = val),
                  ),
                  
                  if (_isRecurring) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _recurringRule,
                      decoration: const InputDecoration(labelText: 'Recurrence Pattern', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'FREQ=DAILY', child: Text('Every Day')),
                        DropdownMenuItem(value: 'FREQ=WEEKLY;BYDAY=FR', child: Text('Every Friday')),
                        DropdownMenuItem(value: 'FREQ=WEEKLY', child: Text('Every Week (This day)')),
                      ],
                      onChanged: (val) => setState(() => _recurringRule = val!),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSubmit(cityId, masjids, scholars),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(widget.announcement != null ? 'Update Announcement' : 'Publish Announcement', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading scholars: $err')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading masjids: $err')),
      ),
    );
  }
}

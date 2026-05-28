import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../models/scholar.dart';
import '../../providers/admin_provider.dart';
import '../../services/service_locator.dart';

class AddScholarScreen extends ConsumerStatefulWidget {
  const AddScholarScreen({super.key});

  @override
  ConsumerState<AddScholarScreen> createState() => _AddScholarScreenState();
}

class _AddScholarScreenState extends ConsumerState<AddScholarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _bioController = TextEditingController();
  final _specController = TextEditingController();

  final List<String> _selectedSpecs = [];
  bool _isLoading = false;

  static const List<String> _suggestedSpecs = ['Hadith', 'Fiqh', 'Tafsir', 'Aqeedah', 'Youth Outreach', 'General Bayan'];

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _bioController.dispose();
    _specController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String cityId) async {
    if (!_formKey.currentState!.validate()) return;
    
    // Add comma separated specs if any typed
    final typedSpecs = _specController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
        
    final allSpecs = [..._selectedSpecs, ...typedSpecs];
    if (allSpecs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter at least one specialization.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final admin = ref.read(adminProvider);
    final city = await citiesService.getCityById(cityId);
    final countryCode = city?.countryCode ?? 'IN';

    final newScholar = Scholar(
      id: const Uuid().v4(),
      nameEnglish: _nameEnController.text.trim(),
      nameArabic: _nameArController.text.trim(),
      specializations: allSpecs,
      bio: _bioController.text.trim(),
      addedBy: admin.adminId!,
      cityId: cityId,
      countryCode: countryCode,
      createdAt: DateTime.now(),
      isActive: true,
      totalPrograms: 0,
    );

    await ref.read(adminProvider.notifier).createScholar(newScholar);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scholar added successfully!'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final cityId = adminState.cityId ?? 'kurnool_in';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Scholar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // English Name
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: 'Scholar Name (English)',
                hintText: 'e.g. Sheikh Abdullah',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'English name is required' : null,
            ),
            const SizedBox(height: 16),

            // Arabic Name
            TextFormField(
              controller: _nameArController,
              decoration: const InputDecoration(
                labelText: 'Scholar Name (Arabic/Urdu Script)',
                hintText: 'e.g. الشيخ عبدالله',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Arabic script name is required' : null,
              textDirection: TextDirection.rtl, // RTL input
            ),
            const SizedBox(height: 24),

            // Specialization tags chips
            const Text('SPECIALIZATIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedSpecs.map((spec) {
                final isSelected = _selectedSpecs.contains(spec);
                return FilterChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSpecs.add(spec);
                      } else {
                        _selectedSpecs.remove(spec);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryEmerald.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryEmerald,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _specController,
              decoration: const InputDecoration(
                labelText: 'Custom Specializations (Comma separated)',
                hintText: 'e.g. Seerah, Aqeedah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Biography / Background',
                hintText: 'Graduate of Madinah University. Specializes in Hadith teaching.',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : () => _handleSubmit(cityId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add Scholar Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

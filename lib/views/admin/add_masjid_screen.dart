import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../constants/colors.dart';
import '../../models/masjid.dart';
import '../../providers/admin_provider.dart';
import '../../services/service_locator.dart';

class AddMasjidScreen extends ConsumerStatefulWidget {
  const AddMasjidScreen({super.key});

  @override
  ConsumerState<AddMasjidScreen> createState() => _AddMasjidScreenState();
}

class _AddMasjidScreenState extends ConsumerState<AddMasjidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _localityController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _localityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(String cityId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final admin = ref.read(adminProvider);
    final city = await citiesService.getCityById(cityId);
    final countryCode = city?.countryCode ?? 'IN';

    final newMasjid = Masjid(
      id: const Uuid().v4(),
      nameArabic: _nameArController.text.trim(),
      nameEnglish: _nameEnController.text.trim(),
      locality: _localityController.text.trim(),
      address: _addressController.text.trim(),
      cityId: cityId,
      countryCode: countryCode,
      isVerified: true,
      followerCount: 0,
      addedBy: admin.adminId!,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await ref.read(adminProvider.notifier).createMasjid(newMasjid);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masjid added successfully!'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final cityId = adminState.cityId ?? 'kurnool_in';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Masjid')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // English Name
            TextFormField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: 'Masjid Name (English)',
                hintText: 'e.g. Masjid Al-Noor',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'English name is required' : null,
            ),
            const SizedBox(height: 16),

            // Arabic Name
            TextFormField(
              controller: _nameArController,
              decoration: const InputDecoration(
                labelText: 'Masjid Name (Arabic Script)',
                hintText: 'e.g. مسجد النور',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Arabic name is required' : null,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),

            // Locality
            TextFormField(
              controller: _localityController,
              decoration: const InputDecoration(
                labelText: 'Locality / Area',
                hintText: 'e.g. Patel Nagar',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Locality is required' : null,
            ),
            const SizedBox(height: 16),

            // Full Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                hintText: 'e.g. 14 Patel Nagar, Kurnool 518002',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Address is required' : null,
              maxLines: 2,
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
                  : const Text('Register Masjid', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

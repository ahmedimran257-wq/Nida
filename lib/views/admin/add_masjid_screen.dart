import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

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
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _localityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Please enable in device settings.')),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() => _isGettingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
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
      latitude: _latitude ?? 0.0,
      longitude: _longitude ?? 0.0,
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
            const SizedBox(height: 16),
            _buildLocationPicker(),
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

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MASJID LOCATION',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        
        if (_latitude != null && _longitude != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primaryEmerald, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${_latitude!.toStringAsFixed(6)}\nLng: ${_longitude!.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: _captureLocation,
                  tooltip: 'Re-capture',
                ),
              ],
            ),
          )
        else
          Text(
            'No location captured yet. Tap the button below while standing at the masjid for maximum accuracy.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        
        const SizedBox(height: 10),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isGettingLocation ? null : _captureLocation,
            icon: _isGettingLocation
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: AppColors.accentGold),
            label: Text(
              _isGettingLocation
                  ? 'Getting location...'
                  : _latitude != null
                      ? 'Update Location'
                      : '📍 Capture Masjid Location (Stand Here)',
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accentGold),
              foregroundColor: AppColors.accentGold,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        
        const SizedBox(height: 6),
        Text(
          '⚠️ For accurate pinning: stand inside or directly in front of the masjid before tapping.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';
import '../../providers/superadmin_provider.dart';

class SuperAdminLoginScreen extends ConsumerStatefulWidget {
  const SuperAdminLoginScreen({super.key});

  @override
  ConsumerState<SuperAdminLoginScreen> createState() => _SuperAdminLoginScreenState();
}

class _SuperAdminLoginScreenState extends ConsumerState<SuperAdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(superAdminProvider.notifier).login(email, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/superadmin/dashboard');
      } else {
        final error = ref.read(superAdminProvider).error ?? 'Login failed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Card(
                color: AppColors.surfaceDark,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.accentGold.withOpacity(0.2), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.accentGold, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        'NIDA',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentGold,
                        ),
                      ),
                      Text(
                        'Super Admin Console',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Super Admin Email',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.accentGold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accentGold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.accentGold),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accentGold),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accentGold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.accentGold),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Password is required' : null,
                      ),
                      const SizedBox(height: 28),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryEmerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Enter Console',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

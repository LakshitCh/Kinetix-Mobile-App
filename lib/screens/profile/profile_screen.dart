import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';
import '../../services/api/api_client.dart';

/// Profile screen — exact port of ProfileScreen.tsx.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profile', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.settings_outlined, size: 20, color: AppColors.mutedForeground),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Profile card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.muted,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                        image: const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Alex Rivera', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                        const SizedBox(height: 4),
                        Text('alex@example.com', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('Pro Member', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats grid
              Row(
                children: [
                  _statBox('47', 'WORKOUTS'),
                  const SizedBox(width: 12),
                  _statBox('86', 'AVG SCORE'),
                  const SizedBox(width: 12),
                  _statBox('12', 'STREAK'),
                ],
              ),
              const SizedBox(height: 32),

              // Settings
              const Text('Settings', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: [
                    _settingsItem(Icons.notifications_none, 'Notifications', AppColors.primary, AppColors.primary.withValues(alpha: 0.1)),
                    _settingsItem(Icons.shield_outlined, 'Privacy & Security', AppColors.secondary, AppColors.secondary.withValues(alpha: 0.1)),
                    _settingsItem(Icons.help_outline, 'Help & Support', const Color(0xFFF59E0B), const Color(0xFFF59E0B).withValues(alpha: 0.1)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              GestureDetector(
                onTap: () async {
                  PremiumEffects.triggerHaptic('heavy');
                  // Clear stored auth data
                  const storage = FlutterSecureStorage();
                  await storage.deleteAll();
                  ApiClient.clearToken();
                  if (context.mounted) context.go('/auth');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.destructive.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20, color: AppColors.destructive),
                      const SizedBox(width: 8),
                      Text('Log Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.destructive)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem(IconData icon, String label, Color iconColor, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground))),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

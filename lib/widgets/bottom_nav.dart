import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/premium_effects.dart';
import 'package:go_router/go_router.dart';

/// Floating pill-shaped bottom navigation — exact port of BottomNav.tsx.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    final navItems = [
      _NavItem(path: '/home', icon: Icons.home_rounded, label: 'Home'),
      _NavItem(path: '/workout-select', icon: Icons.fitness_center_rounded, label: 'Workout'),
      _NavItem(path: '/stats', icon: Icons.grid_view_rounded, label: 'Stats'),
      _NavItem(path: '/calendar', icon: Icons.calendar_today_rounded, label: 'Calendar'),
      _NavItem(path: '/profile', icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: navItems.map((item) {
              final isActive = currentLocation == item.path ||
                  (currentLocation == '/' && item.path == '/home');

              return GestureDetector(
                onTap: () {
                  PremiumEffects.triggerHaptic('light');
                  context.go(item.path);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: isActive ? Colors.white : const Color(0xFF8E8E93),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final String label;

  const _NavItem({required this.path, required this.icon, required this.label});
}

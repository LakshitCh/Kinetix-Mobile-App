import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';

/// Calendar screen — exact port of CalendarScreen.tsx.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dates = [
      {'day': 'Mon', 'date': '11', 'active': false},
      {'day': 'Tue', 'date': '12', 'active': true},
      {'day': 'Wed', 'date': '13', 'active': false},
      {'day': 'Thu', 'date': '14', 'active': false},
      {'day': 'Fri', 'date': '15', 'active': false},
      {'day': 'Sat', 'date': '16', 'active': false},
      {'day': 'Sun', 'date': '17', 'active': false},
    ];

    final workouts = [
      {'time': '07:30 - 08:15', 'title': 'Squats Focus', 'subtitle': 'Lower Body AI', 'color': AppColors.secondary, 'completed': true},
      {'time': '12:00 - 13:00', 'title': 'Full Body Circuit', 'subtitle': 'High Intensity', 'color': AppColors.primary, 'completed': true},
      {'time': '16:00 - 17:00', 'title': 'Push-up Mastery', 'subtitle': 'Upper Body AI', 'color': AppColors.secondary, 'completed': false},
      {'time': '18:30 - 19:15', 'title': 'Core Blast', 'subtitle': 'Planks & Crunches', 'color': AppColors.primary, 'completed': false},
    ];

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
                  GestureDetector(
                    onTap: () { PremiumEffects.triggerHaptic('light'); context.pop(); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.chevron_left, size: 20, color: AppColors.mutedForeground),
                    ),
                  ),
                  const Text('Calendar', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Date scroller
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dates.map((d) {
                  final isActive = d['active'] as bool;
                  return Container(
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12)] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          d['day'] as String,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: isActive ? Colors.white : AppColors.mutedForeground),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d['date'] as String,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isActive ? Colors.white : AppColors.foreground),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Search
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: AppColors.mutedForeground),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 13, color: AppColors.foreground),
                        decoration: InputDecoration(
                          hintText: 'Search name or training',
                          hintStyle: TextStyle(color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Workout list
              const Text('Tuesday, December 12', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
              const SizedBox(height: 16),
              ...workouts.map((w) {
                final completed = w['completed'] as bool;
                final color = w['color'] as Color;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.check_circle_outline, size: 24, color: color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w['time'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.mutedForeground)),
                              const SizedBox(height: 4),
                              Text(w['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                              Text(w['subtitle'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            PremiumEffects.triggerHaptic('light');
                            context.push('/workout-select');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: completed ? Colors.transparent : AppColors.secondary,
                              borderRadius: BorderRadius.circular(100),
                              border: completed ? Border.all(color: AppColors.border) : null,
                              boxShadow: completed ? [] : [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 8)],
                            ),
                            child: Text(
                              completed ? 'Done' : 'Join',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: completed ? AppColors.mutedForeground : Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

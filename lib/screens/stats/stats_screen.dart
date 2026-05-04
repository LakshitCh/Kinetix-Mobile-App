import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';

/// Stats screen — exact port of StatsScreen.tsx.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _activeTab = 'activity';

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
                  _circleButton(Icons.chevron_left, () { PremiumEffects.triggerHaptic('light'); context.pop(); }),
                  const Text('My fitness journey', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  _circleButton(Icons.share_outlined, () {}),
                ],
              ),
              const SizedBox(height: 32),

              // Toggle bar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _tabButton('Activity', Icons.directions_run, 'activity'),
                    _tabButton('Progress', Icons.trending_up, 'progress'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 8),
                  Text('Tue, December 12, 2025', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 24),

              if (_activeTab == 'activity') _buildActivityTab() else _buildProgressTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Steps chart card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Steps: 5,348', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(Icons.directions_walk, size: 12, color: AppColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 128,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [20, 30, 45, 80, 60, 40, 50, 70, 90, 40].asMap().entries.map((e) {
                    final isPrimary = [3, 4, 7, 8].contains(e.key);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: FractionallySizedBox(
                          heightFactor: e.value / 100,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isPrimary ? AppColors.primary : AppColors.muted,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dual cards
        Row(
          children: [
            Expanded(child: _statCard('Calories', '273', 'KCAL', AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: _statCard('Workout:', '1h 5m', null, AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 32),

        // Goals
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My goals', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            Text('+ Add goals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
          ],
        ),
        const SizedBox(height: 12),
        _goalCard('Feel more balanced with yoga', '3x per week', 'Jan 26', '2/3', AppColors.secondary),
        const SizedBox(height: 12),
        _goalCard('5,000 steps per day', 'Every day', 'Never', '2,971', AppColors.primary),
      ],
    );
  }

  Widget _buildProgressTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weekly Streak: 5 Days', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(Icons.local_fire_department, size: 12, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
                  final isActive = e.key < 5;
                  return Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.muted,
                      shape: BoxShape.circle,
                      boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)] : [],
                    ),
                    child: Center(child: Text(e.value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? Colors.white : AppColors.mutedForeground))),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text('Milestones', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground)),
        const SizedBox(height: 16),
        _milestoneCard('100 Squats Club', 'Completed in a single session', Icons.emoji_events, AppColors.secondary, false),
        const SizedBox(height: 16),
        _milestoneCard('Iron Core', 'Hold a plank for 5 minutes', Icons.track_changes, AppColors.mutedForeground, true),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.card, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
        child: Icon(icon, size: 20, color: AppColors.mutedForeground),
      ),
    );
  }

  Widget _tabButton(String label, IconData icon, String tab) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () { PremiumEffects.triggerHaptic('light'); setState(() => _activeTab = tab); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isActive ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 8)] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, String? unit, Color color) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(label == 'Calories' ? Icons.local_fire_department : Icons.schedule, size: 12, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground)),
              if (unit != null) Text(unit, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalCard(String title, String freq, String deadline, String progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(freq, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 12, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(deadline, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
            child: Center(child: Text(progress, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
          ),
        ],
      ),
    );
  }

  Widget _milestoneCard(String title, String subtitle, IconData icon, Color color, bool locked) {
    return Opacity(
      opacity: locked ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.foreground)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

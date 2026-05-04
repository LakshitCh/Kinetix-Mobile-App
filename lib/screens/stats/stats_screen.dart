import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';
import '../../services/local/local_storage_service.dart';

/// Stats screen — powered by real local workout data.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _activeTab = 'activity';

  // Real data
  int _totalReps = 0;
  int _totalCalories = 0;
  int _totalDurationSeconds = 0;
  int _totalWorkouts = 0;
  int _streak = 0;
  List<Map<String, dynamic>> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await LocalStorageService.getStats();
    if (mounted) {
      setState(() {
        _totalReps = stats['totalReps'] as int;
        _totalCalories = stats['totalCalories'] as int;
        _totalDurationSeconds = stats['totalDurationSeconds'] as int;
        _totalWorkouts = stats['totalWorkouts'] as int;
        _streak = stats['streak'] as int;
        _workouts = (stats['workouts'] as List).cast<Map<String, dynamic>>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

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
                  _circleButton(Icons.chevron_left, () { PremiumEffects.triggerHaptic('light'); context.go('/home'); }),
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
                  Text(today, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
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
    // Build bar chart data from the last 10 workouts (reps)
    final recentWorkouts = _workouts.take(10).toList().reversed.toList();
    final maxReps = recentWorkouts.isNotEmpty
        ? recentWorkouts.map((w) => w['reps'] as int? ?? 0).reduce((a, b) => a > b ? a : b)
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reps chart card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Reps: ${_formatNumber(_totalReps)}', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(Icons.fitness_center, size: 12, color: AppColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 128,
                child: recentWorkouts.isEmpty
                    ? Center(
                        child: Text('Complete a workout to see your chart', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: recentWorkouts.asMap().entries.map((e) {
                          final reps = e.value['reps'] as int? ?? 0;
                          final factor = maxReps > 0 ? (reps / maxReps).clamp(0.05, 1.0) : 0.05;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: FractionallySizedBox(
                                heightFactor: factor,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: e.key >= recentWorkouts.length - 3 ? AppColors.primary : AppColors.muted,
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
            Expanded(child: _statCard('Calories', _formatNumber(_totalCalories), 'KCAL', AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: _statCard('Workout:', LocalStorageService.formatDuration(_totalDurationSeconds), null, AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 32),

        // Recent workouts
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Workouts', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            Text('$_totalWorkouts total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
          ],
        ),
        const SizedBox(height: 12),
        if (_workouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 32, color: AppColors.mutedForeground.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('No workouts yet', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Start a workout to see your history here', style: TextStyle(color: AppColors.mutedForeground.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...(_workouts.take(5).map((w) {
            final ts = DateTime.tryParse(w['timestamp'] ?? '');
            final dateStr = ts != null ? DateFormat('MMM d, h:mm a').format(ts) : '';
            final exerciseName = (w['exerciseName'] as String? ?? 'Workout').replaceAll('-', ' ');
            return _workoutHistoryCard(
              exerciseName,
              '${w['reps']} reps • ${LocalStorageService.formatDuration(w['durationSeconds'] ?? 0)}',
              dateStr,
              AppColors.secondary,
            );
          })),
      ],
    );
  }

  Widget _buildProgressTab() {
    // Build weekly streak from real data
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Check which days of this week have workouts
    final daysWithWorkouts = <int>{};
    for (final w in _workouts) {
      final ts = DateTime.tryParse(w['timestamp'] ?? '');
      if (ts != null) {
        final daysDiff = ts.difference(weekStart).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          daysWithWorkouts.add(daysDiff);
        }
      }
    }

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
                  Text('Streak: $_streak ${_streak == 1 ? "Day" : "Days"}', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
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
                children: dayLabels.asMap().entries.map((e) {
                  final isActive = daysWithWorkouts.contains(e.key);
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
        _milestoneCard(
          'First Workout',
          _totalWorkouts >= 1 ? 'Completed!' : 'Complete your first workout',
          Icons.emoji_events,
          _totalWorkouts >= 1 ? AppColors.secondary : AppColors.mutedForeground,
          _totalWorkouts < 1,
        ),
        const SizedBox(height: 16),
        _milestoneCard(
          '100 Reps Club',
          _totalReps >= 100 ? 'Achieved — $_totalReps total reps!' : '${100 - _totalReps} reps to go',
          Icons.track_changes,
          _totalReps >= 100 ? AppColors.secondary : AppColors.mutedForeground,
          _totalReps < 100,
        ),
        const SizedBox(height: 16),
        _milestoneCard(
          '7-Day Streak',
          _streak >= 7 ? 'Unlocked!' : '$_streak / 7 days',
          Icons.local_fire_department,
          _streak >= 7 ? AppColors.primary : AppColors.mutedForeground,
          _streak < 7,
        ),
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

  Widget _workoutHistoryCard(String title, String subtitle, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.fitness_center, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
              ),
            ),
            Text(date, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ],
        ),
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

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}

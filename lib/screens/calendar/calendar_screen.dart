import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';
import '../../services/local/local_storage_service.dart';

/// Calendar screen — shows real workout history by day.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  List<Map<String, dynamic>> _dayWorkouts = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _buildWeek();
    _loadWorkoutsForDay();
  }

  void _buildWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _loadWorkoutsForDay() async {
    final workouts = await LocalStorageService.getWorkoutsForDate(_selectedDate);
    if (mounted) {
      setState(() => _dayWorkouts = workouts);
    }
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    _loadWorkoutsForDay();
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDateFormatted = DateFormat('EEEE, MMMM d').format(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: Scaffold(
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
                    onTap: () {
                      PremiumEffects.triggerHaptic('light');
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
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
                children: _weekDates.asMap().entries.map((e) {
                  final date = e.value;
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;

                  return GestureDetector(
                    onTap: () {
                      PremiumEffects.triggerHaptic('light');
                      _selectDate(date);
                    },
                    child: Container(
                      width: 48,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12)] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayNames[e.key],
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: isSelected ? Colors.white : AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.foreground),
                          ),
                        ],
                      ),
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
              Text(
                isToday ? 'Today' : selectedDateFormatted,
                style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground),
              ),
              const SizedBox(height: 16),

              if (_dayWorkouts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy, size: 40, color: AppColors.mutedForeground.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No workouts on this day', style: TextStyle(color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.push('/workout-select'),
                          child: Text('Start one now →', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._dayWorkouts.map((w) {
                  final ts = DateTime.tryParse(w['timestamp'] ?? '');
                  final timeStr = ts != null ? DateFormat('h:mm a').format(ts) : '';
                  final exerciseName = (w['exerciseName'] as String? ?? 'Workout').replaceAll('-', ' ');
                  final duration = LocalStorageService.formatDuration(w['durationSeconds'] ?? 0);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                            child: Icon(Icons.check_circle_outline, size: 24, color: AppColors.secondary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timeStr, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.mutedForeground)),
                                const SizedBox(height: 4),
                                Text(exerciseName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                                Text('${w['reps']} reps • $duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Done',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground),
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
      ),
    );
  }
}

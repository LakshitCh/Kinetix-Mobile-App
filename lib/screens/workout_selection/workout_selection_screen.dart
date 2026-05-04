import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';
import '../../models/exercise.dart';

/// Workout selection screen with category filtering and rep target configuration.
class WorkoutSelectionScreen extends StatefulWidget {
  final String? initialCategory;
  const WorkoutSelectionScreen({super.key, this.initialCategory});

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  late String _activeCategory;
  String _searchQuery = '';
  ExerciseModel? _selectedExercise;
  int _targetReps = 10;

  @override
  void initState() {
    super.initState();
    _activeCategory = widget.initialCategory ?? 'all';
  }

  List<ExerciseModel> get _filteredExercises {
    return ExerciseData.exercises.where((ex) {
      final matchesCategory = _activeCategory == 'all' || ex.category == _activeCategory;
      final matchesSearch = ex.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _handleStartWorkout() {
    PremiumEffects.triggerHaptic('heavy');
    if (_selectedExercise != null) {
      context.push('/active-workout?exercise=${_selectedExercise!.id}&reps=$_targetReps');
      setState(() => _selectedExercise = null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: Stack(
          children: [
            SafeArea(
              child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.8),
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    Row(
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(Icons.chevron_left, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Select Workout',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.foreground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: const TextStyle(color: AppColors.foreground, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search exercises...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
                          child: Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
                        ),
                        filled: true,
                        fillColor: AppColors.input.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ExerciseData.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = ExerciseData.categories[index];
                      final isActive = _activeCategory == cat['id'];
                      return GestureDetector(
                        onTap: () {
                          PremiumEffects.triggerHaptic('light');
                          setState(() => _activeCategory = cat['id']!);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : AppColors.muted,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: isActive
                                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Text(
                            cat['name']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isActive ? Colors.white : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Exercise list
              Expanded(
                child: _filteredExercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: AppColors.mutedForeground.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text('No exercises found.', style: TextStyle(color: AppColors.mutedForeground)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filteredExercises.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final ex = _filteredExercises[index];
                          return GestureDetector(
                            onTap: () {
                              PremiumEffects.triggerHaptic('light');
                              setState(() {
                                _selectedExercise = ex;
                                _targetReps = 10;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(ex.icon, size: 28, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ex.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.muted,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(ex.difficulty, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(ex.duration, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.muted,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Icon(Icons.chevron_right, size: 20, color: AppColors.foreground),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
          
          // Rep selection bottom sheet
          if (_selectedExercise != null) ...[
            // Backdrop
            GestureDetector(
              onTap: () => setState(() => _selectedExercise = null),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            // Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  border: Border(top: BorderSide(color: AppColors.border)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, -8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedExercise!.name,
                              style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.foreground),
                            ),
                            const SizedBox(height: 4),
                            Text('Set your target reps', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedExercise = null),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
                            child: const Center(child: Text('✕', style: TextStyle(color: AppColors.mutedForeground, fontSize: 14))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRepButton(Icons.remove, () {
                          PremiumEffects.triggerHaptic('light');
                          setState(() => _targetReps = (_targetReps - 1).clamp(1, 999));
                        }),
                        SizedBox(
                          width: 96,
                          child: Center(
                            child: Text(
                              '$_targetReps',
                              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ),
                        _buildRepButton(Icons.add, () {
                          PremiumEffects.triggerHaptic('light');
                          setState(() => _targetReps++);
                        }),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleStartWorkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text('Start Tracking', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildRepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon, size: 24, color: AppColors.foreground),
      ),
    );
  }
}

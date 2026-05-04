import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';
import '../../services/local/local_storage_service.dart';

/// Workout summary screen — saves workout data locally.
class WorkoutSummaryScreen extends StatefulWidget {
  final int reps;
  final int time;
  final String exercise;

  const WorkoutSummaryScreen({
    super.key,
    this.reps = 0,
    this.time = 0,
    this.exercise = 'Workout',
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  late ConfettiController _confettiController;
  bool _isSaving = true;
  bool _saveSuccess = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _saveWorkoutLocally();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Save the completed workout to local storage.
  Future<void> _saveWorkoutLocally() async {
    try {
      final calories = (widget.time * 0.15 + widget.reps * 0.5).round();

      await LocalStorageService.saveWorkout(
        exerciseName: widget.exercise,
        reps: widget.reps,
        durationSeconds: widget.time,
        calories: calories,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final calories = (widget.time * 0.15 + widget.reps * 0.5).round();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
                child: Column(
                  children: [
                    // Success icon
                    Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.directions_run, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    const Text('Great Workout!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                    const SizedBox(height: 8),
                    Text('You crushed ${widget.exercise.replaceAll('-', ' ')} today.', style: TextStyle(color: AppColors.mutedForeground)),

                    // Save status indicator
                    const SizedBox(height: 12),
                    if (_isSaving)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.mutedForeground)),
                          ),
                          const SizedBox(width: 8),
                          Text('Saving workout...', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      )
                    else if (_saveSuccess)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text('Saved ✓', style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Score card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                      child: Column(
                        children: [
                          Text('Session Score', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${(widget.reps > 0 ? (75 + (widget.reps * 2).clamp(0, 25)) : 0)}',
                                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: AppColors.foreground),
                              ),
                              Text('/100', style: TextStyle(fontSize: 22, color: AppColors.mutedForeground)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text('${widget.reps} reps completed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _statCard('EXERCISE', widget.exercise.replaceAll('-', ' '), Icons.fitness_center, AppColors.muted),
                        _statCard('REPS', '${widget.reps}', Icons.check_circle_outline, AppColors.primary.withValues(alpha: 0.1)),
                        _statCard('CALORIES', '$calories', Icons.flash_on, AppColors.muted),
                        _statCard('DURATION', _formatTime(widget.time), Icons.trending_up, AppColors.muted),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Form feedback
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.flash_on, size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              const Text('Form Feedback', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _feedbackItem(
                            widget.reps >= 10
                                ? 'Excellent session! You maintained great consistency throughout.'
                                : 'Good start! Try to increase your rep count next time.',
                            AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _feedbackItem('Focus on controlled movement for maximum muscle engagement.', AppColors.foreground),
                          const SizedBox(height: 12),
                          _feedbackItem('Keep up the momentum — consistency is key to progress!', AppColors.foreground),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go('/workout-select'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text('Start Another Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go('/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.muted,
                          foregroundColor: AppColors.foreground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 20,
                minBlastForce: 5,
                gravity: 0.2,
                colors: const [AppColors.primary, AppColors.secondary, Color(0xFFFFD700), Colors.white],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: AppColors.foreground),
          ),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.foreground)),
        ],
      ),
    );
  }

  Widget _feedbackItem(String text, Color dotColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6, height: 6,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, height: 1.5)),
        ),
      ],
    );
  }
}

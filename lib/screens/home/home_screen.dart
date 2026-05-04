import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/premium_effects.dart';
import '../../services/local/local_storage_service.dart';

/// Home screen with real user data and double-tap-to-exit.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _totalReps = 0;
  int _totalCalories = 0;
  int _totalDurationSeconds = 0;
  int _totalWorkouts = 0;
  int _streak = 0;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await LocalStorageService.getUser();
    final stats = await LocalStorageService.getStats();
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
        _totalReps = stats['totalReps'] as int;
        _totalCalories = stats['totalCalories'] as int;
        _totalDurationSeconds = stats['totalDurationSeconds'] as int;
        _totalWorkouts = stats['totalWorkouts'] as int;
        _streak = stats['streak'] as int;
      });
    }
  }

  String get _userInitial =>
      _userName.isNotEmpty ? _userName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress != null &&
            now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
        } else {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Press back again to exit'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.card,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
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
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.neonCyan, AppColors.neonGreen],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _userInitial,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _userName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.foreground),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.mutedForeground, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text('$_streak', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Hero Banner
                GestureDetector(
                  onTap: () {
                    PremiumEffects.triggerHaptic('heavy');
                    context.push('/workout-select');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextStyle(
                                  fontFamily: 'Playfair Display',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.3,
                                ).let((style) => TextSpan(
                                  children: [
                                    const TextSpan(text: 'Not sure '),
                                    TextSpan(text: 'what\n', style: style.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300)),
                                    const TextSpan(text: 'you want to '),
                                    TextSpan(text: 'train\n', style: style.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w300)),
                                    const TextSpan(text: 'today?'),
                                  ],
                                  style: style,
                                )),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Tell us how you feel, we'll recommend workouts matching your energy & mood.",
                                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500, height: 1.5),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  'Find my match',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Text('🌞', style: TextStyle(fontSize: 36)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/workout-select'),
                      child: Row(
                        children: [
                          Text('See all', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.mutedForeground),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryCard(context, Icons.fitness_center, 'Upper Body', 'arms'),
                      _buildCategoryCard(context, Icons.flash_on, 'Lower Body', 'legs'),
                      _buildCategoryCard(context, Icons.track_changes, 'Core', 'core'),
                      _buildCategoryCard(context, Icons.directions_run, 'Full Body', 'all'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Your Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your progress',
                      style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground),
                    ),
                    GestureDetector(
                      onTap: () {
                        PremiumEffects.triggerHaptic('light');
                        context.push('/stats');
                      },
                      child: Row(
                        children: [
                          Text('See activity', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.mutedForeground),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 144,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildProgressCard(
                        '$_totalReps',
                        'reps',
                        Icons.fitness_center,
                        _totalWorkouts > 0 ? (_totalReps / (_totalWorkouts * 15)).clamp(0.0, 1.0) : 0.0,
                      ),
                      _buildProgressCard(
                        '$_totalCalories',
                        'kcal',
                        Icons.local_fire_department,
                        _totalWorkouts > 0 ? (_totalCalories / (_totalWorkouts * 50)).clamp(0.0, 1.0) : 0.0,
                      ),
                      _buildProgressCard(
                        LocalStorageService.formatDuration(_totalDurationSeconds),
                        'activity',
                        Icons.schedule,
                        _totalWorkouts > 0 ? (_totalDurationSeconds / (_totalWorkouts * 300)).clamp(0.0, 1.0) : 0.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String label, String categoryId) {
    return GestureDetector(
      onTap: () {
        PremiumEffects.triggerHaptic('light');
        context.push('/workout-select', extra: categoryId);
      },
      child: Container(
        width: 96,
        height: 96,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.mutedForeground),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String value, String unit, IconData icon, double progress) {
    return Container(
      width: 144,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mini circular progress
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Center(child: Icon(icon, size: 16, color: AppColors.primary)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.foreground),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to allow inline let for TextStyle
extension _LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

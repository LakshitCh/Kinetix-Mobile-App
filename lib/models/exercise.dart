import 'package:flutter/material.dart';

/// Exercise definition matching the React exercises array.
class ExerciseModel {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final String difficulty;
  final String duration;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.difficulty,
    required this.duration,
  });
}

/// Static exercise list matching WorkoutSelectionScreen.tsx
class ExerciseData {
  static const categories = [
    {'id': 'all', 'name': 'All'},
    {'id': 'chest', 'name': 'Chest'},
    {'id': 'legs', 'name': 'Legs'},
    {'id': 'core', 'name': 'Core'},
    {'id': 'arms', 'name': 'Arms'},
  ];

  static final exercises = [
    ExerciseModel(id: 'Squats', name: 'Squats', category: 'legs', icon: Icons.flash_on, difficulty: 'Beginner', duration: '5 min'),
    ExerciseModel(id: 'Push-ups', name: 'Push-ups', category: 'chest', icon: Icons.shield_outlined, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Shoulder Press', name: 'Shoulder Press', category: 'arms', icon: Icons.fitness_center, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Planks', name: 'Planks', category: 'core', icon: Icons.local_fire_department, difficulty: 'Beginner', duration: '2 min'),
    ExerciseModel(id: 'Lunges', name: 'Lunges', category: 'legs', icon: Icons.directions_run, difficulty: 'Beginner', duration: '5 min'),
    ExerciseModel(id: 'Bicep Curls', name: 'Bicep Curls', category: 'arms', icon: Icons.fitness_center, difficulty: 'Beginner', duration: '5 min'),
    ExerciseModel(id: 'Tricep Dips', name: 'Tricep Dips', category: 'arms', icon: Icons.fitness_center, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Crunches', name: 'Crunches', category: 'core', icon: Icons.local_fire_department, difficulty: 'Beginner', duration: '5 min'),
    ExerciseModel(id: 'Lateral Raises', name: 'Lateral Raises', category: 'arms', icon: Icons.fitness_center, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Lats Pulldown', name: 'Lats Pulldown', category: 'arms', icon: Icons.fitness_center, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Wrist Curls', name: 'Wrist Curls', category: 'arms', icon: Icons.fitness_center, difficulty: 'Beginner', duration: '5 min'),
    ExerciseModel(id: 'Chest Press', name: 'Chest Press', category: 'chest', icon: Icons.fitness_center, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Leg Press', name: 'Leg Press', category: 'legs', icon: Icons.flash_on, difficulty: 'Intermediate', duration: '5 min'),
    ExerciseModel(id: 'Hip Thrusts', name: 'Hip Thrusts', category: 'legs', icon: Icons.flash_on, difficulty: 'Intermediate', duration: '5 min'),
  ];
}

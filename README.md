# Kinetix 🏃‍♂️🏋️‍♀️

**Kinetix** is a next-generation, AI-powered native mobile fitness application. Built from the ground up in Flutter, it acts as your personal virtual trainer, leveraging on-device machine learning to track your form, count your reps, and guide your workouts in real-time.

> **⚠️ NOTE FOR REVIEWERS:** This repository contains both a demo-ready build and a full system architecture. For the best experience, please use the demo branch.

## ⚡ DEMO VERSION (Recommended)

The demo version is located in a separate branch (`demo-local`). This version is:
* **Fully functional**
* **Runs completely offline** (no backend needed)
* **Recommended for testing and live demonstrations**

**To run the demo:**
```bash
git checkout demo-local
flutter pub get
flutter run
```

## 🔀 Project Versions

* **Demo Build (`demo-local` branch):**
  * Local storage using SharedPreferences
  * No backend dependency or active API calls
  * Optimized for immediate, on-device usage

* **Full System (`main` branch):**
  * Intended backend integration (Node.js/MongoDB)
  * Scalable architecture
  * Currently under development / partially implemented

## ✨ Features

* **Real-Time Pose Estimation:** Integrates Google ML Kit's high-performance pose detection model directly into the camera feed.
* **Intelligent Exercise Tracking:** Automatically tracks repetitions for various exercises (squats, push-ups, jumping jacks, etc.) by calculating skeletal joint angles.
* **High-Performance Rendering:** Custom UI rendering pipeline using Flutter's `CustomPainter` to draw real-time skeletal wireframes with zero lag.
* **Premium Dark Mode UI:** A beautifully crafted, modern interface with glassmorphism effects, smooth animations, and a focus on user experience.
* **100% Privacy Focused:** All computer vision and AI processing happens **on-device**. No video feeds are ever recorded or sent to the cloud.

## 🛠️ Technology Stack

* **Frontend:** Flutter & Dart
* **Computer Vision:** Google ML Kit (Pose Detection Stream Mode)
* **Local Storage:** SharedPreferences (Demo Version)
* **Backend Integration (Main Branch):** Planned API layer using Node.js, Express, and MongoDB

## 📱 Screenshots & UI

*(Add screenshots of your application here to showcase the on-device AI tracking and modern UI)*

## 🚀 Getting Started (Full System)

### Prerequisites
* Flutter SDK (Latest Stable)
* Android Studio (for Android deployment)
* Xcode (for iOS deployment)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/LakshitCh/Kinetix-Mobile-App.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up your local configuration:
   * Create a `lib/core/constants/local_config.dart` file.
   * Add your backend IP address (e.g., `class LocalConfig { static const String devIP = '192.168.1.x'; }`).
4. Run the app:
   ```bash
   flutter run
   ```

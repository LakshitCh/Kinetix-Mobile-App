# Kinetix 🏃‍♂️🏋️‍♀️

**Kinetix** is a next-generation, AI-powered native mobile fitness application. Built from the ground up in Flutter, it acts as your personal virtual trainer, leveraging on-device machine learning to track your form, count your reps, and guide your workouts in real-time.

## ✨ Features

* **Real-Time Pose Estimation:** Integrates Google ML Kit's high-performance pose detection model directly into the camera feed.
* **Intelligent Exercise Tracking:** Automatically tracks repetitions for various exercises (squats, push-ups, jumping jacks, etc.) by calculating skeletal joint angles.
* **High-Performance Rendering:** Custom UI rendering pipeline using Flutter's `CustomPainter` to draw real-time skeletal wireframes with zero lag.
* **Secure Authentication:** JWT-based user authentication communicating with a secure Node.js/MongoDB backend.
* **Premium Dark Mode UI:** A beautifully crafted, modern interface with glassmorphism effects, smooth animations, and a focus on user experience.
* **100% Privacy Focused:** All computer vision and AI processing happens **on-device**. No video feeds are ever recorded or sent to the cloud.

## 🛠️ Technology Stack

* **Frontend:** Flutter & Dart
* **Computer Vision:** Google ML Kit (Pose Detection Stream Mode)
* **Local Storage:** Flutter Secure Storage
* **Networking:** Dio (HTTP Client)
* **Backend:** Node.js, Express, MongoDB (Available in the server repository)

## 📱 Screenshots & UI

*(Add screenshots of your application here)*

## 🚀 Getting Started

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

## 🔒 Security

This application has been thoroughly audited. It implements strict input validation, rate limiting on its associated backend, and does not expose sensitive local networking details or API keys to version control.

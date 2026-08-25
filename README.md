# VeriMask v1 (Flutter Face Detection & Privacy)

A clean, lightweight Flutter template for building **face detection and privacy-focused camera applications** on mobile (Android & iOS).

> 💡 **About this Project**: A starter template providing a ready-to-run foundation for developers to integrate real-time face tracking, camera overlays, and on-device image anonymization.

---

## 🚀 Features Included

* 📸 **Camera & Real-Time Preview**: Built on Flutter's official `camera` plugin with front-camera initialization.
* 🤖 **Face Detection (ML Kit)**: Real-time facial landmark detection and bounding box computation via `google_mlkit_face_detection`.
* 🛡️ **Pure-Dart Anonymization**: Fast, pure-Dart Gaussian box-blur and radial gradient background replacement (no complex native setup required).
* 🧱 **Clean Architecture**: Decoupled modules for Capture, Visual Processing, Certification, and Dependency Injection (`get_it`).
* 📱 **Cross-Platform**: Compiles out-of-the-box for Android and iOS.

---

## 🛠️ Roadmap & Ongoing R&D

Currently exploring and prototyping additional security and detection capabilities:

* 🛡️ **Enhanced Detection**: Research & development on almost bank-grade verification
* 🔐 **Community Safeguards**: Cryptographic verification mechanisms to prevent misuse.
* 🚀 **Performance Optimizations**: Further on-device pipeline optimizations.

*Note: These advanced detection and security enhancements are active experiments and work-in-progress.*

---

## 🚀 Quick Start

### 1. Prerequisites
- Flutter SDK `>=3.1.0`
- Android Studio / Xcode

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

---

## 📁 Architecture Overview

```
lib/
├── main.dart                      # App entry point & dark theme setup
├── di/
│   └── service_locator.dart       # Dependency injection registration (GetIt)
├── models/                        # Pure data models & DTOs
├── modules/                       # Core business logic
│   ├── capture_pipeline.dart      # Camera capture orchestrator
│   ├── visual_anonymization.dart  # Pure-Dart face blur & background composition
│   └── image_processor.dart       # Pixel buffer manipulation algorithms
├── screens/                       # App UI screens
│   ├── camera_screen.dart         # Real-time preview & face bounding box
│   └── result_screen.dart         # Anonymized photo preview & sharing
└── services/                      # Infrastructure & ML Kit adapters
```

---

## 📄 License

This template is licensed under the MIT License.

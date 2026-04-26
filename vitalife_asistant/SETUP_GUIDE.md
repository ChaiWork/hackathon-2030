# Vitalife Assistant - Setup & Run Guide

A Flutter health monitoring application with Firebase integration, health tracking, and AI-powered insights.

---

## 📋 Prerequisites

Before starting, ensure you have the following installed on your system:

### **Windows/macOS/Linux:**

- **Git** (for cloning the repository)
  - Download: https://git-scm.com/downloads
- **Flutter SDK** (version ^3.11.4)
  - Download: https://flutter.dev/docs/get-started/install
  - After installation, verify with: `flutter --version`

- **Android Studio** (for Android development)
  - Download: https://developer.android.com/studio
  - Install Android SDK, Android SDK Platform, and Android Emulator
- **Xcode** (macOS only, for iOS development)
  - Install via App Store
  - Command line tools: `xcode-select --install`

- **Android Device or Emulator** (for testing on Android)
  - Create an emulator in Android Studio or connect a physical device via USB

---

## 🚀 Step-by-Step Installation

### **Step 1: Clone the Repository**

```bash
git clone https://github.com/ChaiWork/hackathon-2030.git
cd hackathon-2030/vitalife_asistant
```

Or if you already have the project, navigate to it:

```bash
cd d:\codingProject\hackathon-2030\vitalife_asistant
```

---

### **Step 2: Check Flutter Installation**

Verify Flutter is properly installed and all dependencies are met:

```bash
flutter doctor
```

**Expected output:** All items should show a checkmark ✓

- If you see warnings, follow the suggested fixes

---

### **Step 3: Get Project Dependencies**

Download and install all required Flutter packages:

```bash
flutter pub get
```

Or alternatively:

```bash
flutter pub upgrade
```

**What this does:** Installs all packages listed in `pubspec.yaml` (Firebase, Google Sign-In, Health APIs, etc.)

---

### **Step 4: Configure Firebase (Important)**

This app requires Firebase configuration. You have two options:

#### **Option A: Using Existing Firebase Config**

If `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) already exist:

- Android: Located in `android/app/`
- iOS: Should be added to `ios/Runner/`

#### **Option B: Set Up Your Own Firebase Project**

1. Go to https://console.firebase.google.com/
2. Create a new project
3. Add Android app and download `google-services.json` → place in `android/app/`
4. Add iOS app and download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Enable these Firebase services:
   - Authentication (Google Sign-In)
   - Cloud Firestore
   - Cloud Functions
   - Messaging

---

### **Step 5: Environment Variables (.env)**

Create or update the `.env` file in the project root:

```
# .env
FIREBASE_API_KEY=your_api_key_here
```

(Check with your team for the correct API keys if needed)

---

### **Step 6: Generate Code (Build Runner)**

This project uses code generation. Run:

```bash
flutter pub run build_runner build
```

This generates necessary files for Flutter and Firebase.

---

## ▶️ Running the App

### **Option 1: Run on Android Emulator/Device**

1. **Start Android Emulator** (if using emulator):

   ```bash
   flutter emulators --launch <emulator_name>
   ```

   Or list available emulators:

   ```bash
   flutter emulators
   ```

2. **Run the app**:

   ```bash
   flutter run
   ```

3. **For debug build**:
   ```bash
   flutter run -d android
   ```

---

### **Option 2: Run on iOS Simulator/Device (macOS only)**

1. **Start iOS Simulator**:

   ```bash
   open -a Simulator
   ```

2. **Run the app**:
   ```bash
   flutter run -d ios
   ```

---

### **Option 3: Run on Web Browser**

```bash
flutter run -d chrome
```

or

```bash
flutter run -d web
```

---

### **Option 4: Run on Windows**

```bash
flutter run -d windows
```

---

## 🔨 Build Commands

### **Build Android APK**

```bash
flutter build apk
```

For split APKs by ABI (smaller files):

```bash
flutter build apk --split-per-abi
```

### **Build Android App Bundle (for Play Store)**

```bash
flutter build appbundle
```

### **Build iOS App**

```bash
flutter build ios
```

### **Build Web**

```bash
flutter build web
```

---

## 🐛 Troubleshooting

### **Issue: "flutter: command not found"**

- Add Flutter to your PATH environment variable
- Verify: `flutter --version`

### **Issue: Android SDK not found**

- Open Android Studio → Tools → SDK Manager
- Install required Android API levels (minimum API 21 recommended)

### **Issue: CocoaPods error (iOS)**

```bash
cd ios
pod install --repo-update
cd ..
flutter run
```

### **Issue: Build failed, clean project**

```bash
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run
```

### **Issue: Firebase not working**

- Verify `google-services.json` exists in `android/app/`
- Verify `GoogleService-Info.plist` exists in `ios/Runner/`
- Check Firebase console for proper app registration

---

## 📱 App Features

- **Health Tracking**: Monitor steps, heart rate, workout data
- **Google Sign-In**: Secure authentication
- **Firebase Integration**: Cloud sync and storage
- **Push Notifications**: Real-time health alerts
- **Background Sync**: Automatic data synchronization
- **AI Insights**: Powered by Cloud Functions

---

## 📚 Useful Links

- Flutter Documentation: https://flutter.dev/docs
- Firebase Setup: https://firebase.flutter.dev/docs/overview
- Dart Package Repository: https://pub.dev

---

## ✅ Quick Checklist

- [ ] Flutter SDK installed (`flutter --version` works)
- [ ] Android Studio/Xcode installed
- [ ] Repository cloned
- [ ] `flutter pub get` completed
- [ ] Firebase configured (google-services.json, etc.)
- [ ] `.env` file set up
- [ ] `flutter pub run build_runner build` completed
- [ ] Device/Emulator ready
- [ ] `flutter run` successful

---

## 🆘 Need Help?

If you encounter issues:

1. Run `flutter doctor` to diagnose problems
2. Check the [Flutter documentation](https://flutter.dev/docs)
3. Review Firebase setup at https://firebase.flutter.dev
4. Check project's GitHub issues

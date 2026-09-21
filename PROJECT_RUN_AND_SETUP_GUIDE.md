# Crater Code - Complete Setup & Run Commands Guide

This document contains all the commands to install dependencies, run the PHP backend, run the Flutter frontend (Web, Android, iOS), and deploy to production.

---

## 1. System Requirements & Prerequisites

- **Flutter SDK**: 3.24.x or newer ([flutter.dev](https://flutter.dev))
- **Dart SDK**: Bundled with Flutter
- **PHP**: 7.4, 8.0, 8.1, 8.2, or 8.3 with extensions `fileinfo`, `json`, `mbstring` enabled
- **Google Chrome** (for Web debugging)
- **Android Studio & Android SDK** (for Android)
- **Xcode & CocoaPods** (for iOS, macOS only)

---

## 2. Dependency Installation Commands

### 2.1 Flutter Frontend Packages
From the project root directory:
```bash
# Get all Flutter and Dart package dependencies
flutter pub get

# (Optional) Upgrade or check outdated packages
flutter pub outdated
```

### 2.2 iOS CocoaPods (macOS only)
```bash
cd ios
pod install
cd ..
```

### 2.3 PHP Backend Permissions & Verification
The PHP backend requires **NO Node.js** and **NO Python**. It operates natively with standard PHP.

Ensure the `backend/uploads/` directory has write permissions:
```bash
# Set write permissions for upload subfolders
chmod -R 775 backend/uploads/
```

Verify PHP installation:
```bash
php -v
```

---

## 3. Running the PHP Backend

### 3.1 Local Development Server
Start the built-in PHP development server pointing to the `backend/` directory:

```bash
# Run PHP server on port 8080
php -S 0.0.0.0:8080 -t backend
```

> The server will be accessible at: `http://localhost:8080` (or `http://YOUR_LOCAL_IP:8080` for physical mobile devices on the same Wi-Fi).

### 3.2 Testing the Backend Health
Open another terminal and verify the endpoint:
```bash
curl http://localhost:8080/index.php
```
*Expected output:*
```json
{"status":"ok","message":"Crater Code Media & Storage Backend API is operational","timestamp":...}
```

### 3.3 Deploying to cPanel / Apache / Nginx Shared Hosting
1. Upload the entire contents of the `backend/` folder into your web hosting directory (e.g. `public_html/api` or a subdomain `api.yourdomain.com`).
2. Ensure directory permissions:
   - Folders: `755`
   - Files: `644`
   - `uploads/` folder and subfolders: `775` or `777`
3. If using a custom production domain, update the base URL in Flutter at:
   `lib/src/services/php_storage_service.dart`:
   ```dart
   static String customBaseUrl = 'https://api.yourdomain.com';
   ```

---

## 4. Running the Flutter Application

### 4.1 Running on Web (Chrome)
```bash
# Launch on Chrome on port 3000
flutter run -d chrome --web-port 3000

# Or launch on any available port
flutter run -d chrome
```

### 4.2 Running on Android Emulator / Physical Device
```bash
# List connected devices
flutter devices

# Run on Android
flutter run -d android
```

### 4.3 Running on iOS Simulator / iPhone (macOS only)
```bash
# Run on iOS simulator
flutter run -d ios
```

---

## 5. Building for Production

### 5.1 Build Web
```bash
flutter build web --release
```
*Output folder:* `build/web/` (Ready to host on Firebase Hosting, Apache, Nginx, or cPanel).

### 5.2 Build Android
```bash
# Build APK (for direct installation)
flutter build apk --release

# Build App Bundle (for Google Play Store)
flutter build appbundle --release
```
*Output folder:* `build/app/outputs/flutter-apk/` or `build/app/outputs/bundle/release/`

### 5.3 Build iOS
```bash
flutter build ipa --release
```

---

## 6. Pre-Configured Test Accounts & Fast Navigation

Three verified test accounts are pre-configured in Firebase Authentication & Firestore:

| Role | Email | Password | Direct Web Route | Capabilities |
| :--- | :--- | :--- | :--- | :--- |
| **Super Admin** | `admin@sprintindex.com` | `Password123!` | `/#/admin` | Approve/reject venues, ban users, resolve complaints, full audit logs |
| **Facility Owner**| `owner@sprintindex.com` | `Password123!` | `/#/owner` | Manage nets, set hourly rates, view bookings, confirm cash receipts |
| **Customer / Player** | `player@sprintindex.com` | `Password123!` | `/#/` | Book nets (Cash on Arrival), view on Map, manage bookings, chat |

### 🧭 Role Quick Navigator
On the **Login Screen**, you can tap the **"🧭 Role Quick Navigator"** chip at the top or the bottom **"Explore All 3 Roles"** button to instantly autofill credentials or switch into any role without typing.

---

## 7. Supported Sports in Booking & Map Filter

The venue discovery map, filter dropdown, and club creation support:
1. ⚽ **Football**
2. 🏏 **Cricket**
3. 🎾 **Tennis**
4. 🏑 **Hockey**
5. 🎾 **Padel**
6. 🏀 **Basketball**
7. 🏉 **Rugby**
8. 🏃 **Athletics/Track & Field**

---

## 8. Summary of Main Commands Cheat Sheet

| Action | Command |
| :--- | :--- |
| **Install Flutter Dependencies** | `flutter pub get` |
| **Run Flutter Web** | `flutter run -d chrome --web-port 3000` |
| **Run Flutter Mobile** | `flutter run -d android` or `flutter run -d ios` |
| **Run Local PHP Backend** | `php -S 0.0.0.0:8080 -t backend` |
| **Test PHP Backend** | `curl http://localhost:8080/index.php` |
| **Analyze Code** | `flutter analyze --no-fatal-infos` |
| **Build Web Release** | `flutter build web --release` |
| **Build Android Release** | `flutter build apk --release` |

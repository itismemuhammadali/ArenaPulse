# Running Sports Chat App on Android Devices

## Prerequisites

1. **Android SDK** - Already configured at: `C:\Users\iamsh\AppData\Local\Android\Sdk`
2. **Flutter** - Already configured at: `C:\flutter`
3. **Java 17+** - Required for building
4. **Android Device** - Physical phone or emulator with Android 5.0+ (API 21+)

## Option 1: Run on Physical Android Device

### Step 1: Enable Developer Mode on Your Phone
- Go to **Settings > About Phone**
- Tap **Build Number** 7 times until "Developer mode enabled" appears
- Go back to **Settings > Developer Options**
- Enable **USB Debugging**
- Enable **Install via USB** (if available)

### Step 2: Connect Phone via USB
- Connect your Android phone to your computer with a USB cable
- Accept the "Allow USB debugging?" prompt on your phone
- Verify connection:
  ```
  flutter devices
  ```
  Your phone should appear in the list

### Step 3: Run the App
```bash
flutter run
```

Or specify the device:
```bash
flutter run -d <device-id>
```

### Step 4: Build Release APK (Optional)
```bash
flutter build apk --release
```
The APK will be at: `build/app/outputs/apk/release/app-release.apk`

## Option 2: Run on Android Emulator

### Step 1: Create/Start an Emulator
```bash
flutter emulators
```

List available emulators and start one:
```bash
flutter emulators --launch <emulator-name>
```

Or use Android Studio to create a new virtual device.

### Step 2: Run the App
```bash
flutter run
```

## Troubleshooting

### Device Not Detected
```bash
# Restart ADB
adb kill-server
adb start-server

# Check connected devices
adb devices
```

### Build Fails
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### Permission Issues
- Ensure `android/local.properties` has correct SDK path
- Current config: `sdk.dir=C:\Users\iamsh\AppData\Local\Android\Sdk`

### Gradle Issues
```bash
# Update Gradle wrapper
cd android
./gradlew --version
```

## Current Project Configuration

- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: Latest (configured by Flutter)
- **Signing**: Release builds use keystore at `my-release-key.jks`
- **Permissions**: Camera, Location, Storage, Notifications, Internet

## Quick Commands

| Command | Purpose |
|---------|---------|
| `flutter devices` | List connected devices |
| `flutter run` | Run on connected device |
| `flutter run -d <id>` | Run on specific device |
| `flutter run --release` | Run in release mode |
| `flutter build apk` | Build debug APK |
| `flutter build apk --release` | Build release APK |
| `flutter clean` | Clean build artifacts |

## Notes

- First run may take 5-10 minutes as it compiles the app
- Subsequent runs are faster (hot reload available)
- Ensure phone has internet for Firebase services
- Location services must be enabled for map features

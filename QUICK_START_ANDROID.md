# Quick Start: Running on Android

## Your Setup is Ready ✓

Your project is configured correctly for Android development:

- ✓ Android SDK: `C:\Users\iamsh\AppData\Local\Android\Sdk`
- ✓ Flutter: `C:\flutter`
- ✓ Min SDK: 21 (Android 5.0+)
- ✓ All dependencies resolved
- ✓ Permissions configured
- ✓ Firebase configured

## To Run on Android Device

### 1. Connect Your Phone
- Enable USB Debugging in Developer Options
- Connect via USB cable
- Accept the debugging prompt

### 2. Run the App
```bash
flutter run
```

That's it! The app will build and install automatically.

## To Run on Emulator

```bash
flutter emulators --launch <emulator-name>
flutter run
```

## Common Issues & Fixes

**Device not showing up?**
```bash
adb kill-server
adb start-server
flutter devices
```

**Build fails?**
```bash
flutter clean
flutter pub get
flutter run
```

**Want to build APK for distribution?**
```bash
flutter build apk --release
```
APK location: `build/app/outputs/apk/release/app-release.apk`

## What's Configured

- Camera, Location, Storage, Notifications permissions
- Google Maps API key
- Firebase integration
- Google Sign-In
- Local notifications
- Video player support

See `ANDROID_RUN_SETUP.md` for detailed setup guide.

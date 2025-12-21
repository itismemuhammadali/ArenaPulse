# Google AdMob Integration Guide

## Overview
This guide explains how to integrate Google AdMob ads into your Flutter app. Ads are configured to display every 13 posts in the feed.

## Integration Status
✅ **Easy to integrate** - Google Mobile Ads package handles most of the complexity
✅ **Already added to pubspec.yaml** - `google_mobile_ads: ^6.0.0`
✅ **Ad widget created** - Reusable `BannerAdWidget` component
✅ **Posted tab updated** - Ads display every 13 posts automatically

## Setup Steps

### 1. Create AdMob Account
- Go to [Google AdMob](https://admob.google.com)
- Sign in with your Google account
- Create a new app in AdMob

### 2. Get Your Ad Unit IDs
- In AdMob, create ad units for:
  - **Banner Ads** (for feed)
  - **Interstitial Ads** (optional, for full-screen ads)
- Copy your Ad Unit IDs (format: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy`)

### 3. Update Ad Unit IDs in Code
Edit `lib/src/services/admob_service.dart`:

```dart
// Replace these with your actual AdMob Ad Unit IDs
static const String bannerAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-YOUR-ANDROID-ID/YOUR-ANDROID-BANNER-ID'
    : 'ca-app-pub-YOUR-IOS-ID/YOUR-IOS-BANNER-ID';

static const String interstitialAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-YOUR-ANDROID-ID/YOUR-ANDROID-INTERSTITIAL-ID'
    : 'ca-app-pub-YOUR-IOS-ID/YOUR-IOS-INTERSTITIAL-ID';
```

### 4. Initialize AdMob in Your App
In your main.dart or app initialization:

```dart
import 'package:sports_chat_app/src/services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  await AdMobService().initializeMobileAds();
  
  runApp(const MyApp());
}
```

### 5. Android Configuration
Add to `android/app/AndroidManifest.xml` inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxxxxxxxxxx"/>
```

### 6. iOS Configuration
Add to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxxxxxxxxxx</string>
```

## Testing
The code currently uses **test Ad Unit IDs** for development:
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`

These are safe to use during development and won't affect your AdMob account.

## How It Works

### Ad Placement
- Ads appear every 13 posts in the feed
- Uses `BannerAdWidget` component
- Automatically loads and displays banner ads

### Files Modified/Created
1. **pubspec.yaml** - Added `google_mobile_ads` package
2. **lib/src/services/admob_service.dart** - AdMob service (NEW)
3. **lib/src/widgets/banner_ad_widget.dart** - Reusable ad widget (NEW)
4. **lib/src/tabs/posted_tab.dart** - Updated to show ads every 13 posts

### Key Components

#### AdMobService
Handles all ad loading and management:
- `initializeMobileAds()` - Initialize the SDK
- `loadBannerAd()` - Load banner ads
- `loadInterstitialAd()` - Load full-screen ads
- `showInterstitialAd()` - Display full-screen ads

#### BannerAdWidget
Reusable widget that displays banner ads:
```dart
const BannerAdWidget()
```

## Revenue Optimization Tips

1. **Ad Placement**: Every 13 posts is a good balance between user experience and revenue
2. **Ad Types**: 
   - Banner ads (current) - Non-intrusive, always visible
   - Interstitial ads - Full-screen, higher revenue but more intrusive
   - Rewarded ads - Users get rewards for watching

3. **Testing**: Always test with test Ad Unit IDs first
4. **Monitoring**: Check AdMob dashboard for performance metrics

## Troubleshooting

### Ads Not Showing
1. Verify Ad Unit IDs are correct
2. Check that AdMob account is approved
3. Ensure app is properly configured in AdMob
4. Check device logs for errors

### Low Ad Revenue
1. Ensure ads are visible to users
2. Check ad placement frequency
3. Verify targeting settings in AdMob
4. Monitor fill rates in AdMob dashboard

### Build Errors
1. Run `flutter pub get` to install dependencies
2. Clean build: `flutter clean && flutter pub get`
3. Rebuild: `flutter run`

## Next Steps

1. Create AdMob account and get Ad Unit IDs
2. Update `admob_service.dart` with your IDs
3. Initialize AdMob in main.dart
4. Configure Android and iOS settings
5. Test with test Ad Unit IDs
6. Switch to production Ad Unit IDs when ready

## Resources
- [Google Mobile Ads Flutter Plugin](https://pub.dev/packages/google_mobile_ads)
- [AdMob Documentation](https://support.google.com/admob)
- [Flutter AdMob Integration Guide](https://developers.google.com/admob/flutter/quick-start)

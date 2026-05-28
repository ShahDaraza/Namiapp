# Installation & Troubleshooting Guide

Complete step-by-step guide to get ServiceHub running on your machine.

## System Requirements

### Minimum Requirements
- **Flutter**: 2.19.0 or higher
- **Dart**: 2.19.0 or higher
- **Android Studio**: 4.2+ (for Android development)
- **Xcode**: 13+ (for iOS development on Mac)
- **RAM**: 8GB minimum
- **Disk Space**: 5GB for Flutter + Android SDK

### Supported Platforms
- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11.0+
- ⚠️ Web (limited features)

## Step 1: Install Flutter

### Windows Installation
```powershell
# Download Flutter from https://flutter.dev/docs/get-started/install/windows

# Extract to a location (e.g., C:\flutter)
# Add to PATH:
setx PATH "%PATH%;C:\flutter\bin"

# Verify installation
flutter --version
flutter doctor
```

### Mac Installation
```bash
# Using Homebrew
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install/macos

# Add to PATH
export PATH="$PATH:~/development/flutter/bin"

# Verify
flutter --version
flutter doctor
```

### Linux Installation
```bash
# Download from https://flutter.dev/docs/get-started/install/linux
cd ~/development
tar xf flutter_linux_*.tar.xz

# Add to PATH
export PATH="$PATH:~/development/flutter/bin"

# Verify
flutter --version
flutter doctor
```

## Step 2: Verify Installation

```bash
flutter doctor
```

### Expected Output
```
Doctor summary (to get all the details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Windows 11 ...)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio (version 2022.x.x)
```

### Fix Issues
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install missing tools
flutter doctor -v

# Update Flutter
flutter upgrade
```

## Step 3: Project Setup

```bash
# Navigate to project
cd d:\Albiun App\serviceapp

# Get dependencies
flutter pub get

# (Optional) Analyze code
flutter analyze

# (Optional) Check code formatting
flutter format --set-exit-if-changed lib/
```

### Verify Setup
```bash
flutter run --dry-run
```

## Step 4: Firebase Setup (REQUIRED)

### 4.1 Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click **"Create a project"**
3. Name: `ServiceHub`
4. Accept terms and create
5. Wait for initialization (~1-2 minutes)

### 4.2 Enable Services

#### Firestore Database
```
Build > Firestore Database > Create Database
├─ Location: Select your region
├─ Security rules: Start in test mode
└─ Click Create
```

#### Firebase Auth
```
Build > Authentication > Get started
├─ Click Email/Password
├─ Toggle Enable
└─ Save
```

#### Cloud Storage
```
Build > Cloud Storage > Get started
├─ Select region (same as Firestore)
├─ Choose test mode
└─ Create
```

### 4.3 Configure Android

#### Get SHA-1 Certificate
```bash
# For debug builds (default)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Look for "SHA1" line
# Copy the SHA1 value
```

#### Add Android App to Firebase
1. Go to Project Settings ⚙️
2. Click **"Add app"** > **Android**
3. Package name: `com.albiun.serviceapp`
4. SHA-1: Paste from above
5. Click **"Register app"**
6. Download `google-services.json`

#### Place Configuration
```bash
# Move file to Android app folder
# Windows PowerShell
Move-Item "google-services.json" "android/app/"

# Or on Mac/Linux
mv google-services.json android/app/
```

### 4.4 Configure iOS

#### Add iOS App to Firebase
1. Go to Project Settings ⚙️
2. Click **"Add app"** > **iOS**
3. Bundle ID: `com.albiun.serviceapp`
4. Click **"Register app"**
5. Download `GoogleService-Info.plist`

#### Place Configuration
1. Open iOS project in Xcode: `open ios/Runner.xcworkspace`
2. Right-click **Runner** folder
3. **Add Files to "Runner"**
4. Select downloaded `GoogleService-Info.plist`
5. Check **"Copy items if needed"**
6. Click **Add**

#### Update Pod Dependencies
```bash
cd ios
pod install --repo-update
cd ..
```

## Step 5: Run the App

### Android (Virtual Device)

#### Create Emulator (If not already created)
```bash
# Using Android Studio
# Tools > Device Manager > Create Virtual Device
# Select Phone > Select API level (minimum 21)
# Click Create

# Or using command line
flutter emulators --launch Pixel_6_API_31
```

#### Run App
```bash
flutter run -d android

# Or specify emulator
flutter run -d emulator-5554
```

### Android (Physical Device)

#### Enable USB Debugging
1. Go to Settings > About Phone
2. Tap Build Number 7 times (becomes developer)
3. Go to Settings > Developer Options
4. Enable USB Debugging
5. Connect to computer
6. Authorize computer

#### Run App
```bash
# List connected devices
flutter devices

# Run on device
flutter run
```

### iOS (Simulator)

#### Open Simulator
```bash
open -a Simulator

# Or
xcrun simctl list devices
```

#### Run App
```bash
flutter run -d iphone

# Or specify device
flutter run -d "iPhone 14"
```

### iOS (Physical Device)

#### Build and Deploy
```bash
flutter run -d ios
```

#### First Time Setup
1. Create Apple Developer account
2. Set up signing certificate
3. Trust developer certificate on device (Settings > General)

## Common Issues & Solutions

### Issue 1: "Flutter SDK not found"
**Solution**:
```bash
# Add to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify
flutter --version
```

### Issue 2: "Android SDK not found"
**Solution**:
```bash
# Set ANDROID_SDK_ROOT
export ANDROID_SDK_ROOT=~/Library/Android/sdk  # Mac/Linux
setx ANDROID_SDK_ROOT %USERPROFILE%\AppData\Local\Android\sdk  # Windows

flutter doctor --android-licenses
```

### Issue 3: Firebase not initializing
**Solution**:
```bash
# Check file locations
ls android/app/google-services.json  # Should exist

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue 4: Pod install fails (iOS)
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install --repo-update
cd ..
flutter run
```

### Issue 5: "CocoaPods not installed"
**Solution**:
```bash
# Install CocoaPods (Mac only)
sudo gem install cocoapods

# Update
pod repo update
```

### Issue 6: App crashes on startup
**Solution**:
```bash
# Check Firebase configuration
flutter clean
flutter pub get

# Run with verbose logging
flutter run -v

# Check console output for errors
```

### Issue 7: "No devices found"
**Solution**:
```bash
# List available devices
flutter devices

# Create/start emulator
flutter emulators
flutter emulators --launch Pixel_6_API_31
```

### Issue 8: Build takes too long
**Solution**:
```bash
# Use --release for faster builds
flutter run --release

# Or run directly on device (faster)
flutter run -d real_device

# Skip build cache
flutter clean
```

### Issue 9: Permission denied errors
**Solution**:
```bash
# Run with proper permissions
sudo flutter pub get

# Or fix directory permissions
chmod -R 755 ~/.flutter
```

### Issue 10: "Gradle sync failed"
**Solution**:
```bash
# Clean Gradle
cd android
./gradlew clean
./gradlew --refresh-dependencies
cd ..

flutter clean
flutter pub get
```

## Development Workflow

### Hot Reload (Quick Update)
```bash
# While app is running
# Press 'r' in terminal
# Or Ctrl+\ (Windows/Linux) or Cmd+\ (Mac)

# Changes apply instantly
```

### Hot Restart (Full Restart)
```bash
# While app is running
# Press 'R' in terminal

# Restarts app with code changes
```

### Debug Mode
```bash
# Run with debugger
flutter run

# Or attach debugger to running app
flutter attach
```

### Release Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS Archive
flutter build ios --release
```

## Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

### Check Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Get code metrics
dartanalyzer lib/
```

## Performance Tips

1. **Use Release Mode**: `flutter run --release`
2. **Profile App**: `flutter run --profile`
3. **Check FPS**: Enable performance overlay (dev settings)
4. **Use DevTools**: `flutter pub global activate devtools`
5. **Monitor Hot Reload**: Watch console for slow reloads

## Debugging Tips

### Enable Debug Logging
```dart
// In main.dart
debugPrint('Message: $variable');

// Or verbose Flutter logging
// flutter run -v
```

### Use DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
flutter run --observatory-port=8181
```

### Check Device Logs
```bash
# Android
flutter logs

# iOS
flutter logs
```

## Network Issues

### No Internet Connection
- Check device network settings
- Ensure WiFi/Cellular is enabled
- Check firewall rules
- Verify Firebase connectivity

### Firebase Connection Fails
1. Check internet connection
2. Verify google-services.json
3. Check Firebase console for errors
4. Review Firestore security rules

## Version Information

### Check Versions
```bash
flutter --version
dart --version
flutter doctor -v
```

### Update Flutter
```bash
flutter upgrade
flutter channel stable  # or beta/dev
```

## Documentation Links

- [Flutter Installation](https://flutter.dev/docs/get-started/install)
- [Android Setup](https://flutter.dev/docs/get-started/install/windows#android-setup)
- [iOS Setup](https://flutter.dev/docs/get-started/install/macos#ios-setup)
- [Firebase Setup](https://firebase.flutter.dev/docs/overview)

## Still Having Issues?

1. **Check logs**: `flutter run -v`
2. **Run doctor**: `flutter doctor -v`
3. **Clean everything**: `flutter clean && flutter pub get`
4. **Rebuild completely**: `flutter run --verbose`
5. **Check documentation**: Links above

---

**You're all set!** 🚀 Your ServiceHub app is ready to run.

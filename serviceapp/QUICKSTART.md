# Quick Start Guide

Get the ServiceHub app running in 5 minutes!

## 1. Prerequisites Check

```bash
# Verify Flutter installation
flutter doctor

# Output should show:
# ✓ Flutter SDK
# ✓ Android toolchain
# ✓ Xcode (for iOS)
```

If Flutter is not installed, follow: [Flutter Installation](https://flutter.dev/docs/get-started/install)

## 2. Project Setup

```bash
# Navigate to project
cd d:\Albiun App\serviceapp

# Get dependencies
flutter pub get

# Check for issues
flutter analyze
```

## 3. Firebase Setup (Required)

### Quick Setup (5 min):
1. Go to https://console.firebase.google.com/
2. Create new project: **ServiceHub**
3. Enable **Firestore Database** (Test Mode)
4. Enable **Authentication** (Email/Password)
5. Create **Cloud Storage** bucket
6. Download `google-services.json` (Android)
7. Place in `android/app/google-services.json`
8. Download `GoogleService-Info.plist` (iOS)
9. Place in `ios/Runner/GoogleService-Info.plist`

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

## 4. Run the App

### Android
```bash
flutter run -d android
```

### iOS
```bash
cd ios
pod install --repo-update
cd ..
flutter run -d ios
```

### Web (if supported)
```bash
flutter run -d chrome
```

## 5. Test the App

### Role Selection Screen
- Choose "I need a Service" (User)
- Choose "I offer Services" (Provider)
- Choose "Admin Login"

### Create Test Account
```
Email: test@example.com
Password: Test@123
```

### Browse Services
1. Select a service category
2. View available providers
3. Click "Book Service"
4. Fill booking details
5. Confirm booking

### Admin Panel
```
Email: admin@example.com
Password: admin123
```

## Project Structure Overview

```
serviceapp/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/                      # Data structures
│   ├── screens/
│   │   ├── auth/                    # Login/Signup
│   │   ├── user/                    # User pages
│   │   ├── provider/                # Provider pages
│   │   └── admin/                   # Admin pages
│   ├── services/                    # Firebase operations
│   ├── widgets/                     # Reusable components
│   └── utils/                       # Helper functions
├── pubspec.yaml                     # Dependencies
├── android/                         # Android config
├── ios/                             # iOS config
├── README.md                        # Full documentation
├── FIREBASE_SETUP.md                # Firebase guide
└── SEED_DATA.md                     # Sample data
```

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization |
| `lib/screens/auth/` | Authentication screens |
| `lib/services/` | Firebase operations |
| `lib/models/` | Data models |
| `pubspec.yaml` | Dependencies |
| `README.md` | Full documentation |
| `FIREBASE_SETUP.md` | Firebase instructions |

## Common Commands

```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run with hot reload
flutter run

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Check code quality
flutter analyze

# Run tests
flutter test

# Format code
flutter format lib/
```

## Troubleshooting

### Issue: Firebase not initializing
**Solution**: Check `google-services.json` and `GoogleService-Info.plist` paths

### Issue: App won't run
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Android build fails
**Solution**:
```bash
cd android
./gradlew --refresh-dependencies
cd ..
flutter run
```

### Issue: iOS build fails
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter run
```

## Features Tour

### 👤 User Features
- [ ] Sign up / Login
- [ ] Browse service providers
- [ ] Search by category
- [ ] Book a service
- [ ] Track booking status
- [ ] Rate and review
- [ ] View booking history

### 🔧 Provider Features
- [ ] Register as provider
- [ ] Set services & hourly rate
- [ ] View job requests
- [ ] Accept/decline jobs
- [ ] Update job status
- [ ] View earnings
- [ ] Track reviews

### 🛡️ Admin Features
- [ ] Approve providers
- [ ] Manage users
- [ ] View bookings
- [ ] Monitor payments
- [ ] Analytics (future)

## Next Steps

1. ✅ Install Flutter
2. ✅ Clone/Create project
3. ✅ Set up Firebase
4. ✅ Run the app
5. 📚 Read full [README.md](README.md)
6. 🚀 Deploy to production

## Need Help?

- 📖 [Flutter Docs](https://flutter.dev/docs)
- 🔥 [Firebase Docs](https://firebase.google.com/docs)
- 🐛 [Debugging Guide](https://flutter.dev/docs/testing/debugging)
- 💬 Check `README.md` for FAQs

## What's Next?

- Add real payment gateway (Stripe/PayPal)
- Integrate Google Maps
- Add push notifications
- Set up CI/CD pipeline
- Deploy to Play Store / App Store

---

**You're ready to go!** 🚀 Start with the Role Selection screen.

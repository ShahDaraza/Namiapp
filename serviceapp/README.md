# ServiceHub - Local Service Provider App

A complete Flutter application for booking and managing local service providers (mechanics, plumbers, electricians, etc.). Built with Flutter and Firebase.

## Features

### Core Features
- ✅ User authentication (email/password signup and login)
- ✅ Service categories (Plumber, Electrician, Mechanic, etc.)
- ✅ Search and filter services by category, location, and rating
- ✅ Booking system with real-time status updates
- ✅ Payment integration (dummy/local implementation)
- ✅ Ratings & reviews for service providers

### Service Provider Features
- ✅ Separate provider authentication
- ✅ Profile management (skills, availability, hourly rate)
- ✅ Accept/decline job requests
- ✅ Job history and earnings dashboard
- ✅ Real-time job notifications

### Admin Features
- ✅ Provider registration approval/rejection
- ✅ Dashboard for platform management
- ✅ User and provider management

### UI/UX
- ✅ Modern, clean design
- ✅ Bottom navigation bar for easy navigation
- ✅ Responsive layouts
- ✅ Smooth animations and transitions

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider package
- **Navigation**: Go Router for modern routing
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth

## Project Structure

```
serviceapp/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   ├── service_provider.dart
│   │   ├── booking.dart
│   │   ├── review.dart
│   │   └── service.dart
│   ├── screens/                  # UI screens
│   │   ├── auth/                 # Authentication screens
│   │   ├── user/                 # User-facing screens
│   │   ├── provider/             # Provider screens
│   │   └── admin/                # Admin screens
│   ├── services/                 # Business logic
│   │   ├── firebase_service.dart
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   └── payment_service.dart
│   ├── widgets/                  # Reusable widgets
│   └── utils/                    # Utility functions
├── pubspec.yaml                  # Dependencies
├── android/                      # Android configuration
└── ios/                          # iOS configuration
```

## Prerequisites

### System Requirements
- Flutter SDK (>=2.19.0)
- Dart SDK (>=2.19.0)
- Android Studio / Xcode (for emulators)
- Google account (for Firebase setup)

### Install Flutter
1. Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Follow platform-specific installation instructions
3. Run `flutter doctor` to verify installation

## Setup Instructions

### 1. Clone the Project
```bash
cd d:\Albiun App
# (Project already created in serviceapp folder)
cd serviceapp
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "ServiceHub" (or your preference)
4. Enable Google Analytics (optional)
5. Create the project

#### Enable Firebase Services
1. **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable Email/Password
   - Enable Anonymous (optional, for testing)

2. **Firestore Database**:
   - Create a Firestore database
   - Choose "Start in test mode" for development
   - Select region (closest to you)

3. **Storage**:
   - Create a Cloud Storage bucket
   - Accept default settings

#### Configure for Android
1. In Firebase Console, add Android app
2. Package name: `com.albiun.serviceapp`
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

5. Verify `android/build.gradle` has:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

6. Verify `android/app/build.gradle` applies plugin:
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### Configure for iOS
1. In Firebase Console, add iOS app
2. Bundle ID: `com.albiun.serviceapp`
3. Download `GoogleService-Info.plist`
4. Place in Xcode: `ios/Runner/GoogleService-Info.plist`

5. Run from iOS folder:
```bash
cd ios
pod install --repo-update
cd ..
```

### 4. Run the App

#### On Android Emulator
```bash
flutter emulators --launch <emulator_id>
flutter run
```

#### On iOS Simulator
```bash
open -a Simulator
flutter run
```

#### On Physical Device
```bash
flutter run
```

## Testing the App

### Admin Credentials (Demo)
- Email: `admin@example.com`
- Password: `admin123`

### Test Flow
1. **Role Selection**: Choose between user, provider, or admin
2. **User Flow**:
   - Sign up as a customer
   - Browse services and providers
   - Book a service
   - Track booking status
   - Leave a review after completion

3. **Provider Flow**:
   - Sign up as a service provider
   - Wait for admin approval
   - View incoming job requests
   - Accept/decline jobs
   - Mark jobs as in-progress/completed
   - View earnings dashboard

4. **Admin Flow**:
   - Login with demo credentials
   - Approve/reject provider applications
   - View platform statistics

## Firestore Database Schema

### Collections

#### users/
```
{
  id: string,
  name: string,
  email: string,
  phone: string,
  profileImage: string,
  location: string,
  rating: double,
  totalReviews: int,
  createdAt: timestamp,
  isActive: boolean
}
```

#### providers/
```
{
  id: string,
  name: string,
  email: string,
  phone: string,
  profileImage: string,
  location: string,
  services: array,
  bio: string,
  hourlyRate: double,
  rating: double,
  totalReviews: int,
  totalJobs: int,
  skills: array,
  availability: array,
  isApproved: boolean,
  isActive: boolean,
  totalEarnings: double,
  createdAt: timestamp,
  documentVerificationDate: timestamp
}
```

#### bookings/
```
{
  id: string,
  userId: string,
  providerId: string,
  serviceType: string,
  description: string,
  scheduledTime: timestamp,
  estimatedCost: double,
  finalCost: double,
  status: string (pending|accepted|inProgress|completed|cancelled),
  location: string,
  latitude: double,
  longitude: double,
  createdAt: timestamp,
  completedAt: timestamp,
  cancellationReason: string
}
```

#### reviews/
```
{
  id: string,
  bookingId: string,
  userId: string,
  providerId: string,
  rating: double,
  comment: string,
  images: array,
  createdAt: timestamp
}
```

#### payments/
```
{
  id: string,
  bookingId: string,
  userId: string,
  providerId: string,
  amount: double,
  method: string,
  status: string (pending|completed|failed|refunded),
  createdAt: timestamp,
  completedAt: timestamp,
  transactionId: string,
  errorMessage: string
}
```

## Seed Data

To add sample data to Firestore:

1. **From Firebase Console**:
   - Go to Firestore Database
   - Click "+" next to collections
   - Create collections and documents manually

2. **Using CLI Script** (create `seeds.js`):
```javascript
// Sample document creation script
// Can be run using Firebase Admin SDK
```

### Sample Providers
```
Provider 1:
- Name: John's Plumbing
- Services: [Plumber]
- Rate: $50/hr
- Rating: 4.8

Provider 2:
- Name: ElectroFix
- Services: [Electrician]
- Rate: $60/hr
- Rating: 4.5

Provider 3:
- Name: Auto Mechanics Pro
- Services: [Mechanic]
- Rate: $75/hr
- Rating: 4.9
```

## Firebase Firestore Rules (Test Mode)

For production, set secure rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Providers can read/write their own documents
    match /providers/{providerId} {
      allow read: if true; // Public read
      allow write: if request.auth.uid == providerId;
    }
    
    // Bookings
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.userId 
                     || request.auth.uid == resource.data.providerId;
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId 
                       || request.auth.uid == resource.data.providerId;
    }
    
    // Reviews
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    // Payments
    match /payments/{paymentId} {
      allow read: if request.auth.uid == resource.data.userId 
                     || request.auth.uid == resource.data.providerId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    // Admins
    match /admins/{adminId} {
      allow read, write: if request.auth.uid == adminId;
    }
  }
}
```

## Troubleshooting

### Firebase Connection Issues
- Ensure `google-services.json` is in correct location
- Check Firebase project settings
- Verify network connectivity
- Check Firebase console for errors

### Flutter Build Issues
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

### Android-Specific Issues
```bash
# Update Gradle
cd android
./gradlew --refresh-dependencies
cd ..
```

### iOS-Specific Issues
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
flutter run
```

## Development Tips

1. **Hot Reload**: Press `r` in terminal while app is running
2. **Hot Restart**: Press `R` for full restart
3. **Debug**: Use `print()` statements or IDE debugger
4. **Console Logs**: Check terminal output for errors

## Next Steps / Future Enhancements

- [ ] Real payment gateway integration (Stripe, PayPal)
- [ ] Google Maps integration for location services
- [ ] Real-time notifications (FCM)
- [ ] Video call for consultation
- [ ] Advanced search filters
- [ ] Subscription plans
- [ ] Provider portfolio/gallery
- [ ] User testimonials and case studies
- [ ] Multi-language support
- [ ] Accessibility improvements

## Deployment

### Android Play Store
```bash
# Generate keystore
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build release
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS App Store
```bash
flutter build ios --release
# Then upload using Xcode or Transporter
```

## Support & Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Documentation](https://dart.dev/guides)

## License

This project is provided as-is for educational and development purposes.

## Contact & Support

For issues or questions, please refer to the documentation or check the Firebase/Flutter official channels.

---

**Happy coding!** 🚀

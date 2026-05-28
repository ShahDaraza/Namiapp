# Firebase Setup Guide

This guide helps you set up Firebase for the ServiceHub app.

## Prerequisites
- Google Account
- Flutter installed on your machine
- Android Studio or Xcode (for platform-specific setup)

## Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
- Visit: https://console.firebase.google.com/
- Click "Add project" or "Create a project"

### 1.2 Enter Project Details
- **Project Name**: ServiceHub (or your preference)
- **Project ID**: Will be auto-generated
- **Enable Google Analytics**: Optional, uncheck for faster setup

### 1.3 Wait for Project Creation
- Click "Create project"
- Wait for initialization (takes ~1 minute)

## Step 2: Set Up Authentication

### 2.1 Enable Email/Password Authentication
1. In Firebase Console, select your project
2. Go to **Authentication** > **Sign-in method**
3. Click on **Email/Password**
4. Toggle **Enable** to ON
5. Click **Save**

### 2.2 Enable Anonymous Authentication (Optional)
- Useful for testing without sign-up
- Toggle **Enable** for "Anonymous"

## Step 3: Set Up Firestore Database

### 3.1 Create Firestore Database
1. Go to **Build** > **Firestore Database**
2. Click **Create database**
3. Choose location closest to you
4. Select **Start in test mode** (for development)
5. Click **Create**

### 3.2 Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.value(2025-05-28T00:00:00Z);
    }
  }
}
```

## Step 4: Set Up Cloud Storage

### 4.1 Create Storage Bucket
1. Go to **Build** > **Cloud Storage**
2. Click **Create bucket**
3. Give it a name (e.g., `servicehub-storage`)
4. Select the same region as Firestore
5. Choose **Test mode** for development
6. Click **Create**

## Step 5: Configure for Android

### 5.1 Register Android App
1. In Firebase Console, click **Project Settings** ⚙️
2. Click **Add app** > **Android**
3. Enter:
   - **Package name**: `com.albiun.serviceapp`
   - **App nickname**: ServiceHub (optional)
   - **SHA-1 certificate**: See Step 5.3
4. Click **Register app**

### 5.2 Download Configuration File
1. Download `google-services.json`
2. Place in: `android/app/google-services.json`
3. Click **Next**

### 5.3 Get SHA-1 Certificate (If Needed)
```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore path/to/key.jks
```

### 5.4 Update Android Build Files
**File: `android/build.gradle`**
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**File: `android/app/build.gradle`**
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'  // Add this line
}
```

## Step 6: Configure for iOS

### 6.1 Register iOS App
1. In Firebase Console, click **Project Settings** ⚙️
2. Click **Add app** > **iOS**
3. Enter:
   - **Bundle ID**: `com.albiun.serviceapp`
   - **App nickname**: ServiceHub (optional)
4. Click **Register app**

### 6.2 Download Configuration File
1. Download `GoogleService-Info.plist`
2. In Xcode, add to: `ios/Runner/` folder
   - Right-click `Runner` > **Add Files to "Runner"**
   - Select `GoogleService-Info.plist`
   - Check **Copy items if needed**
3. Click **Finish**

### 6.3 Install CocoaPods Dependencies
```bash
cd ios
pod install --repo-update
cd ..
```

## Step 7: Test Firebase Connection

### Create a Test Script
Create a file `test_firebase.dart` to verify setup:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('✓ Firebase initialized');
    
    // Test Firestore write
    await FirebaseFirestore.instance.collection('test').doc('test').set({
      'timestamp': DateTime.now(),
      'message': 'Firebase is working!',
    });
    print('✓ Firestore write successful');
    
  } catch (e) {
    print('✗ Error: $e');
  }
}
```

## Step 8: Initialize Database Collections

### 8.1 Create Collections in Firestore
Use Firebase Console to create these collections:
- `users`
- `providers`
- `bookings`
- `reviews`
- `payments`
- `admins` (for admin accounts)

### 8.2 Add Sample Data

#### Users Collection Sample:
```json
{
  "id": "user1",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "555-1234",
  "location": "New York",
  "rating": 4.5,
  "totalReviews": 12,
  "createdAt": "2024-05-28T10:00:00Z",
  "isActive": true
}
```

#### Providers Collection Sample:
```json
{
  "id": "provider1",
  "name": "Expert Plumber",
  "email": "plumber@example.com",
  "phone": "555-5678",
  "location": "New York",
  "services": ["Plumber", "Home Repair"],
  "bio": "10+ years of experience",
  "hourlyRate": 50,
  "rating": 4.8,
  "totalReviews": 45,
  "totalJobs": 150,
  "skills": ["Pipe Fixing", "Bathroom Installation"],
  "availability": ["Monday", "Tuesday", "Wednesday"],
  "isApproved": true,
  "isActive": true,
  "totalEarnings": 7500,
  "createdAt": "2024-05-28T10:00:00Z",
  "documentVerificationDate": "2024-05-28T10:00:00Z"
}
```

#### Admins Collection Sample:
```json
{
  "id": "admin1",
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": "2024-05-28T10:00:00Z"
}
```

## Step 9: Run the App

```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## Troubleshooting

### Firebase Not Initializing
- Check `google-services.json` location (Android)
- Check `GoogleService-Info.plist` location (iOS)
- Verify Firebase console permissions
- Check internet connectivity

### Firestore Permissions Error
- Go to Firestore > Rules
- Ensure test mode rules are active
- For production, set proper security rules

### Cloud Build Issues
```bash
# Clean cache
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock

# Rebuild
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter run
```

## Security Best Practices

### For Production:
1. **Update Firestore Rules**:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /providers/{providerId} {
      allow read: if true;
      allow write: if request.auth.uid == providerId;
    }
  }
}
```

2. **Enable Cloud Storage Rules**:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth.uid == uid;
    }
    match /providers/{pid}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == pid;
    }
  }
}
```

3. **Enable Production Mode**:
   - Remove test rules
   - Require authentication
   - Use secure API keys
   - Enable Application Restrictions

## Next Steps

1. ✅ Install Flutter
2. ✅ Create Firebase project
3. ✅ Configure Android
4. ✅ Configure iOS
5. ✅ Add sample data
6. ✅ Run the app

Your Firebase setup is now complete! 🎉

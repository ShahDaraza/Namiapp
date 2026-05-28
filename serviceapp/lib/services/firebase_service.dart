import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }
}

// Firebase configuration
// Note: You'll need to set up your Firebase project and download google-services.json
// For Android: Place it in android/app/ folder
// For iOS: Place it in ios/Runner/ folder and run: flutterfire configure

const firebaseConfig = '''
{
  "projectId": "your-firebase-project",
  "appId": "your-app-id",
  "apiKey": "your-api-key",
  "authDomain": "your-auth-domain"
}
''';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/user_auth_screen.dart';
import 'screens/auth/provider_auth_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/user/user_main_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/user/book_service_screen.dart';
import 'screens/user/user_bookings_screen.dart';
import 'screens/user/review_booking_screen.dart';
import 'screens/user/user_profile_screen.dart';
import 'screens/provider/provider_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/admin/admin_providers_screen.dart';
import 'models/service_provider.dart';
import 'models/booking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    print('Note: Ensure you have set up google-services.json for Android');
    print('and GoogleService-Info.plist for iOS');
  }

  runApp(const ServiceApp());
}

class ServiceApp extends StatelessWidget {
  const ServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF667EEA),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const AuthWrapper(),
      routes: {
        '/auth/role-selection': (_) =>
            const RoleSelectionScreen(),
        '/auth/user-login': (_) =>
            const UserAuthScreen(isLogin: true),
        '/auth/user-signup': (_) =>
            const UserAuthScreen(isLogin: false),
        '/auth/provider-login': (_) =>
            const ProviderAuthScreen(isLogin: true),
        '/auth/provider-signup': (_) =>
            const ProviderAuthScreen(isLogin: false),
        '/auth/admin-login': (_) =>
            const AdminLoginScreen(),
        '/user/home': (_) =>
            const UserMainScreen(),
        '/user/bookings': (_) =>
            const UserBookingsScreen(),
        '/user/profile': (_) =>
            const UserProfileScreen(),
        '/provider/dashboard': (_) =>
            const ProviderMainScreen(),
        '/admin/dashboard': (_) =>
            const AdminMainScreen(),
        '/admin/providers': (_) =>
            const AdminProvidersScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/user/book-service') {
          final provider =
              settings.arguments as ServiceProvider;
          return MaterialPageRoute(
            builder: (context) =>
                BookServiceScreen(provider: provider),
          );
        }
        if (settings.name == '/user/review-booking') {
          final booking =
              settings.arguments as Booking;
          return MaterialPageRoute(
            builder: (context) =>
                ReviewBookingScreen(booking: booking),
          );
        }
        return null;
      },
    );
  }
}

/// This widget handles authentication state and routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check authentication state
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          // You can add logic here to determine
          // if user is a provider, admin, or regular user
          // For now, default to user home
          return const UserMainScreen();
        }

        // User is not logged in
        return const RoleSelectionScreen();
      },
    );
  }
}

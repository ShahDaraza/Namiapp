import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as models;
import '../models/service_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // User signup
  Future<models.User?> signupUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String location,
  }) async {
    try {
      // Create Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final user = models.User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        location: location,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());
      
      return user;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  // Provider signup
  Future<ServiceProvider?> signupProvider({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String location,
    required List<String> services,
    required double hourlyRate,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final provider = ServiceProvider(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        location: location,
        services: services,
        hourlyRate: hourlyRate,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('providers').doc(provider.id).set(provider.toJson());
      
      return provider;
    } catch (e) {
      print('Provider signup error: $e');
      rethrow;
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Get user data
  Future<models.User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return models.User.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Get provider data
  Future<ServiceProvider?> getProviderData(String providerId) async {
    try {
      final doc = await _firestore.collection('providers').doc(providerId).get();
      if (doc.exists) {
        return ServiceProvider.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      print('Get provider data error: $e');
      return null;
    }
  }

  // Check if user is provider
  Future<bool> isProvider(String userId) async {
    try {
      final doc = await _firestore.collection('providers').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('admins').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Update user profile error: $e');
      rethrow;
    }
  }

  // Update provider profile
  Future<void> updateProviderProfile(String providerId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('providers').doc(providerId).update(data);
    } catch (e) {
      print('Update provider profile error: $e');
      rethrow;
    }
  }
}

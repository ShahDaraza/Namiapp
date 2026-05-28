import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/index.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Title
              const Text(
                'ServiceHub',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hire Local Professionals',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),

              // User Role Button
              SizedBox(
                width: 280,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth/user-login');
                  },
                  icon: const Icon(Icons.person, size: 24),
                  label: const Text(
                    'I need a Service',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667EEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Provider Role Button
              SizedBox(
                width: 280,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth/provider-login');
                  },
                  icon: const Icon(Icons.badge, size: 24),
                  label: const Text(
                    'I offer Services',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Admin Login Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/auth/admin-login');
                },
                child: const Text(
                  'Admin Login',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

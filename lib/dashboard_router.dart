import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'home_screen.dart';

class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: AuthService().getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roleId = snapshot.data;

        if (roleId == 1) {
          return const AdminDashboard();
        } else {
          return const HomeScreen(); // your normal user dashboard
        }
      },
    );
  }
}
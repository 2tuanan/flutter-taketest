import 'package:flutter/material.dart';
import 'auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin 👑',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // ← Your admin features will go here
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open notification sending screen later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Send Notification feature coming soon')),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Notification to All Users'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Manage users / roles later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Management coming soon')),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Manage Users & Roles'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const Spacer(),
            const Text(
              'Only admins can see this screen.\n\n'
              'Your RLS policies already protect the database.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/widgets/home_drawer.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:go_router/go_router.dart';

class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?['name'] ?? 'User'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your pets, adoptions, and contributions.',
              style: TextStyle(color: AppTheme.mutedForegroundColor),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildDashboardTile(
                  context,
                  icon: Icons.pets_outlined,
                  label: 'My Submissions',
                  color: Colors.blue,
                  onTap: () => context.push('/my-submissions'),
                ),
                _buildDashboardTile(
                  context,
                  icon: Icons.assignment_outlined,
                  label: 'My Adoptions',
                  color: Colors.orange,
                  onTap: () => context.push('/my-adoptions'),
                ),
                _buildDashboardTile(
                  context,
                  icon: Icons.history,
                  label: 'My Donations',
                  color: Colors.green,
                  onTap: () => context.push('/donations/my'),
                ),
                _buildDashboardTile(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Rehome a Pet',
                  color: AppTheme.primaryColor,
                  onTap: () => context.push('/submit-pet'),
                ),
                _buildDashboardTile(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Donate',
                  color: Colors.redAccent,
                  onTap: () => context.push('/donate'),
                ),
                _buildDashboardTile(
                  context,
                  icon: Icons.logout,
                  label: 'Logout',
                  color: AppTheme.mutedForegroundColor,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

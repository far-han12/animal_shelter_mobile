import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:go_router/go_router.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: Column(
        children: [
          _buildHeader(authState),
          const Divider(height: 1, color: AppTheme.borderColor),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_outlined,
                  label: 'Home',
                  path: '/',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  path: '/admin/dashboard',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outline,
                  label: 'User Management',
                  path: '/admin/users',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.pets_outlined,
                  label: 'Pet Management',
                  path: '/admin/pets',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: 'Adoption Inquiries',
                  path: '/admin/inquiries',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.assignment_outlined,
                  label: 'Adoption Applications',
                  path: '/admin/applications',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Volunteer Applications',
                  path: '/admin/volunteers',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history_outlined,
                  label: 'Donation History',
                  path: '/admin/donations',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.article_outlined,
                  label: 'Stories',
                  path: '/admin/stories',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.event_outlined,
                  label: 'Events',
                  path: '/admin/events',
                  currentPath: currentPath,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Donate',
                  path: '/admin/donate',
                  currentPath: currentPath,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderColor),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.destructiveColor),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.destructiveColor),
            ),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthState authState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Animal Shelter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authState.user?['name'] ?? 'Admin',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            authState.user?['email'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.mutedForegroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required String currentPath,
  }) {
    final isSelected = currentPath.startsWith(path);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppTheme.primaryColor
            : AppTheme.mutedForegroundColor,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryColor : AppTheme.foregroundColor,
        ),
      ),
      selected: isSelected,
      onTap: () {
        context.go(path);
      },
    );
  }
}

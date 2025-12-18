import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pets, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Paws & Claws',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Dedicated to finding loving homes for every pet in need.',
            style: TextStyle(color: AppTheme.mutedForegroundColor),
          ),
          const SizedBox(height: 40),
          _buildFooterSection(context, 'Adopt', {
            'Dogs': '/pets',
            'Cats': '/pets',
            'All Pets': '/pets',
          }),
          const SizedBox(height: 32),
          _buildFooterSection(context, 'Community', {
            'Success Stories': '/stories',
            'Events': '/events',
            'Volunteer': '/volunteer',
          }),
          const SizedBox(height: 32),
          _buildFooterSection(context, 'Support', {
            'Donate': '/donate',
            'Contact Us': '/',
          }),
          const SizedBox(height: 60),
          const Center(
            child: Text(
              '© 2025 Paws & Claws Shelter. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.mutedForegroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(
    BuildContext context,
    String title,
    Map<String, String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...items.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.push(entry.value),
              child: Text(
                entry.key,
                style: const TextStyle(color: AppTheme.mutedForegroundColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class VolunteerSection extends StatelessWidget {
  const VolunteerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      color: const Color(0xFFF8FAFC), // Very light gray/blue
      child: Column(
        children: [
          const Gap(28),
          const Text(
            'Become a Volunteer',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Gap(16),
          const Text(
            "We rely on volunteers to help us care for our animals. If you love animals and have some spare time, we'd love to have you.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const Gap(32),
          ElevatedButton(
            onPressed: () => context.push('/volunteer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Join Us'),
          ),
          const SizedBox(height: 40),
          // Here we would ideally place the illustration if available
          // For now using an icon placeholder
          const Icon(
            Icons.volunteer_activism,
            size: 120,
            color: Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }
}

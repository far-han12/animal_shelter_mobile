import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class RehomeSection extends StatelessWidget {
  const RehomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Rehome a Pet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Gap(16),
          const Text(
            "Can't care for your pet anymore? We can help you find a loving new home for them. Submit a rehoming request and we'll review it.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const Gap(32),
          ElevatedButton(
            onPressed: () => context.push('/submit-pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Get Started'),
          ),
          const SizedBox(height: 40),
          const Icon(Icons.home_outlined, size: 120, color: Color(0xFFE2E8F0)),
        ],
      ),
    );
  }
}

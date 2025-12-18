import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/widgets/home_drawer.dart';
import 'package:mobile/features/home/presentation/widgets/hero_section.dart';
import 'package:mobile/features/home/presentation/widgets/featured_pets_section.dart';
import 'package:mobile/features/home/presentation/widgets/volunteer_section.dart';
import 'package:mobile/features/home/presentation/widgets/rehome_section.dart';
import 'package:mobile/features/home/presentation/widgets/home_footer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.pets, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              'Paws & Claws',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.foregroundColor,
              ),
            ),
          ],
        ),
        actions: const [
          // On mobile we use the drawer for navigation
        ],
      ),
      drawer: const HomeDrawer(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            FeaturedPetsSection(),
            VolunteerSection(),
            RehomeSection(),
            HomeFooter(),
          ],
        ),
      ),
    );
  }
}

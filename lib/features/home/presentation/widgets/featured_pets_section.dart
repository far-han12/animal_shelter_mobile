import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/admin/pets/pet_service.dart';
import 'package:mobile/features/pets/data/pet_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

final featuredPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final petService = ref.watch(petServiceProvider);
  final response = await petService.getPets(limit: 4);
  final List<dynamic> data = response['data'] ?? [];
  return data.map((json) => Pet.fromJson(json)).toList();
});

class FeaturedPetsSection extends ConsumerWidget {
  const FeaturedPetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(featuredPetsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          const Text(
            'Featured Pets',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Meet some of our adorable residents waiting for a forever home.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.mutedForegroundColor,
            ),
          ),
          const SizedBox(height: 40),
          petsAsync.when(
            data: (pets) => Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        1, // On mobile we show one per row as per screenshot
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: pets.length,
                  itemBuilder: (context, index) => _PetCard(pet: pets[index]),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () => context.push('/pets'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                  ),
                  child: const Text('View All Pets'),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading pets: $err'),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: pet.photos.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: pet.photos.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.mutedColor,
                    child: const Icon(
                      Icons.pets,
                      size: 48,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.breed} • ${pet.age} yrs',
                  style: const TextStyle(
                    color: AppTheme.mutedForegroundColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  pet.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/pets/${pet.id}', extra: pet),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
